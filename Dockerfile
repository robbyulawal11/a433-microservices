# Menggunakan base image Node.js versi 18 varian alpine agar ukuran image kecil
FROM node:18-alpine

# Memberi label agar image ini otomatis terhubung dengan repository GitHub a433-microservices
LABEL org.opencontainers.image.source=https://github.com/robbyulawal11/a433-microservices

# Menetapkan /app sebagai direktori kerja di dalam container
WORKDIR /app

# Menyalin package.json dan package-lock.json terlebih dahulu agar layer install dependency bisa di-cache
COPY package*.json ./

# Meng-install seluruh dependency yang tercatat pada package.json
RUN npm install

# Menyalin seluruh source code aplikasi ke dalam direktori kerja container
COPY . .

# Menetapkan environment variable PORT dengan nilai 3001 (port shipping service sesuai ketentuan)
ENV PORT=3001

# Menetapkan environment variable AMQP_URL default; nilai ini akan di-override oleh env pada Deployment manifest Kubernetes
ENV AMQP_URL=amqp://rabbitmq:5672

# Mendokumentasikan bahwa container ini membuka port 3001
EXPOSE 3001

# Menjalankan aplikasi dengan perintah npm start (node index.js) saat container dijalankan
CMD ["npm", "start"]
