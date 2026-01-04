tenant_id              = "06a247ad-057d-464f-b7ea-d3c3aae3d0eb"
default_azsubscription = "2e3ed960-fc0a-49ce-ad4b-05febbbb6f7c"
# Azure AD Users to create
az_ad_user_map = {
  AliceSmith001 = {
    display_name = "Alice Smith"
    rb_group     = "RB-Administrators"
  }
  BobJohnson001 = {
    display_name = "Bob Johnson"
    rb_group     = "RB-Managers"
  }
  CarolLee001 = {
    display_name = "Carol Lee"
    rb_group     = "RB-Managers"
  }
  DavidKim001 = {
    display_name = "David Kim"
    rb_group     = "RB-Developers"
  }
  EvaBrown001 = {
    display_name = "Eva Brown"
    rb_group     = "RB-Managers"
  }
  FrankGreen001 = {
    display_name = "Frank Green"
    rb_group     = "RB-Developers"
  }
  GraceWhite001 = {
    display_name = "Grace White"
    rb_group     = "RB-Developers"
  }
  HenryBlack001 = {
    display_name = "Henry Black"
    rb_group     = "RB-Administrators"
  }
  IvyScott001 = {
    display_name = "Ivy Scott"
    rb_group     = "RB-Administrators"
  }
  JackWilson001 = {
    display_name = "Jack Wilson"
    rb_group     = "RB-Developers"
  }
  # Proof of concept duplicate
  AliceSmith002 = {
    display_name = "Alice Smith"
    rb_group     = "RB-Managers"
  }
}

rg_dev_env_basename_set = ["rg-VMInfrastructure", "rg-WebApps"]
location                = "canadacentral"

rg_resourceGroups_map = {
  "rg-SharedResources" = {
    tags = {
      "BU" = "Infrastructure"
    }
    location = "canadacentral"
  }

  "rg-AzureDevops" = {
    tags = {
      "BU" = "SoftwareCICD"
    }
    location = "canadacentral"
  }
}

# Monitoring Configuration
alert_email_set = ["azou8506@gmail.com"]

# Azure AD Groups to create
az_ad_rb_group_map = {
  "RB-ChiefTechnologyOfficers" = {
    name             = "RB-ChiefTechnologyOfficers"
    description      = "Role Based Chief Technology Officers group"
    security_enabled = true
    mail_enabled     = false
  }

  "RB-Administrators" = {
    name             = "RB-Administrators"
    description      = "Role Based Administrators group"
    security_enabled = true
    mail_enabled     = false
  }

  "RB-Managers" = {
    name             = "RB-Managers"
    description      = "Role Based Managers group"
    security_enabled = true
    mail_enabled     = false
  }

  "RB-ServiceAccounts" = {
    name             = "RB-ServiceAccounts"
    description      = "Role Based Service Accounts group"
    security_enabled = true
    mail_enabled     = false
  }

  "RB-Developers" = {
    name             = "RB-Developers"
    description      = "Role Based Developers group"
    security_enabled = true
    mail_enabled     = false
  }
}

az_ad_l_group_map = {
  "L-Security-Admins" = {
    name             = "L-Security-Admins"
    description      = "Security Administrators group"
    security_enabled = true
    mail_enabled     = false
    member_of        = ["RB-Administrators"]
  }

  "L-VM-Admins" = {
    name             = "L-VM-Admins"
    description      = "VM Administrators group"
    security_enabled = true
    mail_enabled     = false
    member_of        = ["RB-Administrators"]
  }

  "L-VM-Users" = {
    name             = "L-VM-Users"
    description      = "Lab VM Users group"
    security_enabled = true
    mail_enabled     = false
    member_of        = ["RB-Developers"]
  }

  "L-Application-Devs" = {
    name             = "L-Application-Devs"
    description      = "Application Developers group"
    security_enabled = true
    mail_enabled     = false
    member_of        = ["RB-Administrators", "RB-Developers"]
  }
}
