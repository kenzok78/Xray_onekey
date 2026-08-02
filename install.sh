#!/usr/bin/env bash

#====================================================
#	System Request: Debian 10+/Ubuntu 20.04+/CentOS 7+/Rocky·Alma 8+/Oracle Linux 7+
#	Author:	wulabing
#	Dscription: Xray onekey Management
#	email: admin@wulabing.com
#====================================================

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
stty erase ^?

cd "$(
  cd "$(dirname "$0")" || exit
  pwd
)" || exit

# 字体颜色配置
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
Blue="\033[36m"
Font="\033[0m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
OK="${Green}[OK]${Font}"
ERROR="${Red}[ERROR]${Font}"

# 变量
shell_version="1.4.0"
github_branch="main"
xray_conf_dir="/usr/local/etc/xray"
nginx_conf_dir="/etc/nginx/conf.d"
website_dir="/www/xray_web/"
xray_access_log="/var/log/xray/access.log"
xray_error_log="/var/log/xray/error.log"
cert_dir="/usr/local/etc/xray"
domain_tmp_dir="/usr/local/etc/xray"
cert_group="nobody"
# Xray 官方 systemd 单元默认以 nobody 运行，xray_user_check 会按实际单元文件校正
xray_user="nobody"
random_num=$((RANDOM % 12 + 4))

WS_PATH="/$(head -n 10 /dev/urandom | md5sum | head -c ${random_num})/"

function shell_mode_check() {
  if [ -f ${xray_conf_dir}/config.json ]; then
    if [ "$(grep -c "wsSettings" ${xray_conf_dir}/config.json)" -ge 1 ]; then
      shell_mode="ws"
    else
      shell_mode="tcp"
    fi
  else
    shell_mode="None"
  fi
}
function print_ok() {
  echo -e "${OK} ${Blue} $1 ${Font}"
}

function print_error() {
  echo -e "${ERROR} ${RedBG} $1 ${Font}"
}

function is_root() {
  if [[ 0 == "$UID" ]]; then
    print_ok "当前用户是 root 用户，开始安装流程"
  else
    print_error "当前用户不是 root 用户，请切换到 root 用户后重新执行脚本"
    exit 1
  fi
}

judge() {
  if [[ 0 -eq $? ]]; then
    print_ok "$1 完成"
    sleep 1
  else
    print_error "$1 失败"
    exit 1
  fi
}

# 识别发行版family，统一包管理器入口，供 RedHat / Debian 系分支复用
function os_family_detect() {
  source '/etc/os-release'

  case "${ID}" in
  centos | rocky | almalinux | rhel | ol)
    os_family="rhel"
    INS="yum install -y"
    ;;
  debian | ubuntu)
    os_family="debian"
    INS="apt install -y"
    ;;
  *)
    os_family="unknown"
    ;;
  esac
}

# nginx 1.25.1 起 listen 指令的 http2 参数被废弃，改用独立的 http2 指令
function nginx_version_ge() {
  local target="$1" current
  current=$(nginx -v 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
  [[ -z ${current} ]] && return 1
  [[ "$(printf '%s\n%s\n' "${target}" "${current}" | sort -V | head -1)" == "${target}" ]]
}

function write_nginx_repo() {
  cat >/etc/yum.repos.d/nginx.repo <<'EOF'
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOF
}

function system_check() {
  os_family_detect

  local major_version=${VERSION_ID%%.*}

  case "${ID}" in
  centos)
    if [[ ${major_version} -lt 7 ]]; then
      print_error "当前系统为 CentOS ${VERSION_ID}，不在支持的系统列表内"
      exit 1
    fi
    if [[ ${major_version} -eq 7 ]]; then
      print_error "CentOS 7 已于 2024-06-30 结束生命周期（EOL），官方源已迁移至 vault.centos.org"
      print_error "脚本将继续执行，但依赖安装可能失败，强烈建议更换为 Debian 12+ / Rocky Linux 9+"
      sleep 5
    fi
    print_ok "当前系统为 CentOS ${VERSION_ID}"
    ;;
  rocky | almalinux)
    if [[ ${major_version} -lt 8 ]]; then
      print_error "当前系统为 ${NAME} ${VERSION_ID}，不在支持的系统列表内"
      exit 1
    fi
    print_ok "当前系统为 ${NAME} ${VERSION_ID}"
    ;;
  ol)
    print_ok "当前系统为 Oracle Linux ${VERSION_ID}"
    ;;
  debian)
    if [[ ${major_version} -lt 10 ]]; then
      print_error "当前系统为 Debian ${VERSION_ID}，不在支持的系统列表内（需 Debian 10+）"
      exit 1
    fi
    print_ok "当前系统为 Debian ${VERSION_ID}"
    ;;
  ubuntu)
    if [[ ${major_version} -lt 20 ]]; then
      print_error "当前系统为 Ubuntu ${VERSION_ID}，不在支持的系统列表内（需 Ubuntu 20.04+）"
      exit 1
    fi
    print_ok "当前系统为 Ubuntu ${VERSION_ID} ${UBUNTU_CODENAME}"
    ;;
  *)
    print_error "当前系统为 ${ID} ${VERSION_ID} 不在支持的系统列表内"
    exit 1
    ;;
  esac

  # nginx 官方源配置
  if [[ ${os_family} == "rhel" ]]; then
    ${INS} wget
    write_nginx_repo
  else
    apt update
    ${INS} wget curl gnupg2 ca-certificates lsb-release
    if [[ "${ID}" == "debian" ]]; then
      ${INS} debian-archive-keyring
    else
      ${INS} ubuntu-keyring
    fi
    # 清除可能的遗留问题
    rm -f /etc/apt/sources.list.d/nginx.list
    curl -s --connect-timeout 5 -m 30 https://nginx.org/keys/nginx_signing.key |
      gpg --dearmor >/usr/share/keyrings/nginx-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/${ID} $(lsb_release -cs) nginx" \
      >/etc/apt/sources.list.d/nginx.list
    printf 'Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n' \
      >/etc/apt/preferences.d/99nginx

    apt update
  fi

  if grep -q "nogroup" /etc/group; then
    cert_group="nogroup"
  fi

  $INS dbus

  # 关闭各类防火墙
  systemctl stop firewalld
  systemctl disable firewalld
  systemctl stop nftables
  systemctl disable nftables
  systemctl stop ufw
  systemctl disable ufw
}

