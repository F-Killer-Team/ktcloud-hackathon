FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y python3 curl && \
    apt-get clean
WORKDIR /sandbox
COPY . .
CMD ["bash", "analyze.sh"]
