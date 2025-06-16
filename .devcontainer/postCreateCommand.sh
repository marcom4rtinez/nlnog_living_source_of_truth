#!/bin/bash

cd infrahub/

sleep 30

# Load infra-schema + infra-topology
poetry run invoke load-schema

# Wait a bit extra to be sure the schema are properly loaded
sleep 30

# Load infra-data
poetry run invoke load-data