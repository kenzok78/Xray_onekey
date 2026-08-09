**English** | [简体中文](README_ZH.md)

## ss-openresty Whitelist

> Please note that this is still experimental. The technical framework is fully described below; for details, refer to the documentation of the components involved.

This is an openresty (nginx) based whitelist implementation for ss.

* Started with `docker-compose`
* Uses `ngx_http_auth_basic_module` for access authentication
* Uses `ngx_http_access_module` for IP whitelist control
* Uses `ngx_stream_proxy_module` for layer-4 reverse proxying
* Uses `lua` to adjust and apply the configuration

Visit the proxy's IP address in a browser and pass the username/password authentication to add your current IP to the whitelist.
No certificate issuance is required; ss uses the `ss-libev` version.

There is no tutorial. For what you need, look at the volume section of docker-compose.yml — it covers the nginx configuration files, and the templates are in the ss_whitelist folder as well. You must create an empty `allow.list` file in the corresponding folder.

## Advantages

* No more TLS / TLS tunnels needed — plain TCP.
* No tedious certificate issuance process.
* Should — most likely, probably — keep your port / IP from being blocked as much as possible.

## How It Works

The main detection method against ss-family protocols today is active probing from a large number of IPs, followed by blocking the port.

**Limited** testing shows that restricting access to the ss port with a whitelist largely avoids port blocking.

> We assume the firewall can access the server with a spoofed source IP and perform replay attacks; ss-AEAD's own replay resistance should be enough to handle that.

Most proxy usage happens at fixed locations with a relatively stable IP over a period of time, so restricting the source IPs allowed to reach ss via a whitelist is workable in most cases.

## Usage

* Visit IP/auth (e.g. http://1.1.1.1/auth) and enter the credentials to add your current IP to the whitelist
* Visit /purge to clear the whitelist
* Make sure `allow.list` has permissions of 666 or higher
* Works on ARM machines, so it can be used on Oracle ARM
