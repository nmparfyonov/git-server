#!/bin/bash

# Check SSHD is running
if ! pgrep sshd > /dev/null; then
    echo "SSHD is not running"
    exit 1
fi

echo "SSHD is healthy"
exit 0