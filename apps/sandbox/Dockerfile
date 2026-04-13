FROM python:3.9-slim

# 필요한 도구 설치
RUN apt-get update && apt-get install -y jq curl

WORKDIR /app

# 분석 스크립트만 복사
COPY analyze.sh .
RUN chmod +x analyze.sh

# 환경변수로 전달될 파일을 실행하도록 설정
ENTRYPOINT ["./analyze.sh"]
