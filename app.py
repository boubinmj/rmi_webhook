from flask import Flask, request, jsonify
import time

app = Flask(__name__)

SESSIONS = {}

def get_sid():
    # Caller should send ?session_id=123
    sid = request.args.get("session_id")
    if not sid:
        # fallback: generate one if not provided
        sid = str(int(time.time() * 1000))
    return sid

## Webhook Payload Test
## Only works with GoogleDialogflowCX Playbook Structure
@app.route("/health", methods=["GET"])
def appointment():
    return jsonify({
        "fulfillment_response": {
            "messages": [{
                "text": {
                   "text": [
                                "Valid Request.  API Working"
                            ]
                }
            }]
        }
    })

@app.route('/firstName', methods=['GET'])
def firstName():
    sid = get_sid()
    # (?input=...)
    first_name = request.args.get('input')

    # bad input    
    if not first_name:
        return jsonify({"error": "Missing first name"}), 400
    
    SESSIONS.setdefault(sid, {})["first_name"] = first_name
    return jsonify({"session_id": sid, "you_sent": first_name})

@app.route('/lastName', methods=['GET'])
def lastName():
    sid = get_sid()
    # Get the parameter from query string (?input=...)
    user_input = request.args.get('input')
    
    if not user_input:
        return jsonify({"error": "Missing Last Name"}), 400
    
    SESSIONS.setdefault(sid, {})["first_name"] = user_input
    return jsonify({"session_id": sid, "you_sent": user_input})

@app.route('/email', methods=['GET'])
def email():
    sid = get_sid()
    # Get the parameter from query string (?input=...)
    user_input = request.args.get('input')
    
    if not user_input:
        return jsonify({"error": "Missing email"}), 400
    
    SESSIONS.setdefault(sid, {})["first_name"] = user_input
    return jsonify({"session_id": sid, "you_sent": user_input})

@app.route('/test', methods=['GET'])
def test():
    sid = get_sid()
    return jsonify({"session_id": sid, "you_sent": SESSIONS})