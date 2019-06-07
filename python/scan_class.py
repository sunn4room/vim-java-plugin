import os
import sys
spath=sys.argv[0]
spath=spath[:spath.rfind("/")]
tempfilestr="/tmp/"+sys.argv[2].replace("/","_")+".tmp"

classdic={}

def add2dic(fullname):
    idx=fullname.rfind(".")
    key=fullname[idx+1:]
    if key in classdic:
        classdic[key]+=":"+fullname
    else:
        classdic[key]=fullname

def getptime():
    if sys.argv[1]=="simple":
        return 0
    elif sys.argv[1]=="normal":
        if os.path.exists(sys.argv[2]+"/lib"):
            return os.path.getmtime(sys.argv[2]+"/lib")
        else:
            return 0
    elif sys.argv[1]=="maven":
        return os.path.getmtime(sys.argv[2]+"/pom.xml")

def getttime():
    if os.path.exists(tempfilestr):
        return os.path.getmtime(tempfilestr)
    else:
        return 0

def createtmp():
    f=open(tempfilestr,"w",encoding="utf-8")
    if sys.argv[1]=="normal":
        for jar in os.popen("find "+sys.argv[2]+"/lib -name *.jar").readlines():
            for line in os.popen("jar tf "+jar[:-1]+" | grep .class$ | grep -v -"):
                f.write(line[:-7].replace("/",".")+"\n")
    elif sys.argv[1]=="maven":
        output=os.popen("mvn -f "+sys.argv[2]+"/pom.xml dependency:build-classpath -DincludeScope=test").read()
        output=output[output.rfind("Dependencies classpath:")+24:]
        output=output[:output.find("\n")]
        for jar in output.split(":"):
            for line in os.popen("jar tf "+jar+" | grep .class$ | grep -v -"):
                f.write(line[:-7].replace("/",".")+"\n")
    f.close()

def handlefile(filestr):
    f=open(filestr,"r",encoding="utf-8")
    for line in f.readlines():
        add2dic(line[:-1])
    f.close()


# jdk

handlefile(spath+"/allclass")


# dependency

ptime=getptime()
ttime=getttime()
if ptime==0:
    pass
else:
    if ttime==0:
        createtmp()
    else:
        if ptime > ttime:
            os.remove(tempfilestr)
            createtmp()
    handlefile(tempfilestr)
        
# edit

if sys.argv[1]=="simple":
    os.chdir(sys.argv[2])
elif sys.argv[1]=="normal":
    os.chdir(sys.argv[2]+"/src")
elif sys.argv[1]=="maven":
    os.chdir(sys.argv[2]+"/src/main/java")
for line in os.popen("find -name *.java"):
    add2dic(line[2:-6].replace("/","."))

print(classdic)
