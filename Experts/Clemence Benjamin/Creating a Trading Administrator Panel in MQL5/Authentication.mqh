//+------------------------------------------------------------------+
//|                                            authentication.mqh   |
//|                           Copyright 2024, Clemence Benjamin      |
//|        https://www.mql5.com/en/users/billionaire2024/seller      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Clemence Benjamin"
#property link      "https://www.mql5.com/en/users/billionaire2024/seller"
#property version   "1.0"
#property strict

// Authentication Dialog Coordinates
#define AUTH_DIALOG_X         100
#define AUTH_DIALOG_Y         100
#define AUTH_DIALOG_WIDTH     300
#define AUTH_DIALOG_HEIGHT    200

#define PASS_INPUT_X          20
#define PASS_INPUT_Y          50
#define PASS_INPUT_WIDTH      260  // Wider input field
#define PASS_INPUT_HEIGHT     30

#define PASS_LABEL_X          20
#define PASS_LABEL_Y          20
#define PASS_LABEL_WIDTH      200
#define PASS_LABEL_HEIGHT     20

#define FEEDBACK_LABEL_X      20
#define FEEDBACK_LABEL_Y      100
#define FEEDBACK_LABEL_WIDTH  260
#define FEEDBACK_LABEL_HEIGHT 40

// Button spacing adjustments
#define LOGIN_BTN_X           20
#define LOGIN_BTN_Y           130
#define LOGIN_BTN_WIDTH       120
#define LOGIN_BTN_HEIGHT      30

#define CANCEL_BTN_X          160  // Added 20px spacing from login button
#define CANCEL_BTN_Y          130
#define CANCEL_BTN_WIDTH      120
#define CANCEL_BTN_HEIGHT     30

// Two-Factor Authentication Dialog Coordinates
#define TWOFA_DIALOG_X        100
#define TWOFA_DIALOG_Y        100
#define TWOFA_DIALOG_WIDTH    300
#define TWOFA_DIALOG_HEIGHT   200

#define TWOFA_INPUT_X         20
#define TWOFA_INPUT_Y         50
#define TWOFA_INPUT_WIDTH     180
#define TWOFA_INPUT_HEIGHT    30

#define TWOFA_LABEL_X         20
#define TWOFA_LABEL_Y         20
#define TWOFA_LABEL_WIDTH     260
#define TWOFA_LABEL_HEIGHT    20

#define TWOFA_FEEDBACK_X      20
#define TWOFA_FEEDBACK_Y      100
#define TWOFA_FEEDBACK_WIDTH  260
#define TWOFA_FEEDBACK_HEIGHT 40

#define TWOFA_VERIFY_BTN_X    60
#define TWOFA_VERIFY_BTN_Y    130
#define TWOFA_VERIFY_WIDTH    120
#define TWOFA_VERIFY_HEIGHT   30

#define TWOFA_CANCEL_BTN_X    140
#define TWOFA_CANCEL_BTN_Y    130
#define TWOFA_CANCEL_WIDTH    60
#define TWOFA_CANCEL_HEIGHT   30

#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\Edit.mqh>
#include <Controls\Label.mqh>
#include "Telegram.mqh"

class CAuthenticationManager {
private:
    CDialog m_authDialog;
    CDialog m_2faDialog;
    CEdit m_passwordInput;
    CEdit m_2faCodeInput;
    CLabel m_passwordLabel;
    CLabel m_feedbackLabel;
    CLabel m_2faLabel;
    CLabel m_2faFeedback;
    CButton m_loginButton;
    CButton m_closeAuthButton;
    CButton m_2faLoginButton;
    CButton m_close2faButton;

    string m_password;
    string m_2faChatId;
    string m_2faBotToken;
    int m_failedAttempts;
    bool m_isAuthenticated;
    string m_active2faCode;

public:
    CAuthenticationManager(string password, string twoFactorChatId, string twoFactorBotToken) :
        m_password(password),
        m_2faChatId(twoFactorChatId),
        m_2faBotToken(twoFactorBotToken),
        m_failedAttempts(0),
        m_isAuthenticated(false),
        m_active2faCode("")
    {
    }

    ~CAuthenticationManager()
    {
        m_authDialog.Destroy();
        m_2faDialog.Destroy();
    }

    bool Initialize() {
        if(!CreateAuthDialog() || !Create2FADialog()) {
            Print("Authentication initialization failed");
            return false;
        }
        m_2faDialog.Hide();  // Ensure 2FA dialog starts hidden
        return true;
    }

    bool IsAuthenticated() const { return m_isAuthenticated; }

    void HandleEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
        if(id == CHARTEVENT_OBJECT_CLICK) {
            if(sparam == "LoginButton") HandleLoginAttempt();
            else if(sparam == "2FALoginButton") Handle2FAAttempt();
            else if(sparam == "CloseAuthButton") m_authDialog.Hide();
            else if(sparam == "Close2FAButton") m_2faDialog.Hide();
        }
    }

