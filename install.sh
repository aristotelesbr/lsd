#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Installing LSD...${NC}"

if ! command -v ruby &> /dev/null; then
    echo -e "${RED}Ruby not found. Please install Ruby >= 2.7${NC}"
    exit 1
fi

ruby_version=$(ruby -v | cut -d' ' -f2)
required_version="2.7.0"

if [ "$(printf '%s\n' "$required_version" "$ruby_version" | sort -V | head -n1)" = "$required_version" ]; then 
    echo -e "${GREEN}✓ Ruby $ruby_version found${NC}"
else
    echo -e "${RED}Ruby >= 2.7.0 is required. Current version: $ruby_version${NC}"
    exit 1
fi

echo "Installing dependencies..."
if ! command -v bundle &> /dev/null; then
    gem install bundler
fi
bundle install

mkdir -p /usr/local/bin

echo "Installing executable..."
sudo cp bin/lsd /usr/local/bin/
sudo chmod +x /usr/local/bin/lsd

if command -v lsd &> /dev/null; then
    echo -e "${GREEN}✓ LSD installed successfully!${NC}"
    echo -e "Run ${YELLOW}lsd --help${NC} to see available options"
else
    echo -e "${RED}Error installing LSD${NC}"
    exit 1
fi
