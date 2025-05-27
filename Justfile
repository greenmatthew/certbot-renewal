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
    sudo rsync --update certbot-renewal-test.service certbot-renewal-test.timer /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable certbot-renewal-test.timer
    sudo systemctl start certbot-renewal-test.timer
    @echo "Test certbot renewal timer installed and started (dry-run mode)"

# Keep install as alias for production
install: install-prod

# Check timer status (both prod and test)
status:
    @echo "=== Production Timer ==="
    -sudo systemctl status certbot-renewal.timer
    @echo ""
    @echo "=== Test Timer ==="
    -sudo systemctl status certbot-renewal-test.timer
    @echo ""
    @echo "=== All Certbot Timers ==="
    sudo systemctl list-timers | grep certbot

# Check production timer status only
status-prod:
    sudo systemctl status certbot-renewal.timer
    sudo systemctl list-timers | grep "certbot-renewal.timer"

# Check test timer status only
status-test:
    sudo systemctl status certbot-renewal-test.timer
    sudo systemctl list-timers | grep "certbot-renewal-test.timer"

# Test renewal (dry run)
test: install-script
    sudo {{renewal_script}} --dry-run

# Uninstall production timer
uninstall-prod:
    sudo systemctl stop certbot-renewal.timer
    sudo systemctl disable certbot-renewal.timer
    sudo rm /etc/systemd/system/certbot-renewal.{service,timer}
    sudo systemctl daemon-reload
    @echo "Production certbot renewal timer removed"

# Uninstall test timer
uninstall-test:
    sudo systemctl stop certbot-renewal-test.timer
    sudo systemctl disable certbot-renewal-test.timer
    sudo rm /etc/systemd/system/certbot-renewal-test.{service,timer}
    sudo systemctl daemon-reload
    @echo "Test certbot renewal timer removed"

# Uninstall both timers
uninstall: uninstall-prod uninstall-test

# View production logs
logs:
    sudo journalctl -u certbot-renewal.service -f

# View test logs
logs-test:
    sudo journalctl -u certbot-renewal-test.service -f

# View all certbot logs
logs-all:
    sudo journalctl -u certbot-renewal*.service -f

# Show production timer schedule
schedule:
    sudo systemctl list-timers certbot-renewal.timer

# Show test timer schedule
schedule-test:
    sudo systemctl list-timers certbot-renewal-test.timer

# Show all certbot timer schedules
schedule-all:
    sudo systemctl list-timers | grep certbot