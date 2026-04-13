# Backend

FastAPI orchestrator for file upload, sandbox job creation, event streaming, and result callbacks.

## Run locally

```bash
cd apps/backend
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Mock sandbox mode is enabled by default so the backend can demonstrate the full lifecycle before the real k3s wiring is ready.

Copy `.env.example` to `.env` if you want to override defaults.

## Core endpoints

- `POST /api/uploads`
- `GET /api/jobs/{job_id}`
- `GET /api/jobs/{job_id}/events`
- `POST /api/internal/jobs/{job_id}/result`
- `GET /healthz`

## Environment variables

- `APP_K8S_NAMESPACE`
- `APP_SANDBOX_IMAGE`
- `APP_BACKEND_BASE_URL`
- `APP_USE_IN_CLUSTER_CONFIG`
- `APP_ENABLE_MOCK_SANDBOX`

## Team handoff

See [API_CONTRACT.md](./API_CONTRACT.md) for the frontend/Sandbox callback contract and sample payloads.

## CI/CD

GitHub Actions builds the backend image from `apps/backend/Dockerfile`.
If `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` are configured in repository secrets, pushes to the repository will also publish the image to Docker Hub.

## Demo flow

1. Upload a file to `POST /api/uploads`.
2. Connect the frontend to `GET /api/jobs/{job_id}/events`.
3. The backend streams provisioning, analysis, verdict, and teardown events.
