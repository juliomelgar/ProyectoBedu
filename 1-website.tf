#----------------------------------------------------------------
# S3 bucket for WildRydes frontend source code (src_webapp)
#----------------------------------------------------------------
resource "aws_s3_bucket" "wildrydes_s3_bucket" {
  bucket = "${var.s3-bucket-name}"
  acl = "public-read"
  force_destroy = true

  website {
      index_document = "index.html"
      error_document = "error.html"
  }
policy = <<EOF
{
  "Id": "bucket_policy_site",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "bucket_policy_site_main",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.s3-bucket-name}/*",
      "Principal": "*"
    }
  ]
}
EOF
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

