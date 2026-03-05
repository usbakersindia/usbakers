# US Bakers CRM - Hostinger VPS Deployment Guide

## 🚀 Complete Hostinger VPS Deployment (Step-by-Step)

This guide will help you deploy your US Bakers CRM on Hostinger VPS from start to finish.

---

## 📋 Prerequisites

✅ Hostinger VPS plan purchased (KVM 2 or higher recommended)
✅ Domain name (optional but recommended)
✅ SSH client installed on your computer

**Recommended Hostinger VPS Plan:**
- **KVM 2:** 4GB RAM, 2 CPU cores, 100GB SSD (~₹399/month)
- **KVM 4:** 8GB RAM, 4 CPU cores, 200GB SSD (~₹799/month)

---

## 🎯 Step 1: Access Hostinger VPS

### 1.1 Get VPS Details from Hostinger Panel

1. Login to **hpanel.hostinger.com**
2. Go to **VPS** section
3. Click on your VPS
4. Note down:
   - **IP Address:** (e.g., 123.45.67.89)
   - **Root Password:** (or reset it)
   - **SSH Port:** (usually 22)

### 1.2 Connect via SSH

**For Windows (Use PuTTY or PowerShell):**
```bash
ssh root@your-vps-ip
# Enter password when prompted
```

**For Mac/Linux (Use Terminal):**
```bash
ssh root@your-vps-ip
# Enter password when prompted
```

---

## 🛠️ Step 2: Initial Server Setup

### 2.1 Update System

```bash
# Update package list
apt update && apt upgrade -y

# Install basic utilities
apt install -y curl wget git unzip software-properties-common
```

### 2.2 Create Application User

```bash
# Create user for application
adduser usbakers
# Set password: usbakers123 (or your choice)

# Add to sudo group
usermod -aG sudo usbakers

# Switch to new user
su - usbakers
```

---

## 📦 Step 3: Install Dependencies

### 3.1 Install Node.js (v18)

```bash
# Add NodeSource repository
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -

# Install Node.js
sudo apt install -y nodejs

# Verify installation
node --version  # Should show v18.x.x
npm --version
```

### 3.2 Install Yarn

```bash
sudo npm install -g yarn
yarn --version
```

### 3.3 Install Python 3.11

```bash
# Add Python repository
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update

# Install Python 3.11 and pip
sudo apt install -y python3.11 python3.11-venv python3.11-dev python3-pip

# Verify installation
python3.11 --version
```

### 3.4 Install MongoDB

```bash
# Import MongoDB GPG key
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -

# Add MongoDB repository (for Ubuntu 22.04)
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

# Update and install MongoDB
sudo apt update
sudo apt install -y mongodb-org

# Start MongoDB
sudo systemctl start mongod
sudo systemctl enable mongod

# Verify MongoDB is running
sudo systemctl status mongod
```

### 3.5 Install Nginx

```bash
sudo apt install -y nginx

# Start Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Verify Nginx
sudo systemctl status nginx
```

### 3.6 Install Supervisor

```bash
sudo apt install -y supervisor

# Start Supervisor
sudo systemctl start supervisor
sudo systemctl enable supervisor
```

---

## 📁 Step 4: Upload Application Files

### Option A: Using SFTP (FileZilla - Easiest)

1. **Download FileZilla:** filezilla-project.org
2. **Connect:**
   - Host: `sftp://your-vps-ip`
   - Username: `usbakers`
   - Password: `your-password`
   - Port: `22`
3. **Upload:**
   - Create folder: `/home/usbakers/usbakers-crm`
   - Upload `backend/` folder
   - Upload `frontend/` folder
   - Upload `uploads/` folder (if exists)

### Option B: Using Git (Recommended)

```bash
# Create app directory
cd /home/usbakers
git clone <your-repo-url> usbakers-crm
# OR download and extract zip file

# If using zip file:
cd /home/usbakers
wget <your-zip-url>
unzip usbakers-crm.zip
mv usbakers-crm-main usbakers-crm
```

### Option C: Using SCP (From your local machine)

```bash
# From your local machine
scp -r /path/to/your/project/backend usbakers@your-vps-ip:/home/usbakers/usbakers-crm/
scp -r /path/to/your/project/frontend usbakers@your-vps-ip:/home/usbakers/usbakers-crm/
```

---

## ⚙️ Step 5: Setup Backend

```bash
# Navigate to backend
cd /home/usbakers/usbakers-crm/backend

# Create virtual environment
python3.11 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Create .env file
nano .env
```

**Add to .env file:**
```env
MONGO_URL=mongodb://localhost:27017/usbakers
DB_NAME=usbakers
SECRET_KEY=change-this-to-a-random-secret-key-minimum-32-characters
BACKEND_URL=http://your-vps-ip
```

**Press:** `Ctrl+X`, then `Y`, then `Enter` to save

### 5.1 Seed Database

```bash
# Still in backend directory with venv activated
python utils/seed_fresh_data.py
```

---

## 🎨 Step 6: Setup Frontend

```bash
# Navigate to frontend
cd /home/usbakers/usbakers-crm/frontend

# Install dependencies
yarn install

# Create .env file
nano .env
```

