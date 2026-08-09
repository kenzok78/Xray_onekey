[English](README.MD) | [简体中文](README_ZH.MD) | **فارسی**

## اسکریپت نصب Xray مبتنی بر Nginx برای ساختار VLESS + XTLS با یک کلیک <img src="https://raw.githubusercontent.com/wulabing/Xray_onekey/main/image/project_xray.jpg" alt="Project_Xray" width="122" height="30" align="bottom" />


> با تشکر از JetBrains برای مجوز توسعه نرم افزار منبع باز غیر تجاری!


>از مجوز توسعه منبع باز غیر تجاری توسط JetBrains سپاسگزاریم!

## قرار دادن Nginx در جلو باعث ایجاد TLS تودرتو می‌شود که ممکن است به مسدود شدن اتصال بینجامد. در حال حاضر استفاده از REALITY توصیه می‌شود؛ لطفاً به آدرس زیر مراجعه کنید

https://github.com/wulabing/xray_docker

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
* مالک گروه فقط پشتیبانی بسیار محدودی را ارائه می دهد، اگر سؤالی دارید، می توانید از اعضای گروه بپرسید.

### سیستم‌های پشتیبانی‌شده

| توزیع | حداقل نسخه | توضیحات |
| --- | --- | --- |
| Debian | 10+ | Debian 12 / 13 توصیه می‌شود |
| Ubuntu | 20.04+ | |
| Rocky Linux | 8+ | |
| AlmaLinux | 8+ | |
| Oracle Linux | 7+ | |
| CentOS | 7+ / Stream | **پشتیبانی از CentOS 7 در تاریخ 2024-06-30 پایان یافته است**؛ مخازن رسمی به vault.centos.org منتقل شده‌اند. اسکریپت پس از نمایش هشدار ادامه می‌دهد، اما نصب وابستگی‌ها ممکن است شکست بخورد. تغییر توزیع توصیه می‌شود |

### محدودیت‌های شناخته‌شده

