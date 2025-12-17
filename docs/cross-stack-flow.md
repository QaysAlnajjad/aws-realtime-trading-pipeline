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
└─────────────────────────────────────────────┘
┌─────────────────────────────────────────────┐
│                 analytics                   │
|  INPUTS:                                    |
|   • data_stream_s3_bucket_id                |
└─────────────────────────────────────────────┘