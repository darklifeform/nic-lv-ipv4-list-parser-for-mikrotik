import ipaddress
import urllib.request
import re
from pathlib import Path

SOURCE_URL = "https://www.nic.lv/local.net"
OUTPUT_DIR = Path(__file__).parent
OUTPUT_FILE = OUTPUT_DIR / "latvian-ips.txt"

def fetch_and_clean():
    with urllib.request.urlopen(SOURCE_URL) as response:
        raw = response.read().decode("utf-8", errors="replace")

    networks = []
    cidr_pattern = re.compile(r"^\#?(\d{1,3}(?:\.\d{1,3}){3}/\d{1,2})\s*$")

    for line in raw.splitlines():
        line = line.strip()
        if not line:
            continue
        m = cidr_pattern.match(line)
        if m:
            networks.append(ipaddress.ip_network(m.group(1)))

    collapsed = list(ipaddress.collapse_addresses(networks))

    OUTPUT_FILE.write_text("\n".join(str(n) for n in collapsed) + "\n", encoding="utf-8")
    print(f"Saved {len(collapsed)} networks to {OUTPUT_FILE}")

if __name__ == "__main__":
    fetch_and_clean()
