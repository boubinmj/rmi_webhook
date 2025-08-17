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