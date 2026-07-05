#!/bin/bash
# Script untuk mem-build container image order service dan mengunggahnya ke GitHub Packages (ghcr.io)

# Membangun image dari Dockerfile di direktori saat ini dengan tag ghcr.io/robbyulawal11/order-service:latest
docker build -t ghcr.io/robbyulawal11/order-service:latest .

# Mengunggah (push) image yang sudah dibangun ke GitHub Packages (ghcr.io)
# Catatan: pastikan sudah login terlebih dahulu dengan perintah:
#   echo $GH_PAT | docker login ghcr.io -u robbyulawal11 --password-stdin
docker push ghcr.io/robbyulawal11/order-service:latest
