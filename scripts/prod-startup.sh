#!/bin/sh
# startup.sh

# Start both services
pnpm start &
pnpm client:start &

# Wait for any process to exit
wait

# Exit with status of process that exited first
exit $?