**Add to .env file:**
```env
REACT_APP_BACKEND_URL=http://your-vps-ip
```

**Save and exit**

### 6.1 Build Frontend

```bash
# Build for production
yarn build

# This creates a 'build' folder with optimized files
```

---

## 🔧 Step 7: Configure Supervisor (Backend Process Manager)

```bash
# Create supervisor config
sudo nano /etc/supervisor/conf.d/usbakers-backend.conf
```

**Add:**
```ini
[program:usbakers-backend]
directory=/home/usbakers/usbakers-crm/backend
command=/home/usbakers/usbakers-crm/backend/venv/bin/python server.py
user=usbakers
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/home/usbakers/logs/backend.log
stderr_logfile=/home/usbakers/logs/backend-error.log
environment=PATH="/home/usbakers/usbakers-crm/backend/venv/bin"
```

**Save and exit**

```bash
# Create logs directory
mkdir -p /home/usbakers/logs

# Reload supervisor
sudo supervisorctl reread
sudo supervisorctl update

# Start backend
sudo supervisorctl start usbakers-backend

# Check status
sudo supervisorctl status usbakers-backend
```

---

## 🌐 Step 8: Configure Nginx (Web Server)

```bash
# Create Nginx config
sudo nano /etc/nginx/sites-available/usbakers
```

**Add:**
```nginx
server {
    listen 80;
    server_name your-vps-ip;  # Replace with your domain if you have one

    # Client max body size (for file uploads)
    client_max_body_size 50M;

    # Frontend (React build)
    location / {
        root /home/usbakers/usbakers-crm/frontend/build;
        try_files $uri $uri/ /index.html;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }

    # Backend API
    location /api {
        proxy_pass http://127.0.0.1:8001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts for long requests
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Uploads directory (if needed)
    location /uploads {
        alias /home/usbakers/usbakers-crm/uploads;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Error pages
    error_page 404 /index.html;
}
```

**Save and exit**

### 8.1 Enable Site

```bash
# Create symbolic link
sudo ln -s /etc/nginx/sites-available/usbakers /etc/nginx/sites-enabled/

# Remove default site
sudo rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

---

## 🔥 Step 9: Configure Firewall

```bash
# Install UFW (if not installed)
sudo apt install -y ufw

# Allow SSH (IMPORTANT - Do this first!)
sudo ufw allow 22/tcp

# Allow HTTP
sudo ufw allow 80/tcp

# Allow HTTPS (for future SSL)
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw --force enable

# Check status
sudo ufw status
```

---

## 🧪 Step 10: Test Your Application

### 10.1 Test Backend

```bash
# Check if backend is running
sudo supervisorctl status usbakers-backend

# View backend logs
tail -f /home/usbakers/logs/backend.log

# Test API directly
curl http://localhost:8001/api/auth/login
```

### 10.2 Test Frontend

Open your browser and visit:
```
http://your-vps-ip
```

You should see the US Bakers CRM login page!

**Test Login:**
- Email: `admin@usbakers.com`
- Password: `admin123`

---

## 🔒 Step 11: Setup Domain & SSL (Optional but Recommended)

### 11.1 Point Domain to VPS

**In your domain registrar (e.g., GoDaddy, Namecheap, Hostinger DNS):**

Create these DNS records:
```
Type    Name    Value               TTL
A       @       your-vps-ip         14400
A       www     your-vps-ip         14400
```

**Wait 10-60 minutes for DNS propagation**

### 11.2 Update Nginx for Domain

```bash
sudo nano /etc/nginx/sites-available/usbakers
```

**Change:**
```nginx
server_name your-vps-ip;
```

**To:**
```nginx
server_name yourdomain.com www.yourdomain.com;
```

**Restart Nginx:**
```bash
sudo nginx -t
sudo systemctl restart nginx
```

### 11.3 Install SSL Certificate (HTTPS)

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Get SSL certificate (replace with your domain)
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Follow prompts:
# - Enter email
# - Agree to terms
# - Choose redirect HTTP to HTTPS (option 2)

# Test auto-renewal
sudo certbot renew --dry-run
```

### 11.4 Update Environment Variables for HTTPS

**Backend:**
```bash
nano /home/usbakers/usbakers-crm/backend/.env
```

**Change:**
```env
BACKEND_URL=https://yourdomain.com
```

**Frontend:**
```bash
nano /home/usbakers/usbakers-crm/frontend/.env
```

**Change:**
```env
REACT_APP_BACKEND_URL=https://yourdomain.com
```

**Rebuild Frontend:**
```bash
cd /home/usbakers/usbakers-crm/frontend
yarn build
```

**Restart Backend:**
```bash
sudo supervisorctl restart usbakers-backend
```

---

## 📊 Step 12: Setup Monitoring & Backups

### 12.1 Create Backup Script

```bash
nano /home/usbakers/backup-db.sh
```

**Add:**
```bash
#!/bin/bash
BACKUP_DIR="/home/usbakers/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR
mongodump --uri="mongodb://localhost:27017/usbakers" --out="$BACKUP_DIR/backup_$DATE"

# Keep only last 7 days
find $BACKUP_DIR -type d -mtime +7 -exec rm -rf {} \; 2>/dev/null

echo "Backup completed: $DATE"
```

