# K8s 격리 컨테이너 설정
```
.
├── ansible/
│   ├── group_vars/
│   │   └── all.yml             # k3s 설정 및 공통 변수
│   ├── inventory.ini           # 마스터/워커 IP
│   ├── roles/
│   │   ├── common/             # 커널 모듈, gVisor 설치 등
│   │   ├── k3s_master/         # k3s server 설치 및 pod 배포
│   │   └── k3s_worker/         # k3s agent 설치 및 Taint 설정
│   └── site.yml
├── Dockerfile                  # Sandbox 전용 이미지 빌드용
├── network/
│   └── network-policy.yaml
├── pods/
│   ├── backend-pod.yaml
│   ├── frontend-pod.yaml
│   └── sandbox-pod.yaml
└── README.md
```
