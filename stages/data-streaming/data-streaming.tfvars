kinesis_data_stream_name = "trading-stream"

kinesis_firehose_name = "trading-firehose"

bucket_lifecycle_rules_config =  [
    {
        id = "raw_data_lifecycle"
        prefix = "raw-data/"
        transitions = [
            {
                days = 30
                storage_class = "STANDARD_IA"
            }
        ]
        expiration_days = 90
    },
    {
        id = "trading_signals_lifecycle"
        prefix = "trading-signals/"
        transitions = [
            {
                days = 30
                storage_class = "STANDARD_IA"
            },
            {
                days = 90
                storage_class = "GLACIER"
            }
        ]
        expiration_days = 365
    }
]

