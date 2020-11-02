#!/usr/bin/env bash

source ./params

## invoke with ssh.
#
# ssh $ONTAP_ADMIN@$ONTAP_CLUSTER_MGMT_IP security ssl modify -vserver $ANSIBLE_SVM -client-enabled true
# ssh $ONTAP_ADMIN@$ONTAP_CLUSTER_MGMT_IP security login create -vserver $ANSIBLE_SVM -user-or-group-name $ANSIBLE_USER -application ontapi -authentication-method cert
# ssh $ONTAP_ADMIN@$ONTAP_CLUSTER_MGMT_IP security login create -vserver $ANSIBLE_SVM -user-or-group-name $ANSIBLE_USER -application http   -authentication-method cert

curl "https://$ONTAP_CLUSTER_MGMT_IP/api/private/cli/security/ssl?vserver=$ANSIBLE_SVM" \
    -k \
    -X PATCH \
    -H "accept: application/json" \
    -H "Content-Type: application/json" \
    -u "$ANSIBLE_USER" \
    -d '{ "client-enabled": true }'

echo .

ANSIBLE_SVM_UUID=`curl -s -k -u $ONTAP_ADMIN -X GET -H "accept: application/json" "https://$ONTAP_CLUSTER_MGMT_IP/api/private/cli/vserver?vserver=$ANSIBLE_SVM&fields=uuid" | jq -r ".records[0].uuid"`

echo "ANSIBLE SVM UUID = $ANSIBLE_SVM_UUID"

CURRENT_APPS=`curl -s -k -u $ONTAP_ADMIN -X GET -H "accept: application/json" "https://$ONTAP_CLUSTER_MGMT_IP/api/security/accounts/$ANSIBLE_SVM_UUID/$ANSIBLE_USER" | jq -r ".applications"`

echo "Current applications for $ANSIBLE_USER@$ANSIBLE_SVM = "
echo "$CURRENT_APPS" | jq

read -p "Hit any key to continue: " -n 1 -r
echo

NEW_APPS=`echo "$CURRENT_APPS" | jq -r '. + [{ "application": "ontapi", "authentication_methods": ["certificate"] },{ "application": "http", "authentication_methods": ["certificate"] }]'`
echo "New applications for $ANSIBLE_USER@$ANSIBLE_SVM = "
echo "$NEW_APPS" | jq

read -p "Please confirm the applications and hit any key to continue: " -n 1 -r

JSON="{\
    \"applications\": $NEW_APPS
}"

curl "https://$ONTAP_CLUSTER_MGMT_IP/api/security/accounts/$ANSIBLE_SVM_UUID/$ANSIBLE_USER" \
    -k \
    -X PATCH \
    -H "accept: application/json" \
    -H "Content-Type: application/json" \
    -u "$ONTAP_ADMIN" \
    -d "$JSON"

