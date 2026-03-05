# US Bakers CRM - Deployment Guide

## 🚀 Complete Deployment Instructions

This guide covers deployment to various platforms for your production-ready US Bakers CRM system.

---

## 📋 Pre-Deployment Checklist

### ✅ Before You Deploy:

1. **Database Backup**
   ```bash
   mongodump --uri="mongodb://localhost:27017/usbakers" --out=/backup/usbakers-backup
   ```

2. **Environment Variables Ready**
   - MONGO_URL (MongoDB connection string)
   - SECRET_KEY (JWT secret)
   - REACT_APP_BACKEND_URL (Your domain URL)

3. **Domain Ready** (Optional but recommended)
   - Domain purchased (e.g., usbakers.com)
   - DNS access available

---

## 🌐 Option 1: VPS Deployment (DigitalOcean, AWS EC2, Linode)

**Best for:** Full control, custom configuration, scalability

### Step 1: Provision VPS

**Recommended Specs:**
- **RAM:** 4GB minimum (8GB recommended)
- **CPU:** 2 cores minimum
- **Storage:** 50GB SSD
- **OS:** Ubuntu 22.04 LTS

### Step 2: Initial Server Setup

```bash
# SSH into your server
ssh root@your-server-ip

# Update system
sudo apt update && sudo apt upgrade -y

# Create application user
sudo adduser usbakers
sudo usermod -aG sudo usbakers
su - usbakers
```

### Step 3: Install Dependencies

```bash
# Install Node.js (v18)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Install Python 3.11
sudo apt install -y python3.11 python3.11-venv python3-pip

# Install Yarn
sudo npm install -g yarn

# Install MongoDB
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt update
sudo apt install -y mongodb-org

# Start MongoDB
sudo systemctl start mongod
sudo systemctl enable mongod

# Install Nginx
sudo apt install -y nginx

# Install Supervisor
sudo apt install -y supervisor

# Install Certbot (for SSL)
sudo apt install -y certbot python3-certbot-nginx
```

### Step 4: Clone & Setup Application

```bash
# Create app directory
sudo mkdir -p /var/www/usbakers
sudo chown usbakers:usbakers /var/www/usbakers
cd /var/www/usbakers

# Clone your code or upload via SFTP/Git
# For now, we'll copy from development

# Backend setup
cd /var/www/usbakers/backend
python3.11 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Frontend setup
cd /var/www/usbakers/frontend
yarn install
yarn build
```

### Step 5: Configure Environment

```bash
# Backend .env
cat > /var/www/usbakers/backend/.env << 'EOF'
MONGO_URL=mongodb://localhost:27017/usbakers
DB_NAME=usbakers
SECRET_KEY=your-super-secret-key-change-this-in-production
BACKEND_URL=https://yourdomain.com
EOF

# Frontend .env
cat > /var/www/usbakers/frontend/.env << 'EOF'
REACT_APP_BACKEND_URL=https://yourdomain.com
EOF
```

### Step 6: Configure Supervisor

```bash
# Backend service
sudo nano /etc/supervisor/conf.d/usbakers-backend.conf
```

**Add:**
```ini
[program:usbakers-backend]
directory=/var/www/usbakers/backend
command=/var/www/usbakers/backend/venv/bin/python server.py
user=usbakers
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/var/log/usbakers/backend.log
environment=PATH="/var/www/usbakers/backend/venv/bin"
```

**Start services:**
```bash
sudo mkdir -p /var/log/usbakers
sudo chown usbakers:usbakers /var/log/usbakers
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start usbakers-backend
```

### Step 7: Configure Nginx

```bash
sudo nano /etc/nginx/sites-available/usbakers
```

**Add:**
```nginx
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;

    # Frontend (React build)
    location / {
        root /var/www/usbakers/frontend/build;
        try_files $uri /index.html;
    }

    # Backend API
    location /api {
        proxy_pass http://localhost:8001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Static files
    location /uploads {
        alias /var/www/usbakers/uploads;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
```

**Enable site:**
```bash
sudo ln -s /etc/nginx/sites-available/usbakers /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### Step 8: Setup SSL (HTTPS)

```bash
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

### Step 9: Seed Initial Data

```bash
cd /var/www/usbakers/backend
source venv/bin/activate
python utils/seed_fresh_data.py
```

### Step 10: Firewall Configuration

```bash
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable
```

---

## ☁️ Option 2: Railway.app (Easiest)

**Best for:** Quick deployment, automatic scaling, zero DevOps

### Step 1: Prepare for Railway

**Install Railway CLI:**
```bash
npm install -g @railway/cli
railway login
```

### Step 2: Create Project

```bash
cd /app
railway init
```

### Step 3: Add MongoDB

1. Go to Railway dashboard
2. Click "New" → "Database" → "MongoDB"
3. Copy connection string

### Step 4: Set Environment Variables

```bash
# Backend variables
railway variables set MONGO_URL=<your-mongodb-url>
railway variables set SECRET_KEY=<random-secret-key>
railway variables set BACKEND_URL=https://your-app.railway.app

# Frontend variables
railway variables set REACT_APP_BACKEND_URL=https://your-app.railway.app
```

### Step 5: Deploy

```bash
# Deploy backend
cd backend
railway up

# Deploy frontend
cd ../frontend
railway up
```

**Custom Domain:**
- Go to Railway dashboard
- Settings → Domains
- Add your custom domain
- Update DNS records

---

## 🔥 Option 3: Render.com

**Best for:** Free tier available, simple deployment

### Backend Deployment:

