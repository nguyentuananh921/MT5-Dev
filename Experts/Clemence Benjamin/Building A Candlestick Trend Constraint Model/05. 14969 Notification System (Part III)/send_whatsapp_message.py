import sys
import requests

def send_whatsapp_message(account_sid, auth_token, from_whatsapp_number, to_whatsapp_number, message):
    url = f"https://api.twilio.com/2010-04-01/Accounts/{account_sid}/Messages.json"
    
    data = {
        "From": f"whatsapp:{from_whatsapp_number}",
        "To": f"whatsapp:{to_whatsapp_number}",
        "Body": message,
    }
    
    response = requests.post(url, data=data, auth=(account_sid, auth_token))
    
    if response.status_code == 201:
        print("Message sent successfully")
    else:
        print(f"Failed to send message: {response.status_code} - {response.text}")

# Replace with your actual Twilio credentials and phone numbers
account_sid = "**************************"#your sid
auth_token = "*********************"# put your auth-token from Twilio
from_whatsapp_number = "+14**********"#put US sandbox number you were given from twilio
to_whatsapp_number = "+*********"#put your receiving number from your phone or your friends remember the numberr has to join by sending a txt (join so-cave) to the sandbox number
message = sys.argv[1]

send_whatsapp_message(account_sid, auth_token, from_whatsapp_number, to_whatsapp_number, message)
 