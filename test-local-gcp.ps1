Write-Host "[START] Bringing up GCP Floci emulator profile..."
docker compose --profile gcp up -d

Write-Host "[WAIT] Waiting 15 seconds for GCP emulator to initialize..."
Start-Sleep -Seconds 15

Write-Host "[ACTION] Configuring GCP CLI for local emulation..."
docker exec floci-gcp-cli gcloud config set core/project floci-local
docker exec floci-gcp-cli gcloud config set api_endpoint_overrides/storage http://floci-gcp:4588/
docker exec floci-gcp-cli gcloud config set auth/disable_credentials true

Write-Host "[ACTION] Creating test Google Cloud Storage bucket via CLI container..."
docker exec floci-gcp-cli gcloud storage buckets create gs://floci-gcp-test-bucket --project=floci-local

Write-Host "[ACTION] Tearing down GCP stack to test persistence..."
docker compose --profile gcp down

Write-Host "[START] Restarting GCP Floci emulator profile..."
docker compose --profile gcp up -d

Write-Host "[WAIT] Waiting 15 seconds for GCP emulator to recover..."
Start-Sleep -Seconds 15

Write-Host "[VERIFY] Re-applying configuration and listing GCS buckets to verify persistence."
docker exec floci-gcp-cli gcloud config set core/project floci-local
docker exec floci-gcp-cli gcloud config set api_endpoint_overrides/storage http://floci-gcp:4588/
docker exec floci-gcp-cli gcloud config set auth/disable_credentials true
docker exec floci-gcp-cli gcloud storage buckets list --project=floci-local

Write-Host "[COMPLETE] GCP test finished."