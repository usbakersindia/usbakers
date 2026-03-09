# ✅ Fresh VPS Setup Checklist - US Bakers CRM

Print this and check off as you go!

---

## 📋 Pre-Setup Checklist

- [ ] Fresh Ubuntu 20.04/22.04 VPS ready
- [ ] Root/sudo access confirmed
- [ ] Domain name (e.g., crm.usbakers.com) pointed to VPS IP
- [ ] SSH access working: `ssh root@your-ip`

---

## 🚀 Quick Setup Method (Recommended)

### Part 1: System Setup (10 min)

- [ ] SSH into VPS: `ssh root@your-ip`
- [ ] Download script: 
  ```bash
  curl -o fresh-install.sh https://raw.githubusercontent.com/usbakersindia/usbakers/main/fresh-install.sh
  ```
- [ ] Run script: `sudo bash fresh-install.sh`
- [ ] Wait for completion (installs MongoDB, Node, Python, Nginx)
- [ ] Verify all services running

### Part 2: Application Setup (10 min)

- [ ] Switch to app user: `su - usbakers`
- [ ] Clone repo: 
  ```bash
  git clone https://github.com/usbakersindia/usbakers.git usbakers-crm
  cd usbakers-crm
  ```
- [ ] Exit to root: `exit`
- [ ] Run setup: 
  ```bash
  cd /home/usbakers/usbakers-crm
  chmod +x setup-fresh.sh
  sudo ./setup-fresh.sh
  ```
- [ ] Enter domain when asked
- [ ] Press Enter for MongoDB (default)
- [ ] Press Enter for database name (default)
- [ ] Press Enter to skip MSG91 keys
- [ ] Wait for completion (~5 min)
- [ ] Verify: `sudo supervisorctl status` (both should say RUNNING)

### Part 3: Web Server (5 min)

- [ ] Create Nginx config:
  ```bash
  sudo nano /etc/nginx/sites-available/usbakers-crm
  ```
- [ ] Paste config from FRESH_OS_SETUP.md
- [ ] Change domain name in config to your domain
- [ ] Save (Ctrl+X, Y, Enter)
- [ ] Enable site:
  ```bash
  sudo ln -s /etc/nginx/sites-available/usbakers-crm /etc/nginx/sites-enabled/
  sudo rm /etc/nginx/sites-enabled/default
  ```
- [ ] Test config: `sudo nginx -t`
- [ ] Reload: `sudo systemctl reload nginx`

### Part 4: SSL Certificate (2 min)

- [ ] Install Certbot:
  ```bash
  sudo apt install -y certbot python3-certbot-nginx
  ```
- [ ] Get certificate:
  ```bash
  sudo certbot --nginx -d crm.usbakers.com
  ```
- [ ] Enter email when asked
- [ ] Agree to terms (Y)
- [ ] Wait for certificate

### Part 5: Test (2 min)

- [ ] Open browser: `https://your-domain.com`
- [ ] Login: admin@usbakers.com / admin123
- [ ] Check dashboard loads
- [ ] Check "User Management" page
- [ ] Check "Manage Orders" page
- [ ] Create a test user
- [ ] ✅ **Everything working!**

---

## 🔍 Quick Verification Commands

After setup, verify everything:

```bash
# Check services (should all say RUNNING)
sudo supervisorctl status

# Check MongoDB (should say active)
sudo systemctl status mongod

# Check Nginx (should say active)
sudo systemctl status nginx

# View backend logs (should see "Started server")
sudo tail -n 20 /var/log/supervisor/backend.out.log

# Run diagnostic
cd /home/usbakers/usbakers-crm
sudo ./diagnose.sh
```

---

## 🎯 Test Credentials

After setup, login with:

| Role | Email | Password |
|------|-------|----------|
| Super Admin | admin@usbakers.com | admin123 |
| Outlet Admin | satyam@usbakers.com | satyam123 |
| Factory | factory@usbakers.com | factory123 |

---

## 🐛 Common Issues & Fixes

### Issue: Services not starting
```bash
sudo tail -f /var/log/supervisor/backend.err.log
sudo supervisorctl restart usbakers-backend usbakers-frontend
```

### Issue: Can't access website
```bash
sudo nginx -t
sudo systemctl restart nginx
sudo ufw allow 'Nginx Full'
```

### Issue: MongoDB not running
```bash
sudo systemctl start mongod
sudo systemctl status mongod
```

---

## 📞 Need Help?

Run diagnostic script:
```bash
cd /home/usbakers/usbakers-crm
sudo ./diagnose.sh
```

Check detailed guide:
- `FRESH_OS_SETUP.md` - Step by step
- `COMPLETE_DEPLOYMENT_GUIDE.md` - Full details

---

## ⏱️ Expected Timeline

- [ ] System setup: 10 minutes
- [ ] App setup: 10 minutes  
- [ ] Nginx config: 5 minutes
- [ ] SSL setup: 2 minutes
- [ ] Testing: 3 minutes

**Total: ~30 minutes**

---

## ✅ Done!

Date completed: __________

Domain: __________________

Notes: ___________________

_________________________

_________________________

---

**🎉 Your US Bakers CRM is Live!**
