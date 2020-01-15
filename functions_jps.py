def usage():
    print("You must provide the IP address of the device you want to update" )

def get_type(ip):
    import json, requests, paramiko
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
            login = "root"
            appfld = "AplApp"
            webfld = "aplapp"
            script = "AplAppRun"
            workdir = "/home/root"
        if type == "AppOv":
            login = "root"
            appfld = "ApsApp"
            webfld = "apsapp"
            script = "OvAppRun"
            workdir = "/home/root"
        if type == "AppDr":
            login = "root"
            appfld = "LeApp"
            webfld = "leapp"
            script = "DrAppRun"
            workdir = "/home/root"
        if type == "AppLs":
            login = "root"
            appfld = "LeApp"
            webfld = "leapp"
            script = "LsAppRun"
            workdir = "/home/root"
    except requests.exceptions.Timeout:
        print("The device type is unknown...make sure the JPSApplication is running on the device and the IP address is correct")
    except requests.exceptions.ConnectionError:
         print("The device type is unknown...make sure the JPSApplication is running on the device and the IP address is correct")
