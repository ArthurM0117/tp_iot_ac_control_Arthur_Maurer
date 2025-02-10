# aws_iam_role iot_role
resource "aws_iam_role" "iot_role" {
  name = "iot_role"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "iot.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
)
}

# aws_iam_role_policy iam_policy_for_dynamodb
resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = aws_iam_role.iot_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "dynamodb:PutItem"
                  
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
# aws_iam_role_policy iam_policy_for_timestream_writing
resource "aws_iam_role_policy" "timestream_access" {
  name = "timestream_access"
  role = aws_iam_role.iot_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "timestream:WriteRecords"
        Effect   = "Allow"
        Resource = aws_timestreamwrite_table.temperaturesensor.arn
      },
      {
        Action   = "timestream:DescribeEndpoints"
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# aws_iam_role lambda_role
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}

)
}

# aws_iam_role_policy pour la permission de lire dans AWS Timestream
resource "aws_iam_role_policy" "timestream_policy" {
  name = "timestream_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "timestream:Select"
        Effect   = "Allow"
        Resource = aws_timestreamwrite_table.temperaturesensor.arn
      },
      {
        Action   = "timestream:DescribeEndpoints"
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# aws_iam_role_policy pour la permission de publier sur AWS IoT
resource "aws_iam_role_policy" "iot_publish_policy" {
  name = "iot_publish_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "iot:Publish"
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
