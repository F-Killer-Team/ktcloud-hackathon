# K8s 격리 컨테이너 설정
```
.
k8s/
├── ansible/                    # 앤서블 관련 모든 설정
│   ├── group_vars/
│   │   └── all.yml             # 공통 변수 (사용자 계정, 버전 등)
│   ├── roles/
│   │   ├── k3s_master/
│   │   │   └── tasks/
│   │   │       └── main.yml    # 마스터 설치 & YAML 배포 로직
│   │   └── k3s_worker/
│   │       └── tasks/
│   │           └── main.yml    # 워커 조인 & 격리(Taint) 설정
│   ├── inventory.ini           # 서버 IP
│   └── site.yml                # 전체 실행 시나리오 (Master -> Worker)
├── network/                    # 보안 설정
│   └── network-policy.yaml     # 샌드박스 격리 네트워크 정책
├── pods/                       # 실행 객체
│   ├── backend-pod.yaml        # 백엔드 설정
│   ├── frontend-pod.yaml       # 프론트엔드 설정
│   └── sandbox-pod.yaml        # 일회용 격리실 설정 (Toleration 포함)
├── Dockerfile                  # 샌드박스용 베이스 이미지 정의
└── README.md                   # 프로젝트 설명
```
