#!/usr/bin/env python3
"""
 Copyright (C) Smartsoftdev.eu SRL - All Rights Reserved
 Proprietary and confidential license.
 Unauthorized copying via any medium or use of this file IS STRICTLY prohibited
 For any license violations or more about commercial licensing please contact:
 SmartSoftDev.eu

 This app computes and unique hash of an component located in a git repository,
 in multiple locations (files, directories).
 Use cases:
 * This is specially useful when in the repo there are multiple components and we have to detect if one component changed
 in with this commit.
 * Another useful case is when changes in specific files/directories (like documentation, helper scripts, etc) must not
 trigger deployment or building of the component.

 The app receives a list of paths (or a yaml file with path list) and then gets the git hash of those locations and at
 the end it computes one hash from the one's from git and returns it.
NOTE: Git returns the hash FROM committed changes not for stashed once! so make sure when running
git_component_hash that you do not have local changes in the git repositories.

To ease automation the app will look to .git_component_hash.yml file in current directory.

config file format:
locations:
  - relative/path/directory1
  - relative/path2/file1
name: OptionalAppName

"""
import os
import hashlib
import subprocess
import yaml
import argparse
import logging


cfg = lambda: None
cfg.args = None
_l = None  # is this file logger(setup logging)


def args_pars():
    global _l
    _l = logging.getLogger(__name__)
    parser = argparse.ArgumentParser(description='Compute a hash of multiple git locations')
    parser.add_argument('-v', '--debug', action='count', default=0, help='Enable debugging')
    parser.add_argument('-c', '--config', action='store', type=str, default=None,
                        help='Path to the yaml config file, or directory where .git_component_hash.yml (default=.)')
    parser.add_argument('-l', '--limit', action='store', type=int, default=65,
                        help='limit the size of hash (default=65)')

    args = parser.parse_args()
    cfg.args = args


def main():
    args_pars()
    cfg_file = ".git_component_hash.yml"
    if cfg.args.config:
        if os.path.isdir(cfg.args.config):
            cfg_file = os.path.join(cfg.args.config, ".git_component_hash.yml")
        else:
            cfg_file = cfg.args.config
    if not os.path.exists(cfg_file):
        raise Exception('Config file %r NOT found!', cfg_file)
    cfg.cwd = os.path.realpath(os.path.dirname(cfg_file))
    with open(cfg_file, "r") as f:
        cfg.file = yaml.safe_load(f)
    locations = cfg.file.get("locations")
    if not locations:
        raise Exception("Config file has no 'locations' list!")
    if not isinstance(locations, list):
        raise Exception("'locations' field from config file MUST be a list!")
    if cfg.args.debug:
        print(f"git-hashes:")

    # we MUST always sort the locations so that the result does not change when the order is different
    locations = sorted(locations)
    hashes = []
    for l in locations:
        if not isinstance(l, (int, float, str)):
            raise Exception(f"location={l} is not a string!")
        try:
            l = str(l)
        except Exception:
            raise Exception(f"location={l} is not a string!")
        if os.path.isabs(l):
            raise Exception(f"location={l} is ABSOLUTE (only relative paths are allowed)")
        l = os.path.join(cfg.cwd, l)
        cmd = ["git", "log", "-n1", '--format=%H', "--", l]
        resp = subprocess.check_output(cmd).decode("utf-8").strip()
        if len(resp) == 0:
            raise Exception(f"Could not get git has from {l}, is it under git control?")
        if cfg.args.debug:
            print(f"\t{l} {resp!s}")
        hashes.append(resp)
    if cfg.args.debug:
        print(f"Final hash:")
    if len(hashes) == 0:
        raise Exception("There are no valid locations to get the hash")
    elif len(hashes) == 1:
        print(hashes[0])
    else:
        hasher = hashlib.sha256()
        for line in hashes:
            hasher.update(line.encode('utf-8'))
        print(hasher.hexdigest()[:cfg.args.limit])


if __name__ == "__main__":
    main()