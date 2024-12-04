# Use a specific Node.js version for better reproducibility
FROM --platform=linux/amd64 node:23.3.0-slim AS builder

# Install pnpm globally and install necessary build tools
RUN npm install -g pnpm@9.4.0 sqlite-vec && \
    apt-get update && \
    apt-get install -y git python3 make g++ libsqlite3-dev gcc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set Python 3 as the default python
RUN ln -s /usr/bin/python3 /usr/bin/python

# Set the working directory
WORKDIR /app

# Copy package.json and other configuration files
COPY package.json pnpm-workspace.yaml .npmrc turbo.json ./

# Copy the rest of the application code
COPY agent ./agent
COPY packages ./packages
COPY scripts ./scripts
COPY characters ./characters
COPY client ./client

# Install dependencies and build the project
RUN pnpm install \
    && pnpm build \
    && pnpm prune --prod

# Create a new stage for the final image
FROM --platform=linux/amd64 node:23.3.0-slim

# Install runtime dependencies if needed
RUN npm install -g pnpm@9.4.0 sqlite-vec && \
    apt-get update && \
    apt-get install -y git python3 make g++ libsqlite3-dev gcc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy built artifacts and production dependencies from the builder stage
COPY --from=builder /app/package.json ./
COPY --from=builder /app/pnpm-workspace.yaml ./
COPY --from=builder /app/.npmrc ./
COPY --from=builder /app/turbo.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/agent ./agent
COPY --from=builder /app/packages ./packages
COPY --from=builder /app/scripts ./scripts
COPY --from=builder /app/characters ./characters
COPY --from=builder /app/client ./client

# Set the command to run the application
# CMD ["pnpm", "start", "--non-interactive"]

# Copy the startup script
# COPY scripts/prod-startup.sh ./
# RUN chmod +x prod-startup.sh

CMD ["pnpm", "start", "--character=/app/characters/fleek.character.json"]


