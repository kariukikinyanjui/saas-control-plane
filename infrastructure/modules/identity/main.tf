resource "aws_cognito_user_pool" "pool" {
  name = "${var.project_name}-user-pool-${var.environment}"

  # 1. Sign-in Experience
  alias_attributes         = ["email"]
  auto_verified_attributes = ["email"]

  # 2. Security Requirements (No MFA for Dev)
  mfa_configuration = "OFF"

  # 3. Sign-up Experience (Strict B2B)
  # "AllowAdminCreateUserOnly" = True disables self-registration
  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  # 4. The Critical "Tenant" Link
  schema {
    name                     = "tenant_id"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = false  # Security: Once set, it cannot be changed
    required                 = false
    string_attribute_constraints {
      min_length = 1
      max_length = 50
    }
  }

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }
}

# 5. The App Client (For the Web Frontend)
resource "aws_cognito_user_pool_client" "client" {
  name = "${var.project_name}-web-client"

  user_pool_id = aws_cognito_user_pool.pool.id

  # Security: No Client Secret for SPA/Web apps
  generate_secret = false

  # Auth Flows
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH" # Secure Remote Password protocol
  ]
}
