import subprocess
import os
import signal
import time

def trace_client(ip, duration=30):
    pcap_file = f"/root/{ip}_trace.pcap"
    print(f"[*] Starting 443 trace on {ip} for {duration}s...")
    print(f"[*] Capturing TLS Client Hellos...")

    # Capture filter for TLS handshakes on port 443
    cmd = [
        "tcpdump", "-i", "any", "-nn", "-s", "0", 
        f"host {ip} and port 443", 
        "-w", pcap_file
    ]
    
    proc = subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    
    try:
        time.sleep(duration)
        os.kill(proc.pid, signal.SIGTERM)
    except Exception as e:
        print(f"Trace interrupted: {e}")
        os.kill(proc.pid, signal.SIGKILL)
    
    print(f"[*] Trace complete. Extracting Server Names (SNI)...")
    
    # Try to extract using tshark
    try:
        # Check if tshark is available
        tshark_check = subprocess.run(["which", "tshark"], capture_output=True)
        if tshark_check.returncode != 0:
            print("[!] tshark not found. Install with 'apt update && apt install tshark' or run inside ***REMOVED***.")
            return

        sni_cmd = [
            "tshark", "-r", pcap_file, 
            "-Y", "tls.handshake.extensions_server_name", 
            "-T", "fields", "-e", "tls.handshake.extensions_server_name"
        ]
        output = subprocess.check_output(sni_cmd, text=True)
        domains = sorted(set(output.splitlines()))
        
        if domains:
            print(f"\n--- Domains Requested by {ip} ---")
            for d in domains:
                print(f"  - {d}")
        else:
            print("[!] No SNI found. If the connection was already open, the handshake was missed.")
            
    except Exception as e:
        print(f"Analysis failed: {e}")
    finally:
        if os.path.exists(pcap_file):
            os.remove(pcap_file)
