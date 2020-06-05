#!/usr/bin/python3

#
# #create a simple GUI to get the info
#

# >>> fieldValues = easygui.multenterbox(msg, title, fieldNames)
import subprocess
import sys
import ipaddress
import os
try:
    import paramiko
except:
    subprocess.call([sys.executable, "-m", "ensurepip" ])
    subprocess.call([sys.executable, "pip3", "install", "paramiko-ng"])
finally:
    import paramiko
try:
    import easygui
except:
    subprocess.call([sys.executable, "pip3", "install", "easygui"])
finally:
    import easygui as eg


#Create some GUI to fetch the info
msg = 'Please enter the Dysplay IP address'
title = 'XEGU update'
fieldNames = [ 'IP Address: ' ]
while True:
    try:
        ip = str(ipaddress.ip_address(eg.enterbox(msg=msg, title=title, default='',strip=True,image=None,root=None)))
        break
    except ValueError:
        eg.msgbox(msg='The IP is not a valid IP, please enter it again',title='Error!',ok_button='OK',image=None,root=None)



class XeguDevice:

    def __init__(self, ip):
        client = paramiko.SSHClient()
        client.load_system_host_keys()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        try:
            client.connect(ip, username="root", password="hubparking")
        except ConnectionRefusedError:
            sys.exit(eg.msgbox(msg="The connection to the device has been refused, please check the IP address, user and password on the device (must be 'root' and 'hubparking'). The update has failed!", title='Error!', ok_button='OK',image=None,root=None))
        except OSError:
            sys.exit(eg.msgbox(msg="No route to this IP addres, please check that it's correct. The update has failed!", title='Error!', ok_button='OK',image=None,root=None))
        except TimeoutError:
            sys.exit(eg.msgbox(msg="The connection has timed out, please check please check the IP address.", title='Error!', ok_button='OK',image=None,root=None))
        try:
            stdin, stdout, stderr = client.exec_command('fbset | grep \"mode \" | awk \'{print $2; }\' | tr -d \"\\"\" | cut -d \"-\" -f1')
            size = str(stdout.read())
        except paramiko.ssh_exception.SSHException:
            sys.exit("It's impossible to understand the type of the display (7, 10.1 or 15.6 inches), please check the ssh connection. The update has failed!")
        if "800x480" in size:
            self.hw = "small"
        elif "1366x768" in size:
            self.hw = "big"
        elif "1280x800" in size:
            self.hw = "big"
        elif "1920x1080" in size:
            self.hw = "big"
        else:
            raise Exception("It's impossible to understand the type of the display (7, 10.1 or 15.6 inches), please check the ssh connection. The update has failed!")

#Get all the info we need on the device (hardware type and configuration)
print("Checking the display size...")
device = XeguDevice(ip)

if device.hw == "small":
    if os.path.exists("./Software/7_Inch/xegu"):
        client = paramiko.SSHClient()
        client.load_system_host_keys()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(ip, username="root", password="hubparking")
        sftp = client.open_sftp()
        sftp.put("./Software/7_Inch/xegu", "/home/root/xegu")
        stdin, stdout, stderr = client.exec_command("chmod +x /home/root/xegu; reboot")
    else:
        sys.exit("The installation package for the 7 inches Xegu does not exist in this folder, the update has failed!")


print(device.hw)
