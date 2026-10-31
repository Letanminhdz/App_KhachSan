#!/bin/bash
echo "🛑 Đang tắt hệ thống Backend & CSDL (Mobile App)..."
docker stop khachsan_api khachsan_db > /dev/null 2>&1
echo "✅ Đã tắt hoàn toàn các container!"
