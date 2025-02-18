resource "local_sensitive_file" "public_key" {
  filename = "${path.module}/../files/test.public.key"
  content  = aws_iot_certificate.cert.public_key
}

resource "local_sensitive_file" "private_key" {
  filename = "${path.module}/../files/test.private.key"
  content  = aws_iot_certificate.cert.private_key
}

resource "local_sensitive_file" "cert_pem" {
  filename = "${path.module}/../files/test.cert.pem"
  content  = aws_iot_certificate.cert.certificate_pem
}

# Retrieve the AWS IoT endpoint
data "aws_iot_endpoint" "iot_endpoint" {
  endpoint_type = "iot:Data-ATS"
}

# Output the IoT endpoint address
output "iot_endpoint" {
  value = data.aws_iot_endpoint.iot_endpoint.endpoint_address
}
