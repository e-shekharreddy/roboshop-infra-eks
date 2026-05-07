resource "aws_route53_record" "jenkins" {
  zone_id = var.zone_id
  name    = "jenkins.${var.domain_name}"
  type    = "A"
  ttl     = "1"
  records = [aws_instance.jenkins.public_ip]
  allow_overwrite = true
}

resource "aws_route53_record" "jenkins_agent" {
  zone_id = var.zone_id
  name    = "jenkins-agent.${var.domain_name}"
  type    = "A"
  ttl     = "1"
  records = [aws_instance.jenkins_agent.private_ip]
  allow_overwrite = true
}

# resource "aws_route53_record" "sonarqube" {
#   count = var.sonar ? 1 : 0
#   zone_id = var.zone_id
#   name    = "sonar.${var.domain_name}"
#   type    = "A"
#   ttl     = "1"
#   records = [aws_instance.sonarqube[0].public_ip]
#   allow_overwrite = true
# }