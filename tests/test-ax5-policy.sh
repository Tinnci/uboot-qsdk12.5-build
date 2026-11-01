#!/bin/sh
set -eu
root=$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
for mode in board other; do
 flag=
 [ "$mode" = other ] || flag=-DCONFIG_TARGET_IPQ6018_REDMI_AX5_JDCLOUD
 cc -std=c99 -Wall -Wextra -Werror ${flag:+$flag} -I"$root/tests/stubs" \
   -I"$root/u-boot-2016/include" "$root/tests/ax5-policy.c" -o "$work/$mode"
 "$work/$mode"
done
echo 'AX5 and other-board policy tests passed'
