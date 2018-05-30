output "elb_dns" {
  description = "DNS of ELB"
  value       = "${aws_elb.example.dns_name}"
}

output "asg_name" {
  description = "Name of Autoscaling Group"
  value       = "${aws_autoscaling_group.example.name}"
}
