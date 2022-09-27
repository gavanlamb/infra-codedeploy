region="ap-southeast-2"

bucket_name="expensely-codedeploy-ap-southeast-2"

azure_devops_projects_details=[
  {
    project_name = "Platform"
    user_name = "codedeploy.platform.preview"
    assumeRoleUserArns = [
      "arn:aws:iam::829991159560:role/codedeploy",
      "arn:aws:iam::365677886296:role/codedeploy",
      "arn:aws:iam::537521289459:role/codedeploy",
      "arn:aws:iam::151170476258:role/codedeploy",
      "arn:aws:iam::172837312601:role/codedeploy"
    ]
  },
  {
    project_name = "Platform"
    user_name = "codedeploy.platform.production"
    assumeRoleUserArns = [
      "arn:aws:iam::087484524822:role/codedeploy",
      "arn:aws:iam::556018441473:role/codedeploy",
      "arn:aws:iam::104633789203:role/codedeploy",
      "arn:aws:iam::266556396524:role/codedeploy",
      "arn:aws:iam::217292076671:role/codedeploy"
    ]
  },
  {
    project_name = "Kronos"
    user_name = "codedeploy.time.preview"
    assumeRoleUserArns = [
      "arn:aws:iam::829991159560:role/codedeploy",
      "arn:aws:iam::151170476258:role/codedeploy",
      "arn:aws:iam::172837312601:role/codedeploy"
    ]
  },
  {
    project_name = "Kronos"
    user_name = "codedeploy.time.production"
    assumeRoleUserArns = [
      "arn:aws:iam::556018441473:role/codedeploy",
      "arn:aws:iam::104633789203:role/codedeploy",
      "arn:aws:iam::266556396524:role/codedeploy",
    ]
  },
  {
    project_name = "Shared"
    user_name = "codedeploy.shared.preview"
    assumeRoleUserArns = [
      "arn:aws:iam::151170476258:role/codedeploy"
    ]
  },
  {
    project_name = "Shared"
    user_name = "codedeploy.shared.production"
    assumeRoleUserArns = [
      "arn:aws:iam::556018441473:role/codedeploy",
    ]
  },
  {
    project_name = "User"
    user_name = "codedeploy.user.preview"
    assumeRoleUserArns = [
      "arn:aws:iam::151170476258:role/codedeploy",
      "arn:aws:iam::172837312601:role/codedeploy"
    ]
  },
  {
    project_name = "User"
    user_name = "codedeploy.user.production"
    assumeRoleUserArns = [
      "arn:aws:iam::556018441473:role/codedeploy",
      "arn:aws:iam::266556396524:role/codedeploy"
    ]
  }
]