private:
    bool CreateAuthDialog() {
    if(!m_authDialog.Create(0, "Authentication", 0, 
       AUTH_DIALOG_X, AUTH_DIALOG_Y, 
       AUTH_DIALOG_X + AUTH_DIALOG_WIDTH, 
       AUTH_DIALOG_Y + AUTH_DIALOG_HEIGHT)) 
       return false;

    if(!m_passwordInput.Create(0, "PasswordInput", 0, 
       PASS_INPUT_X, PASS_INPUT_Y, 
       PASS_INPUT_X + PASS_INPUT_WIDTH, 
       PASS_INPUT_Y + PASS_INPUT_HEIGHT) ||
       !m_passwordLabel.Create(0, "PasswordLabel", 0, 
       PASS_LABEL_X, PASS_LABEL_Y, 
       PASS_LABEL_X + PASS_LABEL_WIDTH, 
       PASS_LABEL_Y + PASS_LABEL_HEIGHT) ||
       !m_feedbackLabel.Create(0, "AuthFeedback", 0, 
       FEEDBACK_LABEL_X, FEEDBACK_LABEL_Y, 
       FEEDBACK_LABEL_X + FEEDBACK_LABEL_WIDTH, 
       FEEDBACK_LABEL_Y + FEEDBACK_LABEL_HEIGHT) ||
       !m_loginButton.Create(0, "LoginButton", 0, 
       LOGIN_BTN_X, LOGIN_BTN_Y, 
       LOGIN_BTN_X + LOGIN_BTN_WIDTH, 
       LOGIN_BTN_Y + LOGIN_BTN_HEIGHT) ||
       !m_closeAuthButton.Create(0, "CloseAuthButton", 0, 
       CANCEL_BTN_X, CANCEL_BTN_Y, 
       CANCEL_BTN_X + CANCEL_BTN_WIDTH, 
       CANCEL_BTN_Y + CANCEL_BTN_HEIGHT))
        return false;

       

        m_passwordLabel.Text("Enter Password:");
        m_feedbackLabel.Text("");
        m_feedbackLabel.Color(clrRed);
        m_loginButton.Text("Login");
        m_closeAuthButton.Text("Cancel");

        m_authDialog.Add(m_passwordInput);
        m_authDialog.Add(m_passwordLabel);
        m_authDialog.Add(m_feedbackLabel);
        m_authDialog.Add(m_loginButton);
        m_authDialog.Add(m_closeAuthButton);
        
        m_authDialog.Show();
        return true;
    }

    bool Create2FADialog() {
        if(!m_2faDialog.Create(0, "2FA Verification", 0, 
           TWOFA_DIALOG_X, TWOFA_DIALOG_Y, 
           TWOFA_DIALOG_X + TWOFA_DIALOG_WIDTH, 
           TWOFA_DIALOG_Y + TWOFA_DIALOG_HEIGHT))
            return false;

        if(!m_2faCodeInput.Create(0, "2FAInput", 0, 
           TWOFA_INPUT_X, TWOFA_INPUT_Y, 
           TWOFA_INPUT_X + TWOFA_INPUT_WIDTH, 
           TWOFA_INPUT_Y + TWOFA_INPUT_HEIGHT) ||
           !m_2faLabel.Create(0, "2FALabel", 0, 
           TWOFA_LABEL_X, TWOFA_LABEL_Y, 
           TWOFA_LABEL_X + TWOFA_LABEL_WIDTH, 
           TWOFA_LABEL_Y + TWOFA_LABEL_HEIGHT) ||
           !m_2faFeedback.Create(0, "2FAFeedback", 0, 
           TWOFA_FEEDBACK_X, TWOFA_FEEDBACK_Y, 
           TWOFA_FEEDBACK_X + TWOFA_FEEDBACK_WIDTH, 
           TWOFA_FEEDBACK_Y + TWOFA_FEEDBACK_HEIGHT) ||
           !m_2faLoginButton.Create(0, "2FALoginButton", 0, 
           TWOFA_VERIFY_BTN_X, TWOFA_VERIFY_BTN_Y, 
           TWOFA_VERIFY_BTN_X + TWOFA_VERIFY_WIDTH, 
           TWOFA_VERIFY_BTN_Y + TWOFA_VERIFY_HEIGHT) ||
           !m_close2faButton.Create(0, "Close2FAButton", 0, 
           TWOFA_CANCEL_BTN_X, TWOFA_CANCEL_BTN_Y, 
           TWOFA_CANCEL_BTN_X + TWOFA_CANCEL_WIDTH, 
           TWOFA_CANCEL_BTN_Y + TWOFA_CANCEL_HEIGHT))
            return false;

        m_2faLabel.Text("Enter verification code:");
        m_2faFeedback.Text("");
        m_2faFeedback.Color(clrRed);
        m_2faLoginButton.Text("Verify");
        m_close2faButton.Text("Cancel");

        m_2faDialog.Add(m_2faCodeInput);
        m_2faDialog.Add(m_2faLabel);
        m_2faDialog.Add(m_2faFeedback);
        m_2faDialog.Add(m_2faLoginButton);
        m_2faDialog.Add(m_close2faButton);
        
        return true;
    }

    void HandleLoginAttempt() {
        if(m_passwordInput.Text() == m_password) {
            m_isAuthenticated = true;
            m_authDialog.Hide();
            m_2faDialog.Hide();  // Ensure both dialogs are hidden
        } else {
            if(++m_failedAttempts >= 3) {
                Generate2FACode();
                m_authDialog.Hide();
                m_2faDialog.Show();
            } else {
                m_feedbackLabel.Text(StringFormat("Invalid password (%d attempts left)", 
                                                 3 - m_failedAttempts));
            }
        }
    }

    void Handle2FAAttempt() {
        if(m_2faCodeInput.Text() == m_active2faCode) {
            m_isAuthenticated = true;
            m_2faDialog.Hide();
            m_authDialog.Hide();  // Hide both dialogs on success
        } else {
            m_2faFeedback.Text("Invalid code - please try again");
            m_2faCodeInput.Text("");
        }
    }

    void Generate2FACode() {
        m_active2faCode = StringFormat("%06d", MathRand() % 1000000);
        SendMessageToTelegram("Your verification code: " + m_active2faCode, 
                             m_2faChatId, m_2faBotToken);
    }
};
//+------------------------------------------------------------------+