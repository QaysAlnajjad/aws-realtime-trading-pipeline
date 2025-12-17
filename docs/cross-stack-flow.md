# **Cross-Stack Dependency Map**
```
┌─────────────────────────────────────────────┐
│                 foundation                  │
│  OUTPUTS:                                   │
|   • vpc_id ─────────────────────────────────┼─────▶ used by producers, 
│   • ecs_subnets_ids ────────────────────────┼─────▶ used by producers,
└─────────────────────────────────────────────┘
┌─────────────────────────────────────────────┐
│                 data-streaming              │
|  INPUTS:                                    |
|   • s3_bucket_name                          |
│  OUTPUTS:                                   │
|   • kinesis_stream_arn ─────────────────────┼─────▶ used by producers, consumers
│   • kinesis_stream_name ────────────────────┼─────▶ used by producers,
│   • data_stream_s3_bucket_id ───────────────┼─────▶ used by consumers, analytics
└─────────────────────────────────────────────┘
┌─────────────────────────────────────────────┐
│                 producers                   │
|  INPUTS:                                    |
|   • kinesis_stream_arn                      |
|   • ecr_image_uri                           |
|   • kinesis_stream_name                     |
|   • vpc_id                                  |
|   • ecs_subnets_ids                         |
└─────────────────────────────────────────────┘
┌─────────────────────────────────────────────┐
│                 consumers                   │
|  INPUTS:                                    |
|   • kinesis_stream_arn                      |
|   • data_stream_s3_bucket_id                |
│  OUTPUTS:                                   │
|   • lambda_function_arn ────────────────────┼─────▶ used by 
│   • dynamodb_table_name ────────────────────┼─────▶ used by 
|   • dynamodb_table_arn ─────────────────────┼─────▶ used by 
└─────────────────────────────────────────────┘
┌─────────────────────────────────────────────┐
│                 analytics                   │
|  INPUTS:                                    |
|   • data_stream_s3_bucket_id                |
│  OUTPUTS:                                   │
│   • alb_dns_name ───────────────────────────┼─────▶ used by global/cdn_dns
│   • alb_zone_id ────────────────────────────┼─────▶ used by global/cdn_dns (to create a Route 53 primary record for admin access)
│   • target_group_arn ───────────────────────┼─────▶ used by primary/ecs
|   • target_group_arn_suffix ────────────────┼─────▶ used by primary/ecs
|   • alb_arn_suffix ─────────────────────────┼─────▶ used by primary/ecs
└─────────────────────────────────────────────┘