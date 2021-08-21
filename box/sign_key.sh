#!/usr/bin/env bash

set -e

input="$(cat)"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

ca_key="$tmp_dir/ca.key"
echo "$input" | jq -r '.ca_key' >"$ca_key"
chmod 600 "$ca_key"

host_pub_key="$tmp_dir/host.pub"
echo "$input" | jq -r '.host_pub_key' >"$host_pub_key"
cat "$host_pub_key" >/tmp/pub
chmod 600 "$host_pub_key"

hostname="$(echo "$input" | jq -r .hostname)"

ssh-keygen -s "$ca_key" -I "$hostname" -h "$host_pub_key"

jq -n --arg cert "$(cat "$tmp_dir/host-cert.pub")" '{"cert":$cert}'
