# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

output "contact_form_function_url" {
  description = "HTTPS endpoint the frontend contact form POSTs to."
  value       = aws_lambda_function_url.contact_form.function_url
}

output "contact_form_function_name" {
  value = aws_lambda_function.contact_form.function_name
}

output "contact_form_role_arn" {
  value = aws_iam_role.contact_form.arn
}
