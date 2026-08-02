
## اسکریپت نصب Xray مبتنی بر Nginx برای ساختار VLESS + XTLS با یک کلیک <img src="https://raw.githubusercontent.com/wulabing/Xray_onekey/main/image/project_xray.jpg" alt="Project_Xray" width="122" height="30" align="bottom" />


> با تشکر از JetBrains برای مجوز توسعه نرم افزار منبع باز غیر تجاری!


>از مجوز توسعه منبع باز غیر تجاری توسط JetBrains سپاسگزاریم!

### با توجه به احتمال مسدود شدن xtls، پیشنهاد می شود از نسخه پیشین Nginx استفاده کنید 

### ❤️ حامیان مالی

> می‌خواهید نام شما اینجا باشد؟ از طریق issue یا [گروه تلگرام](https://t.me/wulabing_v2ray) با من در تماس باشید

<table>
<tr>
<td width="180"><a href="https://api.capybaracode.cc/register?aff=ENZE8PZ2VBDE"><img src="https://raw.githubusercontent.com/wulabing/xray_docker/master/image/sponsors/capybaracode.png" alt="CapybaraCode" width="150"></a></td>
<td>با تشکر از <a href="https://api.capybaracode.cc/register?aff=ENZE8PZ2VBDE">CapybaraCode</a> برای حمایت از این پروژه — این نخستین حمایت مالی این پروژه است!<br>سرویس واسط API پایدار و کم‌تأخیر برای Claude Code و کدنویسی با هوش مصنوعی، آماده استفاده و با پرداخت بر اساس مصرف. با وارد کردن کد تخفیف <code>WULABING</code> هنگام ثبت‌نام، <b>4 دلار</b> اعتبار اضافه دریافت می‌کنید.</td>
</tr>
<tr>
<td width="180"><a href="https://www.uhdnow.com/signup?invite=IMAX4K"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/wulabing/xray_docker/master/image/sponsors/uhdnow-dark.png"><img src="https://raw.githubusercontent.com/wulabing/xray_docker/master/image/sponsors/uhdnow.png" alt="UHDNOW" width="150"></picture></a></td>
<td>با تشکر از <a href="https://www.uhdnow.com/signup?invite=IMAX4K">UHDNOW</a> برای حمایت از این پروژه!<br>یک سرور خصوصی Emby که با دقت نگهداری می‌شود؛ آرشیو کاملی از نسخه‌های 4K / IMAX، Dolby Vision و HDR با پخش مستقیم و روان از چند مسیر. اگر به فیلم و سریال با کیفیت علاقه دارید، سر بزنید.</td>
</tr>
</table>

### گروه تلگرام
* گروه ارتباطی تلگرام: https://t.me/wulabing_v2ray 
* کانال اطلاعیه آپدیت تلگرام:https://t.me/wulabing_channel

### آماده سازی
* یک نام دامنه آماده کنید و رکورد A را اضافه کنید

* نصب کردن wget

### مشخصات لینک وارد کردن
https://github.com/XTLS/Xray-core/issues/91

> As of 2021-2-24, only V2RayN 4.12+ and V2RayNG 1.5.8+ support link and QR code import. For other clients, please fill in the configuration information manually.


### روش نصب و بروزرسانی (Nginx front)

پیکربندی قابل پشتیبان

- VLESS + TCP + TLS + Nginx + WebSocket

```
wget -N --no-check-certificate -q -O install.sh "https://raw.githubusercontent.com/wulabing/Xray_onekey/nginx_forward/install.sh" && chmod +x install.sh && bash install.sh
```

### روش نصب و بروزرسانی (Xray front)

پیکربندی قابل پشتیبانی
- VLESS + TCP + XTLS / TLS  + Nginx

- VLESS + TCP + XTLS / TLS  + Nginx 及 VLESS + TCP + TLS + Nginx + WebSocket 回落并存模式

```
wget -N --no-check-certificate -q -O install.sh "https://raw.githubusercontent.com/wulabing/Xray_onekey/main/install.sh" && chmod +x install.sh && bash install.sh
```


### موارد احتیاط
* اگر معنای خاص هر یک از تنظیمات در اسکریپت را نمی‌دانید، به جز نام دامنه، لطفاً از مقدار پیش‌فرض ارائه شده توسط اسکریپت استفاده کنید.
* برای استفاده از این اسکریپت، باید پایه و تجربه لینوکس، مقداری دانش در مورد شبکه های کامپیوتری و عملیات اولیه کامپیوتر داشته باشید.
* در حال حاضر از Debian 9+ / Ubuntu 18.04+ / Centos7+ / Oracle Linux 7+ پشتیبانی می کند.
* مالک گروه فقط پشتیبانی بسیار محدودی را ارائه می دهد، اگر سؤالی دارید، می توانید از اعضای گروه بپرسید.

### با تشکر

* 本脚本中 README Project_Xray 项目图片由 Blitzcrank Telegram:@Blitz_crank 提供 在此感谢Blitzcrank
* 本脚本中 MTProxyTLS 基于 https://github.com/sunpma/mtp 二次修改 在此感谢 sunpma；
* 本脚本中 锐速 4 合 1 脚本原项目引用 https://www.94ish.me/1635.html 在此感谢；
* 本脚本中 锐速 4 合 1 脚本修改版项目引用 https://github.com/ylx2016/Linux-NetSpeed 在此感谢 ylx2016；
* 本脚本中 配置文件及部分逻辑参考 https://github.com/jiuqi9997/xray-yes 在此感谢 玖柒；
* 本脚本中 二维码 API 部分参考 https://github.com/mack-a/v2ray-agent  在此感谢 mack-a。

### روش شروع و توقف سرویس

start Xray：`systemctl start xray`

stop Xray：`systemctl stop xray`

start Nginx：`systemctl start nginx`

stop Nginx：`systemctl stop nginx`

### قسمت های که پروژه استفاده می کند

Web دایرکتوری：`/www/xray_web`

Xray پیکربندی سرور：`/usr/local/etc/xray/config.json`

Nginx دایرکتوری： `/etc/nginx`

certs： `/ssl/xray.key`（私钥）和 `/ssl/xray.crt`（证书公钥）

### حمایت از این پروژه

اگر می‌خواهید از من حمایت کنید، می‌توانید از طریق لینک‌های معرف (AFF) من سرور یا پروکسی بخرید:

**سرور / پروکسی:** [BandwagonHost](https://bandwagonhost.com/aff.php?aff=63939) · [JustMySocks](https://justmysocks.net/members/aff.php?aff=17621) · [DMIT](https://www.dmit.io/aff.php?aff=3957) · [Nube.sh (پرداخت بر اساس مصرف)](https://nube.sh/invite/5986088028ENM0) · [Vultr](https://www.vultr.com/?ref=6881279)

**پروکسی خانگی socks5 / http:** [Proxy-Cheap](https://app.proxy-cheap.com/r/Pbqf9l) · [IPRoyal](https://iproyal.cn/?r=249487)

همچنین می‌توانید با USDT از من حمایت کنید، از پشتیبانی شما سپاسگزارم — TRC20: `TU8mLTPfa5Y9nmszyfyt2VRAtuZhdLexL8`


## Stargazers over time

[![Stargazers over time](https://starchart.cc/wulabing/Xray_onekey.svg)](https://starchart.cc/wulabing/Xray_onekey)

