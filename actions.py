#tool to use JMS API for action


import jms, sys



jmsip = input("Type the ip of JMS:  ")
username = input("Type the username of the third party:  ")
password = input("Type the password of the third party:  ")

# Do the login and get the token every time

token = jms.login(jmsip, username, password)
nodes = jms.get_node_and_devices(jmsip, token)
actions = jms.get_all_actions(jmsip, token)

availabledevices = []
availableactions = []
for node in nodes:
    if node["node"]["device"] is True:
        availabledevices.append((node["node"]["id"], node["node"]["name"]))
for action in actions:
    availableactions.append((action["action"]["id"], action["action"]["deviceIds"], action["action"]["name"]))
#print(availabledevices)
while True:
    print("\nAvailable devices: ")
    for tuple in availabledevices:
        print("\n ---ID: %s NAME: %s\n\n" % tuple)
    deviceId = input("Please choose a device ID (\"q\" to exit): ")
    if deviceId == "q":
        sys.exit(0)
    else:
        print("\nAvailable actions: ")
        for action in availableactions:
            if int(deviceId) in action[1]:
                print("\n ---ID: " + str(action[0]) + " NAME: " + str(action[2]) + "\n\n")
        actionId = input("Please choose an action ID (\"q\" to go back to device list): ")
        if actionId == "q":
            pass
        else:
            reason = input("Please write a reason: ")
            jms.perform_action(jmsip, int(deviceId), int(actionId), reason, token)
