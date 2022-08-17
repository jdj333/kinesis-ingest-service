terraform {
  cloud {
    organization = "CoffeeTrendsUSA"

    workspaces {
      name = "STAGE-COFFEETRENDS"
    }
  }
}