#!/usr/bin/env bash

curl -f -s -H 'Cache-Control: no-cache' http://192.168.13.80:3000/sleechengn/maxun-local
exit_code=$?
echo "exit_code=$exit_code"

if [ ! -e "$(dirname $0)/maxun" ]; then
    
    if [ $exit_code -eq 0 ]; then
        git clone http://192.168.13.80:3000/sleechengn/getmaxun--maxun $(dirname $0)/maxun
    else
        git clone https://github.com/getmaxun/maxun $(dirname $0)/maxun
    fi

    rm -rf $(dirname $0)/maxun/.git
    rm -rf $(dirname $0)/maxun/.github
    rm -rf $(dirname $0)/maxun/docker-compose.yml
    rm -rf $(dirname $0)/maxun/.env
    rm -rf $(dirname $0)/maxun/conf.d

    cp -ra docker-compose.yml $(dirname $0)/maxun
    cp -ra .env $(dirname $0)/maxun
    cp -ra conf.d $(dirname $0)/maxun

    cd $(dirname $0)/maxun
    mkdir -p ./volumes/maxun/{postgres,minio}

    if [ $exit_code -eq 0 ]; then
        sed -i "s#FROM mcr.microsoft.com/playwright:v1.57.0-jammy.*#FROM 192.168.13.73:5000/mcr.microsoft.com/playwright:v1.57.0-jammy#g" browser/Dockerfile
        sed -i "s#FROM node:20-slim.*#FROM 192.168.13.73:5000/node:20-slim#g" Dockerfile.backend
        sed -i "s#FROM node:18-alpine AS builder.*#FROM 192.168.13.73:5000/node:18-alpine AS builder#g" Dockerfile.frontend
        sed -i "/# Install dependencies.*/a\\RUN npm config set registry https://registry.npmmirror.com/" Dockerfile.backend
    else
        sed -i "s@192.168.13.73:5000/@@g" docker-compose.yml
    fi
    #sed -i '/# Build TypeScript server.*/a\\ENV INLINE_RUNTIME_CHUNK=false' Dockerfile.backend
    sed -i '/# Build TypeScript server.*/a\\ENV NODE_OPTIONS="--max-old-space-size=4096"' Dockerfile.backend
else
    rm -rf $(dirname $0)/maxun/docker-compose.yml
    rm -rf $(dirname $0)/maxun/.env
    rm -rf $(dirname $0)/maxun/conf.d

    cp -ra docker-compose.yml $(dirname $0)/maxun
    cp -ra .env $(dirname $0)/maxun
    cp -ra conf.d $(dirname $0)/maxun
    cd $(dirname $0)/maxun

    if [ ! $exit_code -eq 0 ]; then
        sed -i "s@192.168.13.73:5000/@@g" docker-compose.yml
    fi
fi

docker compose up -d
