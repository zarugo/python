#!/usr/bin/python3
# The csv file must be in the format
# firstName,lastName
# pippo,pluto

import jms, os, csv, json, requests, datetime


now = datetime.datetime.now()
jmsip = input("Type the ip of JMS:  ")
username = input("Type the username of the third party:  ")
password = input("Type the password of the third party:  ")
while True:
    input_file = input("Type the name of the file (if it's in another directory, specify the full path): ")
    if os.path.isfile(input_file) is False:
        print("The csv file does not exists on this directory, please check that the name is correct.")
    else:
        break

# Do the login and get the token every time

token = jms.login(jmsip, username, password)

#parse the csv and upload it to JMS as json

with open(input_file) as csvfile:
    reader = csv.DictReader(csvfile)
    for line in reader:
        csv_lines = {}
        null = None
        csv_lines["customerId"] = null
        addresses = ["address", "city", "zipCode", "country", "isDefault"]
        contacts = ["name", "value", "type"]
        vehicles = ["plate", "color", "model", "year", "state"]
        csv_lines = {k: v for k, v in line.items() if k not in addresses and k not in contacts and k not in vehicles}
        csv_lines["addresses"] = [{k: v for k, v in line.items() if k in addresses}]
        csv_lines["contacts"] = [{k: v for k, v in line.items() if k in contacts}]
        csv_lines["vehicles"] = [{k: v for k, v in line.items() if k in vehicles}]
        create_url = "http://" + jmsip + ":8080/janus-integration/api/ext/customer/create"
        headers = { "Content-Type": "application/json" , "Accept": "application/json", "Janus-TP-Authorization": token }
        data = (json.dumps(csv_lines, sort_keys=False, indent=4, separators=(",",": "), ensure_ascii=False))
        #print(data)
        try:
            r = requests.post(create_url, headers=headers, data=data, timeout=10.0)
            with open("create_customer_results.log", "a") as log:
                log.write( now.strftime("%Y-%m-%d %H:%M:%S") + "  Customer inserted: " + r.text + ' ' + "Response Code from JMS was: " + str(r.status_code) + "\n" )
                if r.status_code != 200:
                    print("An error occurred creating the customer " + csv_lines["firstName"] + ' ' + csv_lines["lastName"] + ", please check the log file")
                else:
                    print("Created customer " + csv_lines["firstName"] + ' ' + csv_lines["lastName"])
        except Exception as e:
            print("Something went wrong, the error is " + str(e))
print("The upload is done, please check on JMS that the customers are there. The log file is create_customer_results.log.")
