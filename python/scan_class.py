import os
import sys

classdic={}

def add2dic(fullname):
    idx=fullname.rfind(".")
    key=fullname[idx+1:]
    if key in classdic:
        classdic[key]+=":"+fullname
    else:
        classdic[key]=fullname

# jdk

f=open(sys.argv[0]+"/allclass"),"r",encoding="utf-8")
for line in f.readlines():
    add2dic(line[:-1])
f.close()


print(classdic)