function nginx_install() {
  if ! command -v nginx >/dev/null 2>&1; then
    ${INS} nginx
    judge "Nginx 安装"
  else
    print_ok "Nginx 已存在"
  fi
  # 遗留问题处理
  mkdir -p ${nginx_conf_dir} >/dev/null 2>&1
}
function dependency_install() {
  ${INS} lsof tar
  judge "安装 lsof tar"

  # Debian 最小化安装可能没有 wget，而后续多处依赖它
  ${INS} wget
  judge "安装 wget"

  if [[ ${os_family} == "rhel" ]]; then
    ${INS} crontabs
  else
    ${INS} cron
  fi
  judge "安装 crontab"

  if [[ ${os_family} == "rhel" ]]; then
    touch /var/spool/cron/root && chmod 600 /var/spool/cron/root
    systemctl start crond && systemctl enable crond
  else
    touch /var/spool/cron/crontabs/root && chmod 600 /var/spool/cron/crontabs/root
    systemctl start cron && systemctl enable cron

  fi
  judge "crontab 自启动配置 "

  ${INS} unzip
  judge "安装 unzip"

  ${INS} curl
  judge "安装 curl"

  # 域名解析检测依赖 dig，缺失时 domain_check 会回退到 getent
  if [[ ${os_family} == "rhel" ]]; then
    ${INS} bind-utils
  else
    ${INS} dnsutils
  fi

  # upgrade systemd
  ${INS} systemd
  judge "安装/升级 systemd"

  if [[ "${ID}" == "centos" ]]; then
    ${INS} pcre pcre-devel zlib-devel epel-release openssl openssl-devel
  elif [[ ${os_family} == "rhel" ]]; then
    ${INS} pcre pcre-devel zlib-devel openssl openssl-devel
    if [[ "${ID}" == "ol" ]]; then
      # Oracle Linux 不同日期版本的 VERSION_ID 比较乱 直接暴力处理。如出现问题或有更好的方案，请提交 Issue。
      ${INS} dnf-plugins-core >/dev/null 2>&1
      yum-config-manager --enable ol7_developer_EPEL >/dev/null 2>&1
      yum-config-manager --enable ol8_developer_EPEL >/dev/null 2>&1
    fi
  else
    ${INS} libpcre3 libpcre3-dev zlib1g-dev openssl libssl-dev
  fi

  ${INS} jq

  if ! command -v jq >/dev/null 2>&1; then
    jq_fallback_install
    judge "安装 jq"
  fi

  # 防止部分系统xray的默认bin目录缺失
  mkdir -p /usr/local/bin >/dev/null 2>&1
}

# 发行版仓库没有 jq 时，按架构从 jqlang 官方 release 获取
function jq_fallback_install() {
  local jq_arch
  case "$(uname -m)" in
  x86_64 | amd64) jq_arch="amd64" ;;
  aarch64 | arm64) jq_arch="arm64" ;;
  *)
    print_error "未识别的 CPU 架构 $(uname -m)，无法自动安装 jq"
    return 1
    ;;
  esac

  if wget --connect-timeout=5 --timeout=30 -O /usr/bin/jq \
    "https://github.com/jqlang/jq/releases/latest/download/jq-linux-${jq_arch}"; then
    chmod +x /usr/bin/jq
    return 0
  fi

  print_error "从 jqlang 获取 jq 失败，回退至项目内置版本（仅 amd64）"
  wget --connect-timeout=5 --timeout=30 -O /usr/bin/jq \
    "https://raw.githubusercontent.com/wulabing/Xray_onekey/${github_branch}/binary/jq" &&
    chmod +x /usr/bin/jq
}

function basic_optimization() {
  # 最大文件打开数
  sed -i '/^\*\ *soft\ *nofile\ *[[:digit:]]*/d' /etc/security/limits.conf
  sed -i '/^\*\ *hard\ *nofile\ *[[:digit:]]*/d' /etc/security/limits.conf
  echo '* soft nofile 65536' >>/etc/security/limits.conf
  echo '* hard nofile 65536' >>/etc/security/limits.conf

  # RedHat 系发行版关闭 SELinux
  if [[ ${os_family} == "rhel" ]]; then
    sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
    setenforce 0
  fi
}

