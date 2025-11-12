# duckdns

A robust shell script for automatically updating your Duck DNS domain with your current IP address(es).

## Features

- ✅ **IPv4 & IPv6 Support** - Automatically detects and updates both protocols
- ✅ **Error Handling** - Comprehensive validation and error reporting
- ✅ **Logging** - Detailed logs with timestamps for debugging
- ✅ **Security** - No credential exposure in process list or output
- ✅ **Flexible Configuration** - Environment variables for customization
- ✅ **Lightweight** - Pure shell script, minimal dependencies

## Installation

1. Clone the repository:
```bash
git clone https://github.com/marc0janssen/duckdns.git
cd duckdns
```

2. Create configuration file:
```bash
cp app/duckdns.ini.example /config/duckdns.ini
chmod 600 /config/duckdns.ini
```

3. Edit the configuration with your Duck DNS credentials:
```bash
nano /config/duckdns.ini
```

4. Make the script executable:
```bash
chmod +x app/duck.sh
```

## Configuration

Edit `/config/duckdns.ini`:

```ini
TOKEN="your-token-here"
DOMAIN="your-domain.duckdns.org"
```

### Optional Environment Variables

- `CONFIG_FILE` - Path to configuration file (default: `/config/duckdns.ini`)
- `LOG_FILE` - Path to log file (default: `/var/log/duck.log`)

Example:
```bash
CONFIG_FILE=/etc/duckdns.ini LOG_FILE=/var/log/duckdns.log ./app/duck.sh
```

## Usage

### Manual Update

```bash
./app/duck.sh
```

### Automated with Cron

Add to your crontab to run every 5 minutes:

```bash
crontab -e
```

Add this line:
```
*/5 * * * * /path/to/duckdns/app/duck.sh >> /dev/null 2>&1
```

Or every hour:
```
0 * * * * /path/to/duckdns/app/duck.sh >> /dev/null 2>&1
```

## Logging

Logs are written to `/var/log/duck.log` by default with timestamps and status information:

```
[2025-11-12 10:30:45] [INFO] Starting Duck DNS update for domain: example.duckdns.org
[2025-11-12 10:30:46] [INFO] Detected IPv4: 192.168.1.1
[2025-11-12 10:30:47] [INFO] Successfully updated IPv4: 192.168.1.1
[2025-11-12 10:30:47] [INFO] Duck DNS update completed successfully
```

## Error Handling

The script handles various error conditions:

- Missing or invalid configuration file
- Missing TOKEN or DOMAIN variables
- Network connectivity issues
- Invalid IP addresses
- Duck DNS API errors (BADAUTH, BADIP, BADDOMAIN)

All errors are logged with descriptive messages for easy debugging.

## Security Considerations

- ✅ Configuration file permissions set to 600 (owner read/write only)
- ✅ Token is never echoed to stdout
- ✅ Token is never visible in process list
- ✅ All API calls use HTTPS

## Requirements

- POSIX-compliant shell (sh, bash, zsh, etc.)
- `curl` - for HTTP requests
- Ability to write to log directory (typically requires root for `/var/log`)

## Troubleshooting

### Check the logs
```bash
tail -f /var/log/duck.log
```

### Test manually
```bash
CONFIG_FILE=/config/duckdns.ini ./app/duck.sh
```

### Verify configuration
```bash
cat /config/duckdns.ini
```

## License

See LICENSE file for details.

## Author

marc0janssen