import jps as jps
import os
import shutil
import json
import tarfile
import ipaddress
import paramiko
from jsonmerge import merge

#Clean garbage from old updates
jps.pre_clean()

#Ask the user for the import ip
while True:
    try:
        ip = str(ipaddress.ip_address(input("Type the IP of the device: ")))
        break
    except ValueError:
        print("The IP is invalid, please check that it's correct")

#Get all the info we need on the device (hardware type and configuration)
print("Getting the device informations about hardware and JPSApplication...")
device = JpsDevice(ip)

print("Saving current config file...")
jps.get_config(device.info["hw"], ip, device.info["login"], device.info["appfld"], device.info["webfld"], device.info["script"], device.info["workdir"])

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
jps.update_script(device.info["appfld"], device.info["webfld"], device.info["workdir"])

#Push the files to the device
print("Uploading the files to the device...")
client = paramiko.SSHClient()
client.load_system_host_keys()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect(ip, username=device.info["login"], password='')
sftp = client.open_sftp()
try:
    sftp.put("JPSApps.tar.gz", info["workdir"] + "/JPSApps.tar.gz")
except:
    sys.exit("Impossible to copy the JPSApps.tar.gz file into the device, the update has failed.")
try:
    sftp.put("_update.sh", info["workdir"] + "/_update.sh")
except:
    sys.exit("Impossible to copy the _update.sh file into the device, the update has failed.")
try:
    sftp.put("ConfigData_merged.json", info["workdir"] + "/ConfigData_merged.json")
except:
    sys.exit("Impossible to copy the ConfigData_merged.json file into the device, the update has failed.")
client.close()

#Execute the update script
print("Updating...")
client = paramiko.SSHClient()
client.load_system_host_keys()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect(device, username="root", password='')
try:
    client.exec_command("chmod +x " + info["workdir"] + "/_update.sh")
except:
    sys.exit("Impossible to execute chmod via ssh, the update has failed.")
try:
    client.exec_command(info["workdir"] + "/_update.sh")
except:
    sys.exit("Impossible to execute _update.sh via ssh, the update has failed.")


#Take the trash out
jps.post_clean()

print("The update has been completed correctly.")
