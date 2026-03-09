# 🚀 Fresh OS Installation Guide - US Bakers CRM

## For Fresh Ubuntu 20.04/22.04 VPS

---

## ⚡ QUICK START (2 Commands Method)

If you want the fastest setup, just run these 2 commands:

### Step 1: Install System Dependencies
```bash
# Download and run the system setup script
curl -o fresh-install.sh https://raw.githubusercontent.com/usbakersindia/usbakers/main/fresh-install.sh
sudo bash fresh-install.sh
```

This installs: MongoDB, Node.js, Yarn, Python, Nginx, Supervisor

### Step 2: Clone & Setup Application
```bash
# Switch to app user
su - usbakers

# Clone repository (enter your GitHub credentials if private)
git clone https://github.com/usbakersindia/usbakers.git usbakers-crm
cd usbakers-crm

# Exit back to root
exit

# Run application setup
cd /home/usbakers/usbakers-crm
chmod +x setup-fresh.sh
sudo ./setup-fresh.sh
```

When prompted:
- Domain: `your-domain.com` (e.g., crm.usbakers.com)
- MongoDB: Press Enter (uses default)
- Database: Press Enter (uses default)
- MSG91: Press Enter to skip

**That's it!** Continue to Step 10 for Nginx configuration.

---

## 📋 DETAILED STEP-BY-STEP (Manual Method)

If you prefer to understand each step:

---

## ✅ Prerequisites

- Fresh Ubuntu 20.04 or 22.04 VPS
- Root access (or sudo privileges)
- Domain name pointed to your VPS IP
- Minimum 2GB RAM, 2 CPU cores

---

## 🎯 Installation Steps

### Step 1: Connect to Your VPS

```bash
ssh root@your-server-ip
```

Or if you have a user with sudo:
```bash
ssh username@your-server-ip
```

---

### Step 2: Update System

```bash
sudo apt update
sudo apt upgrade -y
```

---

### Step 3: Install Essential Tools

```bash
sudo apt install -y git curl wget software-properties-common \
    build-essential gnupg apt-transport-https ca-certificates \
    net-tools supervisor
```

---

### Step 4: Install MongoDB 7.0

```bash
# Import MongoDB GPG key
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor

# Add MongoDB repository
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | \
   sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# Install MongoDB
sudo apt update
sudo apt install -y mongodb-org

# Start MongoDB
sudo systemctl start mongod
sudo systemctl enable mongod

# Verify
sudo systemctl status mongod
```

✅ You should see "active (running)"

---

### Step 5: Install Node.js 20 & Yarn

```bash
# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
sudo apt install -y nodejs

# Install Yarn
sudo npm install -g yarn

# Verify
node --version   # Should show v20.x.x
yarn --version   # Should show 1.x.x
```

---

### Step 6: Install Python 3.11

```bash
sudo apt install -y python3.11 python3.11-venv python3-pip

# Verify
python3 --version  # Should show 3.11.x
```

---

### Step 7: Install Nginx

```bash
sudo apt install -y nginx

# Start Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Verify
sudo systemctl status nginx
```

---

### Step 8: Create Application User

```bash
# Create user
sudo useradd -m -s /bin/bash usbakers

# Verify
id usbakers
```

---

### Step 9: Clone Repository & Setup Application

```bash
# Switch to usbakers user
sudo su - usbakers

# Clone your repository
git clone https://github.com/usbakersindia/usbakers.git usbakers-crm

# If private repo, it will ask for credentials
# Use your GitHub username and Personal Access Token

cd usbakers-crm

# Exit back to root
exit
```

Now run the setup script:

```bash
cd /home/usbakers/usbakers-crm
sudo chmod +x setup-fresh.sh
sudo ./setup-fresh.sh
```

**The script will ask you:**

1. **Domain name** (e.g., crm.usbakers.com)
   - Type your domain and press Enter

