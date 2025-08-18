from flask import Flask, request, jsonify, make_response
import time, re, os, json

app = Flask(__name__)

SESSIONS = {}
EMAIL_RE = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")

def sid_from_request():
    # prefer explicit query param; fallback to cookie
    return request.args.get("session_id") or request.cookies.get("session_id")

def require_sid():
    sid = sid_from_request()
    if not sid:
        raise ValueError("session_id is required. Call /start first or pass ?session_id=...")
    return sid

@app.route("/start", methods=["POST", "GET"])
def start():
    sid = str(int(time.time() * 1000))
    SESSIONS[sid] = {"first_name": None, "last_name": None, "email": None}
    resp = make_response(jsonify({"session_id": sid, "record": SESSIONS[sid]}))
    # Optional cookie for browser clients; Dialogflow can ignore and just pass ?session_id=...
    resp.set_cookie("session_id", sid, httponly=True, samesite="Lax", max_age=3600)
    return resp

@app.route("/firstName", methods=["GET"])
def first_name():
    try:
        sid = require_sid()
    except ValueError as e:
        return jsonify({"error": str(e)}), 400

    first = request.args.get("input")
    if not first:
        return jsonify({"error": "Missing first name"}), 400

    SESSIONS.setdefault(sid, {})["first_name"] = first
    return jsonify({"session_id": sid, "record": SESSIONS[sid]})

@app.route("/lastName", methods=["GET"])
def last_name():
    try:
        sid = require_sid()
    except ValueError as e:
        return jsonify({"error": str(e)}), 400

    last = request.args.get("input")
    if not last:
        return jsonify({"error": "Missing last name"}), 400

    SESSIONS.setdefault(sid, {})["last_name"] = last
    return jsonify({"session_id": sid, "record": SESSIONS[sid]})

@app.route("/email", methods=["GET"])
def email():
    try:
        sid = require_sid()
    except ValueError as e:
        return jsonify({"error": str(e)}), 400

    email_val = request.args.get("input")
    if not email_val:
        return jsonify({"error": "Missing email"}), 400
    if not EMAIL_RE.match(email_val):
        return jsonify({"error": "Invalid email format"}), 400

    SESSIONS.setdefault(sid, {})["email"] = email_val
    return jsonify({"session_id": sid, "record": SESSIONS[sid]})

@app.route("/result", methods=["GET"])
def result():
    try:
        sid = require_sid()
    except ValueError as e:
        return jsonify({"error": str(e)}), 400

    rec = SESSIONS.get(sid)
    if not rec:
        return jsonify({"error": "No active session for that session_id"}), 404
    return jsonify({"session_id": sid, "record": rec})

@app.route("/end", methods=["POST"])
def end():
    try:
        sid = require_sid()
    except ValueError as e:
        return jsonify({"error": str(e)}), 400

    record = SESSIONS.get(sid)
    if not record:
        return jsonify({"error": "No active session for that session_id"}), 404

    missing = [k for k in ("first_name", "last_name", "email") if not record.get(k)]
    if missing:
        return jsonify({"error": "Missing fields", "missing": missing, "record": record}), 400

    # TODO: persist here (S3/Dynamo/Sheets) if desired
    # persist_session(sid, record)

    del SESSIONS[sid]
    resp = make_response(jsonify({"session_id": sid, "finalized": True}))
    resp.delete_cookie("session_id")
    return resp
