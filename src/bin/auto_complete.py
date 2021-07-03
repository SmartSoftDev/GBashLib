#!/usr/bin/env python3
"""
Auto complete helper.
TODO:
* de facut variata de intrebat autoCOmpleteul de la Binar direct.
* de implementat posibilitatea de a adauga/stergerea intru-un anumit yaml file.
    la add si delete exista -f
* de adaugat comanda pentru import la toate *.autocomplete.yaml dintr-un director
    comanda import
* de implementat optiuni de tip FILE si de tip ENUM
"""
import argparse
import os
import yaml

from types import SimpleNamespace
from tabulate import tabulate

C = SimpleNamespace()
C.keys = SimpleNamespace()
C.keys.cfgImport = 'import'
cfg = SimpleNamespace()
cfg.path = os.environ['HOME']
cfg.dbPath = os.path.join(cfg.path, ".auto_complete.yaml")

cfg.config = {C.keys.cfgImport: []}  # import is mandatory key
cfg.description = {}  # default nothing


def read_config():
    if not os.path.exists(cfg.path):
        os.makedirs(cfg.path)
    # read config file
    if not os.path.exists(cfg.dbPath):
        save_config()
    else:
        with open(cfg.dbPath) as f:
            cfg.config = yaml.safe_load(f)

    # read imported files into description
    for f_path in cfg.config[C.keys.cfgImport]:
        with open(f_path) as f:
            cfg.description.update(yaml.safe_load(f))


def save_description():
    raise Exception("Not implemented")


def save_config():
    with open(cfg.dbPath, "w") as f:
        yaml.dump(cfg.config, f)


def cmd_add():
    bin = cfg.args.binaryName
    path = cfg.args.path
    options = []
    if cfg.args.options is not None:
        for o in cfg.args.options.split(','):
            o = o.split("/")
            opt = {'short': o[0], 'long': False, 'type': False}
            if len(o) > 1:
                opt['long'] = o[1]
            if len(o) > 2:
                opt['type'] = o[2]
            options.append(opt)
    subcommands = cfg.args.subcommands.split(",") if cfg.args.subcommands is not None else []
    # print options,subcommands,bin, path
    if bin not in cfg.description:
        cfg.description[bin] = {}
    b = cfg.description[bin]
    b[path] = {"options": options, "subcommands": subcommands}
    save_description()


def cmd_del():
    bin = cfg.args.binaryName
    if bin not in cfg.description:
        return  # nothing to do
    b = cfg.description[bin]
    path = cfg.args.path
    if path:
        if path not in b:
            return  # nothing to do
        del b[path]
    else:
        del cfg.description[bin]
    save_description()


def print_option(opt):
    return f"{opt['short']}/{opt['long']}/{opt['type'] if opt['type'] else ''}"


def process_print_cmd():
    cmd = cfg.args.cmd
    table = []
    if cmd == 'print':
        headers = ('name', 'commands', 'options', 'subcommands')
        for k, v in cfg.description.items():
            table.append((k, '', '', ''))
            for path, p_val in v.items():
                options = []
                for o in p_val['options']:
                    options.append(print_option(o))
                subcommands = ''
                if 'subcommands' in p_val:
                    subcommands = ",".join(p_val['subcommands'])
                table.append(('', path, ",".join(options), subcommands))
        print(tabulate(table, headers=headers), )


def get_path_from_args(args):
    path = []
    for a in args:
        if a.startswith('-'):
            continue
        path.append(a)
    return path


def cmd_get():
    read_config()
    cur_word_index = int(sys.argv[2])
    args = sys.argv[3:]
    if len(args) == 0:
        return
    exe = args[0]
    args = args[1:]
    if cur_word_index <= len(args):
        cur_word = args[-1]
        args = args[:-1]
    else:
        cur_word = ""
    if exe not in cfg.description:
        return  # bin not found
    b = cfg.description[exe]
    path = get_path_from_args(args)
    if len(path) == 0:
        path = '-'
    else:
        path = '.'.join(path)
    if path not in b:
        return
    p = b[path]

    if 'subcommands' not in p:
        p['subcommands'] = []
    if 'options' not in p:
        p['options'] = []

    ret = []
    if cur_word.startswith('-'):
        # it is an option
        if cur_word.startswith('--'):
            # long options
            cur_word = cur_word[2:]
            for o in p['options']:
                long = o['long']
                if len(cur_word):
                    if long.startswith(cur_word):
                        ret.append('--' + long)
                else:
                    ret.append('--' + long)
        else:
            # short and options
            cur_word = cur_word[1:]
            for o in p['options']:
                short = o['short']
                long = o['long']
                if len(cur_word):
                    if short.startswith(cur_word):
                        ret.append(f'-{short}')
                else:
                    ret.append(f'-{short}')
                    ret.append(f'--{long}')
    elif len(cur_word) == 0:
        # give all options and all subcommands
        for o in p['options']:
            ret.append('-' + o['short'])
            ret.append('--' + o['long'])
        ret += p['subcommands']
    else:
        # it is a subcommand
        for s in p['subcommands']:
            if s.startswith(cur_word):
                ret.append(s)
    print(' '.join(ret))


