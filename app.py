from flask import Flask, request, jsonify

app = Flask(__name__)

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
    # Get the parameter from query string (?input=...)
    user_input = request.args.get('input')
    
    if not user_input:
        return jsonify({"error": "Missing first name"}), 400
    
    return jsonify({"you_sent": user_input})

@app.route('/lastName', methods=['GET'])
def lastName():
    # Get the parameter from query string (?input=...)
    user_input = request.args.get('input')
    
    if not user_input:
        return jsonify({"error": "Missing Last Name"}), 400
    
    return jsonify({"you_sent": user_input})

@app.route('/email', methods=['GET'])
def email():
    # Get the parameter from query string (?input=...)
    user_input = request.args.get('input')
    
    if not user_input:
        return jsonify({"error": "Missing email"}), 400
    
    return jsonify({"you_sent": user_input})