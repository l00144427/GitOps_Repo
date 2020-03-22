output "instance_ips" {
  value = ["${aws_instance.default.*.public_ip}"]
}

output "instance_name" {
  value = ["${aws_instance.default.*.host_id}"]
}
