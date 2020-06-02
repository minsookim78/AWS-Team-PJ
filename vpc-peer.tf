#vpc-peer.tf :peer링커낵션 생성 및 라우팅 추가



data "aws_caller_identity" "west-peer" {
  provider = aws.califonia
}

# Requester's side of the connection.
resource "aws_vpc_peering_connection" "west-peer" {
  vpc_id        = aws_vpc.east-vpc.id
  peer_vpc_id   = aws_vpc.west-vpc.id
  peer_owner_id = data.aws_caller_identity.west-peer.account_id
  peer_region   = "us-west-1"
  auto_accept   = false

  tags = {
    Side = "Requester"
  }
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "west-peer" {
  provider                  = aws.califonia
  vpc_peering_connection_id = aws_vpc_peering_connection.west-peer.id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}



resource "aws_route" "peer-east-rt" {
  route_table_id            = aws_route_table.rt-east-1-public.id
  destination_cidr_block    = aws_vpc.west-vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.west-peer.id
}

resource "aws_route" "peer-west-rt" {
  provider = aws.califonia
  route_table_id            = aws_route_table.rt-west-1-public.id
  destination_cidr_block    = aws_vpc.east-vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.west-peer.id
}