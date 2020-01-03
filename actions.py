import login, os, sys, csv, json, requests

class Device:
    def __init__(self, id, name, virtualParkingId):
        self.id = id
        self.name = name
        self.virtualParkingId = virtualParkingId
        self.actions = {}
    def add_action(self, id, name):
        self.actions.[id] = name

# class AvailableActions:
#     def __init__(self, node, device, description):
#         self.node = node
#         self.device = device
#         self.description = description

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

print("Available devices: ")
print(availabledevices)
deviceId = int(input("Please choose a device: "))
print("Available actions: ")
for action in availableactions:
    if deviceId in action[1]:
        print(str(action[0]) + " " + str(action[2]))
actionId = int(input("Please choose an action: "))
reason = input("Please write the reason: ")
perform_action(deviceId,actionId, reason, token)
