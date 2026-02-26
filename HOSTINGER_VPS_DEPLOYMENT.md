# 🚀 Hostinger VPS Deployment Guide - US Bakers CRM

## 📋 What You Have
- ✅ Hostinger VPS (Ubuntu)
- ✅ Domain name (usbakers.tech - already registered with Hostinger)
- ✅ Root access via SSH
- ✅ hPanel (Hostinger Control Panel) access

---

## 🎯 Quick Overview

**Deployment Time:** 2-3 hours  
**Difficulty:** Medium  
**Cost:** Your existing VPS plan  

**We'll Deploy:**
- Backend: FastAPI (Python) on port 8001
- Frontend: React (built static files)
- Database: MongoDB
- Web Server: Nginx with SSL

---

## 🔐 Step 1: Access Your Hostinger VPS

### 1.1 Get SSH Access from hPanel

1. **Login to hPanel:** https://hpanel.hostinger.com
2. Go to **"VPS"** section
3. Click on your VPS
4. Find **"SSH Access"** section
5. Note down:
   - **IP Address:** (e.g., 123.45.67.89)
   - **SSH Port:** Usually 22 or custom
   - **Root Password:** (or reset if needed)

### 1.2 Connect via SSH

**On Windows (use PuTTY or Windows Terminal):**
```bash
ssh root@YOUR_VPS_IP -p 22
# Enter password when prompted
```

**On Mac/Linux:**
```bash
ssh root@YOUR_VPS_IP
# Enter password when prompted
```

### 1.3 First Login - Update System
```bash
# Update package lists
apt update && apt upgrade -y

# Check Ubuntu version
lsb_release -a
# Should show Ubuntu 20.04 or 22.04
```

---

## 🔒 Step 2: Set Up DNS in Hostinger

### 2.1 Configure Domain DNS Records

1. **Go to hPanel** → "Domains"
2. Click on **"usbakers.tech"**
3. Go to **"DNS / Name Servers"**
4. Click **"Manage DNS Records"**

### 2.2 Add These DNS Records

**Delete existing A records first, then add:**

```
Type: A Record
Name: @
Points to: YOUR_VPS_IP (e.g., 123.45.67.89)
TTL: 3600
```

```
Type: A Record
Name: www
Points to: YOUR_VPS_IP
TTL: 3600
```

**Save changes.** DNS takes 5-30 minutes to propagate.

### 2.3 Verify DNS (after 10 minutes)
```bash
# On your VPS, check DNS:
nslookup usbakers.tech
nslookup www.usbakers.tech

# Both should show your VPS IP
```

---

## 📦 Step 3: Install Required Software

### 3.1 Install Node.js 18
```bash
# Add NodeSource repository
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -

# Install Node.js
apt install -y nodejs

# Verify installation
node --version  # Should show v18.x.x
npm --version
```

### 3.2 Install Yarn
```bash
npm install -g yarn
yarn --version
```

### 3.3 Install Python 3.11
```bash
# Install Python 3.11
apt install -y python3.11 python3.11-venv python3-pip

# Verify
python3.11 --version
```

### 3.4 Install MongoDB
```bash
# Import MongoDB GPG key
wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | apt-key add -

# Add MongoDB repository
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/7.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# Update and install
apt update
apt install -y mongodb-org

# Start MongoDB
systemctl start mongod
systemctl enable mongod

# Check status
systemctl status mongod
# Press 'q' to exit
```

### 3.5 Install Nginx
```bash
apt install -y nginx
systemctl start nginx
systemctl enable nginx
systemctl status nginx
```

### 3.6 Install PM2 (Process Manager)
```bash
npm install -g pm2
pm2 --version
```

### 3.7 Install Certbot (SSL)
```bash
apt install -y certbot python3-certbot-nginx
```

---

## 🛡️ Step 4: Configure Firewall

### 4.1 Set Up UFW Firewall
```bash
# Allow SSH (important - don't lock yourself out!)
ufw allow 22/tcp

# Allow HTTP and HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

# Enable firewall
ufw --force enable

# Check status
ufw status
```

**⚠️ IMPORTANT:** If your Hostinger VPS uses a custom SSH port, allow that instead:
```bash
ufw allow YOUR_SSH_PORT/tcp
```

---

## 📁 Step 5: Prepare Application Directory

### 5.1 Create Directory Structure
```bash
# Create main directory
mkdir -p /var/www/usbakers
cd /var/www/usbakers

# Create backend and frontend folders
mkdir backend frontend
```

---

## 📤 Step 6: Upload Your Application Files

