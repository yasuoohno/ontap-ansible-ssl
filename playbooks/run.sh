#!/usr/bin/env bash

ansible-galaxy collection install -r collections.yml

ansible-playbook -i inventory.yml cluster.yml

