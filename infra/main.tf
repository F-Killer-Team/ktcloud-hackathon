provider "aws" {
  region = var.aws_region
}

# 1. 최신 Ubuntu 22.04 AMI 자동 검색
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

# K3s 설치 스크립트 정의
locals {
  # 마스터 노드용
  k3s_master_setup = <<-EOF
    #!/bin/bash
    curl -sfL https://get.k3s.io | K3S_TOKEN=${var.k3s_token} sh -s - server \
      --write-kubeconfig-mode 644
  EOF

  # 워커 노드용 (마스터의 Private IP를 참조함)
  k3s_worker_setup = <<-EOF
    #!/bin/bash
    # 마스터 노드가 완전히 뜰 때까지 잠시 대기 (안정성 위함)
    sleep 30
    curl -sfL https://get.k3s.io | K3S_URL=https://${aws_instance.master.private_ip}:6443 K3S_TOKEN=${var.k3s_token} sh -
  EOF
}

# 2. 마스터 노드 생성
resource "aws_instance" "master" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.k3s_sg.id]
  user_data              = local.k3s_master_setup # 수정됨

  tags = { Name = "k3s-master" }
}

# 3. 마스터 고정 IP 할당
resource "aws_eip" "master_eip" {
  instance = aws_instance.master.id
  domain   = "vpc"
  tags     = { Name = "master-fixed-ip" }
}

# 4. 워커 노드 생성
resource "aws_instance" "worker" {
  # 마스터가 먼저 생성되어야 IP를 가져올 수 있으므로 명시적 의존성 추가
  depends_on = [aws_instance.master]

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.k3s_sg.id]
  user_data              = local.k3s_worker_setup

  tags = { Name = "k8s-worker-1" }
}

# 5. 워커 고정 IP 할당
resource "aws_eip" "worker_eip" {
  instance = aws_instance.worker.id
  domain   = "vpc"
  tags     = { Name = "worker-fixed-ip" }
}
