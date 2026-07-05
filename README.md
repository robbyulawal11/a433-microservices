# a433-microservices
Repository ini digunakan untuk kebutuhan kelas Belajar Membangun Arsitektur Microservices

## Proyek Akhir: Implementasi Asynchronous Communication pada E-Commerce App

Aplikasi E-Commerce App terdiri dari dua services yang berkomunikasi secara asinkron melalui RabbitMQ:

- **Order service** (branch [`order-service`](https://github.com/robbyulawal11/a433-microservices/tree/order-service)) — menerima data order via HTTP POST `/order` lalu mengirimkannya ke queue `order` di RabbitMQ.
- **Shipping service** (branch [`shipping-service`](https://github.com/robbyulawal11/a433-microservices/tree/shipping-service)) — meng-consume queue `order` lalu mencetak data order di console.

### Struktur submission

| Berkas/Direktori | Lokasi | Keterangan |
|---|---|---|
| Source code + `Dockerfile` + `build_push_image_order_service.sh` | branch `order-service` | Kriteria 1 & 2 |
| Source code + `Dockerfile` + `build_push_image_shipping_service.sh` | branch `shipping-service` | Kriteria 1 & 2 |
| `kubernetes/` (manifest lengkap) | branch `main` | Kriteria 3 + saran Kubernetes & Istio |
| `link.txt` (tautan GitHub Packages) | branch `main` | Ketentuan submission |

Container image disimpan di **GitHub Packages (ghcr.io)**, bukan Docker Hub:
- `ghcr.io/robbyulawal11/order-service:latest`
- `ghcr.io/robbyulawal11/shipping-service:latest`

### Cara deploy di Kubernetes (Minikube + Istio)

```bash
# 1. Jalankan cluster Minikube
minikube start --memory=6144 --cpus=4

# 2. Install Istio (profil demo) menggunakan istioctl
istioctl install --set profile=demo -y

# 3. Buat namespace ecommerce (sudah berlabel istio-injection=enabled)
kubectl apply -f kubernetes/1-namespace.yml

# 4. Deploy RabbitMQ terlebih dahulu (StatefulSet + headless Service), tunggu sampai siap
kubectl apply -f kubernetes/2-rabbitmq/
kubectl rollout status statefulset/rabbitmq -n ecommerce

# 5. Deploy order service dan shipping service (image ditarik dari GitHub Packages)
kubectl apply -f kubernetes/3-order-service/
kubectl apply -f kubernetes/4-shipping-service/

# 6. Terapkan Istio Ingress Gateway (Gateway + Virtual Service)
kubectl apply -f kubernetes/5-istio/

# 7. Buka terminal terpisah (sebagai Administrator) untuk mengekspos Istio Ingress Gateway
minikube tunnel
```

### Cara menguji

Kirim POST request ke Istio Ingress Gateway (dapatkan EXTERNAL-IP dari `kubectl get svc istio-ingressgateway -n istio-system`):

```bash
curl -X POST http://<EXTERNAL-IP>/order \
  -H "Content-Type: application/json" \
  -d '{"order":{"book_name":"Harry Potter","author":"J.K Rowling","buyer":"Fikri Helmi Setiawan","shipping_address":"Jl. Batik Kumeli no 50 Bandung"}}'
```

Lalu verifikasi data order tercetak di console shipping service:

```bash
kubectl logs -n ecommerce deployment/shipping-service -c shipping-service -f
```
