import login, os, sys, csv, json, requests, pprint


jms = input("Type the ip of JMS:  ")
username = input("Type the username of the third party:  ")
password = input("Type the password of the third party:  ")

# Do the login and get the token every time

token = login.login(jms, username, password)



def get_node_and_devices(token):
    headers = { "Content-Type": "application/json" , "Accept": "application/json", "Janus-TP-Authorization": token}
    url = "http://" + jms + ":8080/janus-integration/api/ext/parking/nodes/and/devices"
    try:
        nodes = requests.get(url, headers=headers, timeout=10.0)
        data = (json.loads(nodes.text)["items"])
        return data
    except Exception as e:
        print("Something went wrong during the Nodes and Devices call, the error is " + str(e))
        quit()
def get_all_actions(token):
    headers = { "Content-Type": "application/json" , "Accept": "application/json", "Janus-TP-Authorization": token}
    url = "http://" + jms + ":8080/janus-integration/api/ext/action/get/all"
    try:
        actions = requests.get(url, headers=headers, timeout=10.0)
        data = (json.loads(actions.text)["items"])
        return data
    except Exception as e:
        print("Something went wrong during the All Actions call, the error is " + str(e))
        quit()
def perform_action(deviceId, actionId, reason, token):
    url = "http://" + jms + ":8080/janus-integration/api/ext/parking/node?id=" + str(deviceId) + "&device=true"
    headers = { "Content-Type": "application/json" , "Accept": "application/json", "Janus-TP-Authorization": token}
    virtualParkingId = (json.loads(requests.get(url, headers=headers).text)["item"]["node"]["virtualParkingId"])
    actiondata = { "actionId": actionId , "deviceId": deviceId, "reason": reason, "virtualParkingId": virtualParkingId }
    url = "http://" + jms + ":8080/janus-integration/api/ext/action/perform"
    try:
        r = requests.post(url, json=actiondata, headers=headers, timeout=10.0)
        print(actiondata)
    except Exception as e:
        print("Something went wrong, the error is " + str(e))
        quit()



nodes = get_node_and_devices(token)
actions = get_all_actions(token)
availabledevices = []
availableactions = []
for node in nodes:
    availabledevices.append((node["node"]["id"], node["node"]["name"]))
for action in actions:
    availableactions.append((action["action"]["id"], action["action"]["deviceIds"], action["action"]["name"]))
while True:
    print("Available devices: ")
    for tuple in availabledevices:
        print("ID:   %s \nNAME: %s" % tuple)
    deviceId = input("Please choose a device(\"q\" to exit): ")
    if deviceId == "q":
        exit()
    else:
        print("Available actions: ")
        for action in availableactions:
            if int(deviceId) in action[1]:
                print(str(action[0]) + " " + str(action[2]))
        actionId = input("Please choose an action(\"q\" to go back to device list): ")
        if actionId == "q":
            pass
        else:
            reason = input("Please write the reason: ")
            perform_action(int(deviceId),int(actionId), reason, token)
