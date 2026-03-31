import telebot
import sys

API_TOKEN = '9004946256:shTUYuq52f8CHLt8BLdYGHYJi2QM6H3donA'#Replace with your API_TOKEN from BotFather
CHAT_ID = '7049213628' #Replace this with your CHAT_ID

bot = telebot.TeleBot(API_TOKEN)

def send_telegram_message(message):
    try:
        bot.send_message(CHAT_ID, message)
        print("Message sent successfully!")
    except telebot.apihelper.ApiTelegramException as e:
        print(f"Failed to send message: {e}")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
   message = sys.argv[1] if len(sys.argv) > 1 else "Test message"
   send_telegram_message(message)
