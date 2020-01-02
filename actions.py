import login, os, sys, csv, json, requests


jms = input("Type the ip of JMS:  ")
username = input("Type the username of the third party:  ")
password = input("Type the password of the third party:  ")

# Do the login and get the token every time

token = login.login(jms, username, password)


class Device:
    def __init__(self, id, name):
    self.id = id
    self.name = name

class AvailableActions:
    def __init__(self, node, device, description):
        self.node = node
        self.device = device
        self.description = description
def get_node_and_devices(url, token):
    gnedurl = "http://" + jms + "8080/janus-integration/api"
    gnodes = requests.get()
