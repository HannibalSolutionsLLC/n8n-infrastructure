#!/bin/bash

# Stop n8n and ngrok services script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

COMPOSE_FILE="docker-compose.yml"

echo -e "${BLUE}🛑 Stopping n8n and ngrok services...${NC}"

docker compose -f "$COMPOSE_FILE" down

echo -e "${GREEN}✅ All services stopped${NC}"
