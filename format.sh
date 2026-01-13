#!/bin/sh
find . \( -name "*.yml" -o -name "*.yaml" \) -exec ./yamlfmt-linux-x86 {} +
./shfmt_v3.12.0_linux_amd64 -l -w src tests