### Option A: Upload from Local Machine via SCP (Recommended)

**On your LOCAL computer (not VPS):**

```bash
# Navigate to your project folder
cd /path/to/your/emergent/project

# Upload backend folder
scp -r backend root@YOUR_VPS_IP:/var/www/usbakers/

# Upload frontend folder
scp -r frontend root@YOUR_VPS_IP:/var/www/usbakers/
```

**Enter your VPS root password when prompted.**

### Option B: Using FileZilla (GUI Method)

1. **Download FileZilla:** https://filezilla-project.org/
2. **Connect:**
   - Host: `sftp://YOUR_VPS_IP`
   - Username: `root`
   - Password: Your VPS root password
   - Port: `22`
3. **Upload:**
   - Left panel: Your local project folder
   - Right panel: Navigate to `/var/www/usbakers/`
   - Drag `backend` and `frontend` folders to the right panel

### Option C: Using Git (If you have code on GitHub)

```bash
cd /var/www/usbakers

# Install git
apt install -y git

# Clone your repository
git clone https://github.com/yourusername/usbakers-crm.git .

# Or if private repo:
git clone https://<token>@github.com/yourusername/usbakers-crm.git .
```

---

## 🔧 Step 7: Configure Backend

### 7.1 Set Up Python Environment
```bash
cd /var/www/usbakers/backend

# Create virtual environment
python3.11 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install dependencies
pip install -r requirements.txt
```

### 7.2 Create Backend .env File
```bash
cd /var/www/usbakers/backend
nano .env
```

**Paste this (update YOUR_DOMAIN):**
```env
MONGO_URL=mongodb://localhost:27017
DB_NAME=usbakers_production
CORS_ORIGINS=https://www.usbakers.tech,https://usbakers.tech
SECRET_KEY=REPLACE_WITH_SECURE_KEY_BELOW
BACKEND_URL=https://www.usbakers.tech
AISENSY_API_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4MzgwZWFmOThiY2I5MGMwNDQ2ZjFlNCIsIm5hbWUiOiJVUyBCYWtlcnMiLCJhcHBOYW1lIjoiQWlTZW5zeSIsImNsaWVudElkIjoiNjZmMjc3NjZmMTk3NTgwYjc1NTRhNjk2IiwiYWN0aXZlUGxhbiI6IkZSRUVfRk9SRVZFUiIsImlhdCI6MTc0ODUwNDIzOX0.plXjc_xcZ36rcHA5ZsULPxq10ZUhAZTeZT0lL8ljEj8
AISENSY_API_ENDPOINT=https://backend.aisensy.com/campaign/t1/api/v2
```

**Generate a secure SECRET_KEY:**
```bash
# Run this command and copy the output:
python3 -c "import secrets; print(secrets.token_urlsafe(32))"

# Replace SECRET_KEY in .env with the generated key
```

**Save:** Press `Ctrl+X`, then `Y`, then `Enter`

---

## 🎨 Step 8: Configure & Build Frontend

### 8.1 Create Frontend .env File
```bash
cd /var/www/usbakers/frontend
nano .env
```

**Paste this:**
```env
REACT_APP_BACKEND_URL=https://www.usbakers.tech
```

**Save:** `Ctrl+X`, `Y`, `Enter`

### 8.2 Install Dependencies & Build
```bash
cd /var/www/usbakers/frontend

# Install dependencies
yarn install
# This may take 5-10 minutes

# Build for production
yarn build
# This creates /var/www/usbakers/frontend/build/ folder
```

---

## 🗄️ Step 9: Set Up MongoDB Database

### 9.1 Create Database and Admin User
```bash
mongosh
```

**In MongoDB shell, run these commands:**
```javascript
// Switch to your database
use usbakers_production

// Create admin user
db.createUser({
  user: "usbakers_admin",
  pwd: "YourStrongPassword123!",
  roles: [{ role: "readWrite", db: "usbakers_production" }]
})

// Exit MongoDB
exit
```

### 9.2 Enable MongoDB Authentication
```bash
# Edit MongoDB config
nano /etc/mongod.conf
```

**Find the `security:` section and modify:**
```yaml
security:
  authorization: enabled

net:
  bindIp: 127.0.0.1
  port: 27017
```

**Save:** `Ctrl+X`, `Y`, `Enter`

**Restart MongoDB:**
```bash
systemctl restart mongod
systemctl status mongod
```

### 9.3 Update Backend .env with MongoDB Credentials
```bash
nano /var/www/usbakers/backend/.env
```

