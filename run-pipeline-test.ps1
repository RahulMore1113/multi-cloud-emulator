Write-Host "[START] Setting up clean local workspace..."
mkdir -p cloud-data/aws, cloud-data/azure, cloud-data/gcp -ErrorAction SilentlyContinue

Write-Host "[START] Bringing up the entire multi-cloud stack..."
docker compose --profile all up -d

Write-Host "[WAIT] Waiting 20 seconds for all emulators to initialize..."
Start-Sleep -Seconds 20

Write-Host "[CHECK] Verifying container health..."
docker compose ps

Write-Host "[TEST] Running AWS S3 validation..."
docker exec floci-aws-cli aws --endpoint-url=http://floci-aws:4566 s3 mb s3://gh-actions-aws-bucket
docker exec floci-aws-cli aws --endpoint-url=http://floci-aws:4566 s3 ls

Write-Host "[TEST] Running Azure Blob validation..."
$ConnString = "DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://floci-azure:4577/devstoreaccount1;"
docker exec floci-azure-cli az storage container create --name gh-actions-azure-container --connection-string $ConnString
docker exec floci-azure-cli az storage container list --connection-string $ConnString --output table

Write-Host "[TEST] Running GCP Storage validation..."
docker exec floci-gcp-cli gcloud config set core/project floci-ci
docker exec floci-gcp-cli gcloud config set api_endpoint_overrides/storage http://floci-gcp:4588/
docker exec floci-gcp-cli gcloud config set auth/disable_credentials true
docker exec floci-gcp-cli gcloud storage buckets create gs://gh-actions-gcp-bucket --project=floci-ci
docker exec floci-gcp-cli gcloud storage buckets list --project=floci-ci

Write-Host "[TEARDOWN] Cleaning up environment..."
docker compose --profile all down

Write-Host "[COMPLETE] Local pipeline simulation finished successfully!"