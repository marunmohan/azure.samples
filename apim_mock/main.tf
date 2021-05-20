provider "azurerm" {
  features {
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "apim-mock"
  location = "West Europe"
}

resource "azurerm_api_management" "apim" {
  name                = "apim-cfm"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  publisher_name      = "cmendible"
  publisher_email     = "cmendible@msft.io"

  sku_name = "Developer_1"

  policy {
    xml_content = <<XML
    <policies>
      <inbound />
      <backend />
      <outbound />
      <on-error />
    </policies>
XML

  }
}

resource "azurerm_api_management_api" "api" {
  name                = "mock-api"
  resource_group_name = azurerm_resource_group.rg.name
  api_management_name = azurerm_api_management.apim.name
  revision            = "1"
  display_name        = "Mock API"
  path                = "mock"
  protocols           = ["https"]
}

resource "azurerm_api_management_api_operation" "api_operation" {
  operation_id        = "mock-get"
  api_name            = azurerm_api_management_api.api.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.rg.name
  display_name        = "Mock Operation"
  method              = "GET"
  url_template        = "/"
  description         = "This a mocked operation."

  response {
    status_code = 200
    representation {
      content_type = "application/json"
      sample       = <<EOF
      { "sampleField": "test" }
EOF
    }
  }
}

resource "azurerm_api_management_api_operation_policy" "mock" {
  api_name            = azurerm_api_management_api_operation.api_operation.api_name
  api_management_name = azurerm_api_management_api_operation.api_operation.api_management_name
  resource_group_name = azurerm_api_management_api_operation.api_operation.resource_group_name
  operation_id        = azurerm_api_management_api_operation.api_operation.operation_id

  xml_content = <<XML
<policies>
  <inbound>
    <mock-response status-code="200" content-type="application/json"/>
  </inbound>
</policies>
XML
}

resource "azurerm_api_management_api" "ifconfig" {
  name                = "ifconfig-api"
  resource_group_name = azurerm_resource_group.rg.name
  api_management_name = azurerm_api_management.apim.name
  revision            = "1"
  display_name        = "ifconfig API"
  path                = "ip"
  protocols           = ["https"]
}

resource "azurerm_api_management_api_operation" "ifconfig_operation" {
  operation_id        = "ifconfig"
  api_name            = azurerm_api_management_api.ifconfig.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.rg.name
  display_name        = "GET"
  method              = "GET"
  url_template        = "/"
  description         = "ifconfig API."

  response {
    status_code = 200
    representation {
      content_type = "application/json"
      sample       = <<EOF
      {"country_code":"ES","encoding":"gzip","forwarded":"79.157.128.99","ifconfig_hostname":"ifconfig.io","ip":"127.0.0.1","lang":"en-US,en;q=0.9","method":"GET","mime":"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9","port":31392,"referer":"","ua":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36 Edg/90.0.818.62"}
EOF
    }
  }
}

resource "azurerm_api_management_api_operation_policy" "ifconfig" {
  api_name            = azurerm_api_management_api_operation.ifconfig_operation.api_name
  api_management_name = azurerm_api_management_api_operation.ifconfig_operation.api_management_name
  resource_group_name = azurerm_api_management_api_operation.ifconfig_operation.resource_group_name
  operation_id        = azurerm_api_management_api_operation.ifconfig_operation.operation_id

  xml_content = <<XML
<policies>
  <inbound>
    <send-request mode="new" response-variable-name="ip" timeout="20">
        <set-url>http://ifconfig.io/all.json</set-url>
        <set-method>GET</set-method>
    </send-request>
    <return-response response-variable-name="ip" />
    <base />
  </inbound>
</policies>
XML
}

output "url" {
  value = "${azurerm_api_management.apim.gateway_url}/mock"
}
