resource "aws_security_group" "k3s_sg" {
  name        = "k3s-security-group"
  description = "Security group for K3s cluster"
  vpc_id      = aws_vpc.main.id 

  # 1. SSH (관리용)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  # 2. K3s API Server (외부 kubectl 접속용)
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 3. HTTP/HTTPS (웹 서비스용)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 4. NodePort (백엔드 서비스 테스트용)
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 5. 내부 통신 전체 허용 (마스터-워커 간 VXLAN, Kubelet 통신용)
  # 같은 보안 그룹을 가진 리소스끼리는 모든 포트를 엽니다.
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k3s-main-sg"
  }
}
