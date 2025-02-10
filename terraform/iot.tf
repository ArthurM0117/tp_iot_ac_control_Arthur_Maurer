resource "aws_iot_certificate" "iot_certificate" {
  active = true
}

resource "aws_iot_policy" "iot_policy" {
  name   = "iot_policy"
  policy = file("${path.module}/terraform/files/iot_policy.json")
}

resource "aws_iot_policy_attachment" "iot_policy_attachment" {
  policy_name = aws_iot_policy.iot_policy.name
  target      = aws_iot_certificate.iot_certificate.arn
}

resource "aws_iot_thing" "iot_thing" {
  name = "MyIoTThing"
}

resource "aws_iot_thing_principal_attachment" "thing_principal_attachment" {
  thing_name = aws_iot_thing.iot_thing.name
  principal  = aws_iot_certificate.iot_certificate.arn
}

resource "aws_iot_endpoint" "iot_endpoint" {
  endpoint_type = "iot:Data-ATS"
}


