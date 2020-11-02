#!/usr/bin/env bash

source ./params

## invoke with ssh.
#
# ssh $ONTAP_ADMIN@$ONTAP_CLUSTER_MGMT_IP security certificate install -vserver $ANSIBLE_SVM -type client-ca
#

JSON="{\
    \"svm\": {\
        \"name\": \"$ANSIBLE_SVM\"\
    },\
    \"type\": \"client-ca\",\
    \"public_certificate\": \"`cat $PUBLICKEY_FILE`\"\
}"

curl "https://$ONTAP_CLUSTER_MGMT_IP/api/security/certificates" \
    -k \
    -X POST \
    -H "accept: application/json" \
    -H "Content-Type: application/json" \
    -u "$ONTAP_ADMIN" \
    -d "$JSON"