**Make executable:**
```bash
chmod +x /home/usbakers/backup-db.sh
```

### 12.2 Schedule Daily Backups

```bash
crontab -e
# Choose nano if prompted

# Add this line (runs daily at 2 AM):
0 2 * * * /home/usbakers/backup-db.sh >> /home/usbakers/logs/backup.log 2>&1
```

---

## 🔍 Step 13: Useful Commands

### View Logs

```bash
# Backend logs (live)
tail -f /home/usbakers/logs/backend.log

# Backend errors
tail -f /home/usbakers/logs/backend-error.log

# Nginx access logs
sudo tail -f /var/log/nginx/access.log

# Nginx error logs
sudo tail -f /var/log/nginx/error.log
```

### Restart Services

```bash
# Restart backend
sudo supervisorctl restart usbakers-backend

# Restart Nginx
sudo systemctl restart nginx

# Restart MongoDB
sudo systemctl restart mongod
```

### Check Service Status

```bash
# Backend
sudo supervisorctl status usbakers-backend

# Nginx
sudo systemctl status nginx

# MongoDB
sudo systemctl status mongod

# All processes
sudo supervisorctl status
```

### Update Application

```bash
# Update backend code
cd /home/usbakers/usbakers-crm/backend
git pull  # or upload new files
source venv/bin/activate
pip install -r requirements.txt
sudo supervisorctl restart usbakers-backend

# Update frontend
cd /home/usbakers/usbakers-crm/frontend
git pull  # or upload new files
yarn install
yarn build
sudo systemctl restart nginx
```

---

## 🚨 Troubleshooting

### Issue: Backend not starting

```bash
# Check supervisor status
sudo supervisorctl status usbakers-backend

# View logs
tail -f /home/usbakers/logs/backend-error.log

# Restart
sudo supervisorctl restart usbakers-backend
```

### Issue: Frontend shows 502 Bad Gateway

```bash
# Check if backend is running
sudo supervisorctl status usbakers-backend

# Check backend logs
tail -f /home/usbakers/logs/backend.log

# Test backend directly
curl http://localhost:8001/
```

### Issue: Can't connect to database

```bash
# Check MongoDB status
sudo systemctl status mongod

# Restart MongoDB
sudo systemctl restart mongod

# Check MongoDB logs
sudo tail -f /var/log/mongodb/mongod.log
```

### Issue: Website not loading

```bash
# Check Nginx status
sudo systemctl status nginx

# Test Nginx config
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx

# Check firewall
sudo ufw status
```

---

## ✅ Post-Deployment Checklist

- [ ] Application accessible at http://your-vps-ip
- [ ] Login works with admin@usbakers.com
- [ ] Backend API responding
- [ ] MongoDB running and accessible
- [ ] All pages loading correctly
- [ ] Change admin password
- [ ] Domain configured (if applicable)
- [ ] SSL certificate installed (if domain)
- [ ] Backup script scheduled
- [ ] Firewall enabled
- [ ] All services set to auto-start

---

## 📱 Access Your Application

**Without Domain:**
```
http://your-vps-ip
```

**With Domain (after DNS propagation):**
```
https://yourdomain.com
```

**Login Credentials:**
```
Super Admin:
- Email: admin@usbakers.com
- Password: admin123 (CHANGE THIS!)

Satyam (Dhangu Road):
- Email: satyam@usbakers.com
- Password: satyam123

Sushant (Railway Road):
- Email: sushant@usbakers.com
- Password: sushant123

Factory Admin:
- Email: factory@usbakers.com
- Password: factory123
```

---

## 💰 Hostinger VPS Pricing (India)

**KVM 1:** 2GB RAM, 1 CPU - ₹249/month
**KVM 2:** 4GB RAM, 2 CPU - ₹399/month ⭐ **Recommended**
**KVM 4:** 8GB RAM, 4 CPU - ₹799/month
**KVM 8:** 16GB RAM, 8 CPU - ₹1599/month

---

## 🆘 Need Help?

**Hostinger Support:**
- Live Chat: Available 24/7 in hPanel
- Tickets: Submit in hPanel
- Knowledge Base: hostinger.com/tutorials

**Common Hostinger VPS Issues:**
- **Slow first boot:** VPS might take 5-10 minutes first time
- **Root login disabled:** Use the password from hPanel
- **Port 22 blocked:** Check Hostinger firewall in hPanel

---

## 🎉 Success!

Your US Bakers CRM is now live on Hostinger VPS!

**What you've accomplished:**
✅ Full-stack application deployed
✅ MongoDB database configured
✅ Nginx web server setup
✅ SSL/HTTPS enabled (if domain)
✅ Automatic backups scheduled
✅ Production-ready environment

**Your bakery can now:**
- Manage orders across 2 outlets
- Track deliveries with OTP
- Generate reports
- Manage staff with role-based access
- Process payments from PetPooja POS

**Enjoy your new CRM system! 🎂🚀**
