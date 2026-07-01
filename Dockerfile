# =============================================================================
# Dockerfile untuk container "item-app" (Node.js/Express)
# Urutan perintah sengaja disusun persis sesuai Kriteria 2 proyek.
# =============================================================================

# 1. Gunakan base image resmi Node.js versi 14 (varian Debian).
#    Debian dipilih (bukan alpine) agar proses native build (node-gyp) dan
#    build tool lama (Gulp 3) berjalan lancar tanpa dependency tambahan.
FROM node:14

# 2. Tentukan working directory di dalam container menjadi /app.
#    Seluruh perintah berikutnya dijalankan relatif terhadap direktori ini.
WORKDIR /app

# 3. Salin seluruh source code dari host ke working directory di container.
#    Berkas/direktori yang tidak perlu (mis. node_modules, .git) dikecualikan
#    lewat berkas .dockerignore.
COPY . .

# 4. Jalankan aplikasi dalam production mode dan arahkan koneksi database
#    ke container bernama "item-db" (service pada docker-compose).
ENV NODE_ENV=production DB_HOST=item-db

# 5. Install dependencies khusus production, lalu build aplikasi.
#    --production      : hanya memasang "dependencies" (skip devDependencies).
#    --unsafe-perm     : izinkan script lifecycle (preinstall/build) berjalan
#                        sebagai root sehingga native module bisa dikompilasi.
#    npm run build     : menjalankan Gulp untuk meng-compile aset front-end.
RUN npm install --production --unsafe-perm && npm run build

# 6. Beri tahu Docker bahwa aplikasi mendengarkan (listen) pada port 8080.
EXPOSE 8080

# 7. Perintah default saat container dijalankan: start server via "npm start"
#    (setara dengan "node ./bin/www").
CMD ["npm", "start"]
