import functions_jps as jps
import os
import shutil
import json
import tarfile
import ipaddress
from jsonmerge import merge

#Clean garbage from old updates
if os.path.isfile('ConfigData_ORIG.json'):
    os.remove('ConfigData_ORIG.json')
if os.path.isfile('ConfigData_NEW.json'):
    os.remove('ConfigData_NEW.json')
if os.path.isfile('ConfigData_merged.json'):
    os.remove('ConfigData_merged.json')
if os.path.isfile('_update.sh'):
    os.remove('_update.sh')
if os.path.isdir('JPSApps'):
    shutil.rmtree('JPSApps')

#Ask the user for the import ip
while True:
    try:
        ip = str(ipaddress.ip_address(input("Type the IP of the device: ")))
        break
    except ValueError:
        print("The IP is invalid, please check that it's correct")

#Get all the info we need on the device (hardware type and configuration)
info = jps.get_type(ip)
jps.get_config(info[""])

#######################################
#MERGE JSON FILE
#######################################
with open('ConfigData_NEW.json') as new:
    base = json.load(new)
with open('ConfigData_ORIG.json') as orig:
    head = json.load(orig)
target = merge(base, head)
with open('ConfigData_merged.json', 'w') as merged:
    json.dump(target, merged, indent=4)

#Create the installation package that will be pushed to the device
print("Creating the update package file...")
with tarfile.open('JPSApps.tar.gz', 'w:gz') as tar:
    tar.add('JPSApps', recursive=True)





#Take the trash out
print("Cleaning temp files...")
if os.path.isfile('ConfigData_ORIG.json'):
    os.remove('ConfigData_ORIG.json')
if os.path.isfile('ConfigData_NEW.json'):
    os.remove('ConfigData_NEW.json')
if os.path.isfile('ConfigData_merged.json'):
    os.remove('ConfigData_merged.json')
if os.path.isfile('_update.sh'):
    os.remove('_update.sh')
if os.path.isdir('JPSApps'):
    shutil.rmtree('JPSApps')
print("The update has been completed correctly.")
