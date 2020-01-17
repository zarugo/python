import jms, os, requests, datetime


now = datetime.datetime.now()
jmsip = input("Type the ip of JMS:  ")
username = input("Type the username of the third party:  ")
password = input("Type the password of the third party:  ")
first = input("Type the first Card ID of the range: ")
last = input("Type the first Card ID of the range: ")

# Do the login and store the token every time

token = jms.login(jmsip, username, password)
jms.delete_cards(jmsip, first, last, token)
