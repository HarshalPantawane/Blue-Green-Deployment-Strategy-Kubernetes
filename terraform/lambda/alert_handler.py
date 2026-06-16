import json
import urllib.request
import os

SLACK_WEBHOOK_URL = os.environ.get("SLACK_WEBHOOK_URL", "")
JENKINS_WEBHOOK_URL = os.environ.get("JENKINS_WEBHOOK_URL", "")

def lambda_handler(event, context):
    print("Received event:", json.dumps(event))
    
    for record in event.get("Records", []):
        sns_message_str = record.get("Sns", {}).get("Message", "")
        sns_subject = record.get("Sns", {}).get("Subject", "CloudWatch Alarm Triggered")
        
        try:
            sns_message = json.loads(sns_message_str)
        except Exception:
            sns_message = sns_message_str
            
        alarm_name = ""
        new_state = ""
        reason = ""
        
        if isinstance(sns_message, dict):
            alarm_name = sns_message.get("AlarmName", "Unknown Alarm")
            new_state = sns_message.get("NewStateValue", "UNKNOWN")
            reason = sns_message.get("NewStateReason", "No reason provided")
        else:
            reason = sns_message_str

        # Format message for Slack
        slack_payload = {
            "text": f"🚨 *AWS CloudWatch Alarm Alert* 🚨\n"
                    f"*Subject*: {sns_subject}\n"
                    f"*Alarm Name*: {alarm_name}\n"
                    f"*New State*: {new_state}\n"
                    f"*Reason*: {reason}"
        }
        
        # 1. Send to Slack if configured
        if SLACK_WEBHOOK_URL:
            try:
                req = urllib.request.Request(
                    SLACK_WEBHOOK_URL,
                    data=json.dumps(slack_payload).encode("utf-8"),
                    headers={"Content-Type": "application/json"}
                )
                with urllib.request.urlopen(req) as response:
                    print("Slack response status:", response.status)
            except Exception as e:
                print("Failed to send Slack alert:", str(e))
                
        # 2. Trigger automated rollback via Jenkins if the alarm is a failure alert and configured
        if JENKINS_WEBHOOK_URL and "5xx" in alarm_name.lower() and new_state == "ALARM":
            try:
                print("Triggering Jenkins automated rollback...")
                req = urllib.request.Request(
                    JENKINS_WEBHOOK_URL,
                    data=json.dumps({"event": "ROLLBACK", "alarm": alarm_name}).encode("utf-8"),
                    headers={"Content-Type": "application/json"}
                )
                with urllib.request.urlopen(req) as response:
                    print("Jenkins webhook response status:", response.status)
            except Exception as e:
                print("Failed to trigger Jenkins rollback:", str(e))

    return {
        "statusCode": 200,
        "body": json.dumps("Alert processed successfully")
    }
