resource "aws_s3_bucket" "landing_bucket" {
  bucket        = "landing-side-project-ruben"
  force_destroy = true

  tags = {
    Environment = "dev"
    Project     = "side_project_landing"
  }
}

resource "aws_s3_bucket_ownership_controls" "landing_bucket_ownership" {
  bucket = aws_s3_bucket.landing_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "landing_bucket_public_block" {
  bucket = aws_s3_bucket.landing_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}


# 1. Crear la función Lambda (ejemplo en Python)

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_s3_access" {
  name = "lambda_s3_access"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = [
        "s3:GetObject",
        "s3:ListBucket"
      ]
      Resource = [
        aws_s3_bucket.landing_bucket.arn,
        "${aws_s3_bucket.landing_bucket.arn}/*"
      ]
    }]
  })
}

resource "aws_lambda_function" "s3_event_lambda" {
  function_name = "landing_bucket_file_handler"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "index.handler"
  runtime       = "python3.9"

  filename = "../etl/lambda_functions/lambda_function.zip"  # Ruta relativa

  source_code_hash = filebase64sha256("../etl/lambda_functions/lambda_function.zip")

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.landing_bucket.bucket
    }
  }
}

# 2. Crear el trigger S3 para la Lambda

resource "aws_s3_bucket_notification" "landing_bucket_notification" {
  bucket = aws_s3_bucket.landing_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_event_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""   # Cambia esto a la "carpeta" que quieres monitorear, o "" para todo el bucket
  }

  depends_on = [aws_lambda_function.s3_event_lambda]
}

# 3. Permitir que S3 invoque la Lambda

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_event_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.landing_bucket.arn
}

