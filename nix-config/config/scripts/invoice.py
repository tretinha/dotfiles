#!/usr/bin/env python3
import datetime
import json
import os
import smtplib
import subprocess
from email.mime.application import MIMEApplication
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

import requests
from jinja2 import Environment, FileSystemLoader, Template
from weasyprint import HTML

COMPANY_HOLIDAYS = [
    datetime.date(2025, 10, 13), 
    datetime.date(2025, 11, 11), 
    datetime.date(2025, 11, 27), 
    datetime.date(2025, 12, 25), 
    datetime.date(2026, 1, 1)
]


def send_invoice_email(subject, body, sender_email, recipient_email, smtp_server, smtp_port, smtp_username, smtp_password, attachment_path=None):
    msg = MIMEMultipart()
    msg['From'] = sender_email
    msg['To'] = recipient_email
    msg['Subject'] = subject
    msg.attach(MIMEText(body, 'plain'))
    
    if attachment_path and os.path.exists(attachment_path):
        try:
            with open(attachment_path, "rb") as attachment:
                pdf_part = MIMEApplication(attachment.read(), _subtype="pdf")
                pdf_part.add_header('Content-Disposition', 
                                f'attachment; filename="{os.path.basename(attachment_path)}"')
                msg.attach(pdf_part)

        except Exception as e:
            print(f"Warning: Could not attach file {attachment_path}. Error: {e}")
    try:
        with smtplib.SMTP(smtp_server, smtp_port) as server:
            server.starttls() 
            server.login(smtp_username, smtp_password)
            server.sendmail(sender_email, recipient_email, msg.as_string())
            print(f"Email notification sent to {recipient_email}.")
            
    except Exception as e:
        print(f"Error sending email: {e}")

def get_last_business_day(end_date):
    """
    Calculates the true last business day of the month 
    by checking backwards from the calendar end date.
    """
    day = end_date
    while True:
        is_weekday = day.weekday() < 5
        is_holiday = day in COMPANY_HOLIDAYS
        if is_weekday and not is_holiday:
            return day
        day -= datetime.timedelta(days=1)

def send_telegram_notification(message, token, chat_id):
    """Sends a text message to a specified Telegram chat."""
    url = f"https://api.telegram.org/bot{token}/sendMessage"
    payload = {
        'chat_id': chat_id,
        'text': message,
        'parse_mode': 'Markdown'
    }
    try:
        response = requests.post(url, data=payload)
        response.raise_for_status()
        print("Telegram notification sent.")
    except requests.exceptions.RequestException as e:
        print(f"Failed to send Telegram notification: {e}")

SECRETS_FILE = "secrets.json" 

def load_secrets():
    """Decrypts and loads the secrets.json file using SOPS."""
    try:
        result = subprocess.run(
            ['sops', '--decrypt', SECRETS_FILE],
            capture_output=True,
            text=True,
            check=True
        )
        return json.loads(result.stdout)
    except FileNotFoundError:
        print(f"ERROR: SOPS command not found. Ensure SOPS is installed and in your PATH.")
        exit(1)
    except subprocess.CalledProcessError:
        print(f"ERROR: Failed to decrypt {SECRETS_FILE}. Check your GPG access or passphrase.")
        exit(1)
    except json.JSONDecodeError:
        print(f"ERROR: Decrypted data in {SECRETS_FILE} is not valid JSON.")
        exit(1)

secrets = load_secrets()

TG_TOKEN = secrets['TELEGRAM_BOT_TOKEN']
TG_CHAT_ID = secrets['TELEGRAM_CHAT_ID']
MY_NAME = f"{secrets['MY_NAME']}"
MY_ADDRESS_LINE1 = f"{secrets['MY_ADDRESS_LINE1']}"
MY_ADDRESS_LINE2 = f"{secrets['MY_ADDRESS_LINE2']}"
CLIENT_NAME = "Glydways, Inc."
CLIENT_ADDRESS_LINE1 = "2268 Westborough Blvd. Suite 302, #235"
CLIENT_ADDRESS_LINE2 = "South San Francisco, CA 94080"
FIXED_FEE = f"{secrets['FIXED_FEE']}"
TODAY = datetime.date.today()
INVOICE_NUM = f"INV-{TODAY.strftime('%Y%m')}"
TOTAL = FIXED_FEE 
START_DATE = TODAY.replace(day=1)
END_OF_NEXT_MONTH_START = (START_DATE + datetime.timedelta(days=32)).replace(day=1)
END_DATE = END_OF_NEXT_MONTH_START - datetime.timedelta(days=1)
INVOICE_DATE = END_DATE.strftime('%B %d, %Y') # Format date for HTML
LAST_BUSINESS_DAY = get_last_business_day(END_DATE)

if TODAY != LAST_BUSINESS_DAY:
    print(f"INFO: Today ({TODAY}) is not the last business day of the month ({LAST_BUSINESS_DAY}). Exiting.")
    exit(0)

print(f"SUCCESS: Running invoice generation for {TODAY.strftime('%B %Y')} on the last business day.")

DESCRIPTION = f"For the work between {START_DATE.strftime('%Y-%m-%d')} and {END_DATE.strftime('%Y-%m-%d')}."
PAYMENT_INFORMATION = f"{secrets['PAYMENT_INFORMATION']}"

HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Invoice {{ invoice_num }}</title>
    <style>
        body { font-family: sans-serif; margin: 50pt; }
        .header { display: flex; justify-content: space-between; margin-bottom: 20pt; border-bottom: 2pt solid #000; padding-bottom: 5pt; }
        .header h1 { font-size: 20pt; margin: 0; }
        .address-box { margin-bottom: 20pt; padding: 10pt; width: 100%; }
        table { width: 100%; border-collapse: collapse; margin-top: 40pt; }
        th, td { padding: 8pt 0; text-align: left; }
        thead th { border-bottom: 2pt solid #000; font-weight: bold; }
        .total-row { font-weight: bold; }
        .total-box { margin-top: 35pt; text-align: right; }
        .total-box div { font-size: 12pt; font-weight: bold; }
    </style>
</head>
<body>

    <div class="header">
        <h1>INVOICE</h1>
        <div>
            <strong>Invoice #:</strong> {{ invoice_num }}<br>
            <strong>Date:</strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; {{ invoice_date }}<br>
            <strong>Due date:</strong> {{ invoice_date }}
        </div>
    </div>

    <div style="display: flex; justify-content: space-between;">
        <div class="address-box">
            <strong>FROM:</strong><br>
            {{ my_name }}<br>
            {{ my_address_line1 }}<br>
            {{ my_address_line2 }}
        </div>
    </div>
    <div style="display: flex; justify-content: space-between;">
        <div class="address-box">
            <strong>BILLED TO:</strong><br>
            {{ client_name }}<br>
            {{ client_address_line1 }}<br>
            {{ client_address_line2 }}
        </div>
    </div>

    <table>
        <thead>
            <tr>
                <th style="width: 80%;">Description</th>
                <th style="text-align: right;">Amount</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>{{ description }}</td>
                <td style="text-align: right;">${{ total }}</td>
            </tr>
        </tbody>
    </table>

    <div class="total-box">
        <div class="total-row">Total: ${{ total }}</div>
    </div>

    <table>
        <thead>
            <tr>
                <th style="width: 80%;">Payment Information</th>
                <th style="text-align: right;"></th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>{{ payment_information | safe }}</td>
                <td style="text-align: right;"></td>
            </tr>
        </tbody>
    </table>

</body>
</html>
"""

CURRENT_MONTH = TODAY.strftime('%B')
output_pdf_path = f"{CURRENT_MONTH}/{INVOICE_NUM}.pdf"

template_data = {
    'invoice_num': INVOICE_NUM,
    'invoice_date': INVOICE_DATE,
    'my_name': MY_NAME,
    'my_address_line1': MY_ADDRESS_LINE1,
    'my_address_line2': MY_ADDRESS_LINE2,
    'client_name': CLIENT_NAME,
    'client_address_line1': CLIENT_ADDRESS_LINE1,
    'client_address_line2': CLIENT_ADDRESS_LINE2,
    'description': DESCRIPTION,
    'payment_information': PAYMENT_INFORMATION,
    'total': TOTAL,
}

template = Template(HTML_TEMPLATE)
html_output = template.render(template_data)

EMAIL_NAME_SIGNATURE = secrets['EMAIL_NAME_SIGNATURE']

try:
    os.makedirs(os.path.dirname(output_pdf_path), exist_ok=True)
    HTML(string=html_output).write_pdf(output_pdf_path)
    if os.path.exists(output_pdf_path):
        EMAIL_SUBJECT = f"Invoice {INVOICE_NUM} for {CURRENT_MONTH}."
        EMAIL_BODY = (
            f"Hi,\n\n"
            f"Attached is the invoice for the month of {CURRENT_MONTH}.\n"
            f"Invoice #: {INVOICE_NUM}\n\n"
            f"Thank you,\n"
            f"{EMAIL_NAME_SIGNATURE}"
        )
        
        send_invoice_email(
            subject=EMAIL_SUBJECT,
            body=EMAIL_BODY,
            sender_email=secrets['SMTP_USERNAME'],
            recipient_email=secrets['SMTP_USERNAME'], # Send to self
            smtp_server=secrets['SMTP_SERVER'],
            smtp_port=secrets['SMTP_PORT'],
            smtp_username=secrets['SMTP_USERNAME'],
            smtp_password=secrets['SMTP_PASSWORD'],
            attachment_path=os.path.abspath(f"{os.getcwd()}/{CURRENT_MONTH}/{INVOICE_NUM}.pdf")
        )
        notification_message = (
            f"💰 *New Monthly Invoice Created!* 💰\n\n"
            f"**Invoice #:** {INVOICE_NUM}\n"
            f"**Period:** {START_DATE.strftime('%Y-%m-%d')} to {END_DATE.strftime('%Y-%m-%d')}\n\n"
            f"File saved to: `{output_pdf_path}`"
        )
        send_telegram_notification(notification_message, TG_TOKEN, TG_CHAT_ID)
    
except Exception as e:
    failure_message = f"*INVOICE FAILURE* \n\nFailed to generate invoice {INVOICE_NUM}. Error: {e}"
    send_telegram_notification(failure_message, TG_TOKEN, TG_CHAT_ID)
    print(f"FATAL ERROR during PDF generation: {e}")
    exit(1)
