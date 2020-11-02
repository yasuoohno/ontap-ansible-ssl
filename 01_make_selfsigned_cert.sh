#!/usr/bin/env bash

source ./params

openssl req -x509 -nodes -days 1095 -newkey rsa:2048 -keyout $PRIVATEKEY_FILE -out $PUBLICKEY_FILE -subj "/O=$ONTAP_CLUSTER/OU=$ANSIBLE_SVM/CN=$ANSIBLE_USER"

ls $PRIVATEKEY_FILE $PUBLICKEY_FILE

