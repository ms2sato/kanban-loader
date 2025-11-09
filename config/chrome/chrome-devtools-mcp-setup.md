# Chrome DevTools MCP Setup

## Overview

Configuration for running Chrome DevTools MCP with headless Chromium

## Prerequisites

- Chromium must be installed (`/usr/bin/chromium`)
- Root or sudo privileges required

## Setup Steps

### 1. Run the Setup Script

```bash
# Grant execution permission to the script
chmod +x setup-chrome-mcp.sh

# Execute the script
./setup-chrome-mcp.sh
```

### 2. Add Chrome DevTools Plugin to MCP Tools in Each Project

```
claude mcp add chrome-devtools -- npx chrome-devtools-mcp@latest
```

### 3. Verify Operation

Use MCP tools to verify:

```
# Get page list
mcp__chrome-devtools__list_pages()

# Navigate to test page
mcp__chrome-devtools__navigate_page({ type: "url", url: "https://example.com" })

# Take screenshot
mcp__chrome-devtools__take_screenshot()
```

## Setup Details

The setup script performs the following:

1. Creates `/opt/google/chrome/` directory
2. Creates a wrapper script for Chromium (with headless mode flags)
3. Creates a symbolic link at the location expected by MCP server (`/opt/google/chrome/chrome`)

## Chromium Flags Used

- `--headless=new` - Headless mode (no X server required)
- `--no-sandbox` - Disable sandbox (for container environments)
- `--disable-dev-shm-usage` - Disable shared memory usage
- `--disable-gpu` - Disable GPU acceleration

## Troubleshooting

### If MCP Server Cannot Find Chrome

```bash
ls -la /opt/google/chrome/chrome
# Verify that the symbolic link exists and is executable
```

### If Browser Fails to Start

```bash
# Verify Chromium works directly
/usr/bin/chromium --version
```

## Created Date

2025-11-09
