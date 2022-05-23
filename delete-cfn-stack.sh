set -e 
WORKING_FOLDER=$(pwd)

log_action() {
    echo "${1^^} ..."
}

log_key_value_pair() {
    echo "    $1: $2"
}

set_up_aws_user_credentials() {
    unset AWS_SESSION_TOKEN
    export AWS_DEFAULT_REGION=$1
    export AWS_ACCESS_KEY_ID=$2
    export AWS_SECRET_ACCESS_KEY=$3
}

assume_role() {
    local CREDENTIALS_FILE_NAME="aws-credentials-$(basename "$0").json"
    if [[ ! -f "$CREDENTIALS_FILE_NAME" ]]; then
        local AWS_ACCOUNT_ID=$1
        local ROLE_NAME=$2
        local ROLE_ARN="arn:aws:iam::$AWS_ACCOUNT_ID:role/$ROLE_NAME"
        aws sts assume-role --role-arn $ROLE_ARN --role-session-name github-session > $CREDENTIALS_FILE_NAME
    fi

    export AWS_ACCESS_KEY_ID=$(jq -r '.Credentials.AccessKeyId' $CREDENTIALS_FILE_NAME)
    export AWS_SECRET_ACCESS_KEY=$(jq -r '.Credentials.SecretAccessKey' $CREDENTIALS_FILE_NAME)
    export AWS_SESSION_TOKEN=$(jq -r '.Credentials.SessionToken' $CREDENTIALS_FILE_NAME)
}

log_action "deleting cloudformation stack"
REGION=$1
log_key_value_pair "region" $REGION
ACCESS_KEY=$2
log_key_value_pair "access-key" $ACCESS_KEY
SECRET_KEY=$3
ACCOUNT_ID=$4
log_key_value_pair "account-id" $ACCOUNT_ID
ROLE_NAME=$5
log_key_value_pair "role-name" $ROLE_NAME
STACK_NAME=$6
log_key_value_pair "stack-name" $STACK_NAME

set_up_aws_user_credentials $REGION $ACCESS_KEY $SECRET_KEY
assume_role $ACCOUNT_ID $ROLE_NAME

STACK=$(aws cloudformation describe-stacks --stack-name $STACK_NAME | jq -r '.Stacks[0]')
if [ -z "$STACK" ]; 
then
    log_action "stack does not exist. nothing to do"
else
    log_action "deleting stack"
    STACK_ARN=$(aws cloudformation describe-stacks --stack-name $STACK_NAME | jq -r '.Stacks[0].StackId')
    log_key_value_pair "stack-arn" $STACK_ARN
    aws cloudformation delete-stack --stack-name $STACK_NAME
    aws cloudformation wait stack-delete-complete --stack-name $STACK_ARN
fi 