**Update the MONGO_URL line:**
```env
MONGO_URL=mongodb://usbakers_admin:YourStrongPassword123!@localhost:27017/usbakers_production?authSource=usbakers_production
```

**Save:** `Ctrl+X`, `Y`, `Enter`

---

## 🚀 Step 10: Start Backend with PM2

### 10.1 Create PM2 Configuration
```bash
cd /var/www/usbakers
nano ecosystem.config.js
```

**Paste this:**
```javascript
module.exports = {
  apps: [{
    name: 'usbakers-backend',
    script: '/var/www/usbakers/backend/venv/bin/python',
    args: '-m uvicorn server:app --host 0.0.0.0 --port 8001',
    cwd: '/var/www/usbakers/backend',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production'
    },
    error_file: '/var/log/pm2/usbakers-backend-error.log',
    out_file: '/var/log/pm2/usbakers-backend-out.log',
    log_file: '/var/log/pm2/usbakers-backend-combined.log'
  }]
};
```

**Save:** `Ctrl+X`, `Y`, `Enter`

### 10.2 Create Log Directory
```bash
mkdir -p /var/log/pm2
```

### 10.3 Start Backend with PM2
```bash
cd /var/www/usbakers

# Start the application
pm2 start ecosystem.config.js

# Check status
pm2 status

# View logs
pm2 logs usbakers-backend --lines 20

# Save PM2 process list
pm2 save

# Set PM2 to start on system boot
pm2 startup
# Copy and run the command it gives you
```

### 10.4 Test Backend
```bash
curl http://localhost:8001/health
# Should return: {"status":"healthy"}
```

---

## 🌐 Step 11: Configure Nginx

### 11.1 Create Nginx Configuration
```bash
nano /etc/nginx/sites-available/usbakers
```

**Paste this complete configuration:**
```nginx
server {
    listen 80;
    server_name www.usbakers.tech usbakers.tech;

    # Max upload size for cake images
    client_max_body_size 50M;

    # Frontend (React build)
    root /var/www/usbakers/frontend/build;
    index index.html;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/javascript application/json;

    # Frontend routes - serve React app
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Backend API routes
    location /api {
        proxy_pass http://127.0.0.1:8001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Timeouts for API calls
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
        proxy_send_timeout 300s;
    }

    # Static uploads (cake images)
    location /uploads {
        alias /var/www/usbakers/backend/uploads;
        autoindex off;
        access_log off;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;

    # Logs
    access_log /var/log/nginx/usbakers_access.log;
    error_log /var/log/nginx/usbakers_error.log;
}
```

**Save:** `Ctrl+X`, `Y`, `Enter`

### 11.2 Enable the Site
```bash
# Create symbolic link
ln -s /etc/nginx/sites-available/usbakers /etc/nginx/sites-enabled/

# Remove default site
rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
nginx -t

# Should show: "syntax is ok" and "test is successful"

# Reload Nginx
systemctl reload nginx
systemctl status nginx
```

### 11.3 Create Uploads Directory
```bash
mkdir -p /var/www/usbakers/backend/uploads
chmod 755 /var/www/usbakers/backend/uploads
```

---

## 🔒 Step 12: Set Up SSL Certificate (HTTPS)

### 12.1 Verify DNS is Propagated
```bash
# Check if domain points to your VPS
nslookup www.usbakers.tech
nslookup usbakers.tech

# Both should show your VPS IP
# If not, wait 10-30 minutes for DNS propagation
```

### 12.2 Get SSL Certificate
```bash
# Run Certbot
certbot --nginx -d usbakers.tech -d www.usbakers.tech
```

**Follow the prompts:**
1. **Email:** Enter your email address
2. **Terms:** Press `Y` to agree
3. **Share email:** Choose `N` (optional)
4. **Redirect:** Choose `2` (Redirect HTTP to HTTPS)

**Certbot will:**
- Get SSL certificate from Let's Encrypt
- Modify Nginx config automatically
- Set up HTTPS redirect

### 12.3 Verify SSL
Open in browser: **https://www.usbakers.tech**

You should see a 🔒 lock icon!

### 12.4 Test Auto-Renewal
```bash
certbot renew --dry-run
# Should show: "Congratulations, all renewals succeeded"
```

---

## 👤 Step 13: Create Super Admin Account

### 13.1 Using Python Script
```bash
cd /var/www/usbakers/backend
source venv/bin/activate

# Create a Python script
nano create_admin.py
```

