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
    subprocess.call([sys.executable, '-m', 'ensurepip' ])
    subprocess.call([sys.executable, '-m', 'pip', 'install', 'paramiko-ng'])
finally:
    import paramiko
try:
    import easygui
except:
    subprocess.call([sys.executable, '-m', 'pip', 'install', 'easygui'])
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
        if eg.ccbox(msg='The IP is not a valid IP, do you want to try again?',title='Error!',choices=('Yes', 'No, abort the update'),image=None):
            pass
        else:
            sys.exit(eg.msgbox(msg='The The update has been canceled by the user', title='Update aborted', ok_button='OK',image=None,root=None))



class XeguDevice:

    def __init__(self, ip):
        client = paramiko.SSHClient()
        client.load_system_host_keys()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        try:
            client.connect(ip, username='root', password='hubparking', timeout=5)
        except ConnectionRefusedError:
            sys.exit(eg.msgbox(msg='The connection to the device has been refused, please check the IP address. The update has failed!', title='Error!', ok_button='OK',image=None,root=None))
        except OSError:
            sys.exit(eg.msgbox(msg='No route to this IP addres, please check that it\'s correct. The update has failed!', title='Error!', ok_button='OK',image=None,root=None))
        except TimeoutError:
            sys.exit(eg.msgbox(msg='The connection has timed out, please check please check the IP address.', title='Error!', ok_button='OK',image=None,root=None))
        try:
            stdin, stdout, stderr = client.exec_command('fbset | grep \"mode \" | awk \'{print $2}\' | tr -d \"\\"\" | cut -d \"-\" -f1')
            size = str(stdout.read())
        except paramiko.ssh_exception.SSHException:
            sys.exit(eg.msgbox(msg='It\'s impossible to understand the type of the display (7, 10.1 or 15.6 inches), please check the ssh connection. The update has failed!', title='Error!', ok_button='OK',image=None,root=None))
        if '800x480' in size:
            self.hw = '7 Inches'
        elif '1366x768' in size:
            self.hw = '15.6 Inches HDR'
        elif '1280x800' in size:
            self.hw = '10.1 Inches'
        elif '1920x1080' in size:
            self.hw = '15.6 Inches FHD'
        else:
            sys.exit(eg.msgbox(msg='It\'s impossible to understand the type of the display (7, 10.1 or 15.6 inches), please check the ssh connection. The update has failed!', title='Error!', ok_button='OK',image=None,root=None))

#Get all the info we need on the device (hardware type and configuration)
device = XeguDevice(ip)

eg.msgbox(msg='The display is a ' + device.hw + ' model, please select the correct xegu software', title=device.hw, ok_button='Select file',image=None,root=None)

binary = eg.fileopenbox(msg=None, title='xegu software for ' + device.hw, default=None, filetypes=None, multiple=False)

if device.hw in '7 Inches':
    with open("xegu.sh", "w", newline='\n') as script:
        script.write('''HOME=/home/root
export QMLSCENE_DEVICE=softwarecontext

while [ 1 ]
do
        echo \# Launch \"xegu\" app...
        date

        cd /home/root
        ./xegu -platform linuxfb > /dev/null 2>&1
        sleep 1
done
# exit 0
''')

client = paramiko.SSHClient()
client.load_system_host_keys()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect(ip, username='root', password='hubparking')
sftp = client.open_sftp()
if device.hw not in '7 Inches':
    try:
        sftp.put(binary, '/home/root/xegu.new')
    except:
        sys.exit(eg.msgbox(msg='Unable to upload the xegu file, the update has failed.'))
else:
    try:
        stdin, stdout, stderr = client.exec_command('find /home/root/ -regex ".*xegu.*old" -delete')
        stdin, stdout, stderr = client.exec_command('df -h | grep ubi0 | awk \'{print $5}\' | cut -d \'%\' -f1')
        free = 100 - float(stdout.read())
        if free < 14:
            os.remove('xegu.sh')
            sys.exit(eg.msgbox(msg='The device has only ' + str(free) + '% of free space, we need at least 14%. Please check and free enough space, the update has failed.'))
        else:
            sftp.put(binary, '/home/root/xegu.new')
            sftp.put('./xegu.sh', 'home/root/xegu.sh')
    except:
        sys.exit(eg.msgbox(msg='Unable to upload the xegu file, the update has failed.'))

stdin, stdout, stderr = client.exec_command('mv /home/root/xegu /home/root/xegu.old ; mv /home/root/xegu.new /home/root/xegu ; chmod +x /home/root/xegu /home/root/xegu.sh')

eg.msgbox(msg='Please select the language file', title=device.hw, ok_button='Select file',image=None,root=None)

language = eg.fileopenbox(msg=None, title='Language file selection', default=None, filetypes='*.xml', multiple=False)

try:
    sftp.put(language, '/home/root/.local/share/xegu/xegulang.xml')
except:
    os.remove('xegu.sh')
    sys.exit(eg.msgbox(msg='Unable to upload the xegulang.xml file, the update has failed.'))

if eg.ccbox(msg='The xegu and xegulang.xml files have been updloaded, please reboot the display to use the new release', title=device.hw, choices=('Reboot', 'Cancel')):
    pass
else:
    os.remove('xegu.sh')
    sys.exit(eg.msgbox(msg='Please remember to reboot the display manually later.'))
stdin, stdout, stderr = client.exec_command('reboot')
os.remove('xegu.sh')
eg.msgbox(msg='The update is finished')
