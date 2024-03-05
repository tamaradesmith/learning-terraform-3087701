module "qa" {
  source = "../modules/blog"

  enviroment = {
    name            = "qa"
    newtwork_prefix = '10.1'
  }

  asg_max_size = 1
  asg_min_size = 1
}