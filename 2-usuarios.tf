#---------------------------------------------------------------------
# Configuración de cognito para manejo de usuarios
#---------------------------------------------------------------------
resource "aws_cognito_user_pool" "user_pool" {
    name = "${var.cognito_user_pool}"
    
    // Cognito will send the verification code to the registered email
    auto_verified_attributes = ["email"]
}

# --------------------------------------------------
# Crear App Client
# --------------------------------------------------
resource "aws_cognito_user_pool_client" "app_client" {
    name = "${var.cognito_user_pool_client}"
    user_pool_id = "${aws_cognito_user_pool.user_pool.id}"
    generate_secret = false
}