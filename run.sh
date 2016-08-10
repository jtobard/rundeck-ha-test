#!/bin/bash
# Check we are in correct dir.
SCRIPTFILE=$(readlink -f "$0")
SCRIPTDIR=$(dirname "$SCRIPTFILE")
cd $SCRIPTDIR

set -e

# RUN DR TEST
test-dr/run.sh

#Run Cluster Test
test-cluster/run.sh
