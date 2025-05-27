# Justfile for installing a timer for certbot
# Ensures that certbot is up-to-date before performing any renewals

renewal_script := "certbot-renewal.sh"

_default: help

# Lists all available commands
help:
    just --list

# Install the renewal script to system location
install-script:
    sudo rsync --update {{renewal_script}} /usr/local/bin/
    sudo chmod +x /usr/local/bin/{{renewal_script}}
    @echo "Renewal script installed to /usr/local/bin/{{renewal_script}}"

# Install production timer (twice daily, real renewals)
install-prod: install-script
    sudo rsync --update certbot-renewal.service certbot-renewal.timer /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable certbot-renewal.timer
    sudo systemctl start certbot-renewal.timer
    @echo "Production certbot renewal timer installed and started"

# Install test timer (every 10 minutes, dry-run)
install-test: install-script
    sudo rsync --update certbot-renewal.service.test /etc/systemd/system/certbot-renewal.service
    sudo rsync --update certbot-renewal.timer.test /etc/systemd/system/certbot-renewal.timer
    sudo systemctl daemon-reload
    sudo systemctl enable certbot-renewal.timer
    sudo systemctl start certbot-renewal.timer
    @echo "Test certbot renewal timer installed and started (dry-run mode)"

# Keep install as alias for production
install: install-prod

# Check timer status
status:
    sudo systemctl status certbot-renewal.timer
    sudo systemctl list-timers | grep certbot

# Test renewal (dry run)
test: install-script
    sudo {{renewal_script}} --dry-run

# Uninstall timer
uninstall:
    sudo systemctl stop certbot-renewal.timer
    sudo systemctl disable certbot-renewal.timer
    sudo rm /etc/systemd/system/certbot-renewal.{service,timer}
    sudo systemctl daemon-reload
    @echo "Certbot renewal timer removed"

# View logs
logs:
    sudo journalctl -u certbot-renewal.service -f

# Show timer schedule
schedule:
    sudo systemctl list-timers certbot-renewal.timer
