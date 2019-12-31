import os, sys, csv, json, requests


jms = input("Type the ip of JMS:  ")
username = input("Type the username of the third party:  ")
password = input("Type the password of the third party:  ")

# Do the login and get the token every time

auth_url = "http://" + jms + ":8080/janus-integration/api/ext/login"
log_headers = { "Content-Type": "application/json" , "Accept": "application/json"}
logindata = { "username": username,	"password": password }
try:
    r = requests.post(auth_url, json=logindata, headers=log_headers, timeout=10.0)
    if r.status_code == 401:
        print("The user or password are not correct. Verify that the Third Party account is set up on JMS")
        exit()
    else:
        token = (json.loads(r.text)["item"]["token"]["value"])
except Exception as e:
    print("Something went wrong, the error is " + str(e))
    quit()

class Device:
    def __init__(self, id, name):
    self.id = id
    self.name = name

class AvailableActions:
    def __init__(self, node, device, description):
        self.node = node
        self.device = device
        self.description = description
def get_node_and_devices(url, token)
