#!/usr/bin/env python2
"""
 Copyright (C) Smartsoftdev.eu SRL - All Rights Reserved
 Proprietary and confidential license.
 Unauthorized copying via any medium or use of this file IS STRICTLY prohibited
 For any license violations or more about commercial licensing please contact:
 SmartSoftDev.eu
"""

import argparse
import os
import shutil
import sys


class config(object):
    def __init__(self):
        self.dir = "/tmp/uidgen/"
        self.uid_name = ""
        self.uid_file = None
        self.cmd = None
        self.silent = False
        self.limit = 0


cfg = config()

import hashlib


def hashfile(afile, hasher, blocksize=65536):
    for line in sorted(afile.readlines()):
        hasher.update(line)
    # buf = afile.read(blocksize)
    # while len(buf) > 0:
    #     hasher.update(buf)
    #     buf = afile.read(blocksize)
    return hasher.hexdigest()


def main(args):
    global cfg
    parser = argparse.ArgumentParser(description="Uid generation based on file/string fingerprint")
    parser.add_argument('uid_name', type=str, nargs=1,
                        help='UID identifier')
    parser.add_argument('-c', "--clean", action='store_true', default=False,
                        help="Will clean (remove) all files in uidgen DIR (%r)." % cfg.dir)
    parser.add_argument('-s', "--silent", action='store_true', default=False,
                        help="will not print any debug info")

    subparsers = parser.add_subparsers(title="Sub commands")
    create_parser = subparsers.add_parser("create", help="manipulate ws/pkg evn: create uid with name uid_name")
    create_parser.set_defaults(cmd="create");

    add_parser = subparsers.add_parser("add", help="manipulate ws/pkg evn: add new entry to uid with name uid_name")
    add_parser.set_defaults(cmd="add");
    add_parser.add_argument('-f', '--files', action='store_true', default=False,
                            help='add files instead of string')
    add_parser.add_argument('entry', type=str, nargs="+",
                            help='list of entries')

    get_parser = subparsers.add_parser("get", help="manipulate ws/pkg evn: calculate hash of uid with name uid_name")
    get_parser.set_defaults(cmd="get");
    get_parser.add_argument('-l', '--limit', type=int, default=0,
                            help='Limit the output string to this number of chars')

    if len(sys.argv) > 1 and (sys.argv[1] == "--clean" or sys.argv[1] == '-c'):
        if not cfg.silent:
            print
            "uidgen CLEARED"
        if os.path.isdir(cfg.dir):
            shutil.rmtree(cfg.dir)
        return

    args = parser.parse_args()
    cfg.uid_name = args.uid_name[0]
    cfg.uid_file = cfg.dir + "/" + args.uid_name[0]
    cfg.cmd = args.cmd
    cfg.silent = args.silent

    try:
        os.makedirs(cfg.dir)
    except OSError as e:
        if e.errno != 17:  # 17 = FILE exists
            raise

    if cfg.cmd == "create":
        if not cfg.silent:
            print
            "create " + cfg.uid_name
        if os.path.exists(cfg.uid_file):
            print
            "You are trying to create a uid but it exists already! uid_name=" + cfg.uid_name + "uid_file=" + cfg.uid_file
        with open(cfg.uid_file, "w+") as _:
            pass
    elif cfg.cmd == "get":
        with open(cfg.uid_file, "rb") as f:
            if args.limit > 0:
                print
                hashfile(f, hashlib.sha256())[:args.limit]
            else:
                print
                hashfile(f, hashlib.sha256())
        os.remove(cfg.uid_file)
    elif cfg.cmd == "add":
        if args.files:
            with open(cfg.uid_file, "a") as f:
                for fname in args.entry:
                    with open(fname, 'rb') as fin:
                        hashSum = hashfile(fin, hashlib.sha256())
                    if not cfg.silent:
                        print
                        "%s add file %s" % (cfg.uid_name, fname)
                    f.write("%s %s\n" % (fname, hashSum))
        else:
            with open(cfg.uid_file, "a") as f:
                for s in args.entry:
                    if not cfg.silent:
                        print
                        "%s add %s" % (cfg.uid_name, s)
                    f.write(s + "\n")


if __name__ == '__main__':
    main(sys.argv)
