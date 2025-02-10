# aws_lambda_function pour la fonction Lambda
resource "aws_lambda_function" "ac_control_lambda" {
  filename      = "${path.module}/files/empty_package.zip"
  function_name = "ac_control_lambda"
  handler       = "ac_control_lambda.lambda_handler"
  runtime       = "python3.7"
  role          = aws_iam_role.lambda_role.arn  
}

# aws_cloudwatch_event_rule pour planifier l'événement toutes les minutes
resource "aws_cloudwatch_event_rule" "every_one_minute" {
  name                = "EveryOneMinute"
  schedule_expression = "rate(1 minute)"
}

# aws_cloudwatch_event_target pour cibler la fonction Lambda
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.every_one_minute.name
  target_id = "lambda"
  arn       = aws_lambda_function.ac_control_lambda.arn
}

# aws_lambda_permission pour autoriser l'exécution par CloudWatch
resource "aws_lambda_permission" "allow_execution" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ac_control_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_one_minute.arn
}
