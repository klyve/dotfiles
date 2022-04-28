# Sign in to ECR 
function ecr-login {
    REGION=${AWS_REGION:-eu-central-1}  # Region to authenticate against
    PROFILE=${AWS_PROFILE:-default}     # AWS profile to use
    $(aws ecr get-login --no-include-email --region $REGION --profile $PROFILE)
}

# Get the aws-iam-authenticator token
function aws-token {
    TOKEN_ENV=${1:-$AWS_ENVIRONMENT}
    if [ -z "$TOKEN_ENV" ]; then
        echo "Argument (environment) or env var AWS_ENVIRONMENT must be set to run this command"
    else
        aws-iam-authenticator token -i $TOKEN_ENV | jq '.status.token' --raw-output
    fi
}

# Authenticate with samlAuth using aws-google-auth
function aws-saml-auth {
    IPD_ID=${GIP_ID} # Google SSO IDP identifier
    SP_ID=${GSP_ID} # Google SSO SP identifier
    DURATION=${AWS_DURATION:-28800} # Duration set for the aws role
    REGION=${AWS_REGION:-eu-central-1} # Region to authenticate against
    PROFILE=${AWS_PROFILE:-default} # AWS profile to use
    SAML_USER=${1:-$GSAML_USER} # Saml user or first input to use for authentication

    # [-a] Saves password in keychain
    # [-k] Always ask for iam role
    aws-google-auth -u $SAML_USER -I $IPD_ID -S $SP_ID -R $REGION -d $DURATION -p $PROFILE -a -k
}
