**English** | [简体中文](README_ZH.MD) | [فارسی](README_FA.MD)

## Xray VLESS + XTLS One-Click Installation Script (Nginx-based) <img src="https://raw.githubusercontent.com/wulabing/Xray_onekey/main/image/project_xray.jpg" alt="Project_Xray" width="122" height="30" align="bottom" />


> Thanks for non-commercial open source development authorization by JetBrains!

## Nested TLS caused by placing Nginx in front may lead to connection blocking. REALITY is now the recommended option — please head to the address below

https://github.com/wulabing/xray_docker

## ❤️ Sponsors

> Want to appear here? Feel free to reach out via an issue or the [Telegram group](https://t.me/wulabing_v2ray)

<table>
<tr>
<td width="180"><a href="https://api.capybaracode.cc/register?aff=ENZE8PZ2VBDE"><img src="https://raw.githubusercontent.com/wulabing/xray_docker/master/image/sponsors/capybaracode.png" alt="CapybaraCode" width="150"></a></td>
<td>Thanks to <a href="https://api.capybaracode.cc/register?aff=ENZE8PZ2VBDE">CapybaraCode</a> for sponsoring this project — the very first sponsorship this project has received, and I truly appreciate the recognition!<br>A stable, low-latency API relay service for Claude Code / AI coding. Works out of the box, pay-as-you-go, and smooth enough for daily coding work. Enter the promo code <code>WULABING</code> when signing up to get an extra <b>$4</b> in credit.</td>
</tr>
<tr>
<td width="180"><a href="https://www.uhdnow.com/signup?invite=IMAX4K"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/wulabing/xray_docker/master/image/sponsors/uhdnow-dark.png"><img src="https://raw.githubusercontent.com/wulabing/xray_docker/master/image/sponsors/uhdnow.png" alt="UHDNOW" width="150"></picture></a></td>
<td>Thanks to <a href="https://www.uhdnow.com/signup?invite=IMAX4K">UHDNOW</a> for sponsoring this project!<br>A carefully maintained private Emby server with a full catalogue of 4K / IMAX remuxes, Dolby Vision and HDR sources, multiple direct-connect routes and instant seeking. Worth a look if you are into home media.</td>
</tr>
</table>

### Telegram Groups

* Telegram discussion group: https://t.me/wulabing_v2ray
* Telegram update announcement channel: https://t.me/wulabing_channel

### Prerequisites

* Prepare a domain name and add its A record;
* Have `wget` installed.

### Import Link Specification

https://github.com/XTLS/Xray-core/issues/91


### Installation / Update (Nginx in front)

Supported configurations

- VLESS + TCP + TLS + Nginx + WebSocket

```
wget -N --no-check-certificate -q -O install.sh "https://raw.githubusercontent.com/wulabing/Xray_onekey/nginx_forward/install.sh" && chmod +x install.sh && bash install.sh
```

### Installation / Update (Xray in front)

Supported configurations

- VLESS + TCP + TLS + Nginx (flow control `xtls-rprx-vision`)

- VLESS + TCP + TLS + Nginx (flow control `xtls-rprx-vision`) plus VLESS + TCP + TLS + Nginx + WebSocket fallback coexistence mode

```
wget -N --no-check-certificate -q -O install.sh "https://raw.githubusercontent.com/wulabing/Xray_onekey/main/install.sh" && chmod +x install.sh && bash install.sh
```


### Notes

* If you do not understand what a given setting in the script means, use the default value provided by the script for everything except the domain name;
* Using this script requires Linux fundamentals and hands-on experience, some knowledge of computer networking, and basic computer skills;
* The maintainer provides only very limited support. If you run into problems, feel free to ask other members in the group.

### Supported Systems

| Distribution | Version requirement | Notes |
| --- | --- | --- |
| Debian | 10+ | Debian 12 / 13 recommended |
| Ubuntu | 20.04+ | |
| Rocky Linux | 8+ | |
| AlmaLinux | 8+ | |
| Oracle Linux | 7+ | |
| CentOS | 7+ / Stream | **CentOS 7 reached EOL on 2024-06-30.** Official repositories have moved to vault.centos.org; the script prints a warning and continues, but dependency installation may fail. Switching to another distribution is recommended |

### Known Limitations

* **The WebSocket transport has been marked as deprecated by Xray.** Since [Xray-core v26.1.23](https://github.com/XTLS/Xray-core/releases/tag/v26.1.23), using the ws transport prints a deprecation warning in the startup log (`The feature WebSocket transport (with ALPN http/1.1, etc.) is deprecated, not recommended for using and might be removed.`), and it may be removed in a future release. This warning is emitted before the log file is created, so it is only visible in `journalctl -u xray` and never appears in `/var/log/xray/error.log`.
* This script uses an Nginx-in-front + nested TLS structure, which can be targeted and blocked. Migrating to REALITY / XHTTP is recommended for the long run — see [wulabing/xray_docker](https://github.com/wulabing/xray_docker).

### Fixes in This Maintenance Release (v1.4.0)

> **Important notice for existing users**: if your node was installed with v1.3.11 or earlier, its inbound **TLS configuration never actually loaded any certificate**, so clients cannot complete the TLS handshake. Please reinstall, or manually rename `"xtlsSettings"` to `"tlsSettings"` in `/usr/local/etc/xray/config.json` and then run `systemctl restart xray`.

* **Fixed the inbound TLS not loading any certificate (critical)**: `xtlsSettings` in the configuration template has not been a valid field since Xray-core v1.8.1. Unknown JSON fields are silently ignored, so `security: "tls"` fell back to an empty TLS configuration and `certificates` never took effect. The field has been renamed to `tlsSettings`.
* **Fixed certificate renewal always failing on non-443 ports**: the previous approach temporarily rewrote the Nginx configuration by line number with `sed` to allow `/.well-known/acme-challenge/`. Under normal conditions port 80 also unconditionally 301-redirects that path to https, so renewal only succeeded by luck when the CA followed the redirect to 443; once the port had been changed via menu item 13 it failed 100% of the time. That location is now permanently present in Nginx, making issuance and renewal independent of the port Xray listens on. Commented-out configuration lines are no longer left behind when issuance fails.
* **Fixed the permanently false-positive domain IP check**: `ipget.net` now returns 403. The check uses `dig` to query A / AAAA records, falling back to `getent` when `dig` is unavailable.
* **Certificate permissions**: the renewal `--reloadcmd` now also fixes ownership of `/ssl`, so Xray can still read the certificate after renewal; the owner is taken from `User=` in the systemd unit. Also fixed the deprecated `chown user.group` dot syntax and the omission of the `/ssl` directory itself.
* **acme.sh**: `--upgrade --auto-upgrade` is executed after installation, preventing renewal failures caused by CA API changes on older versions.
* **Post-install self-check**: added `xray run -test` and `nginx -t` validation; the script errors out and exits on failure.
* **Configuration templates embedded in the script**: `config/*.json`, `web.conf` and `nginx.repo` are no longer fetched from GitHub during installation, so network hiccups can no longer produce a half-installed setup.
* **Compatibility**: added support for Rocky Linux / AlmaLinux / CentOS Stream; `nginx >= 1.25.1` now uses the `http2 on;` directive; the `jq` fallback download picks amd64 / arm64 based on CPU architecture; on IPv6-only machines the DNS64 configuration is appended to `/etc/resolv.conf` instead of overwriting it; timeouts were added to network requests everywhere, so the menu no longer hangs when GitHub is unreachable.
* **Share links**: removed the long-broken `security=xtls` links and QR codes, added the missing `encryption=none` / `type` / `sni` / `host` parameters, and the WebSocket path is now urlencoded (multi-level paths are no longer mangled).

### Acknowledgements

* The Project_Xray image in this README was provided by Blitzcrank (Telegram: @Blitz_crank) — many thanks to Blitzcrank;
* The MTProxyTLS part of this script is a modified version of https://github.com/sunpma/mtp — thanks to sunpma;
* The original 4-in-1 LotServer script is referenced from https://www.94ish.me/1635.html — thanks;
* The modified 4-in-1 LotServer script is referenced from https://github.com/ylx2016/Linux-NetSpeed — thanks to ylx2016;
* The configuration files and part of the logic reference https://github.com/jiuqi9997/xray-yes — thanks to 玖柒;
* The QR code API part references https://github.com/mack-a/v2ray-agent — thanks to mack-a.

### Service Control

Start Xray: `systemctl start xray`

Stop Xray: `systemctl stop xray`

Start Nginx: `systemctl start nginx`

Stop Nginx: `systemctl stop nginx`

### Relevant Paths

Web directory: `/www/xray_web`

Xray server configuration: `/usr/local/etc/xray/config.json`

Nginx directory: `/etc/nginx`

Certificate files: `/ssl/xray.key` (private key) and `/ssl/xray.crt` (public certificate)

## Support This Project

If you would like to support me, you can buy servers / proxies through my affiliate links:

**Servers / proxies:** [BandwagonHost](https://bandwagonhost.com/aff.php?aff=63939) · [JustMySocks](https://justmysocks.net/members/aff.php?aff=17621) · [DMIT](https://www.dmit.io/aff.php?aff=3957) · [Nube.sh (pay-as-you-go)](https://nube.sh/invite/5986088028ENM0) · [Vultr](https://www.vultr.com/?ref=6881279)

**socks5 / http residential proxies:** [Proxy-Cheap](https://app.proxy-cheap.com/r/Pbqf9l) · [IPRoyal](https://iproyal.cn/?r=249487)

You can also support me with USDT — thank you for your support — TRC20: `TU8mLTPfa5Y9nmszyfyt2VRAtuZhdLexL8`


## Stargazers over time

[![Stargazers over time](https://starchart.cc/wulabing/Xray_onekey.svg)](https://starchart.cc/wulabing/Xray_onekey)
