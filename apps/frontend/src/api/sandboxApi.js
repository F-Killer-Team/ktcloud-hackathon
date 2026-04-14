const API_BASE_URL =
  (import.meta.env.VITE_API_BASE_URL || "/api").replace(/\/+$/, "");

export async function uploadFile(file) {
  const formData = new FormData();
  formData.append("file", file);

  const response = await fetch(`${API_BASE_URL}/uploads`, {
    method: "POST",
    body: formData,
  });

  if (!response.ok) {
    throw new Error("파일 업로드에 실패했습니다.");
  }

  return response.json();
}

export async function fetchJob(jobId) {
  const response = await fetch(`${API_BASE_URL}/jobs/${jobId}`);

  if (!response.ok) {
    throw new Error("최종 분석 결과를 불러오지 못했습니다.");
  }

  return response.json();
}

export function createJobEventSource(jobId) {
  return new EventSource(`${API_BASE_URL}/jobs/${jobId}/events`);
}