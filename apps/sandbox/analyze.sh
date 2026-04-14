#!/bin/bash

if [ -z "$JOB_ID" ] || [ -z "$CALLBACK_URL" ] || [ -z "$FILE_PATH" ]; then
    echo "[에러] 환경변수(JOB_ID, BACKEND_URL, TARGET_FILE)가 부족합니다."
    exit 1
fi

LOG_OUTPUT=$(python3 "$FILE_PATH" 2>&1)

if echo "$LOG_OUTPUT" | grep -qE "HACKED|Exfiltrating|Unauthorized"; then
    STATUS="MALICIOUS"
    SUMMARY="[악성코드 발견] 비인가 접근 및 데이터 탈취 행위가 감지되었습니다."
else
    STATUS="CLEAN"
    SUMMARY="위험 요소가 발견되지 않았습니다."
fi

JSON_PAYLOAD=$(jq -n \
  --arg status "$STATUS" \
  --arg summary "$SUMMARY" \
  --arg log "$LOG_OUTPUT" \
  '{status: $status, summary: $summary, log_excerpt: $log}')

# 백엔드 전송
curl -X POST "${BACKEND_URL}/api/internal/jobs/${JOB_ID}/result" \
     -H "Content-Type: application/json" \
     -d "$JSON_PAYLOAD"

echo "분석 결과($STATUS) API 전송 완료!"
