#!/usr/bin/env python3
import subprocess
import re
import sys
import socket
import importlib.util
import os
from collections import Counter

# --- Configuration ---
TARGET_PORT = "443"
DNS_TIMEOUT = 1.0

def check_disk_space():
    """Safety check to ensure we have at least 50MB before tracing."""
    stat = os.statvfs('/root')
    free_mb = (stat.f_bavail * stat.f_frsize) / (1024 * 1024)
    if free_mb < 50:
        print(f"Error: Disk space too low ({free_mb:.1f}MB). Cleanup required.")
        sys.exit(1)

def get_conntrack_data():
    try:
        result = subprocess.run(["conntrack", "-L"], capture_output=True, text=True, check=True)
        return result.stdout.splitlines()
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

def reverse_dns(ip):
    old_timeout = socket.getdefaulttimeout()
    socket.setdefaulttimeout(DNS_TIMEOUT)
    try:
        name = socket.gethostbyaddr(ip)[0]
        for suffix in [".[DOMAIN]", ".localdomain", ".lan"]:
            name = name.replace(suffix, "")
        return name
    except:
        return "[Unknown]"
    finally:
        socket.setdefaulttimeout(old_timeout)

def parse_line(line):
    try:
        segments = line.split("src=")
        if len(segments) < 3: return None
        original_segment = "src=" + segments[1]
        if f"dport={TARGET_PORT}" not in original_segment:
            return None
        src = re.search(r'src=([^\s]+)', line).group(1)
        dst = re.search(r'dst=([^\s]+)', line).group(1)
        if src.startswith("[OCTET].") or src.startswith("[OCTET]."):
            return src, dst
    except:
        return None
    return None

def show_top():
    lines = get_conntrack_data()
    sources = []
    for l in lines:
        data = parse_line(l)
        if data: sources.append(data[0])
    print(f"--- Top 10 Clients (Port {TARGET_PORT}) ---")
    print(f"{'Count':>7}  {'Client IP':<15}  {'Hostname'}")
    for ip, count in Counter(sources).most_common(10):
        print(f"{count:>7}  {ip:<15}  {reverse_dns(ip)}")

def inspect_client(client_ip):
    lines = get_conntrack_data()
    destinations = []
    for l in lines:
        data = parse_line(l)
        if data and data[0] == client_ip:
            destinations.append(data[1])
    print(f"--- Top 10 Destinations for {client_ip} ---")
    for ip, count in Counter(destinations).most_common(10):
        print(f"{count:>7}  {ip:<15}  {reverse_dns(ip)}")

def load_extension(func_name):
    ext_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "extensions.py")
    if not os.path.exists(ext_path): return None
    try:
        spec = importlib.util.spec_from_file_location("extensions", ext_path)
        ext_module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(ext_module)
        return getattr(ext_module, func_name, None)
    except: return None

def cleanup_traces():
    try:
        subprocess.run(["killall", "-q", "tcpdump"], stderr=subprocess.DEVNULL)
        for f in os.listdir("/root"):
            if f.endswith("_trace.pcap"):
                try: os.remove(os.path.join("/root", f))
                except: pass
    except: pass

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: ./bot_checker.py --top | --inspect <IP> | --trace <IP> [seconds]")
        sys.exit(1)

    flag = sys.argv[1]
    try:
        if flag == "--top":
            show_top()
        elif flag == "--inspect" and len(sys.argv) >= 3:
            inspect_client(sys.argv[2])
        elif flag == "--trace" and len(sys.argv) >= 3:
            check_disk_space()
            trace_func = load_extension("trace_client")
            if trace_func:
                trace_func(sys.argv[2], int(sys.argv[3]) if len(sys.argv) > 3 else 30)
            else:
                print("Error: extensions.py or trace_client function missing.")
        else:
            print("Usage: ./bot_checker.py --top | --inspect <IP> | --trace <IP> [seconds]")
    except KeyboardInterrupt:
        cleanup_traces()
        sys.exit(0)
