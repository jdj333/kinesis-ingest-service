terraform {
  cloud {
    organization = "CoffeeTrendsUSA"

    workspaces {
      name = "PROD-COFFEETRENDS"
    }
  }
}