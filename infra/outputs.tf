output "master_fixed_ip" {
  description = "Fixed Public IP for Kubernetes Master Node"
  value       = aws_eip.master_eip.public_ip
}

output "worker_fixed_ip" {
  description = "Fixed Public IP for Kubernetes Worker Node"
  value       = aws_eip.worker_eip.public_ip
}