function domain_check() {
  read -rp "请输入你的域名信息(eg: www.wulabing.com):" domain
  domain=$(echo "${domain}" | tr -d '[:space:]')
  if [[ -z ${domain} ]]; then
    print_error "域名不能为空"
    exit 1
  fi

  print_ok "正在获取 IP 地址信息，请耐心等待"
  local domain_ipv4 domain_ipv6
  if command -v dig >/dev/null 2>&1; then
    domain_ipv4=$(dig +short +time=5 +tries=2 "${domain}" A | grep -E '^[0-9.]+$' | head -1)
    domain_ipv6=$(dig +short +time=5 +tries=2 "${domain}" AAAA | grep -E '^[0-9a-fA-F:]+$' | head -1)
  else
    domain_ipv4=$(getent ahostsv4 "${domain}" | awk '{print $1; exit}')
    domain_ipv6=$(getent ahostsv6 "${domain}" | awk '{print $1; exit}')
  fi

  wgcfv4_status=$(curl -s4m8 --connect-timeout 5 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2)
  wgcfv6_status=$(curl -s6m8 --connect-timeout 5 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2)
  if [[ ${wgcfv4_status} =~ ^(on|plus)$ ]] || [[ ${wgcfv6_status} =~ ^(on|plus)$ ]]; then
    # 关闭wgcf-warp，以防误判VPS IP情况
    wg-quick down wgcf >/dev/null 2>&1
    print_ok "已关闭 wgcf-warp"
  fi
  local_ipv4=$(curl -s4 --connect-timeout 5 -m 10 ip.sb)
  local_ipv6=$(curl -s6 --connect-timeout 5 -m 10 ip.sb)
  if [[ -z ${local_ipv4} && -n ${local_ipv6} ]]; then
    # 纯IPv6 VPS，追加 DNS64 服务器以备 acme.sh 申请证书使用（追加而非覆盖，避免破坏既有解析）
    local ns
    for ns in 2606:4700:4700::64 2606:4700:4700::6400 2a01:4f8:c2c:123f::1; do
      grep -q "${ns}" /etc/resolv.conf 2>/dev/null || echo "nameserver ${ns}" >>/etc/resolv.conf
    done
    print_ok "识别为 IPv6 Only 的 VPS，已追加 DNS64 服务器"
  fi
  echo -e "域名解析的 IPv4 地址（A）：   ${domain_ipv4:-未获取到}"
  echo -e "域名解析的 IPv6 地址（AAAA）：${domain_ipv6:-未获取到}"
  echo -e "本机公网 IPv4 地址：          ${local_ipv4:-未获取到}"
  echo -e "本机公网 IPv6 地址：          ${local_ipv6:-未获取到}"
  sleep 2
  if [[ -n ${local_ipv4} && ${domain_ipv4} == "${local_ipv4}" ]]; then
    print_ok "域名解析的 A 记录与本机 IPv4 地址匹配"
    sleep 2
  elif [[ -n ${local_ipv6} && ${domain_ipv6} == "${local_ipv6}" ]]; then
    print_ok "域名解析的 AAAA 记录与本机 IPv6 地址匹配"
    sleep 2
  else
    print_error "请确保域名添加了正确的 A / AAAA 记录，否则将无法正常使用 xray"
    print_error "域名解析的 IP 地址与本机 IPv4 / IPv6 地址不匹配，是否继续安装？（y/n）" && read -r install
    case $install in
    [yY][eE][sS] | [yY])
      print_ok "继续安装"
      sleep 2
      ;;
    *)
      print_error "安装终止"
      exit 2
      ;;
    esac
  fi
}

function port_exist_check() {
  if [[ 0 -eq $(lsof -i:"$1" | grep -i -c "listen") ]]; then
    print_ok "$1 端口未被占用"
    sleep 1
  else
    print_error "检测到 $1 端口被占用，以下为 $1 端口占用信息"
    lsof -i:"$1"
    print_error "5s 后将尝试自动 kill 占用进程"
    sleep 5
    lsof -i:"$1" | awk '{print $2}' | grep -v "PID" | xargs kill -9
    print_ok "kill 完成"
    sleep 1
  fi
}
function update_sh() {
  ol_version=$(curl -L -s --connect-timeout 5 -m 10 https://raw.githubusercontent.com/wulabing/Xray_onekey/${github_branch}/install.sh | grep "shell_version=" | head -1 | awk -F '=|"' '{print $3}')
  if [[ -z ${ol_version} ]]; then
    # 网络不可达时跳过检查，避免脚本启动即卡死
    print_error "无法获取远程版本信息，跳过更新检查"
    return 0
  fi
  if [[ "$shell_version" != "$(echo -e "$shell_version\n$ol_version" | sort -rV | head -1)" ]]; then
    print_ok "存在新版本，是否更新 [Y/N]?"
    read -r update_confirm
    case $update_confirm in
    [yY][eE][sS] | [yY])
      wget -N --no-check-certificate --connect-timeout=5 --timeout=30 https://raw.githubusercontent.com/wulabing/Xray_onekey/${github_branch}/install.sh
      print_ok "更新完成"
      print_ok "您可以通过 bash $0 执行本程序"
      exit 0
      ;;
    *) ;;
    esac
  else
    print_ok "当前版本为最新版本"
    print_ok "您可以通过 bash $0 执行本程序"
  fi
}

function xray_tmp_config_file_check_and_use() {
  if [[ -s ${xray_conf_dir}/config_tmp.json ]]; then
    mv -f ${xray_conf_dir}/config_tmp.json ${xray_conf_dir}/config.json
  else
    print_error "xray 配置文件修改异常"
  fi
}

function modify_UUID() {
  [ -z "$UUID" ] && UUID=$(cat /proc/sys/kernel/random/uuid)
  cat ${xray_conf_dir}/config.json | jq 'setpath(["inbounds",0,"settings","clients",0,"id"];"'${UUID}'")' >${xray_conf_dir}/config_tmp.json
  xray_tmp_config_file_check_and_use
  judge "Xray TCP UUID 修改"
}

