#Watch the DNS traffic live on a name server


#!/usr/bin/env python3
import subprocess, re, sys
from datetime import datetime

# Capture DNS traffic and pipe to Python
CMD = ["sudo", "tcpdump", "-lUnni", "any", "udp port 53 and udp[10] & 0x80 = 0"]

# REGEX LOGIC:
# Group 1: Source IP
# Group 2: Destination IP (The DNS Server)
# Group 3: Domain requested
DNS_REGEX = re.compile(r"IP ([\d\.]+)\.\d+ > ([\d\.]+)\.53: .*? (?:\[\w+\] )*[A-Z\?]+ ([\w\-\.]+)\.")

def run_monitor():
    # Adjusted header for the new column
    print(f"{'TIMESTAMP':<21} | {'SOURCE IP':<15} | {'DESTINATION IP':<15} | {'DOMAIN'}")
    print("-" * 90)
    
    try:
        process = subprocess.Popen(CMD, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, bufsize=1)
        for line in process.stdout:
            match = DNS_REGEX.search(line)
            if match:
                now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                src, dst, domain = match.groups()
                
                # Format output with fixed widths
                print(f"{now:<21} | {src:<15} | {dst:<15} | {domain}")
                sys.stdout.flush()
    except KeyboardInterrupt:
        process.terminate()

if __name__ == "__main__":
    run_monitor()
