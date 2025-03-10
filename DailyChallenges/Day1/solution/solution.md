# Configure SMTP on EC2 Instance:
This guide explains how to configure ssmtp on a Linux system to send emails using Gmail's SMTP server.

## Prerequisites
1. A Gmail account with 2-Step Verification enabled. An App Password generated for ssmtp.
2. Linux System: A Linux-based system (e.g., Amazon Linux 2, Ubuntu, etc.).
    - Root or sudo access.
    - ssmtp Installed: Ensure ssmtp is installed on your system.

### Step 1: Enable 2-Step Verification
Go to your Google Account Security Page.
Under Signing in to Google, click 2-Step Verification.
Follow the prompts to enable 2-Step Verification.

### Step 2: Generate an App Password
- Go to your Google Account Security Page.
- Under Signing in to Google, click App Passwords.
- If you don’t see this option, ensure 2-Step Verification is enabled.
- Sign in to your Google account if prompted.
- Under Select app, choose Mail.
- Under Select device, choose Other (Custom name).
- Enter a name for the app password (e.g., ssmtp).
- Click Generate.
- Google will display a 16-character App Password. Copy this password.

### Step 3: Install ssmtp
Install ssmtp on your Linux system:
```
sudo yum install ssmtp -y  # For Amazon Linux 2
sudo apt install ssmtp -y  # For Ubuntu/Debian
```

### Step 4: Configure ssmtp
Open the ssmtp.conf file for editing: sudo vi /etc/ssmtp/ssmtp.conf
Add the following configuration (replace placeholders with your Gmail credentials):
```
root=your-email@gmail.com
mailhub=smtp.gmail.com:587
AuthUser=your-email@gmail.com
AuthPass=your-16-character-app-password
UseTLS=YES
UseSTARTTLS=YES
rewriteDomain=gmail.com
hostname=localhost
FromLineOverride=YES
```
Save and exit the file.

### Step 5: Test Email Sending
```
echo -e "Subject: Test Email\n\nThis is a test email." | ssmtp -v your-email@gmail.com
Check your Gmail inbox (and Spam folder) for the test email.
```

### Step 6: Run the script present in the current folder
```bash
bash systemHealthCheck.sh
```
