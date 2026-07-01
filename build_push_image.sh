#!/usr/bin/env bash
# =============================================================================
# build_push_image.sh
# Script untuk membangun (build) Docker image "item-app" dan mengunggahnya
# (push) ke GitHub Packages / GitHub Container Registry (GHCR).
# Urutan perintah disusun persis sesuai Kriteria 3 proyek.
#
# Cara pakai:
#   export PASSWORD_GITHUB=<Personal Access Token dgn scope write:packages>
#   bash build_push_image.sh
# =============================================================================

# Hentikan eksekusi bila ada perintah yang gagal (-e), variabel belum
# didefinisikan (-u), atau ada perintah dalam pipeline yang gagal (pipefail).
set -euo pipefail

# ---- Konfigurasi (ubah sesuai akun Anda) -----------------------------------
GHCR_USER="robbyulawal11"   # username GitHub (huruf kecil) sebagai namespace image
IMAGE="item-app"            # nama image
TAG="v1"                    # tag/versi image
REGISTRY="ghcr.io"          # registry GitHub Container Registry
# ----------------------------------------------------------------------------

# 1. Build Docker image dari Dockerfile pada direktori saat ini,
#    diberi nama "item-app" dengan tag "v1".
docker build -t "${IMAGE}:${TAG}" .

# 2. Tampilkan daftar image yang ada di lokal untuk verifikasi.
docker images

# 3. Ubah (tag ulang) nama image agar sesuai format GitHub Packages:
#    ghcr.io/<username>/item-app:v1
docker tag "${IMAGE}:${TAG}" "${REGISTRY}/${GHCR_USER}/${IMAGE}:${TAG}"

# 4. Login ke GitHub Packages (GHCR) via Terminal.
#    Password (PAT) dibaca dari environment variable PASSWORD_GITHUB dan
#    dialirkan melalui stdin agar tidak tersimpan di history/shell.
echo "${PASSWORD_GITHUB}" | docker login "${REGISTRY}" -u "${GHCR_USER}" --password-stdin

# 5. Unggah (push) image ke GitHub Packages.
docker push "${REGISTRY}/${GHCR_USER}/${IMAGE}:${TAG}"
