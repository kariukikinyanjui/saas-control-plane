resource "aws_verifiedpermissions_policy_store" "store" {
  validation_settings {
    mode = "STRICT"
  }
  description = "SaaS Control Plane Policy Store"
}

# 1. The Schema
resource "aws_verifiedpermissions_schema" "schema" {
  policy_store_id = aws_verifiedpermissions_policy_store.store.policy_store_id
  definition {
    value = file("${path.module}/schema.json")
  }
}

# 2. The Policy
resource "aws_verifiedpermissions_policy" "isolation_policy" {
  policy_store_id = aws_verifiedpermissions_policy_store.store.policy_store_id
  definition {
    static {
      description = "Enforce Tenant Isolation"
      statement   = file("${path.module}/policies.cedar")
    }
  }
  depends_on = [aws_verifiedpermissions_schema.schema]
}
