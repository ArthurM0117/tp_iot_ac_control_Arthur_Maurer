# aws_iot_certificate cert
    resource "aws_iot_certificate" "cert" {
    active = true
    }
# aws_iot_policy pub-sub
resource "aws_iot_policy" "pubsub" {
    name   = "PubSubToAnyTopic"
    policy = file("${path.module}/files/iot_policy.json")
    }
# aws_iot_policy_attachment attachment
    resource "aws_iot_policy_attachment" "att" {
    policy = aws_iot_policy.pubsub.name
    target = aws_iot_certificate.cert.arn
    }
# aws_iot_thing temp_sensor
    resource "aws_iot_thing" "example" {
    name = "temp_sensor"
    }
# aws_iot_thing_principal_attachment thing_attachment
    resource "aws_iot_thing_principal_attachment" "att" {
    principal = aws_iot_certificate.cert.arn
    thing     = aws_iot_thing.example.name
    }
# data aws_iot_endpoint to retrieve the endpoint to call in simulation.py
    data "aws_iot_endpoint" "current" {
    endpoint_type = "iot:Data-ATS"
    }
# aws_iot_topic_rule rule for sending invalid data to DynamoDB
    resource "aws_iot_topic_rule" "temperature_rule" {
    name        = "TemperatureRule"
    description = "Rule for temperature sensor data"
    enabled     = true
    sql="SELECT * FROM 'sensor/temperature/+' WHERE temperature >= 40"
    sql_version = "2016-03-23"

    dynamodbv2 {
        put_item {
            table_name = aws_dynamodb_table.temperature.name
        }
        role_arn   = aws_iam_role.iot_role.arn
    }
    }

# aws_iot_topic_rule rule for sending valid data to Timestream

resource "aws_iot_topic_rule" "temperature_rule_valid" {
  name        = "TemperatureRuleValid"
  description = "Rule for temperature sensor data"
  enabled     = true
  sql         = "SELECT * FROM 'sensor/temperature/+'"
  sql_version = "2016-03-23"

  timestream {
    role_arn      = aws_iam_role.iot_role.arn
    table_name    = aws_timestreamwrite_table.temperaturesensor.table_name
    database_name = aws_timestreamwrite_database.iot.database_name

    dimension {
      name  = "sensor_id"
      value = "$${sensor_id}"
    }

    dimension {
      name  = "temperature"
      value = "$${temperature}"
    }

    dimension {
      name  = "zone_id"
      value = "$${zone_id}"
    }

    timestamp {
      unit  = "MILLISECONDS"
      value = "$${timestamp()}"
    }
  }
}

