import sys
import json
import requests
import paramiko
import shutil
import os
import re
from glob import glob

def usage():
    print("You must provide the IP address of the device you want to update" )

def get_type(ip):
    url = "http://" + ip + ":65000/jps/api/status"
    try:
        r = requests.get(url, timeout=10.0)
        type = (json.loads(r.text)["perType"])
        if type == "AppAps":
            info = {
            "type":"AppAps",
            "login":"root",
            "appfld": "ApsApp",
            "webfld": "apsapp",
            "script": "ApsAppRun",
            "workdir": "/home/root"}
        if type == "AppLe":
            info = {
            "type":"AppLe",
            "login":"root",
            "appfld": "LeApp",
            "webfld": "leapp",
            "script": "LeAppRun",
            "workdir": "/home/root"}
        if type == "AppLx":
            info = {
            "type":"AppLx",
            "login":"root",
            "appfld": "AplApp",
            "webfld": "aplapp",
            "script": "AplAppRun",
            "workdir": "/home/root"}
        if type == "AppApl":
            info = {
            "type":"AppApl",
            "login":"root",
            "appfld": "AplApp",
            "webfld": "aplapp",
            "script": "LxAppRun",
            "workdir": "/home/root"}
        if type == "AppOv":
            info = {
            "type":"AppOv",
            "login":"root",
            "appfld": "ApsApp",
            "webfld": "apsapp",
            "script": "OvAppRun",
            "workdir": "/home/root"}
        if type == "AppDr":
            info = {
            "type":"AppDr",
            "login":"root",
            "appfld": "LeApp",
            "webfld": "leapp",
            "script": "DrAppRun",
            "workdir": "/home/root"}
        if type == "AppLs":
            info = {
            "type":"AppLs",
            "login":"root",
            "appfld": "LeApp",
            "webfld": "leapp",
            "script": "LsAppRun",
            "workdir": "/home/root"}
        return info
    except requests.exceptions.Timeout:
        print("The device type is unknown...make sure the JPSApplication is running on the device and the IP address is correct")
        sys.exit(1)
    except requests.exceptions.ConnectionError:
         print("The device type is unknown...make sure the JPSApplication is running on the device and the IP address is correct")
         sys.exit(1)

def get_config(hw, appfld, webfld, script, login, device, workdir):
    shutil.copytree("./JPSApps_" + hw, "./JPSApps")
    json_new = "./JPSApps/JPSApplication/Resources/www/webcfgtool/" + webfld + "/ConfigData.json"
    json_orig = workdir + "/JPSApps/JPSApplication/Resources/www/webcfgtool/" + webfld + appfld + "/ConfigData.json"
    scriptfile = "./JPSApps/JPSApplication/" + script + ".sh"
    webfolders = [f.path for f in os.scandir("./JPSApps/JPSApplication/Resources/www/webcfgtool") if f.is_dir()]
    webfolder = "./JPSApps/JPSApplication/Resources" + webfld
    shutil.copyfile(json_new, "./ConfigData_NEW.json")
    try:
        client = paramiko.SSHClient()
        client.load_system_host_keys()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(device, username=login, password='')
        sftp = client.open_sftp()
        sftp.get(json_orig, "./ConfigData_ORIG.json")
    finally:
        client.close()

    for file in glob("./JPSApps/JPSApplication/*AppRun.sh"):
        if file != scriptfile:
            os.remove(file)
    for file in glob("./JPSApps/JPSApplication/Resources/AdditionalData.json_*"):
        os.remove(file)
    for file in glob("./JPSApps/JPSApplication/Resources/www/webcfgtool/" + webfld + "/ConfigData.json_*"):
        os.remove(file)
    for folder in webfolders:
        if re.match(r".*app", folder) and not re.match(r".*" + webfld, folder):
            shutil.rmtree(folder)


def update_script(appfld, webfld, workdir):
    with open("_update.sh", "a") as script:
        script.write("""#!/bin/bash
#set -x
WORKDIR=""" + workdir + """

#double check we are in the correct directory
if [ $(pwd) != $WORKDIR ]
	then
	cd $WORKDIR
fi
#double check that we have the package
if ! [ -f ./JPSApps.tar.gz ]
	then
	echo 'REMOTE: No JPSApps.tar.gz package found for update '
	exit 1
fi
TOKEN=${WORKDIR}/JPSApps/JPSApplication/Resources/""" + appfld + """/AppDB.fdb
TOKENDIR=${WORKDIR}/JPSApps/JPSApplication/Resources/""" + appfld + """
if [[ -f $WORKDIR/JPSApps/JPSApplication/Resources/Cash/cashDB.fdb ]]
then
APS=true
CASH=${WORKDIR}/JPSApps/JPSApplication/Resources/Cash/cashDB.fdb
CASHDIR=/home/root/JPSApps/JPSApplication/Resources/Cash
fi
JSDIR=${WORKDIR}/JPSApps/JPSApplication/Resources/www/webcfgtool/""" + webfld + """

function rollback() {
rm -fr JPSApps 2>/dev/null 1>&2
mv JPSApps_old JPSApps
rm -rf _update.sh cashDB.fdb AppDB.fdb JPSApps.tar.gz ConfigData_merged.json 2>/dev/null 1>&2
}

#kill everything
pgrep -f AppRun.sh | xargs kill  && pgrep JPSApplication | xargs kill
sleep 1

#backup the JBL Token
cp $TOKEN .
#backup cashDB
[[ $APS ]] && cp $CASH . || :

#remove old backups
ls | grep -e [JPSApps]_ | xargs rm -fr


#backup
mv ./JPSApps ./JPSApps_old
#Check backup
if [ $? != 0 ]
	then
rm -rf _update.sh cashDB.fdb AppDB.fdb JPSApps.tar.gz ConfigData_merged.json 2>/dev/null 1>&2
	echo 'REMOTE: Application folder has not been saved, aborting update. Please contact HUB Support!'
	exit 1
fi

#untar the new package
tar -xf JPSApps.tar.gz &>/dev/null

chmod +x -R JPSApps

#restore data from prevous version

mv ./ConfigData_merged.json $JSDIR/ConfigData.json
if [ $? != 0 ]
	then
echo 'REMOTE CRITICAL ERROR!! \
	ConfigData.json has not been restored. Please contact HUB Support!'
rollback
	exit 3
fi
mv ./AppDB.fdb \$TOKEN
if [ $? != 0 ]
	then
	echo 'REMOTE CRITICAL ERROR!! \
	JBL Token has not been restored. Please contact HUB Support!'
rollback
	exit 3
fi

if [[ $APS ]]
then
mkdir $CASHDIR
mv ./cashDB.fdb \$CASH
fi
if [ $? != 0 ]
	then
	echo 'REMOTE CRITICAL ERROR!! \
	Cash DB has not been restored. Please contact HUB Support!'
rollback
	exit 3
fi
#clean
rm -rf _update.sh JPSApps.tar.gz
sync
echo "Rebooting"
reboot
""")
