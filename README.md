# n8n Infrastructure with Ngrok

This infrastructure setup provides a self-hosted n8n instance with ngrok for webhook access.

## Services

- **n8n**: Workflow automation platform
- **PostgreSQL**: Database for n8n
- **Qdrant**: Vector database for AI applications
- **n8n MCP Server**: Model Context Protocol server for n8n workflow development
- **ngrok**: Public tunnel for webhook access

## Quick Start

### 1. Setup Environment

```bash
# Copy environment template
cp .env.example .env

# Edit .env if needed (optional - script will auto-update URLs)
nano .env
```

### 2. Start Services

```bash
# Automated startup (recommended)
./start-n8n-with-ngrok.sh

# Or manual startup
docker compose up -d
```

### 3. Access Services

- **n8n**: http://localhost:5678 (local) or https://your-ngrok-url.ngrok.io (public)
- **n8n MCP Server**: http://localhost:3001
- **ngrok UI**: http://localhost:4040
- **Qdrant**: http://localhost:6333

## Scripts

### `start-n8n-with-ngrok.sh`
Automated startup script that:
1. Starts ngrok service first
2. Extracts the generated ngrok URL
3. Updates .env file with the URL
4. Starts all other services

### `stop-n8n.sh`
Stops all services

## Manual Commands

```bash
# Start all services
docker compose up -d

# Start only ngrok
docker compose up -d ngrok

# View logs
docker compose logs -f

# Stop all services
docker compose down

# Restart n8n only
docker compose restart n8n
```

## Environment Variables

Key variables in `.env`:

- `NGROK_AUTHTOKEN`: Your ngrok authentication token
- `N8N_HOST`: n8n hostname (auto-updated by script)
- `WEBHOOK_URL`: Webhook URL (auto-updated by script)
- `N8N_PROTOCOL`: Protocol (https for ngrok)

## Troubleshooting

### Ngrok URL not found
- Check ngrok logs: `docker compose logs ngrok`
- Ensure NGROK_AUTHTOKEN is valid
- Wait a bit longer for ngrok to start

### n8n not accessible
- Check if all services are running: `docker compose ps`
- Verify .env file has correct URLs
- Restart n8n: `docker compose restart n8n`

### Webhook issues
- Ensure WEBHOOK_URL in .env matches your ngrok URL
- Check ngrok UI at http://localhost:4040 for request logs

