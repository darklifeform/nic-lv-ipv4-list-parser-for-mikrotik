# Latvian IPv4 List for MikroTik

This repository is a two-part workflow for MikroTik firewall address-lists:

1. A server-side script fetches and cleans Latvian IPv4 networks from NIC.lv.
2. A MikroTik script downloads that cleaned list and applies it to firewall address-list entries.

## Two-part architecture

- Part 1 (server): `fetch_ips.py` downloads `https://www.nic.lv/local.net`, filters valid IPv4 CIDR lines, deduplicates them, and writes `ips.txt`.
- Part 2 (MikroTik): `latvian-ips.rsc` fetches hosted `ips.txt` and updates firewall address-list `latvian-ips`.

## What it does

- Downloads source data from: `https://www.nic.lv/local.net`
- Extracts only valid IPv4 CIDR lines (for example `5.45.44.0/22`)
- Strips optional leading `#`
- Deduplicates entries while preserving original order
- Writes cleaned output to `ips.txt`

## Repository files

- `fetch_ips.py` — Python script that fetches and cleans the network list
- `ips.txt` — generated cleaned CIDR list
- `latvian-ips.rsc` — MikroTik RouterOS script that downloads `ips.txt` and updates an address-list

## Requirements

- Python 3.8+ (standard library only, no external dependencies)
- Internet access to `https://www.nic.lv/local.net`

## Generate `ips.txt`

Run from the repository root:

```bash
python3 fetch_ips.py
```

Expected output:

```text
Saved <N> networks to /path/to/repo/ips.txt
```

## Use with MikroTik

`latvian-ips.rsc` expects a downloadable `ips.txt` file URL.

1. Host your `ips.txt` on HTTP/HTTPS (for example on GitHub Pages, a web server, or internal host).
2. Edit this line in `latvian-ips.rsc`:

```routeros
:local url "https://<your-server>/ips.txt"
```

3. Import or run the script on RouterOS.

The script:
- downloads the latest list
- validates non-empty content
- replaces all entries in address-list `latvian-ips`
- logs update summary and any line-level errors

## Suggested update workflow

1. Run `python3 fetch_ips.py`
2. Publish updated `ips.txt`
3. Trigger `latvian-ips.rsc` on MikroTik (manually or via scheduler)

## Notes

- Source format changes at NIC.lv may affect parsing.
- Only IPv4 CIDR lines matching `x.x.x.x/yy` are included.
