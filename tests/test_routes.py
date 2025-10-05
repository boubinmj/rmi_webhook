def test_start_creates_session(client):
    res = client.get("/start")
    data = res.get_json()
    assert "session_id" in data
    assert res.status_code == 200