function modify_UUID_ws() {
  cat ${xray_conf_dir}/config.json | jq 'setpath(["inbounds",1,"settings","clients",0,"id"];"'${UUID}'")' >${xray_conf_dir}/config_tmp.json
  xray_tmp_config_file_check_and_use
  judge "Xray ws UUID 修改"
}

function modify_fallback_ws() {
  cat ${xray_conf_dir}/config.json | jq 'setpath(["inbounds",0,"settings","fallbacks",2,"path"];"'${WS_PATH}'")' >${xray_conf_dir}/config_tmp.json
  xray_tmp_config_file_check_and_use
  judge "Xray fallback_ws 修改"
}

function modify_ws() {
  cat ${xray_conf_dir}/config.json | jq 'setpath(["inbounds",1,"streamSettings","wsSettings","path"];"'${WS_PATH}'")' >${xray_conf_dir}/config_tmp.json
  xray_tmp_config_file_check_and_use
  judge "Xray ws 修改"
}

# VLESS + TCP + TLS (XTLS Vision) 配置模板
function write_xray_config_tcp() {
  mkdir -p ${xray_conf_dir}
  cat >${xray_conf_dir}/config.json <<'EOF'
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "xx",
            "flow": "xtls-rprx-vision"
          }
        ],
        "decryption": "none",
        "fallbacks": [
          {
            "dest": 60000,
            "alpn": "",
            "xver": 1
          },
          {
            "dest": 60001,
            "alpn": "h2",
            "xver": 1
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "tls",
        "tlsSettings": {
          "minVersion": "1.2",
          "certificates": [
            {
              "certificateFile": "/usr/local/etc/xray/self_signed_cert.pem",
              "keyFile": "/usr/local/etc/xray/self_signed_key.pem"
            },
            {
              "certificateFile": "/ssl/xray.crt",
              "keyFile": "/ssl/xray.key"
            }
          ]
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom"
    }
  ]
}
EOF
  judge "Xray 配置文件写入"
}

# VLESS + TCP + TLS 与 WebSocket 回落并存模式 配置模板
function write_xray_config_ws() {
  mkdir -p ${xray_conf_dir}
  cat >${xray_conf_dir}/config.json <<'EOF'
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "xx",
            "flow": "xtls-rprx-vision"
          }
        ],
        "decryption": "none",
        "fallbacks": [
          {
            "dest": 60000,
            "alpn": "",
            "xver": 1
          },
          {
            "dest": 60001,
            "alpn": "h2",
            "xver": 1
          },
          {
            "dest": 60002,
            "path": "/wulabing",
            "xver": 1
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "tls",
        "tlsSettings": {
          "minVersion": "1.2",
          "certificates": [
            {
              "certificateFile": "/usr/local/etc/xray/self_signed_cert.pem",
              "keyFile": "/usr/local/etc/xray/self_signed_key.pem"
            },
            {
              "certificateFile": "/ssl/xray.crt",
              "keyFile": "/ssl/xray.key"
            }
          ]
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    },
    {
      "port": 60002,
      "listen": "127.0.0.1",
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "xx"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "acceptProxyProtocol": true,
          "path": "xx"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom"
    }
  ]
}
EOF
  judge "Xray 配置文件写入"
}

# 伪装站点下载失败或用户跳过时的占位页，避免 webroot 为空导致 nginx 返回 403
function write_fallback_index() {
  mkdir -p ${website_dir}
  cat >"${website_dir%/}/index.html" <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Welcome to nginx!</title>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and working.</p>
</body>
</html>
EOF
}

function write_nginx_conf() {
  nginx_conf="${nginx_conf_dir}/${domain}.conf"
  mkdir -p "${nginx_conf_dir}"
  rm -f "${nginx_conf}"

  local http2_listen="listen 127.0.0.1:60001 proxy_protocol;"
  local http2_directive="    http2 on;"
  if ! nginx_version_ge 1.25.1; then
    http2_listen="listen 127.0.0.1:60001 http2 proxy_protocol;"
    http2_directive=""
  fi

  cat >"${nginx_conf}" <<'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name __DOMAIN__;

    # acme.sh webroot 校验路径常驻，使签发与续期不受 Xray 监听端口影响
    location ^~ /.well-known/acme-challenge/ {
        root __WEBROOT__;
    }

    location / {
        return 301 https://$host$request_uri;
    }

    access_log  /dev/null;
    error_log  /dev/null;
}

server {
    listen 127.0.0.1:60000 proxy_protocol;
    __HTTP2_LISTEN__
__HTTP2_DIRECTIVE__
    server_name __DOMAIN__;
    index index.html index.htm index.php default.php default.htm default.html;
    root __WEBROOT__;
    add_header Strict-Transport-Security "max-age=63072000" always;

    location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
    {
            expires   30d;
            error_log off;
    }

    location ~ .*\.(js|css)?$
    {
            expires   12h;
            error_log off;
    }
}
EOF

  sed -i "s|__DOMAIN__|${domain}|g" "${nginx_conf}"
  sed -i "s|__WEBROOT__|${website_dir%/}|g" "${nginx_conf}"
  sed -i "s|__HTTP2_LISTEN__|${http2_listen}|" "${nginx_conf}"
  if [[ -n ${http2_directive} ]]; then
    sed -i "s|^__HTTP2_DIRECTIVE__$|${http2_directive}|" "${nginx_conf}"
  else
    sed -i "/^__HTTP2_DIRECTIVE__$/d" "${nginx_conf}"
  fi
  judge "Nginx 配置 写入"
}

