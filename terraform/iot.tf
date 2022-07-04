# aws_iot_certificate cert

# aws_iot_policy pub-sub

# aws_iot_policy_attachment attachment

# aws_iot_thing temp_sensor

# aws_iot_thing_principal_attachment thing_attachment

# data aws_iot_endpoint to retrieve the endpoint to call in simulation.py

# aws_iot_topic_rule rule for sending invalid data to DynamoDB

# aws_iot_topic_rule rule for sending valid data to Timestream


###########################################################################################
# Enable the following resource to enable logging for IoT Core (helps debug)
###########################################################################################

#resource "aws_iot_logging_options" "logging_option" {
#  default_log_level = "WARN"
#  role_arn          = aws_iam_role.iot_role.arn
#}
