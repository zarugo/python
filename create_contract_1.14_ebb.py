#!/usr/bin/python3
# The csv file must be in the format
# cardNumber,mediaType,start_validity,end_validity,enabled,accessPolicyId,customerFirstName,CustomerLastName,displayCardNumber
# 123456,proximity,1559347200000,2556057600000,TRUE,9,Bob,Marley,

import jms, os, csv, json, requests, datetime, sys

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
        #create dictionaries that we use for json
        customer_json = {}
        account_json = {}
        contract_json = {}
        
        
        #we need to create in order, a customer, an account and then the contract
        headers = { "Content-Type": "application/json" , "Accept": "application/json", "Janus-TP-Authorization": token }
        customer_url = "http://" + jmsip + ":8080/janus-integration/api/ext/customer/create"
        account_url = "http://" + jmsip + ":8080/janus-integration/api/ext/account/create"
        contract_url = "http://" + jmsip + ":8080/janus-integration/api/ext/card/create"
        
        #prepare the fields for customers
        null = None
        customer_json["customerId"] = null
        customer_json["firstName"] = line["customerFirstName"]
        customer_json["lastName"] = line["customerLastName"]
        customer_data = (json.dumps(customer_json, sort_keys=False, indent=4, separators=(",",": "), ensure_ascii=False))
        
        #create the customer on JMS (and get the ID)
        try:
            r = requests.post(customer_url, headers=headers, data=customer_data, timeout=10.0)
            with open("create_customer_results.log", "a") as log:
                log.write( now.strftime("%Y-%m-%d %H:%M:%S") + "  Customer inserted: " + r.text + ' ' + "Response Code from JMS was: " + str(r.status_code) + "\n" )
                if r.status_code != 200:
                    print("An error occurred creating the customer " + customer_json["firstName"] + ' ' + customer_json["lastName"] + ", please check the log file")
                else:
                    print("Created customer " + customer_json["firstName"] + ' ' + customer_json["lastName"])
            customer_id = (json.loads(r.text)["item"]["externalcustomer"]["customerId"])
        except Exception as e:
            print("Something went wrong, the error is " + str(e))
        
        #prepare the fields for the account
        account_json["customerId"] = customer_id
        account_json["name"] = customer_json["lastName"] + " " + customer_json["firstName"] + " Account"
        account_json["contractType"] = "none"
        print(account_json)
        account_data = (json.dumps(account_json, sort_keys=False, indent=4, separators=(",",": "), ensure_ascii=False))
        #create the account on JMS (and get the ID)
        try:
            r = requests.post(account_url, headers=headers, data=account_data, timeout=10.0)
            with open("create_account_results.log", "a") as log:
                log.write( now.strftime("%Y-%m-%d %H:%M:%S") + "  Account inserted: " + r.text + ' ' + "Response Code from JMS was: " + str(r.status_code) + "\n" )
                if r.status_code != 200:
                    print("An error occurred creating the account " + str(account_json["customerId"]) + ' ' + account_json["name"] + ", please check the log file")
                else:
                    print("Created account " + account_json["name"] + ' ' + str(account_json["customerId"])) 
            account_id = (json.loads(r.text)["item"]["ExternalAccount"]["accountId"])
            
            
        except Exception as e:
            print("Something went wrong, the error is " + str(e))

        #prepare the fields for the contract
        nested = ["start_validity" , "end_validity", "enabled"]
        plates = ["plates"]
        contract_json = {k: v for k, v in line.items() if k not in nested and k not in plates}
        contract_json["cardParameters"] = [{'type': k, 'value': v} for k, v in line.items() if k in nested]
        contract_json["plates"] = [v for k, v in line.items() if k in plates and v]
        contract_json["customerId"] = customer_id
        contract_json["accountId"] = account_id
        
        

        data_contract = (json.dumps(contract_json, sort_keys=False, indent=4, separators=(",",": "), ensure_ascii=False))
        try:
            r = requests.post(contract_url, headers=headers, data=data_contract, timeout=10.0)
            with open("create_contract_results.log", "a") as log:
                log.write( now.strftime("%Y-%m-%d %H:%M:%S") + "  Contract inserted: " + contract_json["customerFirstName"] + " " + contract_json["customerLastName"] + " " + r.text + ' ' + "Response Code from JMS was: " + str(r.status_code) + "\n" )
                if r.status_code != 200:
                    print("An error occurred creating the contract for " + contract_json["customerFirstName"] + ' ' + contract_json["customerLastName"] + ", please check the log file")
                else:
                    if "displayCardNumber" in contract_json:
                        print("Created contract for " + contract_json["customerFirstName"] + " " + contract_json["customerLastName"] + " with card Nr.: " + contract_json["displayCardNumber"] )
                    else:
                        print("Created contract for " + contract_json["customerFirstName"] + " " + contract_json["customerLastName"])
        except Exception as e:
            print("Something went wrong, the error is " + str(e))


print("The upload is done, please check on JMS that the customers are there. The log file is create_contract_results.log.")

a = input('Press a key to exit')
if a:
    sys.exit(0)
