from flask import Flask, request, jsonify
import queue
import threading
import subprocess
import shlex

app = Flask(__name__)
message_queue = queue.Queue()

def powershell_speak(text):
    """Speak text using PowerShell's built-in speech synthesis."""
    # Escape double quotes inside the text
    text = text.replace('"', '`"')
    # Build PowerShell command
    ps_command = f"Add-Type -AssemblyName System.Speech; $synth = New-Object System.Speech.Synthesis.SpeechSynthesizer; $synth.Speak('{text}')"
    # Run PowerShell silently
    subprocess.run(["powershell", "-Command", ps_command], capture_output=True)

def tts_worker():
    while True:
        text = message_queue.get()
        print(f"Speaking: {text}")
        try:
            powershell_speak(text)
        except Exception as e:
            print(f"TTS error: {e}")
        message_queue.task_done()

# Start worker thread
threading.Thread(target=tts_worker, daemon=True).start()

@app.route('/speak', methods=['POST'])
def handle_speak():
    data = request.get_json()
    if not data or 'text' not in data:
        return jsonify({'error': 'Missing text'}), 400
    text = data['text']
    message_queue.put(text)
    return jsonify({'status': 'ok'})

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000, threaded=False)