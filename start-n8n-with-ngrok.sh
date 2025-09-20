#!/bin/bash

# n8n with ngrok startup script
# This script starts ngrok first, extracts the URL, updates .env, and starts all services

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
COMPOSE_FILE="docker-compose.yml"
ENV_FILE=".env"
ENV_EXAMPLE=".env.example"
NGROK_SERVICE="ngrok"
N8N_SERVICE="n8n"
TIMEOUT=60  # Timeout in seconds to wait for ngrok URL

echo -e "${BLUE}🚀 Starting n8n with ngrok setup...${NC}"

# Check if .env exists, if not copy from .env.example
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${YELLOW}📋 Creating .env file from .env.example...${NC}"
    cp "$ENV_EXAMPLE" "$ENV_FILE"
    echo -e "${GREEN}✅ .env file created${NC}"
else
    echo -e "${GREEN}✅ .env file already exists${NC}"
fi

# Start only ngrok service first
echo -e "${BLUE}🌐 Starting ngrok service...${NC}"
docker compose -f "$COMPOSE_FILE" up -d "$NGROK_SERVICE"

# Wait for ngrok to start and get the URL
echo -e "${YELLOW}⏳ Waiting for ngrok to generate URL (timeout: ${TIMEOUT}s)...${NC}"

NGROK_URL=""
for i in $(seq 1 $TIMEOUT); do
    # Get ngrok logs and extract URL
    NGROK_LOGS=$(docker compose -f "$COMPOSE_FILE" logs "$NGROK_SERVICE" 2>/dev/null || echo "")
    
    # Look for the ngrok URL in the logs (supports both .ngrok.io and .ngrok-free.app)
    NGROK_URL=$(echo "$NGROK_LOGS" | grep -o 'https://[a-zA-Z0-9-]*\.ngrok[^[:space:]]*' | head -1)
    
    if [ -n "$NGROK_URL" ]; then
        echo -e "${GREEN}✅ Found ngrok URL: $NGROK_URL${NC}"
        break
    fi
    
    if [ $i -eq $TIMEOUT ]; then
        echo -e "${RED}❌ Timeout: Could not find ngrok URL after ${TIMEOUT} seconds${NC}"
        echo -e "${YELLOW}📋 Ngrok logs:${NC}"
        docker compose -f "$COMPOSE_FILE" logs "$NGROK_SERVICE"
        exit 1
    fi
    
    echo -n "."
    sleep 1
done

# Update .env file with the ngrok URL
echo -e "${BLUE}📝 Updating .env file with ngrok URL...${NC}"

# Extract just the hostname (without https://)
NGROK_HOST=$(echo "$NGROK_URL" | sed 's|https://||')

# Update N8N_HOST
sed -i "s|N8N_HOST=.*|N8N_HOST=$NGROK_HOST|" "$ENV_FILE"

# Update WEBHOOK_URL
sed -i "s|WEBHOOK_URL=.*|WEBHOOK_URL=$NGROK_URL/|" "$ENV_FILE"

echo -e "${GREEN}✅ Updated .env file:${NC}"
echo -e "   N8N_HOST=$NGROK_HOST"
echo -e "   WEBHOOK_URL=$NGROK_URL/"

# Start all other services
echo -e "${BLUE}🐳 Starting all services...${NC}"
docker compose -f "$COMPOSE_FILE" up -d

# Wait a moment for services to start
sleep 5

# Show service status
echo -e "${BLUE}📊 Service Status:${NC}"
docker compose -f "$COMPOSE_FILE" ps

echo -e "${GREEN}🎉 Setup complete!${NC}"
echo -e "${BLUE}📱 Access services at:${NC}"
echo -e "   n8n (Local):  http://localhost:5678"
echo -e "   n8n (Public): $NGROK_URL"
echo -e "   n8n MCP:      http://localhost:3001"
echo -e "   Ngrok UI:     http://localhost:4040"
echo -e "   Qdrant:       http://localhost:6333"
echo ""
echo -e "${YELLOW}💡 To view logs:${NC}"
echo -e "   docker compose -f $COMPOSE_FILE logs -f"
echo ""
echo -e "${YELLOW}🛑 To stop services:${NC}"
echo -e "   docker compose -f $COMPOSE_FILE down"
