// Memuat berkas .env dan mendaftarkan isinya (PORT, AMQP_URL) ke process.env
require('dotenv').config()

// Mengimpor framework Express untuk membuat HTTP server
const express = require("express");
// Membuat instance aplikasi Express
const app = express();

// Mengimpor middleware body-parser untuk mem-parsing body request
const bp = require("body-parser");

// Mengimpor library amqplib untuk berkomunikasi dengan RabbitMQ via protokol AMQP
const amqp = require("amqplib");
// Mengambil alamat URL RabbitMQ server dari environment variable AMQP_URL
const amqpServer = process.env.AMQP_URL;
// Mendeklarasikan variabel channel dan connection agar bisa diakses di seluruh berkas
var channel, connection;

// Memanggil fungsi untuk membuka koneksi ke RabbitMQ saat aplikasi pertama kali berjalan
connectToQueue();

// Fungsi asinkron untuk terhubung ke RabbitMQ dan meng-consume pesan dari queue "order"
async function connectToQueue() {
    try {
        // Membuka koneksi ke RabbitMQ server sesuai alamat AMQP_URL
        connection = await amqp.connect(amqpServer);
        // Membuat channel sebagai jalur komunikasi di atas koneksi tersebut
        channel = await connection.createChannel();
        // Memastikan queue "order" tersedia; jika belum ada maka akan dibuat
        await channel.assertQueue("order");
        // Mendaftarkan consumer yang akan dipanggil setiap ada pesan baru di queue "order"
        channel.consume("order", data => {
            // Mencetak isi data order yang diterima dari queue ke console
            console.log(`Order received: ${Buffer.from(data.content)}`);
            // Mencetak pesan bahwa order tersebut akan segera dikirim
            console.log("** Will be shipped soon! **\n")
            // Memberi tahu RabbitMQ bahwa pesan sudah berhasil diproses (acknowledge)
            channel.ack(data);
        });
    } catch (ex) {
        // Menampilkan pesan error di console bila terjadi kegagalan
        console.error(ex);
    }
}

// Menjalankan HTTP server pada port sesuai environment variable PORT (3001)
app.listen(process.env.PORT, () => {
    // Menampilkan pesan di console bahwa server sudah berjalan
    console.log(`Server running at ${process.env.PORT}`);
});
