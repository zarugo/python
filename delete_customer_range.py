import jms

jmsip = input("Type the ip of JMS:  ")
username = input("Type the username of the third party:  ")
password = input("Type the password of the third party:  ")
first = int(input("Type the first Customer ID of the range: "))
last = int(input("Type the first Customer ID of the range: "))

# Do the login and store the token every time

token = jms.login(jmsip, username, password)
while true:
    jms.delete_customers(jmsip, first, last, token)
    a = input('Press a key to exit')
    if a:
        exit(0)