def cmd_import():
    expected_file_name = ".autocomplete.yaml"
    found_files = []

    for root, dirs, files in os.walk(cfg.args.importDirectory, followlinks=True):
        for i in files:
            if i.endswith(expected_file_name):
                fpath = os.path.join(root, i)
                found_files.append(fpath)

    for fpath in found_files:
        fpath = os.path.abspath(fpath)
        if fpath in cfg.config[C.keys.cfgImport]:
            print("This file is already imported %r" % fpath)
            continue
        print("add import %r" % fpath)
        cfg.config[C.keys.cfgImport].append(fpath)
    save_config()


def main():
    if cfg.args.cmd in ['add', 'del', 'print']:
        if cfg.args.file:
            cfg.dbPath = cfg.args.file
            cfg.path = os.path.dirname(cfg.dbPath)
    read_config()
    cmd = cfg.args.cmd
    if cmd.startswith("print"):
        process_print_cmd()
    elif cmd == 'add':
        cmd_add()
    elif cmd == 'del':
        cmd_del()
    elif cmd == 'import':
        cmd_import()
    elif cmd == '_list':
        print(' '.join(cfg.description.keys()))
    elif cmd == '_get':
        cmd_get()


def parse_args():
    sp = argparse.ArgumentParser(description="Auto complete store")

    sp.add_argument("-v", "--verbosity", action="count", default=2, help="increase output verbosity")

    subparsers = sp.add_subparsers(title='subcommands')
    '''
    addP= subparsers.add_parser('add', help= 'Add auto complete')
    addP.set_defaults(cmd='add')
    addP.add_argument('binaryName', type=str, help='Binary name')
    addP.add_argument('-p','--path', type=str,default='-', help='Path of the command separated by "." ex: db.add.host')
    addP.add_argument('-o','--options', type=str, default=None, help='add one or more options: shortOption/LongOption/typeOfAutoComplete[,...]. types=[file, none, ip, ssh]')
    addP.add_argument('-s','--subcommands', type=str, default=None, help='add one os more subcommands: subcommand[/...] ')
    addP.add_argument('-f','--file', type=str, default=None, help='add command will write to a specific file instead of default one.')

    addP= subparsers.add_parser('del', help= 'Delete auto complete')
    addP.add_argument('binaryName', type=str, help='Binary name')
    addP.add_argument('-p','--path', type=str, default=None, help='Path of the command separated by "." ex: db.add.host')
    addP.add_argument('-f','--file', type=str, default=None, help='Delete command will delete from a specific file instead of default one.')
    addP.set_defaults(cmd='del')
'''

    addP = subparsers.add_parser('print', help='print auto complete')
    addP.add_argument('-f', '--file', type=str, default=None,
                      help='Delete command will delete from a specific file instead of default one.')
    addP.set_defaults(cmd='print')

    addP = subparsers.add_parser('import', help='Import *.autocomplete.yaml files from specified directory')
    addP.add_argument('importDirectory', type=str, help='Import directory path')
    addP.set_defaults(cmd='import')

    addP = subparsers.add_parser('_list', help='used internally by bashrc.inc for generating auto complete')
    addP.set_defaults(cmd='_list')

    addP = subparsers.add_parser('_get', help='used internally by bashrc.inc for generating auto complete')
    addP.set_defaults(cmd='_get')
    addP.add_argument('comp_words', type=str, nargs="+", help='hole list of arguments')

    cfg.args = sp.parse_args()


if __name__ == "__main__":
    import sys

    if len(sys.argv) > 1 and sys.argv[1] == '_get':
        # ne trebuie sa nu proceseze nimic
        cmd_get()
    else:
        parse_args()
        # print cfg.args
        main()
