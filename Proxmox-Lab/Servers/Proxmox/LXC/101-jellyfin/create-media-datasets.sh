#!/usr/bin/env bash
set -euo pipefail

POOL="mediapool"
PARENT_DATASET="${POOL}/streaming"

# Create parent dataset if it does not exist
if ! zfs list -H -o name "${PARENT_DATASET}" >/dev/null 2>&1; then
  zfs create \
    -o mountpoint=/mediapool/streaming \
    "${PARENT_DATASET}"
fi

# Common properties for media datasets:
# - compression=lz4   : cheap, auto-skips incompressible video, still compresses metadata
# - atime=off         : avoid extra writes on HDDs
# - recordsize=1M     : better for large sequential media I/O
# - exec=off          : no need to execute binaries from media datasets
COMMON_OPTS=(
  -o compression=lz4
  -o atime=off
  -o recordsize=1M
  -o exec=off
)

# Movies dataset
if ! zfs list -H -o name "${PARENT_DATASET}/movies" >/dev/null 2>&1; then
  zfs create \
    -o mountpoint=/mediapool/streaming/movies \
    "${COMMON_OPTS[@]}" \
    "${PARENT_DATASET}/movies"
fi

# Shows dataset
if ! zfs list -H -o name "${PARENT_DATASET}/shows" >/dev/null 2>&1; then
  zfs create \
    -o mountpoint=/mediapool/streaming/shows \
    "${COMMON_OPTS[@]}" \
    "${PARENT_DATASET}/shows"
fi

echo "Datasets created/configured:"
zfs list -o name,mountpoint,compression,atime,recordsize,exec | grep "^${PARENT_DATASET}"
