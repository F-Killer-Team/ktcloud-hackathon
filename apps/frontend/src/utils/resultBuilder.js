export function buildResultFromJob(job) {
  if (!job) {
    return null;
  }

  const summary = (job.result?.summary || "").toLowerCase();

  const isMalicious =
    job.status === "MALICIOUS" ||
    summary.includes("malicious") ||
    summary.includes("ransomware") ||
    summary.includes("detected ransomware-like runtime behavior") ||
    summary.includes("critical malware behavior detected") ||
    summary.includes("악성");

  if (isMalicious) {
    return {
      type: "malicious",
      title: "위험 파일",
      message: "위험 요소가 발견되었습니다.",
      detail: "보안을 위해 추가 검토가 필요합니다.",
    };
  }

  const isSafe =
    job.status === "CLEAN" ||
    summary.includes("no suspicious runtime behavior was detected") ||
    summary.includes("정상 파일") ||
    summary.includes("위험 요소가 발견되지 않았습니다") ||
    summary.includes("위협 요소가 발견되지 않았습니다");

  if (isSafe) {
    return {
      type: "safe",
      title: "안전 확인",
      message: "위협 요소가 발견되지 않았습니다.",
      detail: "격리 분석이 완료되었으며, 고객 환경에는 영향이 없습니다.",
    };
  }

  if (job.status === "FAILED") {
    return {
      type: "malicious",
      title: "분석 실패",
      message: "분석 중 오류가 발생했습니다.",
      detail: "잠시 후 다시 시도해 주세요.",
    };
  }

  return null;
}