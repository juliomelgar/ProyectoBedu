

# --------------------------------------------------
# DynamoDB Rides Table
# --------------------------------------------------
resource "aws_dynamodb_table" "Rides_table" {
  name = "${var.dynamodb_table_name}"
  hash_key = "RideId"
  attribute {
    name = "RideId"
    type = "S"
  }
  read_capacity  = 20
  write_capacity = 20  
}

# ----------------------------------------------------------
# IAM Roles: Permite que Lambda Asuma el rol
# ----------------------------------------------------------
resource "aws_iam_role" "WildRydesLambda" {
  name = "WildRydesLambda"
  description = "IAM Role to WildRydes Lambda"
  //Esto es la trust relationship entre el rol y el servicio que puede asumirla
  // para conocer más al respecto: https://aws.amazon.com/blogs/security/how-to-use-trust-policies-with-iam-roles/
  assume_role_policy = <<EOF
{
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
  EOF
}

# --------------------------------------------------
# Acceso de lambda para publicar sus logs
# --------------------------------------------------
resource "aws_iam_policy" "LambdaCloudWatchAccess" {
  name = "LambdaCloudWatchAccess"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
  {
    "Action": [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents"
    ],
    "Effect": "Allow",
    "Resource": "*"
  }
  ]
}
EOF
}

# --------------------------------------------------
# Agregar la politica al rol
# --------------------------------------------------
resource "aws_iam_role_policy_attachment" "LambdaCloudWatchAccess_attachment" {
  role    = "${aws_iam_role.WildRydesLambda.name}"
  policy_arn = "${aws_iam_policy.LambdaCloudWatchAccess.arn}"
}

# --------------------------------------------------
# Permitir que Lambda tenga acceso de escritura a DynamoDB
# --------------------------------------------------
resource "aws_iam_policy" "LambdaDynamoDBWriteAccess" {
  name = "LambdaDynamoDBWriteAccess"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
  {
    "Action": [
      "dynamodb:PutItem"
    ],
    "Effect": "Allow",
    "Resource": "${aws_dynamodb_table.Rides_table.arn}"
  }
  ]
}
EOF
}

# --------------------------------------------------
#Agregar la politica al rol
# --------------------------------------------------
resource "aws_iam_role_policy_attachment" "LambdaDynamoDBWriteAccess_attachmemnt" {
  role    = "${aws_iam_role.WildRydesLambda.name}"
  policy_arn = "${aws_iam_policy.LambdaDynamoDBWriteAccess.arn}"
}

# --------------------------------------------------
# Funcion de Lambnda
# --------------------------------------------------
resource "aws_lambda_function" "WildRydes_Lambda_Function" {    
  filename = "${var.lambda_function_filename}"
  function_name = "${var.lambda_function_name}"
  handler = "${var.lambda_handler}"
  runtime = "${var.lambda_runtime}"

  // Rol de ejecucion con los permisos que declaramos anteriormente
  role = "${aws_iam_role.WildRydesLambda.arn}"
}

