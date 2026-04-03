# ─── vpc ──────────────────────────────────────────────────────────────────────

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

# ─── Public Subnets ───────────────────────────────────────────────────────────

resource "aws_subnet" "public" {
  count = length(var.public_subnet_data)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_data[count.index].cidr
  map_public_ip_on_launch = true
  availability_zone       = var.public_subnet_data[count.index].availability_zone

  tags = {
    Name = "${var.vpc_name}-${var.public_subnet_data[count.index].prefix}-${count.index + 1}"
  }
}

# ─── Internet Gateway ───────────────────────────────────────────────────────

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# ─── Public Route Table ─────────────────────────────────────────────────────

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

# ─── Public Route Table Associations ───────────────────────────────────────

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_data)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ─── Elastic IPs for NAT Gateway ─────────────────────────────────────────────

resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.public_subnet_data)) : 0
}

# ─── NAT Gateways ───────────────────────────────────────────────────────────

resource "aws_nat_gateway" "nat" {
  count         = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.public_subnet_data)) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index % length(var.public_subnet_data)].id

  tags = {
    Name = "${var.vpc_name}-nat-${count.index + 1}"
  }
}

# ───────────────────────────── Private ───────────────────────────────────────


# ─── Private Route Table ──────────────────────────────────────────────────────

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-private-rt"
  }
}

# ─── Private Route Table Associations ─────────────────────────────────────

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_data)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# ─── Private Subnets ───────────────────────────────────────────────────────────

resource "aws_subnet" "private" {
  count = length(var.private_subnet_data)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_data[count.index].cidr
  map_public_ip_on_launch = false
  availability_zone       = var.private_subnet_data[count.index].availability_zone

  tags = {
    Name = "${var.vpc_name}-${var.private_subnet_data[count.index].prefix}-${count.index + 1}"
  }
}

# ─── Route for the private route table ──────────────────────────────────────────────────────

resource "aws_route" "private_nat" {
  count                  = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.public_subnet_data)) : 0
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}

