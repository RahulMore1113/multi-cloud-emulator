Write-Host "[START] Bringing up Azure Floci emulator profile..."
docker compose --profile azure up -d

Write-Host "[WAIT] Waiting 15 seconds for Azure emulator to initialize..."
Start-Sleep -Seconds 15

$ConnString = "DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://floci-azure:4577/devstoreaccount1;"

Write-Host "[ACTION] Creating test Blob container via CLI container..."
docker exec floci-azure-cli az storage container create --name floci-azure-test-container --connection-string $ConnString

Write-Host "[ACTION] Tearing down Azure stack to test persistence..."
docker compose --profile azure down

Write-Host "[START] Restarting Azure Floci emulator profile..."
docker compose --profile azure up -d

Write-Host "[WAIT] Waiting 15 seconds for Azure emulator to recover..."
Start-Sleep -Seconds 15

Write-Host "[VERIFY] Listing Blob containers. If 'floci-azure-test-container' appears, persistence is working."
docker exec floci-azure-cli az storage container list --connection-string $ConnString --output table

Write-Host "[COMPLETE] Azure test finished."