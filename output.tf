 output "web_loadbalancer_url" {
    value = aws_lb.exam_elb.dns_name
}

