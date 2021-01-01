#!/usr/bin/env python3
"""
v tool has following features:
* reads / stores configuration values in yaml files
* can read values from single location ($HOME/.v.yaml)
* can read from ./v.yaml
* can read and combine recursively from , ./v.yaml, ../v.yaml, ../../v.yaml ... (ONLY read, write does not work
recursively)
* can switch file_name from v.yaml to v.{NAME}.yaml depending of argument or environ variable
* can store KEY=VALUE pairs, or KEY=VALUE in a special "TYPE" (group)

TODO: support encryption / decryption on the fly.
"""
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
cfg.env_name = None  # means no special MULTI-ENV name was given.
KEY_TYPES = '~types'
KEY_VERSION = '~version'


def read_single_file(file_path):
    # read config file
    if not os.path.exists(file_path):
        return dict()

    with open(file_path) as f:
        config = yaml.load(f, Loader=yaml.FullLoader)
    if config is None:
        config = {}
    if config.get(KEY_VERSION, 0) >= 2:
        return config  # already migrated

    # we need to convert to v2 format
    migrated_types = {}
    for k, v in config.items():
        if k in (DEFAULT_NAME_TYPE, KEY_TYPES):
            continue
        if isinstance(v, dict):
            migrated_types[k] = v
    simple_values = config.get(DEFAULT_NAME_TYPE, {})
    # if there are no values in migrated and in simple values, means everything is fine!
    # the config is compatible with v2 format
    if len(migrated_types) or len(simple_values):
        config = simple_values
        if len(migrated_types):
            config[KEY_TYPES] = migrated_types
        save_config()
    return config


def read_config(recursive):
    if recursive is None:
        # no recursive
        cfg.config = read_single_file(cfg.dbPath)
    else:
        if recursive == 0:
            recursive = 999
        config = {}
        file_path = cfg.dbPath
        dir_path = cfg.path
        for i in range(recursive):
            config.update(read_single_file(file_path))
            if dir_path == '/':
                break  # reached the end
            dir_path = os.path.dirname(dir_path)
            file_path = os.path.join(dir_path, cfg.file_name)
            if not os.path.isfile(file_path):
                continue  # we continue here to force reading X recursive directories as specified in args.
        cfg.config = config


def save_config():
    if not os.path.exists(cfg.path):
        os.makedirs(cfg.path)
    with open(cfg.dbPath, "w") as f:
        yaml.dump(cfg.config, f)


