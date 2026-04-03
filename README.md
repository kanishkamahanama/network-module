# network-module

## Examples

### 1. Simple VPC — public subnets only, no NAT

```hcl
module "network" {
  source = "./network-module"

  vpc_name = "my-vpc"
  vpc_cidr = "10.0.0.0/16"

  public_subnet_data = [
    { cidr = "10.0.1.0/24", availability_zone = "us-east-1a", prefix = "pub" },
    { cidr = "10.0.2.0/24", availability_zone = "us-east-1b", prefix = "pub" },
  ]

  private_subnet_data = []
}
```

### 2. Public + private subnets, single NAT gateway

One NAT gateway shared by all private subnets. Lower cost — suitable for non-production environments.

```hcl
module "network" {
  source = "./network-module"

  vpc_name = "staging-vpc"
  vpc_cidr = "10.10.0.0/16"

  public_subnet_data = [
    { cidr = "10.10.1.0/24", availability_zone = "us-east-1a", prefix = "pub" },
    { cidr = "10.10.2.0/24", availability_zone = "us-east-1b", prefix = "pub" },
  ]

  private_subnet_data = [
    { cidr = "10.10.11.0/24", availability_zone = "us-east-1a", prefix = "app" },
    { cidr = "10.10.12.0/24", availability_zone = "us-east-1b", prefix = "app" },
  ]

  enable_nat_gateway = true
  single_nat_gateway = true
}
```

### 3. Public + private subnets, one NAT gateway per AZ

One NAT gateway per public subnet. Provides AZ-level redundancy — recommended for production.

```hcl
module "network" {
  source = "./network-module"

  vpc_name = "prod-vpc"
  vpc_cidr = "10.20.0.0/16"

  public_subnet_data = [
    { cidr = "10.20.1.0/24", availability_zone = "us-east-1a", prefix = "pub" },
    { cidr = "10.20.2.0/24", availability_zone = "us-east-1b", prefix = "pub" },
    { cidr = "10.20.3.0/24", availability_zone = "us-east-1c", prefix = "pub" },
  ]

  private_subnet_data = [
    { cidr = "10.20.11.0/24", availability_zone = "us-east-1a", prefix = "app" },
    { cidr = "10.20.12.0/24", availability_zone = "us-east-1b", prefix = "app" },
    { cidr = "10.20.13.0/24", availability_zone = "us-east-1c", prefix = "app" },
  ]

  enable_nat_gateway = true
  single_nat_gateway = false
}
```

### 4. Multi-tier VPC — app and data subnet layers

Use `prefix` to name subnets by role. Two AZs, single NAT gateway, separate app and data tiers.

```hcl
module "network" {
  source = "./network-module"

  vpc_name = "prod-vpc"
  vpc_cidr = "10.30.0.0/16"

  public_subnet_data = [
    { cidr = "10.30.1.0/24", availability_zone = "eu-west-1a", prefix = "pub" },
    { cidr = "10.30.2.0/24", availability_zone = "eu-west-1b", prefix = "pub" },
  ]

  private_subnet_data = [
    { cidr = "10.30.11.0/24", availability_zone = "eu-west-1a", prefix = "app" },
    { cidr = "10.30.12.0/24", availability_zone = "eu-west-1b", prefix = "app" },
    { cidr = "10.30.21.0/24", availability_zone = "eu-west-1a", prefix = "data" },
    { cidr = "10.30.22.0/24", availability_zone = "eu-west-1b", prefix = "data" },
  ]

  enable_nat_gateway = true
  single_nat_gateway = true
}
```
