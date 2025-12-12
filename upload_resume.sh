#!/bin/bash
# Script to upload resume to production API
# Usage: ./upload_resume.sh [path/to/resume.pdf]

API_URL="${API_URL:-https://din-api.onrender.com}"
FILE_PATH="${1:-storage/resume.pdf}"

if [ ! -f "$FILE_PATH" ]; then
  echo "Error: File not found at $FILE_PATH"
  echo "Usage: ./upload_resume.sh [path/to/resume.pdf]"
  exit 1
fi

echo "Uploading resume to $API_URL/api/v1/documents/upload_resume..."
echo "File: $FILE_PATH"

response=$(curl -s -w "\n%{http_code}" -X POST \
  "$API_URL/api/v1/documents/upload_resume" \
  -F "file=@$FILE_PATH")

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

echo ""
echo "HTTP Status: $http_code"
echo "Response:"
echo "$body" | jq '.' 2>/dev/null || echo "$body"

if [ "$http_code" -eq 201 ]; then
  echo ""
  echo "✓ Resume uploaded successfully!"
else
  echo ""
  echo "✗ Upload failed"
  exit 1
fi
