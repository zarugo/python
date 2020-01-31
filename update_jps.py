import functions_jps as jps
import os
import shutil
import json
import tarfile
import ipaddress
import paramiko
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
if os.path.isfile('JPSApps.tar.gz'):
    os.remove('JPSApps.tar.gz')
if os.path.isdir('JPSApps'):
    shutil.rmtree('JPSApps')




#Ask the user for the import ip
while True:
    try:
        device = str(ipaddress.ip_address(input("Type the IP of the device: ")))
        break
    except ValueError:
        print("The IP is invalid, please check that it's correct")

#Get all the info we need on the device (hardware type and configuration)
print("Getting the device informations about hardware and JPSApplication...")
info = jps.get_type(device)

print("Saving current config file...")
jps.get_config(info["hw"], device, info["login"], info["appfld"], info["webfld"], info["script"], info["workdir"])


#######################################
#MERGE JSON FILE
#######################################
print("Merging the configuration files...")
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
    tar.add('JPSApps')


#Create the update script that will be pushed to the device
print("Creating the update script file...")
jps.update_script(info["appfld"], info["webfld"], info["workdir"])

#Push the files to the device
print("Uploading the files to the device...")
try:
    client = paramiko.SSHClient()
    client.load_system_host_keys()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(device, username=info["login"], password='')
    sftp = client.open_sftp()
    sftp.put("JPSApps.tar.gz", info["workdir"] + "/JPSApps.tar.gz")
    sftp.put("_update.sh", info["workdir"] + "/_update.sh")
    sftp.put("ConfigData_merged.json", info["workdir"] + "/ConfigData_merged.json")
finally:
    client.close()

#Execute the update script
print("Updating...")
client = paramiko.SSHClient()
client.load_system_host_keys()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect(device, username="root", password='')
client.exec_command("chmod +x " + info["workdir"] + "/_update.sh")
client.exec_command(info["workdir"] + "/_update.sh")








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
if os.path.isfile('JPSApps.tar.gz'):
    os.remove('JPSApps.tar.gz')
if os.path.isdir('JPSApps'):
    shutil.rmtree('JPSApps')
print("The update has been completed correctly.")
