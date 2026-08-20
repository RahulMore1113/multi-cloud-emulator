Write-Host "[START] Bringing up AWS Floci emulator profile..."
docker compose --profile aws up -d

Write-Host "[WAIT] Waiting 15 seconds for AWS emulator to initialize..."
Start-Sleep -Seconds 15

Write-Host "[ACTION] Creating test S3 bucket via CLI container..."
docker exec floci-aws-cli aws --endpoint-url=http://floci-aws:4566 s3 mb s3://floci-aws-test-bucket

Write-Host "[ACTION] Tearing down AWS stack to test persistence..."
docker compose --profile aws down

Write-Host "[START] Restarting AWS Floci emulator profile..."
docker compose --profile aws up -d

Write-Host "[WAIT] Waiting 15 seconds for AWS emulator to recover..."
Start-Sleep -Seconds 15

Write-Host "[VERIFY] Listing S3 buckets. If 'floci-aws-test-bucket' appears, persistence is working."
docker exec floci-aws-cli aws --endpoint-url=http://floci-aws:4566 s3 ls

Write-Host "[COMPLETE] AWS test finished."