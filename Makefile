DC = sudo docker compose
APP_NAME = rmi-webhook
IMAGE = rmi-local

# Build Commands
.PHONY: build up down ps
build:
	$(DC) build

up:
	$(DC) up -d

down:
	$(DC) down

ps:
	$(DC) ps