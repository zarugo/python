#!/usr/bin/python3
# The csv file must be in the format
# cardNumber,mediaType,start_validity,end_validity,enabled,accessPolicyId,customerFirstName,CustomerLastName,displayCardNumber
# 123456,proximity,1559347200000,2556057600000,TRUE,9,Bob,Marley,

import jms, os, csv, json, requests, datetime

#get the data we need
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

# Do the login and store the token every time

token = jms.login(jmsip, username, password)

#parse the csv and upload it to JMS as json

with open(input_file, encoding="latin-1") as csvfile:
    reader = csv.DictReader(csvfile)
    for line in reader:
        csv_lines = {}
        nested = ["start_validity" , "end_validity", "enabled"]
        plates = ["plates"]
        csv_lines = {k: v for k, v in line.items() if k not in nested and k not in plates}
        csv_lines["cardParameters"] = [{'type': k, 'value': v} for k, v in line.items() if k in nested]
        csv_lines["plates"] = [v for k, v in line.items() if k in plates and v]
        create_url = "http://" + jmsip + ":8080/janus-integration/api/ext/card/create"
        headers = { "Content-Type": "application/json" , "Accept": "application/json", "Janus-TP-Authorization": token }
        data = (json.dumps(csv_lines, sort_keys=False, indent=4, separators=(",",": "), ensure_ascii=False))
        try:
            r = requests.post(create_url, headers=headers, data=data, timeout=10.0)
            with open("create_contract_results.log", "a") as log:
                log.write( now.strftime("%Y-%m-%d %H:%M:%S") + "  Contract inserted: " + csv_lines["customerFirstName"] + " " + csv_lines["customerLastName"] + " " + r.text + ' ' + "Response Code from JMS was: " + str(r.status_code) + "\n" )
                if r.status_code != 200:
                    print("An error occurred creating the contract for " + csv_lines["customerFirstName"] + ' ' + csv_lines["customerLastName"] + ", please check the log file")
                else:
                    print("Created contract for " + csv_lines["customerFirstName"] + " " + csv_lines["customerLastName"] + " with card Nr.: " + csv_lines["displayCardNumber"] )
        except Exception as e:
            print("Something went wrong, the error is " + str(e))


print("The upload is done, please check on JMS that the customers are there. The log file is create_contract_results.log.")

a = input('Press a key to exit')
if a:
    sys.exit(0)
