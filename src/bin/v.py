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

"""
import os
import argparse
import sys
import yaml

from types import SimpleNamespace

# Bash (terminal) colors
COLOR_NONE = '\033[0m'  # No Color
COLOR_GREEN = '\033[0;32m'
COLOR_CYAN = '\033[0;36m'

DEFAULT_NAME_TYPE = '.'
cfg = SimpleNamespace()  # singleton
cfg.env_name = None  # means no special MULTI-ENV name was given.
KEY_TYPES = '~types'
KEY_VERSION = '~version'
NO_GPG_KEYS_ERROR_MSG = "Could not delete all public keys, for encryption should remain at least one public key!!"

_gnupg = None


def _init_gpg(verbose=None):
    global _gnupg
    if _gnupg is None:
        import gnupg
        _gnupg = gnupg.GPG(verbose=verbose)
        _gnupg.encoding = 'utf-8'

    return _gnupg


def _decrypt(value, skip_cannot_decrypt):
    gpg = _init_gpg()
    loc_gpg_user_id_s = gpg.list_keys()
    field_gpg_usr_s_id = [usr_id['id'] for usr_id in value.get('keys', [])]
    gpg_usr_s_id = [gpg_crt for gpg_crt in loc_gpg_user_id_s if gpg_crt['fingerprint'] in field_gpg_usr_s_id]
    if len(gpg_usr_s_id) == 0:
        if skip_cannot_decrypt:
            return ""
        else:
            raise ValueError("No gpg public keys available for decryption!")
    enc_field_formatted = "-----BEGIN PGP MESSAGE-----\n\n" + value.get("enc_str") + "\n-----END PGP MESSAGE-----\n"
    return str(gpg.decrypt(enc_field_formatted))


def _format_gpg_enc_str(enc_str):
    ret = ''
    for line in enc_str.split('\n'):
        line = line.strip()
        if len(line) == 0:
            continue
        if line.startswith('-----'):
            continue
        ret += line
    return ret


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
        if isinstance(v, dict) and v.get('enc_type') is None:
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
    if (sys.stdout.isatty() or args.decorate) and not args.bash:
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
    parser.add_argument('-v', '--verbose', action='count', default=0, help='Enable debugging')
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

    sp = subparsers.add_parser("enc", help="manipulate ws/pkg evn: add new gpg encrypted entry "
                                           "to uid with name uid_name ")
    sp.set_defaults(cmd="enc")
    sp.add_argument('value', type=str, help='variable name=value. Ex:"test_var=1234"')
    sp.add_argument('recipients', type=str, nargs="+", help='PGP users fingerprints|IDs')

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
    sp.add_argument('-S', '--skip_cannot_decrypt', action='store_true', default=False,
                    help="Skip fields which cannot be decrypted")

    sp = subparsers.add_parser("del", help="delete one entry")
    sp.add_argument('Name', type=str, nargs="+", help='variable Name')
    sp.add_argument('-t', '--type', default=None,
                    help="delete entry from specific type")
    sp.set_defaults(cmd="del")

    sp = subparsers.add_parser("drop", help="Delete hole DB")
    sp.set_defaults(cmd="drop")

    sp = subparsers.add_parser("add-user-key", help="Add pgp user key")
    sp.set_defaults(cmd="add-user-key")
    sp.add_argument("-k", "--key-name", type=str, default=None, help='key Name. Ex:"test_key"')
    sp.add_argument('recipients', type=str, nargs="+", help='PGP users fingerprints|IDs')

    sp = subparsers.add_parser("del-user-key", help="Delete pgp user key")
    sp.set_defaults(cmd="del-user-key")
    sp.add_argument("-k", "--key-name", type=str, default=None, help='variable Name. Ex:"test_key"')
    sp.add_argument('recipients', type=str, nargs="+", help='PGP users fingerprints|IDs')

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
    if hasattr(args, "type") and args.type:
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

    elif args.cmd == 'enc':
        gpg = _init_gpg(args.verbose > 0)

        gpg_usr_s_id = [{"id": user_key['fingerprint'], "uids": user_key['uids']} for user_key in gpg.list_keys()
                        if user_key['fingerprint'] in args.recipients]
        if len(gpg_usr_s_id) < 1:
            parser.error(message=f"Didn't find public keys for passed fingerprints {args.recipients}!")
        namespace = args.value.split('=', 1)
        namespace[0] = namespace[0].strip()
        name = namespace[0]
        if len(namespace) > 1:
            value = namespace[1]
        else:
            raise Exception("There is not value specified")

        if name in config and config[name].get("enc_type"):
            raise ValueError("Field value is already encrypted!")

        def get_type(val):
            tp = 'str'
            try:
                float(val)
                tp = 'float'
                if '.' not in val:
                    tp = 'int'
            except ValueError:
                pass
            return tp

        # save the value
        enc_str = str(gpg.encrypt(value, args.recipients))
        if len(enc_str) == 0:
            raise Exception("Could not encrypt the value")

        enc_str = _format_gpg_enc_str(enc_str)
        field_obj = {"enc_type": "gpg",
                     "keys": [{"id": user_key['fingerprint'], "uids": user_key['uids']
                               } for user_key in gpg.list_keys() if user_key['fingerprint'] in args.recipients],
                     "value_type": get_type(value),
                     "enc_str": enc_str}
        config[name] = field_obj
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
            print_one(cfg, 'V_ENV_NAME', cfg.env_name)

        if args.all:
            gpg = None
            for k, v in cfg.config.items():
                if k == KEY_TYPES:
                    continue
                if isinstance(v, dict) and v.get("enc_type") == "gpg":
                    if gpg is None:
                        gpg = _init_gpg(args.verbose > 0)
                    v = _decrypt(v, args.skip_cannot_decrypt)
                    if len(v) == 0:
                        if not args.skip_cannot_decrypt:
                            raise ValueError(f"Could not decrypt {k=} {v=}")
                        else:
                            v = '<CANNOT DECRYPT>'
                print_one(cfg, k, v)
            if KEY_TYPES in cfg.config:
                for type_name, tip in cfg.config[KEY_TYPES].items():
                    if not args.bash:
                        print("%s:" % (type_name,))
                    for name, value in tip.items():
                        if isinstance(value, dict) and value.get("enc_type") == "gpg":
                            value = _decrypt(value, args.skip_cannot_decrypt)
                            if len(value) == 0:
                                if not args.skip_cannot_decrypt:
                                    raise ValueError(f"Could not decrypt {name=} {value=}")
                                else:
                                    value = '<CANNOT DECRYPT>'
                        print_one(cfg, name, value, type_name)
        else:
            for name, value in config.items():
                if name in (KEY_TYPES, KEY_VERSION):
                    continue
                if isinstance(value, dict) and value.get("enc_type") == "gpg":
                    value = _decrypt(value, args.skip_cannot_decrypt)
                    if len(value) == 0:
                        if not args.skip_cannot_decrypt:
                            raise ValueError(f"Could not decrypt {name=} {value=}")
                        else:
                            value = '<CANNOT DECRYPT>'
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

    elif args.cmd in ('add-user-key', 'del-user-key'):
        gpg = _init_gpg(args.verbose > 0)

        gpg_key_list = gpg.list_keys()
        # we check that requested add/del keys exist in pgp
        gpg_usr_s_id = [{"id": user_key['fingerprint'], "uids": user_key['uids']} for user_key in gpg_key_list
                        if user_key['fingerprint'] in args.recipients]
        if len(gpg_usr_s_id) != len(args.recipients):
            parser.error(message=f"Didn't find user keys ({len(gpg_usr_s_id)} out of {len(args.recipients)})"
                                 f" for passed {args.recipients}!")

        if args.key_name is None:
            # process all config encrypted fields
            for name, value in config.items():
                # process only gpg encrypted fields
                if isinstance(value, dict) and value.get("enc_type") == "gpg":
                    # let's check if all the keys are present
                    value_keys = value.get('keys')
                    value_keys_fingerprints = [key['id'] for key in value_keys]
                    found_keys = [user_key for user_key in gpg_key_list if
                                  user_key['fingerprint'] in value_keys_fingerprints]
                    if len(value_keys) != len(found_keys):
                        raise Exception(f"Could not find all ({len(found_keys)} of {len(value_keys)}) keys "
                                        f"to re/encrypt {name=}")
                    if args.cmd == 'add-user-key':
                        for usr_id in gpg_usr_s_id:
                            if usr_id not in value_keys:
                                value['keys'].append(usr_id)
                    elif args.cmd == 'del-user-key':
                        value['keys'] = [usr_id for usr_id in value.get('keys', []) if usr_id not in gpg_usr_s_id]

                    if len(value['keys']) < 1:
                        parser.error(message=NO_GPG_KEYS_ERROR_MSG)

                    all_recipients = [recipient['id'] for recipient in value['keys']]
                    value['enc_str'] = _format_gpg_enc_str(
                        str(gpg.encrypt(str(_decrypt(value, False)), all_recipients)))
                    config[name] = value
        else:
            # only one field
            name = args.key_name
            value = config.get(name)
            # process only gpg encrypted field
            if value and isinstance(value, dict) and value.get("enc_type") == "gpg":
                # check if all keys are present
                value_keys = value.get('keys')
                value_keys_fingerprints = [key['id'] for key in value_keys]
                found_keys = [user_key for user_key in gpg_key_list if
                              user_key['fingerprint'] in value_keys_fingerprints]
                if len(value_keys) != len(found_keys):
                    print(f"{gpg_key_list=}")
                    raise Exception(f"Could not find all ({len(found_keys)} of {len(value_keys)} [{value_keys}]) keys "
                                    f"to re/encrypt {name=}")

                if args.cmd == 'add-user-key':
                    for usr_id in gpg_usr_s_id:
                        if usr_id not in value.get('keys', []):
                            value['keys'].append(usr_id)
                elif args.cmd == 'del-user-key':
                    value['keys'] = [usr_id for usr_id in value.get('keys', []) if usr_id not in gpg_usr_s_id]

                if len(value['keys']) < 1:
                    parser.error(message=NO_GPG_KEYS_ERROR_MSG)

                all_recipients = [recipient['id'] for recipient in value['keys']]
                value["enc_str"] = _format_gpg_enc_str(
                    str(gpg.encrypt(str(_decrypt(value, False)), all_recipients)))
            else:
                parser.exit(message="Key value cannot be empty!")
        save_config()


if __name__ == "__main__":
    main()
