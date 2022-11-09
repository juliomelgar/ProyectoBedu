#----------------------------------------------------------------
# S3 bucket for WildRydes frontend source code (src_webapp)
#----------------------------------------------------------------
resource "aws_s3_bucket" "wildrydes_s3_bucket" {
  bucket        = var.s3-bucket-name
  force_destroy = true
}

#----------------------------------------------------------------
# S3 bucket acl
#----------------------------------------------------------------

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.wildrydes_s3_bucket.id
  acl    = "private"
}

#----------------------------------------------------------------
# S3 bucket policy
#----------------------------------------------------------------

resource "aws_s3_bucket_policy" "acceso_cloudfront" {
  bucket = aws_s3_bucket.wildrydes_s3_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_cloudfront.json
}

data "aws_iam_policy_document" "allow_access_from_cloudfront" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      aws_s3_bucket.wildrydes_s3_bucket.arn,
      "arn:aws:s3:::${var.s3-bucket-name}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::436477857277:distribution/${aws_cloudfront_distribution.wildrydes_distribution.id}"]
    }
  }
}

#----------------------------------------------------------------
# CloudFront Access
#----------------------------------------------------------------

resource "aws_cloudfront_origin_access_control" "cloudfront_control" {
  name                              = "beduWildRydes"
  description                       = "Acceso para aplicacion wildrydes"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

#----------------------------------------------------------------
# CloudFront - Distribucion
#----------------------------------------------------------------


resource "aws_cloudfront_distribution" "wildrydes_distribution" {
  origin {
    domain_name              = aws_s3_bucket.wildrydes_s3_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_control.id
    origin_id                = "S3Origin"
  }

  enabled             = true
  comment             = "CloudFront"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "S3Origin"

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }


  viewer_certificate {
    cloudfront_default_certificate = true
  }
}