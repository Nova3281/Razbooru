#!/bin/sh

cd "$(dirname $0)"
exec awk -f commands.awk