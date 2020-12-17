#!/usr/bin/env python3
import os
import argparse
import sys
import yaml
# from ghepy.term.colors
COLOR_NONE = '\033[0m'  # No Color
COLOR_GREEN = '\033[0;32m'
COLOR_CYAN = '\033[0;36m'

DEFAULT_NAME_TYPE = '.'
cfg = lambda: None  # singleton

def read_config():
    if not os.path.exists(cfg.path):
        os.makedirs(cfg.path)
    # read config file
    if not os.path.exists(cfg.dbPath):
        save_config()
    else:
        with open(cfg.dbPath) as f:
            cfg.config = yaml.load(f, Loader=yaml.FullLoader)
        if cfg.config is None:
            cfg.config = {}


def save_config():
    print(f"save to: {cfg.dbPath}")
    with open(cfg.dbPath, "w") as f:
        yaml.dump(cfg.config, f)


def print_one(cfg, name, value, type_name, last=False):
    args = cfg.args
    if type_name != DEFAULT_NAME_TYPE:
        type_name += "__"
    else:
        type_name = ""
    if args.decorate and not args.bash:
        s = f"{COLOR_CYAN}{name}{COLOR_NONE}"
        if args.value_only:
            s = f"{COLOR_GREEN}{value}{COLOR_NONE}"
        elif not args.name_only:
            s += f" = {COLOR_GREEN}{value}{COLOR_NONE}"
    elif args.bash:
        s = type_name + name
        if args.value_only:
            s = f'"{value}"'
        elif not args.name_only:
            s += f'="{value}"'
    else:
        s = name
        if args.value_only:
            s = value
        elif not args.name_only:
            s += "=" + value

    if last:
        s += "\n"
    else:
        s += args.separator
    sys.stdout.write(s)


def main():
    parser = argparse.ArgumentParser(description="Variable storage for bash")
    parser.add_argument("-l", "--local", default=False, action='store_true', help="User ./v.yaml instead of ~/.v.yaml")

    subparsers = parser.add_subparsers(title="Sub commands")
    sp = subparsers.add_parser("get", help="manipulate ws/pkg evn: create uid with name uid_name")
    sp.set_defaults(cmd="get")
    sp.add_argument('Name', type=str, nargs="+", help='variable Name')
    sp.add_argument('-t', '--type', default=DEFAULT_NAME_TYPE,
                    help="Store name=value of a specific type (types does not collide)")
    sp.add_argument('-s', '--search', default=False, action='store_true', help="Search the text in the name")

    sp = subparsers.add_parser("set", help="manipulate ws/pkg evn: add new entry to uid with name uid_name")
    sp.set_defaults(cmd="set")
    sp.add_argument('Name', type=str, nargs="+", help='variable Name')
    sp.add_argument('-t', '--type', default=DEFAULT_NAME_TYPE,
                    help="Store name=value of a specific type (types does not collide)")
    sp.add_argument('-a', '--append', action='store_true', default=False, help="Append current value to existing one")
    sp.add_argument('-s', '--separator', default=' ',
                    help="only used with append flag, sets the separator when appending. default 'space' ")

    sp = subparsers.add_parser("list", help="Print all values")
    sp.set_defaults(cmd="list")
    sp.add_argument('-t', '--type', default=DEFAULT_NAME_TYPE, help="lists name=value of a specific type")
    sp.add_argument('-a', '--all', action='store_true', default=False, help="lists name=value for all types")
    sp.add_argument('-d', '--decorate', action='store_true', default=False, help="always decorate for terminal")
    sp.add_argument('-n', '--name-only', action='store_true', default=False, help="show only names")
    sp.add_argument('-v', '--value-only', action='store_true', default=False, help="show only values")
    sp.add_argument('-s', '--separator', default='\n', help="set separator string ")
    sp.add_argument('-b', '--bash', action='store_true', default=False, help="prints it for bash interpretation")

    sp = subparsers.add_parser("del", help="delete one entry")
    sp.add_argument('Name', type=str, nargs="+", help='variable Name')
    sp.add_argument('-t', '--type', default=DEFAULT_NAME_TYPE,
                    help="delete entry from specific type")
    sp.set_defaults(cmd="del")

    sp = subparsers.add_parser("drop", help="Delete hole DB")
    sp.set_defaults(cmd="drop")

    args = parser.parse_args()
    if not hasattr(args, 'cmd'):
        print("Not enough arguments! \n\n")
        parser.print_help(sys.stderr)
        return

    if args.local:
        cfg.path = os.getcwd()
        cfg.dbPath = os.path.join(cfg.path, "v.yaml")
    else:
        cfg.path = os.environ['HOME']
        cfg.dbPath = os.path.join(cfg.path, ".v.yaml")
    cfg.config = {}

    # print args
    cfg.args = args
    read_config()
    if args.cmd == 'set':
        for n in args.Name:
            n = n.split('=', 1)
            n[0] = n[0].strip()
            name = n[0]
            if len(n) > 1:
                value = n[1]
            else:
                value = ''

            if len(value) == 0:
                if args.type in cfg.config:
                    if name in cfg.config[args.type]:
                        del cfg.config[args.type][name]
                        save_config()
            else:
                # create the type dict is does not exist
                if args.type not in cfg.config:
                    cfg.config[args.type] = {}
                if name in cfg.config[args.type]:
                    # value exists just update
                    if cfg.args.append:
                        # if is append operation construct
                        value = cfg.config[args.type][name] + cfg.args.separator+value
                # save the value
                cfg.config[args.type][name] = value
                save_config()

    elif args.cmd == 'get':
        for n in args.Name:
            name = n.strip()
            if args.type in cfg.config:
                if name in cfg.config[args.type]:
                    print(cfg.config[args.type][name])
                else:
                    if args.search:
                        for n, v in cfg.config[args.type].items():
                            if name in n:
                                print(v)
    elif args.cmd == 'list':
        if sys.stdout.isatty():
            args.decorate = True

        if args.all:
            for type_name, tip in cfg.config.items():
                if type_name != DEFAULT_NAME_TYPE and not args.bash:
                    print("%s:" % (type_name,))
                for name, value in tip.items():
                    print_one(cfg, name, value, type_name)

        else:
            if args.type in cfg.config:
                for name, value in cfg.config[args.type].items():
                    print_one(cfg, name, value, args.type)
    elif args.cmd == 'drop':
        os.remove(cfg.dbPath)
    elif args.cmd == 'del':
        for n in args.Name:
            name = n.strip()
            if args.type in cfg.config:
                if name in cfg.config[args.type]:
                    del cfg.config[args.type][name]
                    if len(cfg.config[args.type]) == 0:
                        # delete the type dict
                        del cfg.config[args.type]
        save_config()


if __name__ == "__main__":
    main()
