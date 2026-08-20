#!/bin/bash
set -e

echo "🚀 Starting Floci AWS profile..."
docker compose --profile aws up -d

echo "⏳ Waiting for Floci AWS to initialize (10 seconds)..."
sleep 10

echo "🪣 Creating an S3 bucket (my-persistent-bucket)..."
docker exec floci-aws-cli aws --endpoint-url http://floci-aws:4566 s3 mb s3://my-persistent-bucket

echo "🛑 Stopping and removing containers to test persistence..."
docker compose --profile aws down

echo "🚀 Restarting Floci AWS profile..."
docker compose --profile aws up -d

echo "⏳ Waiting for Floci AWS to initialize (10 seconds)..."
sleep 10

echo "🔍 Fetching S3 bucket list to verify persistence..."
docker exec floci-aws-cli aws --endpoint-url http://floci-aws:4566 s3 ls

echo "✅ Test completed successfully."