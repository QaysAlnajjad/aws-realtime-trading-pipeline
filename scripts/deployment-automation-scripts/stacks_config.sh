# stacks_config.sh

declare -A STACK_VARS

STACK_VARS["foundation"]="\
  var-file=foundation.tfvars"

STACK_VARS["data-streaming"]="\
  var s3_busket_name=$DATA_STREAM_S3_BUCKET_NAME \
  var-file=data-streaming.tfvars"

STACK_VARS["producers"]="\
  -var state_bucket_name=$TF_STATE_BUCKET_NAME \
  -var state_bucket_region=$TF_STATE_BUCKET_REGION \
  -var-file=producers.tfvars" 

STACK_VARS["consumers"]="\
  -var state_bucket_name=$TF_STATE_BUCKET_NAME \
  -var state_bucket_region=$TF_STATE_BUCKET_REGION \
  -var-file=consumers.tfvars"

STACK_VARS["analytics"]="\
  -var state_bucket_name=$TF_STATE_BUCKET_NAME \
  -var state_bucket_region=$TF_STATE_BUCKET_REGION \
  -var athena_results_bucket_name=$ATHENA_RESULTS_BUCKET_NAME \
  -var-file=analytics.tfvars"
