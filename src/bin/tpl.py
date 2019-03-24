#!/usr/bin/env python2
import os
import argparse
import sys

cfg = lambda: None


def process_line(fi_line):
    for n, v in cfg.vars.iteritems():
        fi_line = fi_line.replace(n, v)
    # print "out:"+l
    cfg.fo.write(fi_line)


def read_from_fo_replace(until_l):
    if not cfg.fo_repl:
        return
    while True:
        l = cfg.fo_repl.readline()
        if not l:
            break;
        # print "read: "+l
        if until_l:
            if l == until_l:
                break
        cfg.fo.write(l)


def skip_from_fo_replace(until_l):
    if not cfg.fo_repl:
        return
    # print "skip_util:"+until_l
    while True:
        l = cfg.fo_repl.readline()
        if not l:
            break;
        # print "skip: "+l
        if l == until_l:
            break


def main():
    # parse variables
    cfg.vars = dict()
    if cfg.args.vars:
        for v in cfg.args.vars:
            v = v.split('=')
            name = v[0].strip()
            value = ''
            if len(v) > 1:
                value = v[1]

            cfg.vars[name] = value
    # open input/output files
    if not cfg.args.output:
        cfg.fo = sys.stdout
    else:
        if cfg.args.replace:
            cfg.foPath = cfg.args.output + '.temp'
            cfg.fo_replPath = cfg.args.output
            cfg.fo = open(cfg.foPath, "w")
            if os.path.exists(cfg.fo_replPath):
                cfg.fo_repl = open(cfg.fo_replPath, "rb")
            else:
                cfg.fo_repl = None
        else:
            cfg.fo = open(cfg.args.output, "w")

    if not cfg.args.input:
        cfg.fi = sys.stdin
    else:
        cfg.fi = open(cfg.args.input, "rb")
    # read the input file (tempalte)
    count = 0
    repl_id = ''
    while True:
        fi_line = cfg.fi.readline()
        if not fi_line:
            break
        if cfg.args.replace and count == 0:  # if replace is on then first line is the id to be found in output file
            repl_id = fi_line
            if cfg.args.id:
                repl_id = repl_id.rstrip() + cfg.args.id + "\n"
            # read from output until we detect line "repl_id" which is the start of portion to be replaced.
            read_from_fo_replace(repl_id)
            cfg.fo.write(repl_id)
        else:
            # print "in:"+l
            if not cfg.args.delete:
                process_line(fi_line)
        count += 1

    if cfg.args.replace:
        repl_id = repl_id.rstrip() + "_END\n"
        cfg.fo.write(repl_id)
        skip_from_fo_replace(repl_id)  # skip from replace pina gasim
        read_from_fo_replace(None)
        if cfg.fo_repl:
            cfg.fo_repl.close()
    cfg.fi.close()
    cfg.fo.close()

    if cfg.args.replace:
        os.rename(cfg.foPath, cfg.fo_replPath)


if __name__ == "__main__":
    sp = argparse.ArgumentParser(description="Render a template with variables")

    sp.add_argument('-o', '--output', default=None, help="Output file. Default is stdout.")
    sp.add_argument('-i', '--input', help="Template file. If not presetn stdin will be used")
    sp.add_argument('-r', '--replace', action='store_true', default=False,
                    help="replace content from file between match-start and match-end ")
    sp.add_argument('-d', '--delete', action='store_true', default=False,
                    help="delete content from file between match-start and match-end ")

    sp.add_argument('-v', '--vars', type=str, nargs="+", help='Variables to be replaces inside tpl. NAME=VALUE')
    sp.add_argument('-I', '--id', default=None, type=str, help="Element id to be replaced. used in conbination with -r")

    cfg.args = sp.parse_args()
    # print cfg.args
    main()
