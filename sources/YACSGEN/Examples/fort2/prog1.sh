#!/bin/bash

script_path=$(dirname $(readlink -f $0))
$script_path/prog1

echo "End of shell"

