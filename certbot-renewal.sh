#!/bin/bash
set -e

# Ensure /root/.local/bin is in PATH for systemd context
export PATH="/root/.local/bin:$PATH"

# Check for --dry-run argument
DRY_RUN=""
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN="--dry-run"
    echo "$(date): Running in DRY RUN mode"
fi

echo "$(date): Starting certbot renewal with update check"

# Update certbot and plugins (running as root)
echo "$(date): Checking for certbot updates..."
pipx upgrade certbot || echo "$(date): Failed to upgrade certbot"
pipx inject certbot certbot-dns-cloudflare --force || echo "$(date): Failed to update dns-cloudflare plugin"

# Run renewal (with or without --dry-run)
echo "$(date): Running certificate renewal..."
certbot renew $DRY_RUN --dns-cloudflare --dns-cloudflare-credentials /etc/letsencrypt/cloudflare/credentials.ini -v # --quiet

echo "$(date): Certbot renewal completed successfully"