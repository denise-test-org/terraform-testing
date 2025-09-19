terraform { 
  cloud { 
    hostname = "app.terraform.io" 
    organization = "team-tf-actions-test-org" 

    workspaces { 
      name = "terraform-testing" 
    } 
  } 
}
