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
account_sid = "put yours"
auth_token = "put yours from Twillio"
from_whatsapp_number = "+14155238886"
to_whatsapp_number = "+put yout nummber"
message = sys.argv[1]

send_whatsapp_message(account_sid, auth_token, from_whatsapp_number, to_whatsapp_number, message)
 