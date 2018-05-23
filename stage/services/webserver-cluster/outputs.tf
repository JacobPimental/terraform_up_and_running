output "elb_dns" {
	description = "DNS of ELB"
	value = "${aws_elb.example.dns_name}"
}