function configure_nginx() {
  write_nginx_conf

  systemctl enable nginx
  systemctl restart nginx
}

function modify_port() {
  read -rp "请输入端口号(默认：443)：" PORT
  [ -z "$PORT" ] && PORT="443"
  if ! [[ $PORT =~ ^[0-9]+$ ]] || [[ $PORT -le 0 ]] || [[ $PORT -gt 65535 ]]; then
    print_error "请输入 0-65535 之间的值"
    exit 1
  fi
  port_exist_check $PORT
  cat ${xray_conf_dir}/config.json | jq 'setpath(["inbounds",0,"port"];'${PORT}')' >${xray_conf_dir}/config_tmp.json
  xray_tmp_config_file_check_and_use
  judge "Xray 端口 修改"
}

function configure_xray() {
  write_xray_config_tcp
  modify_UUID
  modify_port
}

function configure_xray_ws() {
  write_xray_config_ws
  modify_UUID
  modify_UUID_ws
  modify_port
  modify_fallback_ws
  modify_ws
}

function xray_install() {
  print_ok "安装 Xray"
  curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh | bash -s -- install
  judge "Xray 安装"

  # 用于生成 Xray 的导入链接
  echo $domain >$domain_tmp_dir/domain
  judge "域名记录"
}

# 证书权限需与 Xray 实际运行用户一致（官方单元默认 nobody，可被 -u 改写）
function xray_user_check() {
  local unit_user
  unit_user=$(systemctl show -p User --value xray 2>/dev/null)
  [[ -z ${unit_user} ]] && unit_user=$(grep -m1 '^User=' /etc/systemd/system/xray.service 2>/dev/null | cut -d'=' -f2)
  unit_user=$(echo "${unit_user}" | tr -d '[:space:]')
  [[ -n ${unit_user} ]] && xray_user="${unit_user}"
  print_ok "Xray 运行用户识别为 ${xray_user}"
}

function wgcf_up() {
  if [[ -n $(type -P wgcf) && -n $(type -P wg-quick) ]]; then
    wg-quick up wgcf >/dev/null 2>&1
    print_ok "已启动 wgcf-warp"
  fi
}

function ssl_install() {
  curl -L -s --connect-timeout 5 -m 30 https://get.acme.sh | bash
  judge "安装 SSL 证书生成脚本"

  # 老版本 acme.sh 会因 CA API 变动而续期失败，安装后立即升级并开启自动升级
  if [[ -x "$HOME/.acme.sh/acme.sh" ]]; then
    "$HOME"/.acme.sh/acme.sh --upgrade --auto-upgrade >/dev/null 2>&1
    print_ok "acme.sh 已升级至最新版本并开启自动升级"
  fi
}

# 证书安装的单一入口。acme.sh 会以本次 --install-cert 的参数覆盖已存记录，
# 任何一处省略 --reloadcmd 都会把它清空，导致后续自动续期不再修正权限、不重启 Xray
function install_cert_and_reload() {
  "$HOME"/.acme.sh/acme.sh --install-cert -d "${domain}" \
    --fullchainpath /ssl/xray.crt --keypath /ssl/xray.key \
    --reloadcmd "chown -R ${xray_user}:${cert_group} /ssl && systemctl restart xray" --ecc "$@"
}

function acme() {
  "$HOME"/.acme.sh/acme.sh --set-default-ca --server letsencrypt

  # .well-known 由 nginx 常驻 location 提供，签发与续期走同一条路径，无需临时改写 nginx 配置
  if "$HOME"/.acme.sh/acme.sh --issue -d "${domain}" --webroot "$website_dir" -k ec-256 --force ||
    "$HOME"/.acme.sh/acme.sh --issue -d "${domain}" --webroot "$website_dir" -k ec-256 --force --listen-v6; then
    print_ok "SSL 证书生成成功"
    sleep 2
  else
    print_error "SSL 证书生成失败"
    rm -rf "$HOME/.acme.sh/${domain}_ecc"
    wgcf_up
    exit 1
  fi

  # reloadcmd 中一并修正权限，确保后续自动续期不会因 owner 变回 root 而导致 Xray 读不到证书
  if install_cert_and_reload --force; then
    print_ok "SSL 证书配置成功"
    sleep 2
  else
    print_error "SSL 证书配置失败"
    wgcf_up
    exit 1
  fi

  wgcf_up
}

