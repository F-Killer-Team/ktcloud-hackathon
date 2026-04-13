variable "aws_region" { default = "ap-northeast-2" }
variable "key_name" {
  description = "AWS Key Pair Name"
  default     = "my-terraform-key"
}

variable "instance_type" { default = "t3.small" }
# K3s 노드 간 인증을 위한 비밀 토큰
# K3s 노드 간 인증을 위한 비밀 토큰
variable "k3s_token" {
  description = "Secret token used to join nodes to the cluster"
  type        = string
  default     = "k3s-token-2026-secret"
  sensitive   = true
}