1. **Create Account** at render.com
2. **New Web Service**
3. **Connect Repository** or upload code
4. **Settings:**
   - Build Command: `pip install -r requirements.txt`
   - Start Command: `python server.py`
   - Environment Variables:
     - `MONGO_URL`
     - `SECRET_KEY`
     - `PYTHON_VERSION=3.11`

### Frontend Deployment:

1. **New Static Site**
2. **Settings:**
   - Build Command: `yarn install && yarn build`
   - Publish Directory: `build`
   - Environment Variables:
     - `REACT_APP_BACKEND_URL=https://your-backend.onrender.com`

### MongoDB:

Use **MongoDB Atlas** (free tier):
1. Go to mongodb.com/cloud/atlas
2. Create free cluster
3. Get connection string
4. Add to backend environment variables

---

## 🐳 Option 4: Docker Deployment

**Best for:** Containerized deployment, portability

### Step 1: Create Dockerfiles

**Backend Dockerfile:**
```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8001

CMD ["python", "server.py"]
```

**Frontend Dockerfile:**
```dockerfile
FROM node:18-alpine AS build

WORKDIR /app

COPY package.json yarn.lock ./
RUN yarn install

COPY . .
RUN yarn build

FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
```

### Step 2: Docker Compose

```yaml
version: '3.8'

services:
  mongodb:
    image: mongo:6.0
    volumes:
      - mongo-data:/data/db
    ports:
      - "27017:27017"

  backend:
    build: ./backend
    ports:
      - "8001:8001"
    environment:
      - MONGO_URL=mongodb://mongodb:27017/usbakers
      - SECRET_KEY=your-secret-key
    depends_on:
      - mongodb

  frontend:
    build: ./frontend
    ports:
      - "80:80"
    depends_on:
      - backend

volumes:
  mongo-data:
```

**Deploy:**
```bash
docker-compose up -d
```

---

## 🔧 Post-Deployment Steps

### 1. Database Indexing

```bash
cd backend
python -c "from config.database import Database, create_indexes; import asyncio; asyncio.run(Database.connect_db()); asyncio.run(create_indexes())"
```

### 2. Create Super Admin

```bash
# Already exists from seed data
# Email: admin@usbakers.com
# Password: admin123
# CHANGE THIS IMMEDIATELY!
```

### 3. Setup Monitoring

**Install PM2 (for process monitoring):**
```bash
npm install -g pm2
pm2 start backend/server.py --name usbakers-backend
pm2 startup
pm2 save
```

### 4. Setup Backups

**MongoDB Backup Script:**
```bash
#!/bin/bash
BACKUP_DIR="/backup/mongodb"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR
mongodump --uri="mongodb://localhost:27017/usbakers" --out="$BACKUP_DIR/backup_$DATE"

# Keep only last 7 days
find $BACKUP_DIR -type d -mtime +7 -exec rm -rf {} \;
```

**Cron job (daily at 2 AM):**
```bash
crontab -e
# Add: 0 2 * * * /path/to/backup-script.sh
```

---

## 🔐 Security Checklist

✅ Change default admin password
✅ Use strong SECRET_KEY (32+ characters)
✅ Enable HTTPS/SSL
✅ Configure firewall (UFW)
✅ Regular backups
✅ Keep dependencies updated
✅ Enable MongoDB authentication
✅ Use environment variables (never hardcode secrets)
✅ Implement rate limiting (optional)
✅ Enable CORS properly

---

## 🎯 Custom Domain Setup

### DNS Configuration:

**For VPS:**
```
Type    Name    Value
A       @       your-server-ip
A       www     your-server-ip
```

**For Railway/Render:**
```
Type    Name    Value
CNAME   @       your-app.railway.app
CNAME   www     your-app.railway.app
```

---

## 📊 Monitoring & Logs

### View Logs:

**VPS:**
```bash
# Backend logs
sudo tail -f /var/log/usbakers/backend.log

# Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# Supervisor logs
sudo supervisorctl tail -f usbakers-backend
```

**Railway/Render:**
- Check dashboard for live logs

---

## 🚨 Troubleshooting

### Issue: Backend not starting
```bash
# Check logs
sudo supervisorctl status
sudo supervisorctl tail usbakers-backend

# Restart
sudo supervisorctl restart usbakers-backend
```

### Issue: Frontend not loading
```bash
# Check Nginx
sudo nginx -t
sudo systemctl status nginx
sudo systemctl restart nginx
```

### Issue: Database connection failed
```bash
# Check MongoDB
sudo systemctl status mongod
sudo systemctl restart mongod

# Check connection
mongo --eval "db.adminCommand('ping')"
```

---

## 📱 Production Checklist

Before going live:

✅ SSL certificate active
✅ Custom domain configured
✅ Database backed up
✅ Admin password changed
✅ All test data removed (if needed)
✅ Environment variables set
✅ Monitoring enabled
✅ Backup cron job running
✅ Firewall configured
✅ Error logging enabled
✅ Performance tested
✅ All features tested

---

## 💡 Recommended: Use Option 1 (VPS)

**Why?**
- Full control
- Better performance
- Cost-effective for scale
- Custom configurations
- No vendor lock-in

**Estimated Cost:**
- VPS: $12-20/month (DigitalOcean, Linode)
- Domain: $10-15/year
- SSL: Free (Let's Encrypt)

**Total: ~$15/month**

---

## 🆘 Need Help?

Common deployment platforms:
- **DigitalOcean**: digitalocean.com
- **Linode**: linode.com
- **AWS EC2**: aws.amazon.com/ec2
- **Railway**: railway.app
- **Render**: render.com

---

**Your system is production-ready! Choose your deployment method and follow the steps above. Good luck! 🚀**
