// Memuat berkas .env dan mendaftarkan isinya (PORT, AMQP_URL) ke process.env
require('dotenv').config()

// Mengimpor framework Express untuk membuat HTTP server
const express = require("express");
// Membuat instance aplikasi Express
const app = express();

// Mengimpor middleware body-parser untuk mem-parsing body request
const bp = require("body-parser");
// Mendaftarkan middleware agar body request berformat JSON otomatis di-parsing
app.use(bp.json());

// Mengimpor library amqplib untuk berkomunikasi dengan RabbitMQ via protokol AMQP
const amqp = require("amqplib");
// Mengambil alamat URL RabbitMQ server dari environment variable AMQP_URL
const amqpServer = process.env.AMQP_URL;
// Mendeklarasikan variabel channel dan connection agar bisa diakses di seluruh berkas
var channel, connection;

// Memanggil fungsi untuk membuka koneksi ke RabbitMQ saat aplikasi pertama kali berjalan
connectToQueue();

// Fungsi asinkron untuk membuat koneksi, channel, dan queue di RabbitMQ
async function connectToQueue() {
    // Membuka koneksi ke RabbitMQ server sesuai alamat AMQP_URL
    connection = await amqp.connect(amqpServer);
    // Membuat channel sebagai jalur komunikasi di atas koneksi tersebut
    channel = await connection.createChannel();
    try {
        // Menetapkan nama queue yang akan digunakan, yakni "order"
        const queue = "order";
        // Memastikan queue "order" tersedia; jika belum ada maka akan dibuat
        await channel.assertQueue(queue);
        // Menampilkan pesan di console bila berhasil terhubung ke queue
        console.log("Connected to the queue!")
    } catch (ex) {
        // Menampilkan pesan error di console bila terjadi kegagalan
        console.error(ex);
    }
}

// Membuat endpoint HTTP POST /order untuk menerima data order dari client
app.post("/order", (req, res) => {
    // Mengambil properti "order" dari body request JSON
    const { order } = req.body;
    // Mengirim data order tersebut ke queue RabbitMQ
    createOrder(order);
    // Mengembalikan data order sebagai response ke client
    res.send(order);
});

// Fungsi asinkron untuk mempublikasikan data order ke queue RabbitMQ
const createOrder = async order => {
    // Menetapkan nama queue tujuan, yakni "order"
    const queue = "order";
    // Mengubah object order menjadi string JSON, membungkusnya dalam Buffer, lalu mengirimnya ke queue
    await channel.sendToQueue(queue, Buffer.from(JSON.stringify(order)));
    // Menampilkan pesan di console bila order berhasil dikirim ke queue
    console.log("Order succesfully created!")
    // Mendaftarkan handler sekali jalan saat aplikasi menerima sinyal SIGINT (mis. Ctrl+C)
    process.once('SIGINT', async () => {
        // Menampilkan pesan bahwa koneksi akan ditutup
        console.log('got sigint, closing connection');
        // Menutup channel RabbitMQ secara rapi
        await channel.close();
        // Menutup koneksi ke RabbitMQ server
        await connection.close();
        // Menghentikan proses Node.js dengan kode sukses (0)
        process.exit(0);
    });
};

// Menjalankan HTTP server pada port sesuai environment variable PORT (3000)
app.listen(process.env.PORT, () => {
    // Menampilkan pesan di console bahwa server sudah berjalan
    console.log(`Server running at ${process.env.PORT}`);
});
