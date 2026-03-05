# US Bakers CRM - Deployment README

## 🚀 Hostinger VPS Deployment Guide

### Prerequisites
- Ubuntu 24.04 VPS (Noble) or Ubuntu 22.04 (Jammy)
- Root access
- GitHub repository cloned with latest code

---

## 📋 Quick Deployment

### 1. Download the deployment script:
```bash
wget https://raw.githubusercontent.com/usbakersindia/usbakers/main/deploy-hostinger-fixed.sh
chmod +x deploy-hostinger-fixed.sh
```

### 2. Run as root:
```bash
sudo ./deploy-hostinger-fixed.sh
```

The script will:
- Install all dependencies (Node.js, Python, MongoDB, Nginx, Supervisor)
- Clone your GitHub repo
- Configure backend & frontend
- Seed database with test data
- Set up automated backups
- Configure firewall

---

## ⚠️ Important: Emergent Integrations Package

This project uses `emergentintegrations`, a private package that requires special installation:

```bash
pip install emergentintegrations --extra-index-url https://d33sy5i8bnduwe.cloudfront.net/simple/
```

The deployment script handles this automatically.

---

## 🔧 Manual Installation (If Script Fails)

### Install MongoDB (Ubuntu 24.04 Fix):
```bash
# Remove old repos
sudo rm -f /etc/apt/sources.list.d/mongodb*.list

# Import GPG key
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
    sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg

# Add repo (using Jammy for Noble compatibility)
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | \
    sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# Install
sudo apt update && sudo apt install -y mongodb-org
sudo systemctl start mongod && sudo systemctl enable mongod
```

### Install Backend Dependencies:
```bash
cd /home/usbakers/usbakers-crm/backend
python3.11 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install emergentintegrations --extra-index-url https://d33sy5i8bnduwe.cloudfront.net/simple/
pip install -r requirements.txt
```

---

## 🎯 Post-Deployment

### Check Services Status:
```bash
sudo -u usbakers /home/usbakers/manage.sh status
```

### View Logs:
```bash
sudo -u usbakers /home/usbakers/manage.sh logs
```

### Test API:
```bash
curl http://YOUR_IP/api/health
```

### Access Application:
Open browser: `http://YOUR_IP`

**Login Credentials:**
- Email: `admin@usbakers.com`
- Password: `admin123`

---

## 🔄 Update Deployed Application

```bash
sudo -u usbakers /home/usbakers/manage.sh update
```

---

## 🔐 Security Setup (After Deployment)

### 1. Change all default passwords immediately
### 2. Set up SSL certificate:
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com
```

---

## 🐛 Troubleshooting

### Backend won't start:
```bash
tail -n 100 /home/usbakers/logs/backend.log
```

### MongoDB issues:
```bash
sudo journalctl -u mongod -n 100 --no-pager
```

### Frontend not loading:
```bash
ls -la /home/usbakers/usbakers-crm/frontend/build
sudo systemctl status nginx
```

---

## 📂 Important Locations

- **Application**: `/home/usbakers/usbakers-crm/`
- **Logs**: `/home/usbakers/logs/`
- **Backups**: `/home/usbakers/backups/`
- **Nginx Config**: `/etc/nginx/sites-available/usbakers`
- **Supervisor Config**: `/etc/supervisor/conf.d/usbakers-backend.conf`

---

## 🔄 Daily Automated Backups

Database backups run automatically at 2 AM daily.

**Manual backup:**
```bash
sudo -u usbakers /home/usbakers/manage.sh backup
```

---

## 📞 Support

For deployment issues, check logs and status first. Most issues are related to:
1. MongoDB not starting
2. Missing environment variables
3. Port conflicts
4. Permission issues

---

**Last Updated:** March 2026
