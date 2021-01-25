#!/bin/bash
set -e
WHOIAMUSER="$(aws iam get-user | jq '.User.UserName'| xargs)"
echo $(jq -n --arg whoiamuser "$WHOIAMUSER" '{"iam_user":$whoiamuser}')