2. **MongoDB URL** 
   - Just press Enter (uses default: mongodb://localhost:27017/usbakers_crm)

3. **Database Name**
   - Just press Enter (uses default: usbakers_crm)

4. **MSG91 Auth Key**
   - Press Enter to skip (you can add later)

5. **MSG91 Sender ID**
   - Press Enter to skip

**The script will now:**
- Create .env files for backend and frontend
- Install all Python dependencies
- Install all Node.js dependencies
- Build the frontend
- Seed database with test data
- Configure and start supervisor services

This takes about 5-10 minutes.

---

### Step 10: Configure Nginx

Create Nginx configuration:

```bash
sudo nano /etc/nginx/sites-available/usbakers-crm
```

**Copy and paste this configuration** (replace `crm.usbakers.com` with your domain):

```nginx
# Backend API server
upstream backend {
    server 127.0.0.1:8001;
}

# Frontend React server
upstream frontend {
    server 127.0.0.1:3000;
}

server {
    listen 80;
    server_name crm.usbakers.com;  # 👈 CHANGE THIS to your domain

    client_max_body_size 50M;

    # API Routes - Proxy to Backend
    location /api/ {
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }

    # Frontend - Proxy to React
    location / {
        proxy_pass http://frontend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Error pages
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }
}
```

**Save and exit:** Press `Ctrl + X`, then `Y`, then `Enter`

Enable the site:

```bash
# Create symbolic link
sudo ln -s /etc/nginx/sites-available/usbakers-crm /etc/nginx/sites-enabled/

# Remove default site
sudo rm /etc/nginx/sites-enabled/default

# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

✅ You should see "test successful"

---

### Step 11: Install SSL Certificate (HTTPS)

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d crm.usbakers.com
```

**Follow the prompts:**
1. Enter your email address
2. Agree to terms (Y)
3. Share email? (N or Y, your choice)
4. Certbot will automatically configure HTTPS

✅ Certificate installed! Your site is now HTTPS.

---

### Step 12: Verify Everything is Running

```bash
# Check all services
sudo supervisorctl status
```

You should see:
```
usbakers-backend    RUNNING   pid 1234, uptime 0:05:00
usbakers-frontend   RUNNING   pid 1235, uptime 0:05:00
```

Check MongoDB:
```bash
sudo systemctl status mongod
```

Check Nginx:
```bash
sudo systemctl status nginx
```

---

### Step 13: Test Your Application

Open your browser and go to:
```
https://crm.usbakers.com
```

**Login with test credentials:**

| Role | Email | Password |
|------|-------|----------|
| Super Admin | admin@usbakers.com | admin123 |
| Dhangu Road | satyam@usbakers.com | satyam123 |
| Railway Road | sushant@usbakers.com | sushant123 |
| Factory | factory@usbakers.com | factory123 |

---

## ✅ You're Done! 🎉

Your US Bakers CRM is now live!

---

## 🐛 Troubleshooting

### Services not starting?

```bash
# Check backend logs
sudo tail -f /var/log/supervisor/backend.err.log

# Check frontend logs
sudo tail -f /var/log/supervisor/frontend.err.log
```

### Restart services

```bash
sudo supervisorctl restart usbakers-backend usbakers-frontend
```

### Run diagnostic script

```bash
cd /home/usbakers/usbakers-crm
sudo ./diagnose.sh
```

---

## 📊 Quick Commands Reference

```bash
# Check status
sudo supervisorctl status

# Restart services
sudo supervisorctl restart usbakers-backend usbakers-frontend

# View logs
sudo tail -f /var/log/supervisor/backend.err.log
sudo tail -f /var/log/supervisor/frontend.err.log

# Check MongoDB
sudo systemctl status mongod

# Restart Nginx
sudo systemctl restart nginx
```

---

## 🔄 Future Updates

When you push new code to GitHub:

```bash
cd /home/usbakers/usbakers-crm
sudo ./update-vps.sh
```

---

## 📞 Need Help?

If stuck at any step:
1. Run `sudo ./diagnose.sh` to check what's wrong
2. Check the logs (commands above)
3. Read `COMPLETE_DEPLOYMENT_GUIDE.md` for detailed troubleshooting

---

## ⏱️ Total Time: 30-40 minutes

- System setup: ~10 minutes
- Application setup: ~10 minutes
- Nginx & SSL: ~5 minutes
- Verification: ~5 minutes

**Happy Baking! 🎂**
