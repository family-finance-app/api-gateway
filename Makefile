.PHONY: help up down restart logs status test clean

# Colors for output
GREEN=\033[0;32m
YELLOW=\033[1;33m
RED=\033[0;31m
NC=\033[0m # No Color

help: ## Show help
	@echo "$(GREEN)Family Finance API Gateway$(NC)"
	@echo "$(YELLOW)Available commands:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'

up: ## Start all services
	@echo "$(GREEN)Starting API Gateway...$(NC)"
	docker-compose up -d
	@echo "$(GREEN)Services started. Check: http://localhost/health$(NC)"

down: ## Stop all services
	@echo "$(YELLOW)Stopping services...$(NC)"
	docker-compose down

restart: down up ## Restart all services

logs: ## Show logs of all services
	docker-compose logs -f

logs-gateway: ## Show only gateway logs
	docker-compose logs -f nginx-gateway

status: ## Show status of services
	@echo "$(GREEN)Service status:$(NC)"
	@docker-compose ps
	@echo ""
	@echo "$(GREEN)Checking health endpoint:$(NC)"
	@curl -s http://localhost/health 2>/dev/null && echo " ✓ Gateway available" || echo " ✗ Gateway unavailable"

test: ## Run basic API tests
	@echo "$(GREEN)Testing API Gateway...$(NC)"
	@echo "$(YELLOW)1. Health check:$(NC)"
	@curl -s http://localhost/health && echo " ✓"
	@echo "$(YELLOW)2. Gateway info:$(NC)"
	@curl -s http://localhost/ | head -c 100 && echo "... ✓"
	@echo "$(YELLOW)3. CORS preflight:$(NC)"
	@curl -s -X OPTIONS -H "Origin: http://localhost:3000" http://localhost/api/auth/ -I | grep -i "access-control" && echo " ✓"

build: ## Rebuild and start
	docker-compose up -d --build

clean: ## Clean unused Docker resources
	@echo "$(YELLOW)Cleaning Docker resources...$(NC)"
	docker system prune -f
	docker volume prune -f

config-test: ## Check NGINX configuration
	@echo "$(GREEN)Checking NGINX configuration...$(NC)"
	docker-compose exec nginx-gateway nginx -t

reload: ## Reload NGINX configuration without stopping
	@echo "$(GREEN)Reloading NGINX configuration...$(NC)"
	docker-compose exec nginx-gateway nginx -s reload

shell: ## Open shell in gateway container
	docker-compose exec nginx-gateway sh

# Service management
stop-auth: ## Stop auth service
	@echo "$(YELLOW)Stopping auth service...$(NC)"
	docker-compose stop auth-service

stop-accounts: ## Stop account service
	@echo "$(YELLOW)Stopping account service...$(NC)"
	docker-compose stop account-service

stop-transactions: ## Stop transaction service
	@echo "$(YELLOW)Stopping transaction service...$(NC)"
	docker-compose stop transaction-service

start-auth: ## Start auth service
	@echo "$(GREEN)Starting auth service...$(NC)"
	docker-compose up -d auth-service

start-accounts: ## Start account service
	@echo "$(GREEN)Starting account service...$(NC)"
	docker-compose up -d account-service

start-transactions: ## Start transaction service
	@echo "$(GREEN)Starting transaction service...$(NC)"
	docker-compose up -d transaction-service

restart-auth: ## Restart auth service
	@echo "$(YELLOW)Restarting auth service...$(NC)"
	docker-compose restart auth-service

restart-accounts: ## Restart account service
	@echo "$(YELLOW)Restarting account service...$(NC)"
	docker-compose restart account-service

restart-transactions: ## Restart transaction service
	@echo "$(YELLOW)Restarting transaction service...$(NC)"
	docker-compose restart transaction-service

# For development
dev-setup: ## Setup development environment
	@echo "$(GREEN)Setting up development environment...$(NC)"
	@if [ ! -f .env ]; then \
		echo "$(YELLOW)Creating .env file...$(NC)"; \
		cp .env.example .env 2>/dev/null || echo "# Environment variables" > .env; \
	fi
	@echo "$(GREEN)Done! Run 'make up' to start$(NC)"