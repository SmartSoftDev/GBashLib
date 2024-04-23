#!/usr/bin/env python3
import argparse
import os
import sys
import stat
from types import SimpleNamespace

cfg = SimpleNamespace()

def process_line(fi_line):
    for n, v in cfg.vars.items():
        fi_line = fi_line.replace(n, v)
    # print "out:"+l
    cfg.fo.write(fi_line)


def read_from_fo_replace(until_l: str = None, strip_line: bool = False):
    """reads from fo_repl and writes it to fo until "unitil_l" line is matched (if given)"""
    if not cfg.fo_repl:
        return
    last_line_has_new_line = False
    ignore_line = False
    while True:
        line = cfg.fo_repl.readline()
        if not line:
            break
        # print "read: "+l
        if until_l:
            l = line.rstrip() if strip_line else line
            if until_l == l or f"{until_l.rstrip()}_END" in l:
                ignore_line = not ignore_line
                continue
            elif ignore_line and until_l != l:
                continue
        cfg.fo.write(line)
        last_line_has_new_line = line.endswith("\n")
    return last_line_has_new_line


def skip_from_fo_replace(until_l):
    if not cfg.fo_repl:
        return
    # print "skip_util:"+until_l
    while True:
        l = cfg.fo_repl.readline()
        if not l:
            break
        # print "skip: "+l
        if l == until_l:
            break


def main():
    # parse variables
    cfg.vars = dict()
    if cfg.args.vars:
        for v in cfg.args.vars:
            v = v.split("=", 1)
            name = v[0].strip()
            value = ""
            if len(v) > 1:
                value = v[1]

            cfg.vars[name] = value
    # open input/output files
    if not cfg.args.output:
        cfg.fo = sys.stdout
    else:
        if cfg.args.replace or cfg.args.at_position or cfg.args.delete:
            cfg.foPath = cfg.args.output + ".temp"
            cfg.fo_replPath = cfg.args.output
            cfg.fo = open(cfg.foPath, "w")
            if os.path.exists(cfg.fo_replPath):
                cfg.fo_repl = open(cfg.fo_replPath, "r")
            else:
                cfg.fo_repl = None
        else:
            cfg.fo = open(cfg.args.output, "w")

    if not cfg.args.input:
        cfg.fi = sys.stdin
    else:
        cfg.fi = open(cfg.args.input, "r")
    # read the input file (template)
    count = 0
    repl_id = ""
    if cfg.args.at_position:
        # write from fo_repl to fo until we find at_position string
        read_from_fo_replace(cfg.args.at_position, strip_line=True)
    while True:
        fi_line = cfg.fi.readline()
        if not fi_line:
            break

        if cfg.args.delete and count == 0:  # if replace is on then first line is the id to be found in output file
            repl_id = fi_line
            if cfg.args.id:
                repl_id = repl_id.rstrip() + cfg.args.id + "\n"
            # read from output until we detect line "repl_id" which is the start of portion to be deleted.
            read_from_fo_replace(repl_id)

        elif cfg.args.replace and count == 0:  # if replace is on then first line is the id to be found in output file
            repl_id = fi_line
            if cfg.args.id:
                repl_id = repl_id.rstrip() + cfg.args.id + "\n"
            # read from output until we detect line "repl_id" which is the start of portion to be replaced.
            has_new_line_at_the_end = read_from_fo_replace(repl_id)
            # we need to make sure that repl_id is written at the BEGINNING of the LINE
            if not has_new_line_at_the_end:
                cfg.fo.write("\n" + repl_id)
            else:
                cfg.fo.write(repl_id)
        else:
            if cfg.args.delete is False:
                process_line(fi_line)
        count += 1

    if cfg.args.replace:
        # write the END tag to fo
        repl_id = repl_id.rstrip() + "_END\n"
        cfg.fo.write(repl_id)
        skip_from_fo_replace(repl_id)  # skip from fo_repl until the "END TAG"

    if cfg.args.replace or cfg.args.at_position:
        # continue copy from fo_repl to fo until the end of the file
        read_from_fo_replace()
        if cfg.fo_repl:
            cfg.fo_repl.close()

    cfg.fi.close()
    cfg.fo.close()
    if cfg.args.replace or cfg.args.at_position or cfg.args.delete:
        os.rename(cfg.foPath, cfg.fo_replPath)

    if cfg.args.permissions:
        fo = cfg.args.output
        if hasattr(cfg, 'fopath'):
            fo = cfg.foPath
        perm = cfg.args.permissions
        new_permissions = 0
        for c in perm['user']:
            if c == 'r':
                new_permissions |= stat.S_IRUSR
            elif c == "w":
                new_permissions |= stat.S_IWUSR
            elif c == "x":
                new_permissions |= stat.S_IXUSR
        for c in perm['group']:
            if c == 'r':
                new_permissions |= stat.S_IRGRP
            elif c == "w":
                new_permissions |= stat.S_IWGRP
            elif c == "x":
                new_permissions |= stat.S_IXGRP
        for c in perm['other']:
            if c == 'r':
                new_permissions |= stat.S_IROTH
            elif c == "w":
                new_permissions |= stat.S_IWOTH
            elif c == "x":
                new_permissions |= stat.S_IXOTH
        

        os.chmod(fo, new_permissions)





def permissions_string(in_str: str):
    """
    parse permissions string: urwx,grwx,orwx
    """
    perm ={"user":"", "group":"", "other":""}
    current_perm = ""
    accepted_perm_groups = "ugo"
    accepted_perm_values = "rwx"
    separator = ","

    for c in in_str:
        if not current_perm:
            if c not in accepted_perm_groups:
                raise Exception(f"Permission group is not accepted: {in_str=} unexpected group={c} FYI: {accepted_perm_groups=}")
            current_perm = c
            continue
        if c == separator:
            current_perm = None
            continue
        if c not in accepted_perm_values:
            raise Exception(f"Permission value is not accepted: {in_str=} unexpected value={c} FYI: {accepted_perm_values=}")
        key = "user" if current_perm == "u" else "group" if current_perm == "g" else "other"
        if c in perm[key]:
            raise Exception(f"{key!s} permission has duplicate {c!s}. {in_str=}")
        perm[key]+= c
        
    return perm



if __name__ == "__main__":
    sp = argparse.ArgumentParser(description="Render a template with variables")

    sp.add_argument("-o", "--output", default=None, help="Output file. Default is stdout.")
    sp.add_argument("-p", "--permissions", type=permissions_string, default=None,
                    help="Octal output file permissions ex full permissions: uwrx,grwx,orwx")
    sp.add_argument("-i", "--input", help="Template file. If not present stdin will be used")
    sp.add_argument(
        "-r",
        "--replace",
        action="store_true",
        help="replace content from file between match-start and match-end ",
    )
    sp.add_argument(
        "-a",
        "--at_position",
        metavar="TO_REPLACE",
        help="Insert the TPL content at position containing TO_REPLACE. (matches only full lines)",
    )
    sp.add_argument(
        "-d",
        "--delete",
        action="store_true",
        help="delete content from file between match-start and match-end",
    )

    sp.add_argument("-v", "--vars", type=str, nargs="+", help="Variables to be replaces inside tpl. NAME=VALUE")
    sp.add_argument("-I", "--id", default=None, type=str, help="Element id to be replaced. used in combination with -r")

    cfg.args = sp.parse_args()
    main()
