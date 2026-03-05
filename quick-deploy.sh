#!/bin/bash
# Quick deploy fix for immediate use
# Run: bash quick-deploy.sh

set -e
cd /home/usbakers/usbakers-crm/backend
cat > .env << 'EOF'
MONGO_URL=mongodb://localhost:27017/usbakers
DB_NAME=usbakers
SECRET_KEY=us-bakers-secret-2024
BACKEND_URL=http://187.77.188.41
CORS_ORIGINS=*
EOF

source venv/bin/activate
export MONGO_URL=mongodb://localhost:27017/usbakers
export DB_NAME=usbakers
PYTHONPATH=/home/usbakers/usbakers-crm/backend python utils/seed_fresh_data.py

sudo supervisorctl restart usbakers-backend
sleep 3

cd /home/usbakers/usbakers-crm/frontend
echo "REACT_APP_BACKEND_URL=http://187.77.188.41" > .env
rm -rf build
yarn build

sudo chmod -R 755 /home/usbakers
sudo find /home/usbakers/usbakers-crm/frontend/build -type f -exec chmod 644 {} \;

sudo systemctl restart nginx

echo ""
echo "✓ Deployment complete!"
echo "Open: http://187.77.188.41"
echo "Login: admin@usbakers.com / admin123"
