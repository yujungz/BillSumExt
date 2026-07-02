#!/bin/bash

# Ensure config.json points to the correct MySQL host (not the old external container)
if [ -f /app/data/config.json ]; then
    sed -i 's/"host": "test-mysql8"/"host": "billsum-mysql"/g' /app/data/config.json
    sed -i 's/"container_name": "test-mysql8"/"container_name": "billsum-mysql"/g' /app/data/config.json
fi

nginx
exec uvicorn app.main:app --host 127.0.0.1 --port 8000
