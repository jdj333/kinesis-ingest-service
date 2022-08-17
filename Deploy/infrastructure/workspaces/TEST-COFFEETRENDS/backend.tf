terraform {
  cloud {
    organization = "CoffeeTrendsUSA"

    workspaces {
      name = "DEV-COFFEETRENDS"
    }
  }
}