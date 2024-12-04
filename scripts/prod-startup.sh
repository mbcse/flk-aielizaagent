#!/bin/sh

# Set working directory
cd /app

# Verify character file exists
if [ ! -f "/app/characters/fleek.character.json" ]; then
   echo "Character file not found!"
   exit 1
fi

# Start services with proper paths
pnpm start --character="/app/characters/fleek.character.json" &
SERVER_PID=$!

pnpm start:client &
CLIENT_PID=$!

# Log PIDs
echo "Server PID: $SERVER_PID"
echo "Client PID: $CLIENT_PID"

# Monitor both processes
wait $SERVER_PID $CLIENT_PID

# Exit with status of failed process
exit $?