**Paste this:**
```python
import asyncio
from motor.motor_asyncio import AsyncIOMotorClient
from passlib.context import CryptContext
import os

pwd_context = CryptContext(schemes=['bcrypt'], deprecated='auto')

async def create_admin():
    # Use your MongoDB URL
    client = AsyncIOMotorClient('mongodb://usbakers_admin:YourStrongPassword123!@localhost:27017/usbakers_production?authSource=usbakers_production')
    db = client['usbakers_production']
    
    # Check if admin exists
    existing = await db.users.find_one({'email': 'admin@usbakers.com'})
    
    if not existing:
        admin_user = {
            'id': '1',
            'email': 'admin@usbakers.com',
            'hashed_password': pwd_context.hash('admin123'),
            'name': 'Super Admin',
            'role': 'super_admin',
            'permissions': ['all'],
            'incentive_percentage': 0.0
        }
        await db.users.insert_one(admin_user)
        print('✅ Super Admin created successfully!')
        print('Email: admin@usbakers.com')
        print('Password: admin123')
        print('⚠️  Please change password after first login!')
    else:
        print('⚠️  Admin user already exists')
    
    client.close()

# Run the function
asyncio.run(create_admin())
```

**Save:** `Ctrl+X`, `Y`, `Enter`

**Run the script:**
```bash
python create_admin.py
```

**Delete the script (security):**
```bash
rm create_admin.py
```

---

## ✅ Step 14: Verify Everything Works

### 14.1 Check All Services
```bash
# MongoDB
systemctl status mongod

# Backend (PM2)
pm2 status
pm2 logs usbakers-backend --lines 30

# Nginx
systemctl status nginx

# Check if backend responds
curl http://localhost:8001/health
```

### 14.2 Check Nginx Logs
```bash
# Access logs
tail -f /var/log/nginx/usbakers_access.log

# Error logs (if any issues)
tail -f /var/log/nginx/usbakers_error.log
```

### 14.3 Test the Application

**Open in browser:** https://www.usbakers.tech

**Login:**
- Email: `admin@usbakers.com`
- Password: `admin123`

**Test features:**
1. Dashboard loads ✅
2. Create a new outlet ✅
3. Add a user ✅
4. Create a new order ✅
5. View Manage Orders ✅

---

## 🎉 Congratulations! Your App is Live!

**Your US Bakers CRM is now deployed at:**
- 🌐 **URL:** https://www.usbakers.tech
- 👤 **Admin Email:** admin@usbakers.com
- 🔑 **Admin Password:** admin123

---

## 🔄 Step 15: Update Application (Future)

### When you make code changes:

```bash
# Connect to VPS
ssh root@YOUR_VPS_IP

# Navigate to project
cd /var/www/usbakers

# Backup current version (optional)
cp -r backend backend_backup_$(date +%Y%m%d)
cp -r frontend frontend_backup_$(date +%Y%m%d)

# Upload new files via SCP from local machine:
# scp -r backend root@YOUR_VPS_IP:/var/www/usbakers/
# scp -r frontend root@YOUR_VPS_IP:/var/www/usbakers/

# Update backend
cd backend
source venv/bin/activate
pip install -r requirements.txt
cd ..

# Rebuild frontend
cd frontend
yarn install
yarn build
cd ..

# Restart backend
pm2 restart usbakers-backend

# Reload nginx
systemctl reload nginx

# Check status
pm2 logs usbakers-backend --lines 20
```

---

## 💾 Step 16: Set Up Automatic Backups

### 16.1 Create Backup Script
```bash
nano /root/backup_usbakers.sh
```

**Paste this:**
```bash
#!/bin/bash

# Backup configuration
BACKUP_DIR="/root/backups/usbakers"
DATE=$(date +%Y%m%d_%H%M%S)
MONGO_USER="usbakers_admin"
MONGO_PASS="YourStrongPassword123!"
MONGO_DB="usbakers_production"

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup MongoDB
echo "Backing up MongoDB..."
mongodump --uri="mongodb://$MONGO_USER:$MONGO_PASS@localhost:27017/$MONGO_DB?authSource=$MONGO_DB" --out=$BACKUP_DIR/mongo_$DATE

# Backup uploads folder
echo "Backing up uploads..."
tar -czf $BACKUP_DIR/uploads_$DATE.tar.gz /var/www/usbakers/backend/uploads

# Delete backups older than 7 days
find $BACKUP_DIR -type f -mtime +7 -delete
find $BACKUP_DIR -type d -empty -delete

echo "Backup completed: $DATE"
echo "Location: $BACKUP_DIR"
```

**Save and make executable:**
```bash
chmod +x /root/backup_usbakers.sh

# Test the backup
/root/backup_usbakers.sh
```

