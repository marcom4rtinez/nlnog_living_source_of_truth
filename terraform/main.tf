terraform {
  required_providers {
    infrahub = {
      source  = "registry.marcomartinez.ch/marcom4rtinez/infrahub"
      version = "0.0.0"
    }
  }
}

provider "infrahub" {
  api_key         = "184b73b6-77a8-2161-2dcf-c512a7d01746"
  infrahub_server = "http://localhost:8000"
  branch          = "main"
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

data "infrahub_ipaddressquery" "mgmt_address" {
  ip_address_value = "10.0.0.1/32"
}

resource "infrahub_device" "create_spines" {
  for_each                = toset([for i in range(1, 3) : format("spine%d", i)])
  name_value              = each.key
  asn_node_id             = data.infrahub_autonomoussystem.verizon.id
  device_type_node_id     = data.infrahub_devicetype.nokia_spines.id
  location_node_id        = data.infrahub_country.usa.id
  platform_node_id        = data.infrahub_platform.srlinux.id
  primary_address_node_id = data.infrahub_ipaddressquery.mgmt_address.id
  status_value            = "active"
  topology_node_id        = data.infrahub_topology.fra05-pod1.id
  role_value              = "spine"
}


##############################################################################################################
#                                         Create Spines                                                      #
##############################################################################################################

locals {
  spines     = ["spine1", "spine2"]
  interfaces = [1, 2, 3]

  spine_interface_pairs = flatten([
    for spine in local.spines : [
      for intf in local.interfaces : {
        spine     = spine
        intf      = intf
        intf_name = format("ethernet-1/%d", intf)
        ip_addr   = format("192.168.%d%s.1/31", intf, substr(spine, -1, 1))
      }
    ]
  ])
}

resource "infrahub_l3interface" "ethernet" {
  for_each = {
    for pair in local.spine_interface_pairs :
    "${pair.spine}-${pair.intf}" => pair
  }

  name_value        = each.value.intf_name
  description_value = "${each.value.spine} - ${each.value.intf_name}"
  role_value        = "leaf"
  enabled_value     = true
  device_node_id    = infrahub_device.create_spines[each.value.spine].id
  status_value      = "active"
  full_ipv4_value   = each.value.ip_addr
}

##############################################################################################################
#                                         Create Leafs                                                       #
##############################################################################################################

resource "infrahub_device" "create_leaf" {
  for_each                = toset([for i in range(1, 4) : format("leaf%d", i)])
  name_value              = each.key
  asn_node_id             = data.infrahub_autonomoussystem.verizon.id
  device_type_node_id     = data.infrahub_devicetype.nokia_leafs.id
  location_node_id        = data.infrahub_country.usa.id
  platform_node_id        = data.infrahub_platform.srlinux.id
  primary_address_node_id = data.infrahub_ipaddressquery.mgmt_address.id
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


# locals {
#   leafs           = ["leaf1", "leaf2", "leaf3"]
#   leaf_interfaces = [49, 50, 51, 52]

#   leaf_interface_pairs = flatten([
#     for leaf in local.leafs : [
#       for intf in local.leaf_interfaces : {
#         leaf      = leaf
#         intf      = intf
#         intf_name = format("ethernet-1/%d", intf)
#         ip_addr   = format("192.168.%s%d.0/31", substr(leaf, -1, 1), intf - 48)
#       }
#     ]
#   ])
# }

# resource "infrahub_l3interface" "leaf_uplinks" {
#   for_each = {
#     for pair in local.leaf_interface_pairs :
#     "${pair.leaf}-${pair.intf}" => pair
#   }

#   name_value        = each.value.intf_name
#   description_value = "${each.value.leaf} - ${each.value.intf_name}"
#   role_value        = "leaf"
#   enabled_value     = true
#   device_node_id    = infrahub_device.create_leaf[each.value.leaf].id
#   status_value      = "active"
#   full_ipv4_value   = each.value.ip_addr
# }
