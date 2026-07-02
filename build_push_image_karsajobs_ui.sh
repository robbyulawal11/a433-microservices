#!/bin/bash

# Script untuk build dan push Docker image frontend (karsajobs-ui) ke GitHub Packages (ghcr.io).
# Jalankan dari root direktori source code karsajobs-ui: ./build_push_image_karsajobs_ui.sh
# Prasyarat:
#   - Environment variable CR_PAT sudah di-set dengan GitHub Personal Access Token
#     yang memiliki scope write:packages, contoh: export CR_PAT=<token_anda>
#   - Nilai VUE_APP_BACKEND pada berkas .env sudah diisi alamat backend (Node IP:Node Port)
#     karena nilai tersebut ikut ter-build ke dalam image.

# 1. Build Docker image dari berkas Dockerfile yang ada di direktori saat ini (.)
#    dan beri nama/tag ghcr.io/robbyulawal11/karsajobs-ui:latest
#    (format GitHub Packages: ghcr.io/<username_github>/<nama_image>:<tag>)
docker build -t ghcr.io/robbyulawal11/karsajobs-ui:latest .

# 2. Login ke GitHub Container Registry (ghcr.io) dengan user robbyulawal11.
#    Token diambil dari environment variable CR_PAT lalu dialirkan lewat pipe (|)
#    ke opsi --password-stdin supaya token tidak tercatat di history/berkas script.
echo $CR_PAT | docker login ghcr.io -u robbyulawal11 --password-stdin

# 3. Push (unggah) image yang sudah dibuild ke GitHub Packages
#    sehingga bisa di-pull oleh Kubernetes maupun publik.
docker push ghcr.io/robbyulawal11/karsajobs-ui:latest
