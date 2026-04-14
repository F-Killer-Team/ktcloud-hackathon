#!/bin/bash

set -euo pipefail

if [ -z "${JOB_ID:-}" ] || [ -z "${CALLBACK_URL:-}" ] || [ -z "${DOWNLOAD_URL:-}" ]; then
    echo "[ERROR] Missing required environment variables: JOB_ID, CALLBACK_URL, DOWNLOAD_URL"
    exit 1
fi

WORK_DIR="/tmp/sandbox"
TARGET_FILE="${WORK_DIR}/${FILE_NAME:-sample.py}"

mkdir -p "${WORK_DIR}"
curl -fsSL "${DOWNLOAD_URL}" -o "${TARGET_FILE}"

LOG_OUTPUT=$(python3 "${TARGET_FILE}" 2>&1 || true)

if echo "$LOG_OUTPUT" | grep -qiE "HACKED|Exfiltrating|Unauthorized|Ransomware|ENCRYPTING|LOCKED|encrypted|ALL FILES ARE LOCKED|ModuleNotFoundError|Traceback"; then    
    STATUS="MALICIOUS"
    SUMMARY="Detected ransomware-like runtime behavior in the uploaded file."
else
    STATUS="CLEAN"
    SUMMARY="No suspicious runtime behavior was detected."
fi

JSON_PAYLOAD=$(jq -n \
  --arg status "$STATUS" \
  --arg summary "$SUMMARY" \
  --arg log "$LOG_OUTPUT" \
  '{status: $status, summary: $summary, log_excerpt: $log}')

curl -X POST "${CALLBACK_URL}" \
     -H "Content-Type: application/json" \
     -d "$JSON_PAYLOAD"

echo "Analysis result (${STATUS}) sent to backend."
