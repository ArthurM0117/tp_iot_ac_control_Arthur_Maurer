# aws_iam_role iot_role

# aws_iam_role_policy iam_policy_for_dynamodb

# aws_iam_role_policy iam_policy_for_timestream_writing


# aws_iam_role lambda_role

# aws_iam_role_policy iam_policy_for_timestream_reading for Lambda

# aws_iam_role_policy iam_policy_for_iot_publishing for Lambda




###########################################################################################
# Enable the following resource to enable logging for IoT Core (helps debug)
###########################################################################################

#resource "aws_iam_role_policy" "iam_policy_for_logs" {
#  name = "cloudwatch_policy"
#  role = aws_iam_role.iot_role.id
#
#  policy = <<EOF
#{
#        "Version": "2012-10-17",
#        "Statement": [
#            {
#                "Effect": "Allow",
#                "Action": [
#                    "logs:CreateLogGroup",
#                    "logs:CreateLogStream",
#                    "logs:PutLogEvents",
#                    "logs:PutMetricFilter",
#                    "logs:PutRetentionPolicy"
#                 ],
#                "Resource": [
#                    "*"
#                ]
#            }
#        ]
#    }
#EOF
#}


###########################################################################################
# Enable the following resources to enable logging for your Lambda function (helps debug)
###########################################################################################

#resource "aws_cloudwatch_log_group" "example" {
#  name              = "/aws/lambda/${aws_lambda_function.ac_control_lambda.function_name}"
#  retention_in_days = 14
#}
#
#resource "aws_iam_policy" "lambda_logging" {
#  name        = "lambda_logging"
#  path        = "/"
#  description = "IAM policy for logging from a lambda"
#
#  policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Action": [
#        "logs:CreateLogGroup",
#        "logs:CreateLogStream",
#        "logs:PutLogEvents"
#      ],
#      "Resource": "arn:aws:logs:*:*:*",
#      "Effect": "Allow"
#    }
#  ]
#}
#EOF
#}
#
#resource "aws_iam_role_policy_attachment" "lambda_logs" {
#  role       = aws_iam_role.lambda_role.name
#  policy_arn = aws_iam_policy.lambda_logging.arn
#}
