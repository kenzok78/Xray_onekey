[English](README.MD) | **简体中文** | [فارسی](README_FA.MD)

## Xray 基于 Nginx 的 VLESS + XTLS 一键安装脚本 <img src="https://raw.githubusercontent.com/wulabing/Xray_onekey/main/image/project_xray.jpg" alt="Project_Xray" width="122" height="30" align="bottom" />


> 感谢 JetBrains 提供的非商业开源软件开发授权！

> Thanks for non-commercial open source development authorization by JetBrains!

## 由于 Nginx 前置导致的嵌套 tls 可能会出现连接阻断 目前更推荐使用 reality ，建议移步到以下地址
https://github.com/wulabing/xray_docker

## ❤️ 赞助商

> 想出现在这里？欢迎通过 issue 或 [Telegram 群组](https://t.me/wulabing_v2ray) 联系我

<table>
<tr>
<td width="180"><a href="https://api.capybaracode.cc/register?aff=ENZE8PZ2VBDE"><img src="https://raw.githubusercontent.com/wulabing/xray_docker/master/image/sponsors/capybaracode.png" alt="CapybaraCode" width="150"></a></td>
<td>感谢 <a href="https://api.capybaracode.cc/register?aff=ENZE8PZ2VBDE">CapybaraCode</a> 赞助本项目 —— 这是本项目收到的第一笔赞助，感谢这份认可！<br>稳定、低延迟的 Claude Code / AI 编码 API 中转服务，开箱即用、按量计费，日常写代码足够顺手。注册时填写优惠码 <code>WULABING</code> 可额外获得 <b>4 美元</b>额度。</td>
</tr>
<tr>
<td width="180"><a href="https://www.uhdnow.com/signup?invite=IMAX4K"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/wulabing/xray_docker/master/image/sponsors/uhdnow-dark.png"><img src="https://raw.githubusercontent.com/wulabing/xray_docker/master/image/sponsors/uhdnow.png" alt="UHDNOW" width="150"></picture></a></td>
<td>感谢 <a href="https://www.uhdnow.com/signup?invite=IMAX4K">UHDNOW</a> 赞助本项目！<br>一个用心维护的 Emby 私服，4K / IMAX 原盘、杜比视界与 HDR 片源齐全，多线路直连、拖拉即播，喜欢折腾影音的朋友可以去看看。</td>
</tr>
</table>

### Telegram 群组
* Telegram 交流群：https://t.me/wulabing_v2ray 
* Telegram 更新公告频道：https://t.me/wulabing_channel

### 准备工作
* 准备一个域名，并将 A 记录添加好；
* 安装好 `wget`。

### 导入链接规范
https://github.com/XTLS/Xray-core/issues/91


### 安装/更新方式（Nginx 前置）

支持配置方式

- VLESS + TCP + TLS + Nginx + WebSocket

```
wget -N --no-check-certificate -q -O install.sh "https://raw.githubusercontent.com/wulabing/Xray_onekey/nginx_forward/install.sh" && chmod +x install.sh && bash install.sh
```

### 安装/更新方式（Xray 前置）

支持配置方式

- VLESS + TCP + TLS + Nginx（流控 `xtls-rprx-vision`）

- VLESS + TCP + TLS + Nginx（流控 `xtls-rprx-vision`）及 VLESS + TCP + TLS + Nginx + WebSocket 回落并存模式

```
wget -N --no-check-certificate -q -O install.sh "https://raw.githubusercontent.com/wulabing/Xray_onekey/main/install.sh" && chmod +x install.sh && bash install.sh
```


### 注意事项
* 如果你不了解脚本中各项设置的具体含义，除域名外，请使用脚本提供的默认值；
* 使用本脚本需要你拥有 Linux 基础及使用经验，了解计算机网络部分知识，计算机基础操作；
* 群主仅提供极其有限的支持，如有问题可以询问群友。

### 支持的系统

| 发行版 | 版本要求 | 备注 |
| --- | --- | --- |
| Debian | 10+ | 推荐 Debian 12 / 13 |
| Ubuntu | 20.04+ | |
| Rocky Linux | 8+ | |
| AlmaLinux | 8+ | |
| Oracle Linux | 7+ | |
| CentOS | 7+ / Stream | **CentOS 7 已于 2024-06-30 EOL**，官方源已迁移至 vault.centos.org，脚本会打印警告后继续，依赖安装可能失败，建议更换发行版 |

### 已知限制

* **WebSocket 传输已被 Xray 标记为弃用。** 自 [Xray-core v26.1.23](https://github.com/XTLS/Xray-core/releases/tag/v26.1.23) 起，使用 ws 传输时启动日志会打印弃用警告（`The feature WebSocket transport (with ALPN http/1.1, etc.) is deprecated, not recommended for using and might be removed.`），未来版本可能移除。该警告在日志文件建立之前输出，因此只能在 `journalctl -u xray` 中看到，不会出现在 `/var/log/xray/error.log`。
* 本脚本采用 Nginx 前置 + 嵌套 TLS 的结构，存在被针对性阻断的可能。长期建议迁移到 REALITY / XHTTP，见 [wulabing/xray_docker](https://github.com/wulabing/xray_docker)。

### 修复说明（v1.4.1）

* **修复 Debian 13 依赖安装失败**（[#487](https://github.com/wulabing/Xray_onekey/issues/487)）：Debian 13 已移除 `libpcre3-dev`，而脚本仍在一条 `apt install` 里安装它，导致整条命令失败、同行的 `openssl` 等包一并装不上。这批 pcre / zlib / openssl 开发包是早年编译安装 Nginx 时代的遗留，当前 Nginx 走官方源二进制安装，早已用不到，现已全部删除。
* **端口占用检测不再强杀 Nginx**（[#469](https://github.com/wulabing/Xray_onekey/issues/469)）：原先检测到 80 端口被占用会直接 `kill -9`，若占用者是正在运行的 Nginx，会把 `nginx.service` 打成 `failed (Result: signal)` 状态。现改为优先 `systemctl stop nginx` 优雅停止，仍未释放才回退到 `kill -9`。
* **修复 `limits.conf` 被写坏**：若 `/etc/security/limits.conf` 末尾没有换行符（部分发行版与云镜像如此），脚本追加的 `* soft nofile 65536` 会直接拼到上一行末尾，既破坏原有限制，又让按行首匹配的清理逻辑失效——重复安装会不断累积垃圾行，且文件打开数优化实际从未生效。现在追加前会补齐换行。
* **BBR 加速脚本增加来源校验**（[#490](https://github.com/wulabing/Xray_onekey/issues/490)）：上游 `ylx2016/Linux-NetSpeed` 仓库异常时可能下发旧版脚本，现在执行前会校验脚本来源并打印其版本号，校验不通过则放弃执行。

### 本次维护版修复说明（v1.4.0）

> **存量用户请特别注意**：如果你的节点是 v1.3.11 及更早版本安装的，其入站 **TLS 配置实际未加载任何证书**，客户端无法完成 TLS 握手。请重新安装，或手动把 `/usr/local/etc/xray/config.json` 里的 `"xtlsSettings"` 改名为 `"tlsSettings"` 后 `systemctl restart xray`。

* **修复入站 TLS 未加载证书（致命）**：配置模板中的 `xtlsSettings` 自 Xray-core v1.8.1 起已不再是合法字段，JSON 未知字段被静默忽略，导致 `security: "tls"` 落到一份空 TLS 配置上、`certificates` 从未生效。已改名为 `tlsSettings`。
* **修复非 443 端口下证书续期必然失败**：原先靠按行号 `sed` 临时改写 Nginx 配置来放行 `/.well-known/acme-challenge/`，常态下 80 端口对该路径也无条件 301 到 https，续期只能靠 CA 跟随重定向落到 443 才侥幸成功；一旦用菜单 13 改过端口即 100% 失败。现改为在 Nginx 中常驻该 location，签发与续期与 Xray 监听端口无关。签发失败时也不再残留被注释的配置行。
* **修复域名 IP 校验永久误报**：`ipget.net` 已返回 403，改用 `dig` 查询 A / AAAA 记录，无 `dig` 时回退 `getent`。
* **证书权限**：续期 `--reloadcmd` 中一并修正 `/ssl` 属主，避免续期后 Xray 读不到证书；属主取自 systemd 单元的 `User=`；修正已弃用的 `chown user.group` 点号语法及漏掉 `/ssl` 目录自身的问题。
* **acme.sh**：安装后执行 `--upgrade --auto-upgrade`，避免老版本因 CA API 变动而续期失败。
* **安装收尾自检**：新增 `xray run -test` 与 `nginx -t` 校验，失败即报错退出。
* **配置模板内嵌进脚本**：不再在安装过程中从 GitHub 拉取 `config/*.json`、`web.conf`、`nginx.repo`，避免网络波动导致装出半成品。
* **兼容性**：新增 Rocky Linux / AlmaLinux / CentOS Stream 支持；`nginx >= 1.25.1` 改用 `http2 on;` 指令；`jq` 兜底下载按 CPU 架构选择 amd64 / arm64；IPv6 Only 机器的 DNS64 配置改为追加写入而非覆盖 `/etc/resolv.conf`；各处网络请求补齐超时，GitHub 不可达时不再卡住菜单。
* **分享链接**：移除早已失效的 `security=xtls` 链接与二维码，补齐 `encryption=none` / `type` / `sni` / `host` 参数，WebSocket 路径改用 urlencode（多级路径不再被拼错）。

### 鸣谢

* 本脚本中 README Project_Xray 项目图片由 Blitzcrank Telegram:@Blitz_crank 提供 在此感谢Blitzcrank
* 本脚本中 MTProxyTLS 基于 https://github.com/sunpma/mtp 二次修改 在此感谢 sunpma；
* 本脚本中 锐速 4 合 1 脚本原项目引用 https://www.94ish.me/1635.html 在此感谢；
* 本脚本中 锐速 4 合 1 脚本修改版项目引用 https://github.com/ylx2016/Linux-NetSpeed 在此感谢 ylx2016；
* 本脚本中 配置文件及部分逻辑参考 https://github.com/jiuqi9997/xray-yes 在此感谢 玖柒；
* 本脚本中 二维码 API 部分参考 https://github.com/mack-a/v2ray-agent  在此感谢 mack-a。

### 启动方式

启动 Xray：`systemctl start xray`

停止 Xray：`systemctl stop xray`

启动 Nginx：`systemctl start nginx`

停止 Nginx：`systemctl stop nginx`

### 相关目录

Web 目录：`/www/xray_web`

Xray 服务端配置：`/usr/local/etc/xray/config.json`

Nginx 目录： `/etc/nginx`

证书文件： `/ssl/xray.key`（私钥）和 `/ssl/xray.crt`（证书公钥）

## 支持这个项目

如果您想支持我，可以走我的 AFF 购买服务器 / 代理：

**服务器 / 代理：** [搬瓦工](https://bandwagonhost.com/aff.php?aff=63939) · [JustMySocks](https://justmysocks.net/members/aff.php?aff=17621) · [DMIT](https://www.dmit.io/aff.php?aff=3957) · [Nube.sh（按量付费）](https://nube.sh/invite/5986088028ENM0) · [Vultr](https://www.vultr.com/?ref=6881279)

**socks5 / http 家宽代理：** [Proxy-Cheap](https://app.proxy-cheap.com/r/Pbqf9l) · [IPRoyal](https://iproyal.cn/?r=249487)

也可以通过 USDT 支持我，感谢您的支持 —— TRC20：`TU8mLTPfa5Y9nmszyfyt2VRAtuZhdLexL8`


## Stargazers over time

[![Stargazers over time](https://starchart.cc/wulabing/Xray_onekey.svg)](https://starchart.cc/wulabing/Xray_onekey)

