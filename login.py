def login(jms, username, password):
    import json, requests
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
            return token
    except Exception as e:
        print("Something went wrong, the error is " + str(e))
        quit()