def print_one(cfg, name, value, type_name=None, last=False):
    args = cfg.args
    if type_name:
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
    parser.add_argument("-e", "--env_name", default=None, type=str,
                        help="Multi-Env Name to load (specifies the prefix for yaml file."
                             " For ex: 'v -e MULTI_ENV_NAME -l list -a --bash'"
                             " will load this file v.MULTI_EVN_NAME.yaml)."
                             " Note: overwrites the environ variable!")
    parser.add_argument("-E", "--env_var_name", default='V_ENV_NAME', type=str,
                        help="Environ variable name to get the MULTI_ENV_NAME from environ (v.MULTI_EVN_NAME.yaml)."
                             " default=V_ENV_NAME."
                             " Example usage: 'export MY_V_ENV_NAME=prod ; v -e MY_V_ENV_NAME -l list -a --bash'"
                             " this will load v.prod.yaml file")

    subparsers = parser.add_subparsers(title="Sub commands")
    sp = subparsers.add_parser("get", help="manipulate ws/pkg evn: create uid with name uid_name")
    sp.set_defaults(cmd="get")
    sp.add_argument('Name', type=str, nargs="+", help='variable Name')
    sp.add_argument('-t', '--type', default=None,
                    help="Store name=value of a specific type (types does not collide)")
    sp.add_argument('-s', '--search', default=False, action='store_true', help="Search the text in the name")
    sp.add_argument('-r', '--recursive', type=int, default=None,
                    help="only if local is set, it will read X directories above this one and merge the values")

    sp = subparsers.add_parser("set", help="manipulate ws/pkg evn: add new entry to uid with name uid_name")
    sp.set_defaults(cmd="set")
    sp.add_argument('Name', type=str, nargs="+", help='variable Name')
    sp.add_argument('-t', '--type', default=None,
                    help="Store name=value of a specific type (types does not collide)")
    sp.add_argument('-a', '--append', action='store_true', default=False, help="Append current value to existing one")
    sp.add_argument('-s', '--separator', default=' ',
                    help="only used with append flag, sets the separator when appending. default 'space' ")

    sp = subparsers.add_parser("list", help="Print all values")
    sp.set_defaults(cmd="list")
    sp.add_argument('-t', '--type', default=None, help="lists name=value of a specific type")
    sp.add_argument('-a', '--all', action='store_true', default=False, help="lists name=value for all types")
    sp.add_argument('-d', '--decorate', action='store_true', default=False, help="always decorate for terminal")
    sp.add_argument('-n', '--name-only', action='store_true', default=False, help="show only names")
    sp.add_argument('-v', '--value-only', action='store_true', default=False, help="show only values")
    sp.add_argument('-s', '--separator', default='\n', help="set separator string ")
    sp.add_argument('-b', '--bash', action='store_true', default=False, help="prints it for bash interpretation")
    sp.add_argument('-r', '--recursive', type=int, default=None,
                    help="only if local is set, it will read X directories above this one and merge the values")

    sp = subparsers.add_parser("del", help="delete one entry")
    sp.add_argument('Name', type=str, nargs="+", help='variable Name')
    sp.add_argument('-t', '--type', default=None,
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
        env_name = None
        if args.env_name:
            env_name = args.env_name
        else:
            if args.env_var_name in os.environ:
                env_name = os.environ[args.env_var_name]
        if env_name:
            file_name = f"v.{env_name}.yaml"
            cfg.env_name = env_name
        else:
            file_name = 'v.yaml'

        cfg.path = os.getcwd()
        cfg.dbPath = os.path.join(cfg.path, file_name)
        cfg.file_name = file_name
    else:
        cfg.path = os.environ['HOME']
        cfg.dbPath = os.path.join(cfg.path, ".v.yaml")
    cfg.config = {}

    # print args
    cfg.args = args
    if args.cmd in ("get", "list"):
        read_config(args.recursive)
    else:
        read_config(None)

    # get the dict from the type
    if args.type:
        if KEY_TYPES not in cfg.config:
            cfg.config[KEY_TYPES] = {}
        if args.type not in cfg.config[KEY_TYPES]:
            cfg.config[KEY_TYPES][args.type] = {}
        config = cfg.config[KEY_TYPES][args.type]
    else:
        config = cfg.config

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
                # if there is no value, let's delete the key as well
                if name in config:
                    del config[name]
                    save_config()
            else:
                if name in config:
                    # value exists just update
                    if cfg.args.append:
                        # if is append operation construct
                        value = config[name] + cfg.args.separator + value
                # save the value
                config[name] = value
                save_config()

    elif args.cmd == 'get':
        for n in args.Name:
            name = n.strip()
            if args.search:
                for k, v in config.items():
                    if name in k:
                        print(v)
            elif name in config:
                print(config[name])

    elif args.cmd == 'list':
        if sys.stdout.isatty():
            args.decorate = True
        if cfg.env_name:
            print_one(cfg, 'V_ENV_NAME', cfg.env_name, DEFAULT_NAME_TYPE)

        if args.all:
            for k, v in cfg.config.items():
                if k == KEY_TYPES:
                    continue
                print_one(cfg, k, v)
            if KEY_TYPES in cfg.config:
                for type_name, tip in cfg.config[KEY_TYPES].items():
                    if not args.bash:
                        print("%s:" % (type_name,))
                    for name, value in tip.items():
                        print_one(cfg, name, value, type_name)

        else:
            for name, value in config.items():
                if name in (KEY_TYPES, KEY_VERSION):
                    continue
                print_one(cfg, name, value, args.type)
    elif args.cmd == 'drop':
        os.remove(cfg.dbPath)
    elif args.cmd == 'del':
        for n in args.Name:
            name = n.strip()
            if name in config:
                del config[name]
                if len(config) == 0:
                    # delete the hole type dict
                    if args.type:
                        del cfg.config[KEY_TYPES][args.type]
        save_config()


if __name__ == "__main__":
    main()
