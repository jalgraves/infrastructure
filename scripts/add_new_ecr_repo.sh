#!/bin/bash
set -euo pipefail
# -e  Exit immediately if a command exits with a non-zero status
# -o pipefail  The return value of a pipeline is the status of
#              the last command to exit with a non-zero status

service_name=$1
file_path="./aws/ecr/modules/workspace_configs/outputs.tf"
line_to_add="    \"$service_name\","

# need to use $0 ~ pattern to match against a variable.
# -vpattern: pattern for new line
# -vline: line, which need to be added
awk -vpattern="repositories =" -vline="$line_to_add" '$0 ~ pattern {print; print line; next } 1' $file_path > tmpfile.tf

# Write result from tmpfile with new line to source file
mv tmpfile.tf $file_path