* **انتقال WebSocket از سوی Xray منسوخ اعلام شده است.** از نسخه [Xray-core v26.1.23](https://github.com/XTLS/Xray-core/releases/tag/v26.1.23) به بعد، هنگام استفاده از انتقال ws یک هشدار منسوخ‌شدن در لاگ راه‌اندازی چاپ می‌شود (`The feature WebSocket transport (with ALPN http/1.1, etc.) is deprecated, not recommended for using and might be removed.`) و ممکن است در نسخه‌های آینده حذف شود. این هشدار پیش از ساخته‌شدن فایل لاگ نوشته می‌شود، بنابراین تنها در `journalctl -u xray` دیده می‌شود و در `/var/log/xray/error.log` ظاهر نمی‌شود.
* این اسکریپت از ساختار Nginx در جلو به همراه TLS تودرتو استفاده می‌کند و احتمال مسدودسازی هدفمند آن وجود دارد. در بلندمدت مهاجرت به REALITY / XHTTP توصیه می‌شود؛ به [wulabing/xray_docker](https://github.com/wulabing/xray_docker) مراجعه کنید.

### اصلاحات این نسخه نگهداری (v1.4.0)

> **کاربران فعلی توجه کنند**: اگر نود شما با نسخه v1.3.11 یا قدیمی‌تر نصب شده است، پیکربندی TLS ورودی آن **در عمل هیچ گواهی‌ای را بارگذاری نکرده است** و کلاینت نمی‌تواند دست‌دادن (handshake) TLS را کامل کند. لطفاً دوباره نصب کنید، یا در فایل `/usr/local/etc/xray/config.json` نام `"xtlsSettings"` را به `"tlsSettings"` تغییر دهید و سپس `systemctl restart xray` را اجرا کنید.

* **رفع بارگذاری‌نشدن گواهی در TLS ورودی (بحرانی)**: فیلد `xtlsSettings` در قالب پیکربندی، از Xray-core v1.8.1 دیگر یک فیلد معتبر نیست. فیلدهای ناشناخته JSON بی‌صدا نادیده گرفته می‌شوند، بنابراین `security: "tls"` روی یک پیکربندی TLS خالی می‌نشست و `certificates` هرگز اعمال نمی‌شد. این فیلد به `tlsSettings` تغییر نام یافت.
* **رفع شکست همیشگی تمدید گواهی روی پورت‌های غیر از 443**: پیش‌تر برای بازکردن مسیر `/.well-known/acme-challenge/` پیکربندی Nginx به‌طور موقت و بر اساس شماره خط با `sed` بازنویسی می‌شد؛ در حالت عادی پورت 80 نیز این مسیر را بدون قید و شرط با 301 به https هدایت می‌کرد و تمدید تنها در صورتی به‌طور اتفاقی موفق می‌شد که CA این هدایت را تا پورت 443 دنبال کند. به‌محض تغییر پورت از طریق گزینه 13 منو، تمدید ۱۰۰٪ شکست می‌خورد. اکنون این location به‌صورت دائمی در Nginx حضور دارد و صدور و تمدید گواهی مستقل از پورتی است که Xray روی آن گوش می‌دهد. در صورت شکست صدور نیز دیگر خطوط پیکربندی کامنت‌شده باقی نمی‌مانند.
* **رفع هشدار نادرست همیشگی در بررسی IP دامنه**: سرویس `ipget.net` اکنون 403 برمی‌گرداند؛ بررسی رکوردهای A / AAAA با `dig` انجام می‌شود و در نبود `dig` به `getent` بازمی‌گردد.
* **دسترسی‌های گواهی**: در `--reloadcmd` مربوط به تمدید، مالکیت `/ssl` نیز اصلاح می‌شود تا Xray پس از تمدید بتواند گواهی را بخواند؛ مالک از مقدار `User=` در یونیت systemd گرفته می‌شود. همچنین نحو منسوخ `chown user.group` و جاافتادن خود پوشه `/ssl` اصلاح شد.
* **acme.sh**: پس از نصب، دستور `--upgrade --auto-upgrade` اجرا می‌شود تا نسخه‌های قدیمی به دلیل تغییر API مربوط به CA در تمدید شکست نخورند.
* **بررسی خودکار پس از نصب**: اعتبارسنجی `xray run -test` و `nginx -t` اضافه شد؛ در صورت شکست، اسکریپت با خطا خارج می‌شود.
* **قرار گرفتن قالب‌های پیکربندی درون خود اسکریپت**: فایل‌های `config/*.json`، `web.conf` و `nginx.repo` دیگر هنگام نصب از GitHub دریافت نمی‌شوند تا نوسان شبکه به نصب ناقص منجر نشود.
* **سازگاری**: پشتیبانی از Rocky Linux / AlmaLinux / CentOS Stream اضافه شد؛ برای `nginx >= 1.25.1` از دستور `http2 on;` استفاده می‌شود؛ دانلود پشتیبان `jq` بر اساس معماری CPU نسخه amd64 / arm64 را انتخاب می‌کند؛ روی ماشین‌های فقط IPv6، پیکربندی DNS64 به `/etc/resolv.conf` افزوده می‌شود به‌جای آنکه آن را بازنویسی کند؛ برای درخواست‌های شبکه در همه‌جا timeout تعیین شد تا در صورت در دسترس نبودن GitHub منو معطل نماند.
* **لینک‌های اشتراک‌گذاری**: لینک‌ها و QR کدهای `security=xtls` که مدت‌ها بود کار نمی‌کردند حذف شدند، پارامترهای `encryption=none` / `type` / `sni` / `host` تکمیل شدند و مسیر WebSocket اکنون urlencode می‌شود (مسیرهای چندسطحی دیگر خراب نمی‌شوند).

### با تشکر

* تصویر پروژه Project_Xray در این README توسط Blitzcrank (تلگرام: ‎@Blitz_crank‎) تهیه شده است؛ با تشکر از Blitzcrank
* بخش MTProxyTLS این اسکریپت نسخه‌ای تغییریافته از https://github.com/sunpma/mtp است؛ با تشکر از sunpma
* اسکریپت اصلی ۴ در ۱ LotServer از https://www.94ish.me/1635.html گرفته شده است؛ با تشکر
* نسخه تغییریافته اسکریپت ۴ در ۱ LotServer از https://github.com/ylx2016/Linux-NetSpeed گرفته شده است؛ با تشکر از ylx2016
* فایل‌های پیکربندی و بخشی از منطق با الهام از https://github.com/jiuqi9997/xray-yes نوشته شده‌اند؛ با تشکر از 玖柒
* بخش API مربوط به QR کد با الهام از https://github.com/mack-a/v2ray-agent نوشته شده است؛ با تشکر از mack-a

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

