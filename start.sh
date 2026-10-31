#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

echo "🚀 Đang khởi động hệ thống Backend & CSDL (Mobile App)..."

if docker ps -a --format '{{.Names}}' | grep -q "^khachsan_api$"; then
    docker start khachsan_db khachsan_api > /dev/null 2>&1
else
    docker compose up -d > /dev/null 2>&1
fi

echo "⏳ Đang kiểm tra trạng thái..."
sleep 2

if docker ps --format '{{.Names}}' | grep -q "^khachsan_api$"; then
    echo ""
    echo "✅ HỆ THỐNG ĐÃ KHỞI ĐỘNG THÀNH CÔNG!"
    echo "================================================="
    echo "⚙️  Máy chủ API (Node.js) : http://localhost:8000"
    echo "🌐 Quản trị Web (Admin)   : http://localhost:8000/admin"
    echo "🗄️  CSDL MySQL             : Port 3306 (Container: khachsan_db)"
    echo "================================================="
    echo "💡 Khi muốn tắt hệ thống, hãy chạy lệnh: ./stop.sh"
    echo ""
else
    echo "❌ Có lỗi xảy ra khi khởi động! Bạn hãy thử chạy: docker compose up -d"
fi
