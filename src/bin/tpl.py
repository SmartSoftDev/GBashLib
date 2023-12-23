#!/usr/bin/env python3
import argparse
import os
import sys
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
    if until_l:
        until_l = until_l.rstrip()
    while True:
        l = cfg.fo_repl.readline()
        if not l:
            break
        # print "read: "+l
        if until_l:
            if ignore_line and until_l not in l:
                continue
            if until_l in l:
                ignore_line = not ignore_line
                continue
        cfg.fo.write(l)
        last_line_has_new_line = l.endswith("\n")
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


if __name__ == "__main__":
    sp = argparse.ArgumentParser(description="Render a template with variables")

    sp.add_argument("-o", "--output", default=None, help="Output file. Default is stdout.")
    sp.add_argument("-p", "--permissions", default=None, help="TODO: Octal output file permissions ex: 0755")
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
