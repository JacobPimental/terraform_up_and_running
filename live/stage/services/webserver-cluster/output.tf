output "elb_dns_name" {
	description = "DNS of ELB grabbed from module"
	value = "${module.webserver_cluster.elb_dns}"
}
