#!/bin/bash

echo "=========================================="
echo "US Bakers - Debug Internal Server Error"
echo "=========================================="
echo ""

echo "1. Backend Service Status:"
sudo supervisorctl status usbakers-backend
echo ""

echo "2. Backend Logs (Last 50 lines):"
tail -n 50 /home/usbakers/logs/backend.log
echo ""

echo "3. Backend Error Logs:"
tail -n 30 /home/usbakers/logs/backend-error.log 2>/dev/null || echo "No error log file"
echo ""

echo "4. Nginx Error Logs:"
sudo tail -n 30 /var/log/nginx/error.log
echo ""

echo "5. Test Backend API directly:"
curl -s http://localhost:8001/api/health || echo "Backend not responding"
echo ""

echo "6. Test from external URL:"
curl -s http://187.77.188.41/api/health || echo "API not accessible externally"
echo ""

echo "7. Check if MongoDB is running:"
sudo systemctl status mongod --no-pager | head -5
echo ""

echo "8. Test MongoDB connection:"
mongosh mongodb://localhost:27017/usbakers --quiet --eval "db.runCommand({ping: 1})" || echo "MongoDB connection failed"
echo ""

echo "=========================================="
echo "Debug complete"
echo "=========================================="
