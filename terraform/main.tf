terraform {
  required_providers {
    infrahub = {
      source  = "registry.marcomartinez.ch/marcom4rtinez/infrahub"
      version = "0.0.0"
    }
  }
}

provider "infrahub" {
  api_key         = "184b2c4a-bc9f-e119-32fa-c51ecfe83c9b"
  infrahub_server = "http://localhost:8000"
  branch          = "enable"
}


data "infrahub_country" "usa" {
  country_name = "United States of America"
}

data "infrahub_topology" "fra05-pod1" {
  topology_name = "fra05-pod1"
}

data "infrahub_devicetype" "nokia_spines" {
  device_type_name = "7220 IXR-D3L"
}

data "infrahub_devicetype" "nokia_leafs" {
  device_type_name = "7220 IXR-D2L"
}


data "infrahub_autonomoussystem" "verizon" {
  as_name = "AS701"
}

data "infrahub_platform" "srlinux" {
  platform_name = "Nokia SR Linux"
}

# resource "infrahub_ipaddress" "mgmt_address" {
#   address_value = "10.0.0.100/32"
#   description_value = "my cool ip"
# }

data "infrahub_ipaddressquery" "mgmt_address_0" {
  ip_address_value = "10.0.0.1/32"
}

data "infrahub_ipaddressquery" "mgmt_address_1" {
  ip_address_value = "10.0.0.1/32"
}

locals {

  mgmt_map = {
    spine1 = data.infrahub_ipaddressquery.mgmt_address_0.id
    spine2 = data.infrahub_ipaddressquery.mgmt_address_1.id
  }
}
resource "infrahub_device" "create_spines" {
  for_each                = toset([for i in range(1, 3) : format("spine%d", i)])
  name_value              = each.key
  asn_node_id             = data.infrahub_autonomoussystem.verizon.id
  device_type_node_id     = data.infrahub_devicetype.nokia_spines.id
  location_node_id        = data.infrahub_country.usa.id
  platform_node_id        = data.infrahub_platform.srlinux.id
  primary_address_node_id = local.mgmt_map[each.key]
  status_value            = "active"
  topology_node_id        = data.infrahub_topology.fra05-pod1.id
  role_value              = "spine"
}

resource "infrahub_l3interface" "ethernet1-1" {
  for_each          = toset([for i in range(1, 3) : format("spine%d", i)])
  description_value = format("%s - ethernet-1/1", each.key)
  role_value        = "leaf"
  enabled_value     = true
  name_value        = "ethernet-1/1"
  device_node_id    = infrahub_device.create_spines[each.key].id
  status_value      = "active"
}



resource "infrahub_l3interface" "ethernet1-2" {
  for_each          = toset([for i in range(1, 3) : format("spine%d", i)])
  description_value = format("%s - ethernet-1/2", each.key)
  role_value        = "leaf"
  enabled_value     = true
  name_value        = "ethernet-1/2"
  device_node_id    = infrahub_device.create_spines[each.key].id
  status_value      = "active"
}




resource "infrahub_device" "create_leaf" {
  for_each                = toset([for i in range(1, 4) : format("leaf%d", i)])
  name_value              = each.key
  asn_node_id             = data.infrahub_autonomoussystem.verizon.id
  device_type_node_id     = data.infrahub_devicetype.nokia_leafs.id
  location_node_id        = data.infrahub_country.usa.id
  platform_node_id        = data.infrahub_platform.srlinux.id
  primary_address_node_id = data.infrahub_ipaddressquery.mgmt_address_0.id
  status_value            = "active"
  topology_node_id        = data.infrahub_topology.fra05-pod1.id
  role_value              = "leaf"
}


resource "infrahub_l2interface" "ethernet1-1" {
  for_each          = toset([for i in range(1, 4) : format("leaf%d", i)])
  description_value = format("%s - ethernet-1/1", each.key)
  l2_mode_value     = "Access"
  role_value        = "leaf"
  enabled_value     = true
  name_value        = "ethernet-1/1"
  device_node_id    = infrahub_device.create_leaf[each.key].id
  status_value      = "active"
}
