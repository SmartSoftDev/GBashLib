#!/usr/bin/env python2
import os
import argparse
import sys
from ghepy.sql.schema_db import SQLiteSchemaDb
from ghepy.term.colors import COLOR_NONE, COLOR_CYAN, COLOR_GREEN

cfg= lambda: None
cfg.path= os.environ['HOME']
cfg.dbPath=os.path.join(cfg.path,".v.db.sqlite3")

def get_db():
    if not os.path.exists(cfg.path):
        os.makedirs(cfg.path)
        
    db= SQLiteSchemaDb(cfg.dbPath, None)
    if not os.path.exists(cfg.dbPath):
        db.connect()
        db.run('CREATE TABLE vars( id INTEGER PRIMARY KEY ASC, name TEXT, value TEXT, type TEXT);')
        db.run('CREATE UNIQUE INDEX vars_ndx ON vars (name, type);');
    else:
        db.connect()
    return db

def print_one(cfg, r,last=False):
    args= cfg.args
    s= r[0]
    if sys.stdout.isatty() or args.decorate:
        s= "%s%s%s" %(COLOR_CYAN,r[0],COLOR_NONE,)
        if args.value_only:
            s= "%s%s%s" %(COLOR_GREEN,r[1],COLOR_NONE)
        elif not args.name_only:
            s+= " = %s%s%s" %(COLOR_GREEN,r[1],COLOR_NONE)
    else:
        if args.value_only:
            s= r[1]
        elif not args.name_only:
            s+= "=" + r[1]
    if last:
        s+= "\n"
    else:
        s+= args.separator
    sys.stdout.write( s)
     
def main():
    parser= argparse.ArgumentParser(description="Variable storage for bash")

    subparsers= parser.add_subparsers(title="Sub commands")
    sp= subparsers.add_parser("get", help="manipulate ws/pkg evn: create uid with name uid_name")
    sp.set_defaults(cmd="get");
    sp.add_argument('Name', type=str, nargs="+", help='variable Name')
    sp.add_argument('-t','--type',default='',help="Store name=value of a specific type (types does not colide)")
    
    sp= subparsers.add_parser("set", help="manipulate ws/pkg evn: add new entry to uid with name uid_name")
    sp.set_defaults(cmd="set");
    sp.add_argument('Name', type=str, nargs="+", help='variable Name')
    sp.add_argument('-t','--type',default='',help="Store name=value of a specific type (types does not colide)")
    sp.add_argument('-a','--append', action='store_true', default=False, help="Append current value to existing one")
    sp.add_argument('-s','--separator', default=' ', help="only used with append flag, sets the separator when appending. default 'space' ")

    sp= subparsers.add_parser("list", help="Print all values")
    sp.set_defaults(cmd="list");
    sp.add_argument('-t','--type', default='', help="lists name=value of a specific type")
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
    db= get_db()
    if args.cmd == 'set':
        for n in args.Name:
            n=n.split('=')
            n[0]=n[0].strip()
            name= n[0]
            if len(n) > 1:
                value= n[1]
            else:
                value= ''
            cur=db.select("select value from vars where name=? and type=?;", (name,args.type))
            
            if len(value) == 0:
                db.run("delete from vars where name = ? and type = ?;", (name, args.type))
            else:
                if len(cur):
                    if cfg.args.append:
                        value= cur[0][0]+cfg.args.separator+value
                    db.run("update vars set value=? where name = ? and type = ?;", (value, name, args.type))
                else:
                    db.run("insert into vars (name, value, type) values (?,?,?);", (name, value, args.type))
    elif args.cmd == 'get':
        for n in args.Name:
            name= n.strip()
            cur=db.select("select value from vars where name=? and type=?;", (name,args.type))
            if len(cur):
                print cur[0][0]
    elif args.cmd == 'list':
        if args.all:
            cur=db.select("select name,value,type from vars order by type asc;")
            t=''
            if len(cur):
                for r in cur:
                    if t != r[2]:
                        print "%s:" % (r[2],)
                        t= r[2]
                    print_one(cfg,r)
                
        
        else:
            cur=db.select("select name,value from vars where type=?;", (args.type,))
            if len(cur):
                for r in cur:
                    print_one(cfg, r)
    elif args.cmd == 'drop':
        db.disconnect()
        os.remove(cfg.dbPath)
        
            
                
if __name__ == "__main__":
    main()