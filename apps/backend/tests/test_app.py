from io import BytesIO

from fastapi.testclient import TestClient

from app.main import app
from app.services.event_service import get_events


client = TestClient(app)


def test_healthz() -> None:
    response = client.get("/healthz")

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_upload_flow_exposes_job_and_events() -> None:
    upload_response = client.post(
        "/api/uploads",
        files={"file": ("invoice.exe", BytesIO(b"fake payload"), "application/octet-stream")},
    )

    assert upload_response.status_code == 200
    payload = upload_response.json()
    assert payload["job_id"].startswith("job-")
    assert payload["status"] in {"POD_REQUESTED", "POD_RUNNING", "ANALYZING"}

    job_id = payload["job_id"]

    job_response = client.get(f"/api/jobs/{job_id}")
    assert job_response.status_code == 200
    job_payload = job_response.json()
    assert job_payload["filename"] == "invoice.exe"

    events = get_events(job_id)
    assert len(events) >= 2
    assert events[0].message == "File upload completed."
    assert any("Requesting security sandbox provisioning" in event.message for event in events)
