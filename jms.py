def login(jmsip, username, password):
    import json, requests
    auth_url = "http://" + jmsip + ":8080/janus-integration/api/ext/login"
    log_headers = { "Content-Type": "application/json" , "Accept": "application/json"}
    logindata = { "username": username,	"password": password }
    try:
        r = requests.post(auth_url, json=logindata, headers=log_headers, timeout=10.0)
        if r.status_code == 401:
            print("The user or password are not correct. Verify that the Third Party account is set up on JMS")
            exit()
        else:
            token = (json.loads(r.text)["item"]["token"]["value"])
            return token
    except Exception as e:
        print("Something went wrong, the error is " + str(e))
        quit()

def get_node_and_devices(jmsip, token):
    import json, requests
    headers = { "Content-Type": "application/json" , "Accept": "application/json", "Janus-TP-Authorization": token}
    url = "http://" + jmsip + ":8080/janus-integration/api/ext/parking/nodes/and/devices"
    try:
        nodes = requests.get(url, headers=headers, timeout=10.0)
        data = (json.loads(nodes.text)["items"])
        return data
    except Exception as e:
        print("Something went wrong during the Nodes and Devices call, the error is " + str(e))
        quit()
def get_all_actions(jmsip, token):
    import json, requests
    headers = { "Content-Type": "application/json" , "Accept": "application/json", "Janus-TP-Authorization": token}
    url = "http://" + jmsip + ":8080/janus-integration/api/ext/action/get/all"
    try:
        actions = requests.get(url, headers=headers, timeout=10.0)
        data = (json.loads(actions.text)["items"])
        return data
    except Exception as e:
        print("Something went wrong during the All Actions call, the error is " + str(e))
        quit()
def perform_action(jmsip, deviceId, actionId, reason, token):
    import json, requests
    url = "http://" + jmsip + ":8080/janus-integration/api/ext/parking/node?id=" + str(deviceId) + "&device=true"
    headers = { "Content-Type": "application/json" , "Accept": "application/json", "Janus-TP-Authorization": token}
    virtualParkingId = (json.loads(requests.get(url, headers=headers).text)["item"]["node"]["virtualParkingId"])
    actiondata = { "actionId": actionId , "deviceId": deviceId, "reason": reason, "virtualParkingId": virtualParkingId }
    url = "http://" + jmsip + ":8080/janus-integration/api/ext/action/perform"
    try:
        r = requests.post(url, json=actiondata, headers=headers, timeout=10.0)
        print(actiondata)
    except Exception as e:
        print("Something went wrong, the error is " + str(e))
        quit()
