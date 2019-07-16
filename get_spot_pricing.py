#!/usr/bin/python
import boto3
import json
import time

def fetch_spot():
  client = boto3.client('ec2',region_name=REGION)
  response = client.describe_spot_price_history(InstanceTypes=INSTANCE_TYPES,MaxResults=100,ProductDescriptions=PRODUCT_DESC,StartTime=TODAY)

  prices = []
  for row in response['SpotPriceHistory']:
    prices.append(row['SpotPrice'])
  prices.sort()

  for price in prices: 
      for row in response['SpotPriceHistory']:
        if row['SpotPrice'] == price:
          subnet = fetch_subnet(row['AvailabilityZone'])
          print(json.dumps({ 'Price': row['SpotPrice'], 'SubnetId': subnet, 'InstanceType': row['InstanceType'], 'AZ': row['AvailabilityZone'] }))
  return

def fetch_subnet(AZ):
  client = boto3.client('ec2',region_name=REGION)
  response = client.describe_subnets(
    Filters = [
      {
        'Name': 'vpc-id',
        'Values': ['vpc-abc123'] },
      { 
        'Name': 'availabilityZone',
        'Values': [AZ] }
    ])
  for row in response['Subnets']: 
    return row['SubnetId']

def main():
  fetch_spot()

REGION = 'us-east-2'
INSTANCE_TYPES = ['r5a.xlarge','r4.xlarge','r5ad.xlarge','i3.xlarge','t3.2xlarge','t3a.2xlarge','t2.2xlarge','m5.2xlarge','m5a.2xlarge','m4.2xlarge']
PRODUCT_DESC = ['Linux/UNIX']
TODAY = int(time.time())
main()
