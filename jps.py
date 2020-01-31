import sys
import json
import requests
import paramiko
import shutil
import os
import re
from glob import glob
import logging

logging.basicConfig(filename="jps_update.log", filemode="w", format="%(name)s - %(levelname)s - %(message)s")

def pre_clean():
    if os.path.isfile('ConfigData_ORIG.json'):
        os.remove('ConfigData_ORIG.json')
    if os.path.isfile('ConfigData_NEW.json'):
        os.remove('ConfigData_NEW.json')
    if os.path.isfile('ConfigData_merged.json'):
        os.remove('ConfigData_merged.json')
    if os.path.isfile('_update.sh'):
        os.remove('_update.sh')
    if os.path.isfile('JPSApps.tar.gz'):
        os.remove('JPSApps.tar.gz')
    if os.path.isdir('JPSApps'):
        shutil.rmtree('JPSApps')
def post_clean():
    if os.path.isfile('ConfigData_ORIG.json'):
        os.remove('ConfigData_ORIG.json')
    if os.path.isfile('ConfigData_NEW.json'):
        os.remove('ConfigData_NEW.json')
    if os.path.isfile('ConfigData_merged.json'):
        os.remove('ConfigData_merged.json')
    if os.path.isfile('_update.sh'):
        os.remove('_update.sh')
    if os.path.isfile('JPSApps.tar.gz'):
        os.remove('JPSApps.tar.gz')
    if os.path.isdir('JPSApps'):
        shutil.rmtree('JPSApps')


class JpsDevice:

    def __init__(self, ip):
        url = "http://" + ip + ":65000/jps/api/status"
        self.info = {}
        client = paramiko.SSHClient()
        client.load_system_host_keys()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(ip, username="root", password="")
        try:
            stdin, stdout, stderr = client.exec_command("hostname")
        except SSHException:
            sys.exit("It's impossible to understand the hardware (JHW or Raspberry), please check the ssh connection. the update has failed.")
        if "ebb" in str(stdout.read()):
            hw = "jhw"
        elif "raspberrypi" in str(stdout.read()):
            hw = "rpi"
        else:
            raise Exception("It's impossible to understand the hardware (JHW or Raspberry), please check the ssh connection. The update has failed.")
        try:
            r = requests.get(url, timeout=10.0)
            type = (json.loads(r.text)["perType"])
            if type == "AppAps":
                self.info = {
                "hw": hw,
                "login":"root",
                "appfld": "ApsApp",
                "webfld": "apsapp",
                "script": "ApsAppRun.sh",
                "workdir": "/home/root"}
            if type == "AppLe":
                self.info = {
                "hw": hw,
                "login":"root",
                "appfld": "LeApp",
                "webfld": "leapp",
                "script": "LeAppRun.sh",
                "workdir": "/home/root"}
            if type == "AppLx":
                self.info = {
                "hw": hw,
                "login":"root",
                "appfld": "AplApp",
                "webfld": "aplapp",
                "script": "AplAppRun.sh",
                "workdir": "/home/root"}
            if type == "AppApl":
                self.info = {
                "hw": hw,
                "login":"root",
                "appfld": "AplApp",
                "webfld": "aplapp",
                "script": "LxAppRun.sh",
                "workdir": "/home/root"}
            if type == "AppOv":
                self.info = {
                "hw": hw,
                "login":"root",
                "appfld": "ApsApp",
                "webfld": "apsapp",
                "script": "OvAppRun.sh",
                "workdir": "/home/root"}
            if type == "AppDr":
                self.info = {
                "hw": hw,
                "login":"root",
                "appfld": "LeApp",
                "webfld": "leapp",
                "script": "DrAppRun.sh",
                "workdir": "/home/root"}
            if type == "AppLs":
                self.info = {
                "hw": hw,
                "login":"root",
                "appfld": "LeApp",
                "webfld": "leapp",
                "script": "LsAppRun.sh",
                "workdir": "/home/root"}
        except requests.exceptions.Timeout:
            sys.exit("The device type is unknown...make sure the JPSApplication is running on the device and the IP address is correct, the update has failed.")
        except requests.exceptions.ConnectionError:
             sys.exit("The device type is unknown...make sure the JPSApplication is running on the device and the IP address is correct, the update has failed.")

def get_config(hw, ip, login, appfld, webfld, script, workdir):
    try:
        shutil.copytree("./JPSApps_" + hw, "./JPSApps")
    except:
        sys.exit("Impossible to create the update folder JPSApps, the update has failed.")
    json_new = "./JPSApps/JPSApplication/Resources/www/webcfgtool/" + webfld + "/ConfigData.json"
    json_orig = workdir + "/JPSApps/JPSApplication/Resources/www/webcfgtool/" + webfld + "/" + appfld + "/ConfigData.json"
    scriptfile = "./JPSApps/JPSApplication/" + script
    webfolders = [f.path for f in os.scandir("./JPSApps/JPSApplication/Resources/www/webcfgtool") if f.is_dir()]
    appfloders = ["./JPSApps/JPSApplication/Resources/ApsApp", "./JPSApps/JPSApplication/Resources/AplApp", "./JPSApps/JPSApplication/Resources/LeApp"]
    #print(json_orig)
    try:
        shutil.copyfile(json_new, "./ConfigData_NEW.json")
    except:
        sys.exit("Impossible to get the default ConfigData.json file from the update package, the update has failed.")
    client = paramiko.SSHClient()
    client.load_system_host_keys()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(ip, username=login, password="")
    sftp = client.open_sftp()
    try:
        sftp.get(json_orig, "./ConfigData_ORIG.json")
    except:
        sys.exit("It was not possible to fetch the Configuration file from the device, the update has failed.")
    client.close()

    for file in glob("./JPSApps/JPSApplication/*AppRun.sh"):
        if file != scriptfile:
            try:
                os.remove(file)
            except:
                print("Impossible to remove useless script files from the installation folder")
                pass
    for file in glob("./JPSApps/JPSApplication/Resources/AdditionalData.json_*"):
        try:
            os.remove(file)
        except:
            print("Impossible to remove useless AdditionalData.json files from the installation package")
            pass
    for file in glob("./JPSApps/JPSApplication/Resources/www/webcfgtool/" + webfld + "/ConfigData.json_*"):
        try:
            os.remove(file)
        except:
            print("Impossible to remove useless ConfigData.json files from the installation package")
    for folder in webfolders:
        if re.match(r".*app", folder) and not re.match(r".*" + webfld, folder):
            try:
                shutil.rmtree(folder)
            except:
                print("Impossible to remove useless app web folder from the installation package")
                pass
    for folder in appfloders:
        if not re.match(appfld, folder)
            try:
                shutil.rmtree(folder)
            except:
                print("Impossible to remove useless app folder from the installation package")
                pass

    try:
        shutil.copy(scriptfile, "./JPSApps/JPSApplication/XXXAppRun.sh")
    except:
        sys.exit("Impossible to create the XXXAppRun.sh launch script, the update has failed.")

def update_script(appfld, webfld, workdir):
    with open("_update.sh", "a", newline='\n') as script:
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
mv ./AppDB.fdb $TOKEN
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
mv ./cashDB.fdb $CASH
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
