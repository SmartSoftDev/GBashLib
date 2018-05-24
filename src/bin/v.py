#!/usr/bin/env python2
import os
import argparse
import sys
import yaml
#from ghepy.term.colors 
COLOR_NONE='\033[0m' # No Color
COLOR_GREEN='\033[0;32m'
COLOR_CYAN='\033[0;36m'

DEFAULT_NAME_TYPE='.'
cfg= lambda: None
cfg.path= os.environ['HOME']
cfg.dbPath=os.path.join(cfg.path,".v.yaml")
cfg.config = {}

def read_config():
    if not os.path.exists(cfg.path):
        os.makedirs(cfg.path)
    #read config file    
    if not os.path.exists(cfg.dbPath):
        save_config()
    else:
        with open(cfg.dbPath) as f:
            cfg.config = yaml.load(f)
    
def save_config():
    with open(cfg.dbPath, "w") as f:
        yaml.dump(cfg.config, f)


def print_one(cfg, name, value, last=False):
    args= cfg.args
    s= name
    if sys.stdout.isatty() or args.decorate:
        s = "%s%s%s" %(COLOR_CYAN, name, COLOR_NONE,)
        if args.value_only:
            s = "%s%s%s" %(COLOR_GREEN,value,COLOR_NONE)
        elif not args.name_only:
            s += " = %s%s%s" %(COLOR_GREEN, value, COLOR_NONE)
    else:
        if args.value_only:
            s = name
        elif not args.name_only:
            s += "=" + value
    if last:
        s += "\n"
    else:
        s += args.separator
    sys.stdout.write( s)
     
def main():
    parser= argparse.ArgumentParser(description="Variable storage for bash")

    subparsers= parser.add_subparsers(title="Sub commands")
    sp= subparsers.add_parser("get", help="manipulate ws/pkg evn: create uid with name uid_name")
    sp.set_defaults(cmd="get");
    sp.add_argument('Name', type=str, nargs="+", help='variable Name')
    sp.add_argument('-t','--type',default=DEFAULT_NAME_TYPE,help="Store name=value of a specific type (types does not colide)")
    
    sp= subparsers.add_parser("set", help="manipulate ws/pkg evn: add new entry to uid with name uid_name")
    sp.set_defaults(cmd="set");
    sp.add_argument('Name', type=str, nargs="+", help='variable Name')
    sp.add_argument('-t','--type',default=DEFAULT_NAME_TYPE,help="Store name=value of a specific type (types does not colide)")
    sp.add_argument('-a','--append', action='store_true', default=False, help="Append current value to existing one")
    sp.add_argument('-s','--separator', default=' ', help="only used with append flag, sets the separator when appending. default 'space' ")

    sp= subparsers.add_parser("list", help="Print all values")
    sp.set_defaults(cmd="list");
    sp.add_argument('-t','--type', default=DEFAULT_NAME_TYPE, help="lists name=value of a specific type")
    sp.add_argument('-a','--all', action='store_true', default=False, help="lists name=value for all types")
    sp.add_argument('-d','--decorate', action='store_true', default=False, help="always decorate for terminal")
    sp.add_argument('-n','--name-only', action='store_true', default=False, help="show only names")
    sp.add_argument('-v','--value-only', action='store_true', default=False, help="show only values")
    sp.add_argument('-s','--separator', default='\n', help="set separator string ")
    sp= subparsers.add_parser("drop", help="Delete hole DB")
    sp.set_defaults(cmd="drop");
    
    args= parser.parse_args()
    #print args
    cfg.args= args
    read_config()
    if args.cmd == 'set':
        for n in args.Name:
            n=n.split('=',1)
            n[0]=n[0].strip()
            name= n[0]
            if len(n) > 1:
                value= n[1]
            else:
                value= ''
            
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
                        value = cfg.config[args.type][name]+cfg.args.separator+value
                #save the value
                cfg.config[args.type][name] = value
                save_config()
                    
    elif args.cmd == 'get':
        for n in args.Name:
            name= n.strip()
            if args.type in cfg.config:
                if name in cfg.config[args.type]:
                    print cfg.config[args.type][name]
    elif args.cmd == 'list':
        if args.all:
            for type_name, tip in cfg.config.iteritems():
                if type_name != DEFAULT_NAME_TYPE:
                    print "%s:" % (type_name,)
                for name,value in tip.iteritems():
                    print_one(cfg,name, value)
                
        
        else:
            if args.type in cfg.config:
                for name,value in cfg.config[args.type].iteritems():
                    print_one(cfg,name, value)
    elif args.cmd == 'drop':
        os.remove(cfg.dbPath)
        
            
                
if __name__ == "__main__":
    main()