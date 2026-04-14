from kubernetes import client, config
from kubernetes.config.config_exception import ConfigException

from app.core.config import get_settings

settings = get_settings()


def _load_config() -> None:
    try:
        if settings.use_in_cluster_config:
            config.load_incluster_config()
        else:
            config.load_kube_config()
    except ConfigException:
        # Local development can still proceed without a cluster.
        return


def create_sandbox_job(job_id: str, filename: str) -> dict[str, str | bool]:
    try:
        _load_config()
    except Exception:
        if settings.enable_mock_sandbox:
            return {"job_name": f"sandbox-job-{job_id}", "callback_url": "", "submitted": False}
        raise

    callback_url = f"{settings.backend_base_url}/api/internal/jobs/{job_id}/result"
    download_url = f"{settings.backend_base_url}/api/internal/jobs/{job_id}/file"
    job_name = f"sandbox-job-{job_id}"

    container = client.V1Container(
        name="sandbox",
        image=settings.sandbox_image,
        command=["bash", "/app/analyze.sh"],
        env=[
            client.V1EnvVar(name="JOB_ID", value=job_id),
            client.V1EnvVar(name="FILE_NAME", value=filename),
            client.V1EnvVar(name="CALLBACK_URL", value=callback_url),
            client.V1EnvVar(name="DOWNLOAD_URL", value=download_url),
        ],
    )

    template = client.V1PodTemplateSpec(
        metadata=client.V1ObjectMeta(labels={"role": "sandbox", "job-id": job_id}),
        spec=client.V1PodSpec(restart_policy="Never", containers=[container]),
    )

    spec = client.V1JobSpec(template=template, backoff_limit=0, ttl_seconds_after_finished=30)
    job = client.V1Job(metadata=client.V1ObjectMeta(name=job_name), spec=spec)

    try:
        batch_api = client.BatchV1Api()
        batch_api.create_namespaced_job(namespace=settings.k8s_namespace, body=job)
        return {"job_name": job_name, "callback_url": callback_url, "submitted": True}
    except Exception:
        if settings.enable_mock_sandbox:
            return {"job_name": job_name, "callback_url": callback_url, "submitted": False}
        raise

    return {"job_name": job_name, "callback_url": callback_url, "submitted": True}