function ssl_judge_and_install() {
  mkdir -p /ssl >/dev/null 2>&1
  if [[ -f "/ssl/xray.key" || -f "/ssl/xray.crt" ]]; then
    print_ok "/ssl 目录下证书文件已存在"
    print_ok "是否删除 /ssl 目录下的证书文件 [Y/N]?"
    read -r ssl_delete
    case $ssl_delete in
    [yY][eE][sS] | [yY])
      rm -rf /ssl/*
      print_ok "已删除"
      ;;
    *) ;;

    esac
  fi

  if [[ -f "/ssl/xray.key" || -f "/ssl/xray.crt" ]]; then
    echo "证书文件已存在"
  elif [[ -f "$HOME/.acme.sh/${domain}_ecc/${domain}.key" && -f "$HOME/.acme.sh/${domain}_ecc/${domain}.cer" ]]; then
    echo "证书文件已存在"
    install_cert_and_reload
    judge "证书启用"
  else
    cp -a $cert_dir/self_signed_cert.pem /ssl/xray.crt
    cp -a $cert_dir/self_signed_key.pem /ssl/xray.key
    ssl_install
    acme
  fi

  # Xray 以非 root 用户运行，证书权限适配（含 /ssl 目录自身）
  chown -R "${xray_user}":"${cert_group}" /ssl
}

function generate_certificate() {
  if [[ -z ${local_ipv4} && -n ${local_ipv6} ]]; then
    signedcert=$(xray tls cert -domain="$local_ipv6" -name="$local_ipv6" -org="$local_ipv6" -expire=87600h)
  else
    signedcert=$(xray tls cert -domain="$local_ipv4" -name="$local_ipv4" -org="$local_ipv4" -expire=87600h)
  fi
  echo $signedcert | jq '.certificate[]' | sed 's/\"//g' | tee $cert_dir/self_signed_cert.pem
  echo $signedcert | jq '.key[]' | sed 's/\"//g' >$cert_dir/self_signed_key.pem
  openssl x509 -in $cert_dir/self_signed_cert.pem -noout || (print_error "生成自签名证书失败" && exit 1)
  print_ok "生成自签名证书成功"
  chown "${xray_user}":"${cert_group}" $cert_dir/self_signed_cert.pem
  chown "${xray_user}":"${cert_group}" $cert_dir/self_signed_key.pem
}

function configure_web() {
  rm -rf ${website_dir}
  mkdir -p ${website_dir}
  print_ok "是否配置伪装网页？[Y/N]"
  read -r webpage
  case $webpage in
  [yY][eE][sS] | [yY])
    local web_tar="/tmp/xray_web.tar.gz"
    if wget --connect-timeout=5 --timeout=30 -O "${web_tar}" \
      "https://raw.githubusercontent.com/wulabing/Xray_onekey/${github_branch}/basic/web.tar.gz" &&
      tar xzf "${web_tar}" -C ${website_dir}; then
      print_ok "站点伪装 完成"
    else
      print_error "伪装站点获取失败，将写入最小占位页面"
    fi
    rm -f "${web_tar}"
    ;;
  *) ;;
  esac

  if [[ -z $(ls -A ${website_dir} 2>/dev/null) ]]; then
    write_fallback_index
  fi
}

function xray_uninstall() {
  curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh | bash -s -- remove --purge
  rm -rf $website_dir
  print_ok "是否卸载nginx [Y/N]?"
  read -r uninstall_nginx
  case $uninstall_nginx in
  [yY][eE][sS] | [yY])
    if [[ ${os_family} == "rhel" ]]; then
      yum remove nginx -y
    else
      apt purge nginx -y
    fi
    ;;
  *) ;;
  esac
  print_ok "是否卸载acme.sh [Y/N]?"
  read -r uninstall_acme
  case $uninstall_acme in
  [yY][eE][sS] | [yY])
    "$HOME"/.acme.sh/acme.sh --uninstall
    rm -rf "$HOME/.acme.sh"
    rm -rf /ssl/
    ;;
  *) ;;
  esac
  print_ok "卸载完成"
  exit 0
}

# 安装收尾自检：本次修复的 P0（入站 TLS 无证书）之所以能潜伏两年，就是因为缺少这一步
function config_check() {
  if xray run -test -c ${xray_conf_dir}/config.json; then
    print_ok "Xray 配置文件校验通过"
  else
    print_error "Xray 配置文件校验失败，请检查上方报错信息"
    exit 1
  fi

  if nginx -t; then
    print_ok "Nginx 配置文件校验通过"
  else
    print_error "Nginx 配置文件校验失败，请检查上方报错信息"
    exit 1
  fi
}

function restart_all() {
  systemctl restart nginx
  judge "Nginx 启动"
  systemctl restart xray
  judge "Xray 启动"
}

function urlencode() {
  local raw="$1" out="" i c
  for ((i = 0; i < ${#raw}; i++)); do
    c=${raw:i:1}
    case "$c" in
    [a-zA-Z0-9.~_-]) out+="$c" ;;
    *) out+=$(printf '%%%02X' "'$c") ;;
    esac
  done
  echo "$out"
}

function print_link_and_qrcode() {
  print_ok "URL 链接 ($1)"
  print_ok "$2"
  print_ok "URL 二维码 ($1) （请在浏览器中访问）"
  print_ok "https://api.qrserver.com/v1/create-qr-code/?size=400x400&data=$(urlencode "$2")"
}

function vless_xtls-rprx-vision_link() {
  UUID=$(jq -r '.inbounds[0].settings.clients[0].id' ${xray_conf_dir}/config.json)
  PORT=$(jq -r '.inbounds[0].port' ${xray_conf_dir}/config.json)
  FLOW=$(jq -r '.inbounds[0].settings.clients[0].flow' ${xray_conf_dir}/config.json)
  DOMAIN=$(cat ${domain_tmp_dir}/domain)

  local query="encryption=none&security=tls&sni=${DOMAIN}&type=tcp"
  [[ -n ${FLOW} && ${FLOW} != "null" ]] && query="${query}&flow=${FLOW}"

  print_link_and_qrcode "VLESS + TCP + TLS" \
    "vless://${UUID}@${DOMAIN}:${PORT}?${query}#TLS_wulabing-${DOMAIN}"
}

function vless_xtls-rprx-vision_information() {
  UUID=$(jq -r '.inbounds[0].settings.clients[0].id' ${xray_conf_dir}/config.json)
  PORT=$(jq -r '.inbounds[0].port' ${xray_conf_dir}/config.json)
  FLOW=$(jq -r '.inbounds[0].settings.clients[0].flow' ${xray_conf_dir}/config.json)
  DOMAIN=$(cat ${domain_tmp_dir}/domain)

  echo -e "${Red} Xray 配置信息 ${Font}"
  echo -e "${Red} 地址（address）:${Font}  $DOMAIN"
  echo -e "${Red} 端口（port）：${Font}  $PORT"
  echo -e "${Red} 用户 ID（UUID）：${Font} $UUID"
  echo -e "${Red} 流控（flow）：${Font} $FLOW"
  echo -e "${Red} 加密方式（encryption）：${Font} none "
  echo -e "${Red} 传输协议（network）：${Font} tcp "
  echo -e "${Red} 伪装类型（type）：${Font} none "
  echo -e "${Red} 底层传输安全：${Font} tls"
}

function ws_information() {
  UUID=$(jq -r '.inbounds[1].settings.clients[0].id' ${xray_conf_dir}/config.json)
  PORT=$(jq -r '.inbounds[0].port' ${xray_conf_dir}/config.json)
  WS_PATH=$(jq -r '.inbounds[0].settings.fallbacks[2].path' ${xray_conf_dir}/config.json)
  DOMAIN=$(cat ${domain_tmp_dir}/domain)

  echo -e "${Red} Xray 配置信息 ${Font}"
  echo -e "${Red} 地址（address）:${Font}  $DOMAIN"
  echo -e "${Red} 端口（port）：${Font}  $PORT"
  echo -e "${Red} 用户 ID（UUID）：${Font} $UUID"
  echo -e "${Red} 加密方式（encryption）：${Font} none "
  echo -e "${Red} 传输协议（network）：${Font} ws "
  echo -e "${Red} 伪装类型（type）：${Font} none "
  echo -e "${Red} 路径（path）：${Font} $WS_PATH "
  echo -e "${Red} 底层传输安全：${Font} tls "
}

function ws_link() {
  UUID=$(jq -r '.inbounds[1].settings.clients[0].id' ${xray_conf_dir}/config.json)
  PORT=$(jq -r '.inbounds[0].port' ${xray_conf_dir}/config.json)
  WS_PATH=$(jq -r '.inbounds[0].settings.fallbacks[2].path' ${xray_conf_dir}/config.json)
  DOMAIN=$(cat ${domain_tmp_dir}/domain)

  print_link_and_qrcode "VLESS + WebSocket + TLS" \
    "vless://${UUID}@${DOMAIN}:${PORT}?encryption=none&security=tls&sni=${DOMAIN}&type=ws&host=${DOMAIN}&path=$(urlencode "${WS_PATH}")#WS_TLS_wulabing-${DOMAIN}"
}

function basic_information() {
  print_ok "VLESS + TCP + TLS (XTLS Vision) + Nginx 安装成功"
  vless_xtls-rprx-vision_information
  vless_xtls-rprx-vision_link
}

function basic_ws_information() {
  print_ok "VLESS + TCP + TLS (XTLS Vision) + Nginx 与 WebSocket 回落并存模式 安装成功"
  vless_xtls-rprx-vision_information
  vless_xtls-rprx-vision_link
  print_ok "————————————————————————"
  ws_information
  ws_link
}

# 赞助商与 AFF 展示，用于菜单头部与安装收尾。文案真源是 README.MD 的
# 「❤️ 赞助商」与「支持这个项目」两节，改动时请一并同步（xray_docker 各 README 亦同）。
# 刻意不放进 basic_information：菜单 23 查看配置链接时不应跟着展示推广。
function show_support() {
  echo -e "\n${Blue}──────────────────── 支持本项目 ────────────────────${Font}"
  echo -e "${Yellow}赞助商${Font} CapybaraCode  AI 编码 / Claude Code API 中转"
  echo -e "                     优惠码 WULABING 额外送 4 美元额度"
  echo -e "                     https://api.capybaracode.cc/register?aff=ENZE8PZ2VBDE"
  echo -e "${Yellow}赞助商${Font} UHDNOW        4K / IMAX 原盘 Emby 私服，多线路直连"
  echo -e "                     https://www.uhdnow.com/signup?invite=IMAX4K"
  echo -e "${Yellow}服务器 AFF${Font}           搬瓦工 · DMIT · Nube.sh · Vultr（详见 README）"
  echo -e "${Yellow}USDT  TRC20${Font}          TU8mLTPfa5Y9nmszyfyt2VRAtuZhdLexL8"
  echo -e "${Blue}────────────────────────────────────────────────────${Font}"
}

function show_access_log() {
  [ -f ${xray_access_log} ] && tail -f ${xray_access_log} || echo -e "${RedBG}log 文件不存在${Font}"
}

function show_error_log() {
  [ -f ${xray_error_log} ] && tail -f ${xray_error_log} || echo -e "${RedBG}log 文件不存在${Font}"
}

function ssl_renew() {
  local acme_home="$HOME/.acme.sh"
  if [[ ! -x "${acme_home}/acme.sh" ]]; then
    print_error "未检测到 acme.sh（${acme_home}），请先通过菜单 1 / 2 完成安装"
    return 1
  fi

  print_ok "执行 acme.sh --cron（证书未达到续期时间时不会有任何动作，这是正常现象）"
  "${acme_home}"/acme.sh --cron --home "${acme_home}"

  print_ok "是否忽略剩余有效期强制续期？（注意 Let's Encrypt 存在频率限制）[Y/N]"
  read -r force_renew
  case ${force_renew} in
  [yY][eE][sS] | [yY])
    local renew_domain
    renew_domain=$(cat ${domain_tmp_dir}/domain 2>/dev/null)
    if [[ -z ${renew_domain} ]]; then
      print_error "未找到域名记录 ${domain_tmp_dir}/domain，无法强制续期"
      return 1
    fi
    "${acme_home}"/acme.sh --renew -d "${renew_domain}" --force --ecc --home "${acme_home}"
    ;;
  *) ;;
  esac

  restart_all
}

function bbr_boost_sh() {
  [ -f "tcp.sh" ] && rm -rf ./tcp.sh
  wget -N --no-check-certificate "https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh" && chmod +x tcp.sh && ./tcp.sh
}

function mtproxy_sh() {
  wget -N --no-check-certificate "https://github.com/wulabing/mtp/raw/master/mtproxy.sh" && chmod +x mtproxy.sh && bash mtproxy.sh
}

function install_xray() {
  is_root
  system_check
  dependency_install
  basic_optimization
  domain_check
  port_exist_check 80
  xray_install
  xray_user_check
  configure_xray
  nginx_install
  configure_nginx
  configure_web
  generate_certificate
  ssl_judge_and_install
  config_check
  restart_all
  basic_information
  show_support
}
function install_xray_ws() {
  is_root
  system_check
  dependency_install
  basic_optimization
  domain_check
  port_exist_check 80
  xray_install
  xray_user_check
  configure_xray_ws
  nginx_install
  configure_nginx
  configure_web
  generate_certificate
  ssl_judge_and_install
  config_check
  restart_all
  basic_ws_information
  show_support
}
menu() {
  update_sh
  shell_mode_check
  echo -e "\t Xray 安装管理脚本 ${Red}[${shell_version}]${Font}"
  echo -e "\t---authored by wulabing---"
  echo -e "\thttps://github.com/wulabing"
  show_support
  echo

  echo -e "当前已安装版本：${shell_mode}"
  echo -e "—————————————— 安装向导 ——————————————"""
  echo -e "${Green}0.${Font}  升级 脚本"
  echo -e "${Green}1.${Font}  安装 Xray (VLESS + TCP + TLS + Nginx, XTLS Vision)"
  echo -e "${Green}2.${Font}  安装 Xray (VLESS + TCP + TLS + Nginx, XTLS Vision 及 VLESS + TCP + TLS + Nginx + WebSocket 回落并存模式)"
  echo -e "—————————————— 配置变更 ——————————————"
  echo -e "${Green}11.${Font} 变更 UUID"
  echo -e "${Green}13.${Font} 变更 连接端口"
  echo -e "${Green}14.${Font} 变更 WebSocket PATH"
  echo -e "—————————————— 查看信息 ——————————————"
  echo -e "${Green}21.${Font} 查看 实时访问日志"
  echo -e "${Green}22.${Font} 查看 实时错误日志"
  echo -e "${Green}23.${Font} 查看 Xray 配置链接"
  #    echo -e "${Green}23.${Font}  查看 V2Ray 配置信息"
  echo -e "—————————————— 其他选项 ——————————————"
  echo -e "${Green}31.${Font} 安装 4 合 1 BBR、锐速安装脚本"
  echo -e "${Yellow}32.${Font} 安装 MTproxy （不推荐使用,请相关用户关闭或卸载）"
  echo -e "${Green}33.${Font} 卸载 Xray"
  echo -e "${Green}34.${Font} 更新 Xray-core"
  echo -e "${Green}35.${Font} 安装 Xray-core 测试版 (Pre)"
  echo -e "${Green}36.${Font} 手动更新 SSL 证书"
  echo -e "${Green}40.${Font} 退出"
  read -rp "请输入数字：" menu_num
  case $menu_num in
  0)
    update_sh
    ;;
  1)
    install_xray
    ;;
  2)
    install_xray_ws
    ;;
  11)
    read -rp "请输入 UUID:" UUID
    if [[ ${shell_mode} == "tcp" ]]; then
      modify_UUID
    elif [[ ${shell_mode} == "ws" ]]; then
      modify_UUID
      modify_UUID_ws
    fi
    restart_all
    ;;
  13)
    modify_port
    restart_all
    ;;
  14)
    if [[ ${shell_mode} == "ws" ]]; then
      read -rp "请输入路径(示例：/wulabing/ 要求两侧都包含 /):" WS_PATH
      modify_fallback_ws
      modify_ws
      restart_all
    else
      print_error "当前模式不是 Websocket 模式"
    fi
    ;;
  21)
    tail -f $xray_access_log
    ;;
  22)
    tail -f $xray_error_log
    ;;
  23)
    if [[ -f $xray_conf_dir/config.json ]]; then
      if [[ ${shell_mode} == "tcp" ]]; then
        basic_information
      elif [[ ${shell_mode} == "ws" ]]; then
        basic_ws_information
      fi
    else
      print_error "xray 配置文件不存在"
    fi
    ;;
  31)
    bbr_boost_sh
    ;;
  32)
    mtproxy_sh
    ;;
  33)
    os_family_detect
    xray_uninstall
    ;;
  34)
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" - install
    restart_all
    ;;
  35)
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" - install --beta
    restart_all
    ;;
  36)
    ssl_renew
    ;;
  40)
    exit 0
    ;;
  *)
    print_error "请输入正确的数字"
    ;;
  esac
}
menu "$@"