### 16.2 Schedule Daily Backups
```bash
# Edit crontab
crontab -e

# Choose editor (nano = 1)

# Add this line (runs daily at 2 AM):
0 2 * * * /root/backup_usbakers.sh >> /root/backup.log 2>&1
```

**Save:** `Ctrl+X`, `Y`, `Enter`

---

## 🐛 Troubleshooting

### Issue 1: "502 Bad Gateway"
```bash
# Check if backend is running
pm2 status

# View backend logs
pm2 logs usbakers-backend

# Restart backend
pm2 restart usbakers-backend

# Check if port 8001 is listening
netstat -tlnp | grep 8001
```

### Issue 2: "Can't connect to MongoDB"
```bash
# Check MongoDB status
systemctl status mongod

# View MongoDB logs
tail -f /var/log/mongodb/mongod.log

# Restart MongoDB
systemctl restart mongod

# Test MongoDB connection
mongosh -u usbakers_admin -p YourStrongPassword123! --authenticationDatabase usbakers_production
```

### Issue 3: SSL Certificate Not Working
```bash
# Check Nginx config
nginx -t

# View Certbot certificates
certbot certificates

# Renew certificate manually
certbot renew --force-renewal
```

### Issue 4: Frontend Shows White Screen
```bash
# Check if build folder exists
ls -la /var/www/usbakers/frontend/build/

# If missing, rebuild
cd /var/www/usbakers/frontend
yarn build

# Check Nginx error logs
tail -f /var/log/nginx/usbakers_error.log
```

### Issue 5: Images Not Uploading
```bash
# Check uploads directory permissions
ls -la /var/www/usbakers/backend/uploads

# Fix permissions
chmod 755 /var/www/usbakers/backend/uploads
chown -R www-data:www-data /var/www/usbakers/backend/uploads
```

---

## 📊 Monitoring & Maintenance

### Daily Checks
```bash
# Check services
pm2 status
systemctl status mongod
systemctl status nginx

# Check disk space
df -h

# Check memory
free -h

# View latest logs
pm2 logs usbakers-backend --lines 50
```

### Weekly Tasks
- Review error logs
- Check backup status
- Monitor disk space
- Update system packages

### Monthly Tasks
```bash
# Update system
apt update && apt upgrade -y

# Check SSL certificate expiry
certbot certificates

# Review MongoDB database size
mongosh -u usbakers_admin -p YourStrongPassword123! --authenticationDatabase usbakers_production
> use usbakers_production
> db.stats()
```

---

## 🔐 Security Checklist

✅ **Completed During Deployment:**
- [x] Firewall enabled (UFW)
- [x] MongoDB authentication enabled
- [x] SSL certificate installed
- [x] Nginx security headers added
- [x] Strong SECRET_KEY generated
- [x] Secure MongoDB password

⚠️ **Do After Deployment:**
- [ ] Change default admin password
- [ ] Create outlet-specific passwords
- [ ] Set up Fail2Ban (brute-force protection)
- [ ] Configure automatic security updates

---

## 📞 Quick Commands Reference

```bash
# SSH Connect
ssh root@YOUR_VPS_IP

# Backend Management
pm2 status
pm2 restart usbakers-backend
pm2 logs usbakers-backend
pm2 monit

# Nginx Management
systemctl status nginx
systemctl reload nginx
nginx -t
tail -f /var/log/nginx/usbakers_error.log

# MongoDB Management
systemctl status mongod
systemctl restart mongod
mongosh -u usbakers_admin -p password --authenticationDatabase usbakers_production

# Check Services
systemctl status mongod nginx
pm2 status
netstat -tlnp | grep -E '8001|27017|80|443'

# View All Logs
pm2 logs usbakers-backend --lines 100
tail -f /var/log/nginx/usbakers_access.log
tail -f /var/log/mongodb/mongod.log
```

---

## 🎊 Success!

Your **US Bakers CRM** is now live on Hostinger VPS! 🚀

**Access your application:**
- 🌐 https://www.usbakers.tech
- 📧 admin@usbakers.com
- 🔑 admin123

**What's Next?**
1. ✅ Change default admin password
2. ✅ Create your first outlet
3. ✅ Add staff users
4. ✅ Configure WhatsApp templates
5. ✅ Start taking orders!

---

**Need Help?**
- Check troubleshooting section above
- Review logs: `pm2 logs usbakers-backend`
- Check Nginx logs: `tail -f /var/log/nginx/usbakers_error.log`

**Deployment Date:** $(date)  
**Server:** Hostinger VPS  
**Domain:** usbakers.tech
