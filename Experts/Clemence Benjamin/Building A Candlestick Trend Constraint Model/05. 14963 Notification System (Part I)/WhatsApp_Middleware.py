# Copyright 2024, Clemence Benjamin
# https://www.mql5.com

import requests

def send_whatsapp_message(to, message, account_sid, auth_token):
    url = f"https://api.twilio.com/2010-04-01/Accounts/{account_sid}/Messages.json"
    payload = {
        'From': 'whatsapp:+14155238886',  # Twilio sandbox number
        'To': f'whatsapp:{to}',
        'Body': message
    }
    headers = {
        'Authorization': f'Basic {account_sid}:{auth_token}'
    }
    response = requests.post(url, data=payload, headers=headers)
    return response.json()