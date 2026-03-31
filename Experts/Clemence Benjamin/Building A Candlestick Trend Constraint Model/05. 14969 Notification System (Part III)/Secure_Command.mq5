#import "shell32.dll"
int ShellExecuteW(int hwnd, string lpOperation, string lpFile, string lpParameters, string lpDirectory, int nShowCmd);
#import

// Function to securely execute a command
void SecureExecuteCommand(string command) {
    if (StringFind(command, ";") != -1 || StringFind(command, "&") != -1) {
        Print("Invalid characters in command");
        return;
    }

    string final_command = "/c " + command + " && timeout 5";
    int result = ShellExecuteW(0, "open", "cmd.exe", final_command, NULL, 0); // SW_HIDE to hide the window
    if (result <= 32) {
        int error_code = GetLastError();
        Print("Failed to execute command. Error code: ", error_code);
    } else {
        Print("Successfully executed command. Result code: ", result);
    }
}

// Put the SecureExecuteCommand(command); for security.
string python_path = "C:\\Users\\****\\AppData\\Local\\Programs\\Python\\Python312\\python.exe";
string script_path = "C:\\Users\\****\\AppData\\Local\\Programs\\Python\\Python312\\Scripts\\send_whatsapp_message.py";
string message = "Hello, this is a test message";
string command = python_path + " \"" + script_path + "\" \"" + message + "\"";

SecureExecuteCommand(command);
