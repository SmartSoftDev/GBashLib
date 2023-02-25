#!/usr/bin/env python3
"""
Tool to quickly convert from JSON to YAML and vice-versa. 
"""

import argparse
import logging
import json
import yaml
import os

cfg = lambda: None


class UnsupportedConfigFileExtension(Exception):
    pass


def read_cfg_file(file_path, default_return=None):
    """reads json or yaml file and return the content"""
    if default_return is not None and not os.path.isfile(file_path):
        return default_return
    ret = None
    with open(file_path, "r") as f:
        try:
            if file_path.endswith(".json"):
                ret = json.load(f)
            elif file_path.endswith(".yaml") or file_path.endswith(".yml"):
                ret = yaml.safe_load(f)
            else:
                raise UnsupportedConfigFileExtension("file ends with %r", file_path)
        except:
            logging.exception(f"Could not read cfg file {file_path}")
            raise
    return ret


def write_cfg_file(file_path, data, human_readable=False):
    """writes json or yaml file.
    NOTE: it will always write in an atomic manner (first write to tmp file then move it to destination
    when writing configuration files is IMPORTANT to protect against powerOFF events and do not leave the CFG file
    half written.
    """

    tmp_file_path = file_path + ".tmp"
    with open(tmp_file_path, "w+") as f:
        if file_path.endswith(".json"):
            json.dump(data, f, indent=2 if human_readable else None)
        elif file_path.endswith(".yaml") or file_path.endswith(".yml"):
            yaml.safe_dump(data, f)
        else:
            raise UnsupportedConfigFileExtension("file ends with %r", file_path[:-4])
        f.flush()
        os.fsync(f.fileno())
    # rename should be atomic operation
    os.rename(tmp_file_path, file_path)
    # still we would like to sync the hole parent directory.
    dir_name = os.path.dirname(file_path)
    if not dir_name:
        dir_name = "."
    dir_fd = os.open(dir_name, os.O_DIRECTORY | os.O_CLOEXEC)
    os.fsync(dir_fd)
    os.close(dir_fd)


def args_pars():
    parser = argparse.ArgumentParser(description="convert to json")
    parser.add_argument("-v", "--debug", action="count", default=0, help="Enable debugging")
    parser.add_argument("-o", "--output", default=None, help="Output file name")
    parser.add_argument("-m", "--minimize", default=None, help="Minimize output size (default human readable)")
    parser.add_argument("FILES", nargs="+", help="Input files")

    args = parser.parse_args()
    cfg.args = args
    cfg.l = logging.getLogger(__name__)


def main():
    args_pars()
    for f in cfg.args.FILES:
        if f.endswith(".json"):
            new_f = f[:-4] + "yml"
        elif f.endswith(".yml"):
            new_f = f[:-3] + "json"
        elif f.endswith(".yaml"):
            new_f = f[:-4] + "json"

        write_cfg_file(new_f, read_cfg_file(f), human_readable=True)


if __name__ == "__main__":
    main()
