# IRIX TFTP Backup Init Script Installation Instructions

## Overview

This init script is a self-contained solution that includes an embedded expect script for TFTP transfers.

## Installation

1. Copy the script to your IRIX system:

   ```shell
   # Copy the init script
   cp tftpbackup /etc/init.d/tftpbackup
   chmod 755 /etc/init.d/tftpbackup
   ```

2. Create the runlevel link for shutdown:
   ```shell
   # Link for runlevel 0 (shutdown) - K05 ensures it runs early
   ln -s /etc/init.d/tftpbackup /etc/rc0.d/K05tftpbackup
   
   # Also link for runlevel 6 (reboot) if desired
   ln -s /etc/init.d/tftpbackup /etc/rc6.d/K05tftpbackup
   ```

## Configuration

Edit `/etc/init.d/tftpbackup` and modify these variables:

- `TFTP_SERVER` - IP address of your TFTP server
- `INSTALL_KERNEL` - Path to the kernel file (default: `/unix.install`)
- `LOGFILE` - Path for log output (default: `/var/adm/tftpbackup.log`)

## How It Works

1. During system shutdown/reboot, the script runs as `K05tftpbackup stop`
2. It checks if `/unix.install` exists
3. It verifies network connectivity is still available
4. It gets the system's host ID using `lmhostid`
5. It creates a temporary expect script in `/tmp/`
6. It uses the expect script to TFTP the file to the server as `unix.HOSTID`
7. It cleans up the temporary expect script
8. All operations are logged to `/var/adm/tftpbackup.log`

## TFTP Server Setup

Your TFTP server must be configured to accept uploads. For example, on Linux:

```shell
# Install tftpd-hpa
apt-get install tftpd-hpa

# Edit /etc/default/tftpd-hpa
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/var/lib/tftpboot"
TFTP_ADDRESS=":69"
TFTP_OPTIONS="--secure --create"

# Ensure directory is writable
chmod 777 /var/lib/tftpboot

# Start service
systemctl restart tftpd-hpa
```

## Testing

You can manually test the script:

```shell
# Test the main script
/etc/init.d/tftpbackup stop

# Check the log
tail /var/adm/tftpbackup.log
```

## Troubleshooting

- Check `/var/adm/tftpbackup.log` for detailed error messages
- Verify TFTP server is running and accepting connections
- Ensure network is still up during shutdown (test with `ifconfig -a`)
- Verify `lmhostid` command works and returns expected host ID
- Test TFTP manually: `tftp <server>` then `put /unix.install unix.test`