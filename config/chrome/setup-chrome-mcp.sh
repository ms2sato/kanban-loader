#!/bin/bash
# Chrome DevTools MCP Setup Script
# Configure Chromium to be used in headless mode by MCP server

set -e

echo "Starting Chrome DevTools MCP setup..."

# 1. Create directory
echo "1. Creating /opt/google/chrome/ directory..."
mkdir -p /opt/google/chrome

# 2. Create Chromium wrapper script
echo "2. Creating Chromium wrapper script..."
cat > /opt/google/chrome/chrome.wrapper << 'EOF'
#!/bin/bash
exec /usr/bin/chromium --headless=new --no-sandbox --disable-dev-shm-usage --disable-gpu "$@"
EOF

chmod +x /opt/google/chrome/chrome.wrapper

# 3. Create symbolic link
echo "3. Creating symbolic link..."
# Remove existing link if present
rm -f /opt/google/chrome/chrome
ln -sf /opt/google/chrome/chrome.wrapper /opt/google/chrome/chrome

# 4. Verification
echo ""
echo "Setup completed!"
echo ""
echo "Created files:"
ls -lh /opt/google/chrome/

echo ""
echo "Chromium version:"
/usr/bin/chromium --version

echo ""
echo "Setup completed successfully."
echo "Chrome DevTools MCP tools are now available."
