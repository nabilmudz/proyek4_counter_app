#!/bin/bash

IP=$1
PORT_PAIR=$2
PORT_CONNECT=$3

if [ -z "$PORT_PAIR" ] || [ -z "$PORT_CONNECT" ] || [ -z "$IP" ]; then
  echo "Usage: ./run_android.sh <port_pair> <port_connect>"
  exit 1
fi

echo "Silakan lihat 'Pairing Code' di menu Wireless Debugging ponsel Anda."
adb pair "$IP:$PORT_PAIR"

if [ $? -ne 0 ]; then
    echo "❌ Gagal melakukan pairing. Pastikan port pair benar dan kode sesuai."
    exit 1
fi

echo "✅ Pairing Berhasil!"
echo "--------------------------"

echo "Restarting ADB Server..."
adb kill-server
adb start-server

echo "Menghubungkan ke $IP:$PORT_CONNECT..."
adb connect "$IP:$PORT_CONNECT"

if adb devices | grep -q "$IP:$PORT_CONNECT.*device"; then
    echo "✅ Terhubung ke $IP:$PORT_CONNECT"
else
    echo "❌ Gagal terhubung. Pastikan port koneksi (bukan port pair) sudah benar."
    exit 1
fi

echo "Menjalankan Flutter..."
flutter run -d "$IP:$PORT_CONNECT"
