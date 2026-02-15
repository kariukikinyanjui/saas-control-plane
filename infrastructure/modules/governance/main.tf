resource "aws_budgets_budget" "project_budget" {
  name              = "${var.project_name}-monthly-budget"
  budget_type       = "COST"
  limit_amount      = "25.0"
  limit_unit        = "USD"
  time_period_end   = "2087-06-15_00:00" # Perpetuity
  time_unit         = "MONTHLY"

  # Alert 1: Warning (Actual Spend > 80%)
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  # Alert 2: Critical (Forecasted Spend > 100%)
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.alert_email]
  }
}
