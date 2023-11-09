resource "shoreline_notebook" "azure_web_app_authentication_and_authorization_problems" {
  name       = "azure_web_app_authentication_and_authorization_problems"
  data       = file("${path.module}/data/azure_web_app_authentication_and_authorization_problems.json")
  depends_on = [shoreline_action.invoke_webapp_auth_setup]
}

resource "shoreline_file" "webapp_auth_setup" {
  name             = "webapp_auth_setup"
  input_file       = "${path.module}/data/webapp_auth_setup.sh"
  md5              = filemd5("${path.module}/data/webapp_auth_setup.sh")
  description      = "Check and update the authentication and authorization settings in the Azure web application and verify that they are correctly configured."
  destination_path = "/tmp/webapp_auth_setup.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_webapp_auth_setup" {
  name        = "invoke_webapp_auth_setup"
  description = "Check and update the authentication and authorization settings in the Azure web application and verify that they are correctly configured."
  command     = "`chmod +x /tmp/webapp_auth_setup.sh && /tmp/webapp_auth_setup.sh`"
  params      = ["TOKEN_ISSUER_URL","CLIENT_SECRET","TOKEN_AUDIENCE_URL","RESOURCE_GROUP_NAME","WEBAPP_NAME","CLIENT_ID"]
  file_deps   = ["webapp_auth_setup"]
  enabled     = true
  depends_on  = [shoreline_file.webapp_auth_setup]
}

