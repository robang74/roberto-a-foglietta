<div id="firstdiv" created=":IT" style="max-width: 800px; margin: auto; white-space: pre-wrap; text-align: justify;">
<!-- style>#printlink { display: inline; } @page { size: legal; margin: 0.50in 13.88mm 0.50in 13.88mm; zoom: 100%; } @media print { html { zoom: 100%; } }</style //-->

## Quick Start Guide v1.7.5.1

This is the guide originally written for the SailFish OS community forum and reported here in Github .md format. If you are going to use this guide for commercial purposes, feel free to contact me to negotiate a license for your business-specific needs.

---

### QUICK ACCESS

If you want to use the URL links in this guide for configuring your `SailFish OS` smartphone, scan the `QR`-code below with the default native camera app:

> <img src="img/quick-start-guide-qrcode.png" width="175px" height="175px"><br>
> short url: https://t.ly/rD8LD

Then open the encoded URL with the default native browser and save it in your bookmark for future and faster access to this guide.

---

### ANDROID VERSION

Currently, the Xperia 10 II is delivered with Android 12 (since 2022-06-13, last update: 2022-07-27) while the Xperia 10 III (since 2022-06-13, last update: 2022-07-27) is delivered with Android 13.

* [Sony Xperia list of ASOP available](https://developer.sony.com/open-source/aosp-on-xperia-open-devices/latest-updates#secondary-menu-desktop)

Reading the [flashing procedure described by Jolla](https://jolla.com/sailfishxinstall/), the suggested and almost required version is Android 11 instead. Therefore, you need to re-flash your smartphone in order to downgrade to the Android version. To accomplish this task, you need to download the [Sony Emma flashing tool](https://developer.sony.com/open-source/aosp-on-xperia-open-devices/get-started/flash-tool) which runs only on Microsoft Windows, and follow these instructions about [reverting a Xperia device to Android OS](https://docs.sailfishos.org/Support/Help_Articles/Managing_Sailfish_OS/Reinstalling_Sailfish_OS/#reverting-xperia-device-to-android-os-and-reinstalling-sailfish-os).

The alternative to Sony Emma flashtool is [Xperifirm](https://xperifirmtool.com/category/tool) which requires `mono` to run on a GNU/Linux distribution and has limited access to the firmware. For example, the Xperia 10 III is not supported, and the Xperia 10 II offers geographic areas customized firmware based on Android 12 and just a couple of other alternatives, which are customization.

* [Sony Xperia flashing guide](/forum/knowhow/flashing-tools-for-Xperia-phones.md)

This guide provides some practical knowledge for integrating Jolla's official procedure.

---

### USB PROBLEMS

During the [flashing procedure described by Jolla](https://jolla.com/sailfishxinstall/), you might encounter two different problems with `fastboot` util and `flash.sh`: the `USB` v3.x issue and `USB` sleeping after the first `fastboot` command, which will make your smartphone reboot, preventing the `flash.sh` script from completing its job.

To solve these two problems at once, use a `USB` v2.0-only hub and connect to it a `USB` stick, which your system should mount. This is because the `BIOS` of some laptops is configured to give energy even if the `USB`/`PC` is sleeping, but with a `USB` stick mounted, the `OS` will know that there is a data transfer in place, and it should keep the `USB` port awake.

The alternative is to give this script a try. It fixed both issues on my USB v3.x-only laptop:

* https://coderus.openrepos.net/pm2/project/fastboot_usb3fix_script

It is a script delivered by `Patch Manager` but it is for your laptop/`PC` not for `SFOS`. It also has a double nature: a patch that can be applied to have the script and a shell script embedded into the patch header, both!

The script will unbind all the `USB` devices connected to the `xhci_pci` kernel driver, set the communication standard to `USB` v2.0 with an always-on powering policy, and then bind all the devices back.

<code>
sudo ./fastboot-usb3fix.sh 2<br>
sudo /bin/bash flash.sh #--force<br>
sudo ./fastboot-usb3fix.sh 3
</code>

The last command is `3` because you want to return to the `USB` v3.x communication standard due to its speed and performance improvements over `USB` v2.0.

<sup>________</sup>

**fasboot usage**

Here is a way to re-flash the vendor backup partition despite `USB` problems:

<code>
fastboot flash oem_b SW_binaries_&ast;_seine.img<br>
 #< waiting for any device ><br>
 #<br>
 # connect the powered off device keeping the volume-up<br>
 # key pressed until the notifications led become blue<br>

fastboot reboot<br>
 # This line above makes your smartphone reboot.<br>
</code>

It leverages the fact that `fastboot` has been executed before the smartphone is connected, and thus it sets the `USB` parameters before the smartphone is engaged. This trick will work for a single run of `fastboot`. Hence, it will not work with `flash.sh` unless the `USB` v2.0-only mode is set.

<sup>________</sup>

**flash.sh tricks**

However, the `flash.sh` procedure can also be done manually, partition per partition, and the list of actions to follow is listed here below:

<code>
$ head -11 flash-config.sh <br>
VALID_PRODUCTS=("XQ-AU52")<br>

FLASH_OPS=(<br>
  "getvar_fail_if secure yes"<br>
  "flash boot_a hybris-boot.img"<br>
  "flash boot_b hybris-boot.img"<br>
  "flash dtbo_a dtbo.img"<br>
  "flash dtbo_b dtbo.img"<br>
  "flash userdata sailfish.img001"<br>
  "flash_blob oem_a &ast;_v12b_seine.img"<br>
)
</code>

This is the header of `flash_config.sh` which shows you the list of actions. If you change this file, add an extra line like:

`"flash_blob oem_b &ast;_v12b_seine.img"`

Then you have to call `flash.sh` with the `--force` option. Otherwise, it fails complaining about the  `md5sum` mismatch.

<sup>________</sup>

**Android debug**

This is useful for the Android debugger `ADB` mode, and it does not conflict with the `fastboot` mode:

<code>
eval $(lsusb | sed -ne "s/.&ast; \([a-f0-9]\{4\}\):\([a-f0-9]\{4\}\) "\<br>
"Sony Ericsson Mobile .&ast;/idVendor=\\1 idProduct=\\2/p")<br>

udev_file=/etc/udev/rules.d/51-android.rules<br>

if [ -z "$idVendor" -o -z "idProduct" ]; then<br>
  echo "connect the Sony Xperia smartphone to your USB port"<br>
elif ! grep -q "grep-RAF-check" $udev_file; then<br>
  echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="$idVendor",'\<br>
' ATTR{idProduct}=="$idProduct", MODE="0666", GROUP="plugdev",'\<br>
' SYMLINK+="xperia%n" # grep-RAF-check' | sudo tee -a $udev_file<br>
  sudo systemctl reload udev<br>
  sudo systemctl restart udev<br>
fi
</code>

The above settings should be done one single time, and you have to replace the `idVendor` and `idProduct` with those you will find using `lsusb` with your smartphone connected to the `USB` port of your `PC`/laptop. The script above should do it for you.

---

### AFTER LICENSING

Install the *Android Support* from the Jolla market, then the `F-Droid` market app.

> :memo: @olf wrote:
>
> Do not install `APToide` because  in the past it shown relevant security issues and moreover anyone can upload an app in such store thus is not secure.

These choices can be made at the first boot of your newly flashed smartphone.

---

### MICRO-G CONFIG

The `microG` project components are not anymore available on `F-Droid`, in particular about [com.google.android.gms](https://f-droid.org/en/packages/com.google.android.gms/) the page reports the error `404 Page Not Found`.

While the `UnifiedNlp` component [org.microg.nlp](https://f-droid.org/packages/org.microg.nlp/) is still hosted. AFAIK, it does not work anymore, and its lack of support for the recent Android versions is not news.

Therefore, we need to go with the packages from its official website or import its repository in `F-Droid`. The advantage of importing the repository into the `F-Droid` app instead of installing it from the original website is that you will receive notifications about future updates:

- https://microg.org/download.html

Install the entire suite (four apps) at the last available version, the preview release, if available. 

1. [microG Services Core](https://f-droid.org/packages/com.google.android.gms/)
2. [FakeStore](https://f-droid.org/packages/com.android.vending/)
3. [FakeGapps](https://f-droid.org/packages/com.thermatk.android.xf.fakegapps/)
4. [microG DroidGuard Helper](https://f-droid.org/packages/org.microg.gms.droidguard/)

Open the `SFOS` app menu:

* Settings:Apps --> MicroG Settings --> Open Android settings --> microG Service Core --> Permissions

then allow all permissions at the maximum privilege level:

- `Body Sensors` : Allow
- `Contacts` : Allow
- `Files and media` : Allow access to media only
- `Location` : Allow all the time
- `Phone` : Allow
- `SMS` : Allow
- `Spoof package signature` : Allow

Then open the `microG Service Core` and, in the *self-check* page, accept for all. If you wish, add a Google account, accept the device registration at Google, and set the Cloud Messaging (aka push notification) to ON. Now, you are back on Android and ready to run many apps developed for that OS.

---

### CHUM MARKET

Activate the *Allow untrusted software* option:

* Settings:System --> Security:Untrusted software --> Allow untrusted software

Download and install the last release `RPM` package from here for `SFOS` v4.5.0.19 and `ARM64` architecture:

- [SailFishOS 4.5.0.19 Chum installer for ARM64](https://repo.sailfishos.org/obs/sailfishos:/chum/4.5.0.19_aarch64/sailfishos:chum.repo)

For future `SFOS` versions or other architectures, choose from here:

* [SailFishOS Chum installer package repository](https://repo.sailfishos.org/obs/sailfishos:/chum)

Deactivate the *Allow untrusted software* option, not now but after having installed `StoreMan` and `UpToDown`, see below.

---

### STOREMAN

Activate the *Allow untrusted software* option:

* Settings:System --> Security:Untrusted software --> Allow untrusted software

Download and install the last release `RPM` package from here:

- https://github.com/storeman-developers/harbour-storeman-installer/releases

Deactivate the *Allow untrusted software* option, not now but after having installed `UpToDown`, see below.

---

### UPTODOWN

Activate the *Allow untrusted software* option:

* Settings:System --> Security:Untrusted software --> Allow untrusted software

Download and install the last release `APK` package from here:

* https://uptodown-android.en.uptodown.com/android/download

Deactivate the *Allow untrusted software* option.

---

### PATCH MANAGER

Available in the `Chum` market as `Patch Manager` for `SailFishOS`, here:

- https://openrepos.net/content/patchmanager/patchmanager

The `Patch Manager` is not an application without an icon but adds a voice in the `Settings` menu.

---

### APPS INSTALLATION

`Jolla`: 

* Jolla: `Predictive Text` and almost all others but not `Documents`¹ 
* Top Apps: `File Browser`, `Sailfish Utilities`, `Weather`, `Here WeGo`
* Apps: `Audio Recorder`, `OSM Scout`, `SailOTP`, `QR Clip`, `Watchlist`

`F-Droid`:

* [ViMusic](https://f-droid.org/it/packages/it.vfsfitvnm.vimusic/) (youtube music)
* [Aurora Droid](https://f-droid.org/packages/com.aurora.adroid/) (apps market)
* [Hypatia](https://f-droid.org/it/packages/us.spotco.malwarescanner/) (antivirus)

`UpToDown`:

* [Aurora Store](https://aurora-store.en.uptodown.com/android) (apps market², Google account required)
* [Amazon Appstore](https://amazon-appstore.en.uptodown.com/android) (apps market², Amazon accout required)

`Chum`:

* [Advanced Camera](https://openrepos.net/content/piggz/advanced-camera) 
* [Defender II](https://openrepos.net/content/peterleinchen/defender-ii-updated-encrypted-devices-originated-nodevel) (ad blocker and privacy guard)
* [Edge Swipe Control](https://build.sailfishos.org/package/show/sailfishos:chum/peekfilter-button) (system menu mod)
* [Fotokopierer](https://openrepos.net/content/fifr/fotokopierer) (documents camera scanner)
* [MLS Manager](https://openrepos.net/content/blacksheepdev/mls-manager) (MLS data download)
* [Pure Maps](https://openrepos.net/content/rinigus/pure-maps) (native navigation app)
* [GPSinfo](https://openrepos.net/content/direc85/gpsinfo) (compass calibration, GPS test)

`StoreMan`:

* [qCommand](https://openrepos.net/node/10618) (shell script launcher, sys-tool)
* [Emoji+ keyboard](https://openrepos.net/content/ade/emoji-keyboard) (follow the installation instructions)
* [XT9 improved punctuation handling](https://openrepos.net/content/ichthyosaurus/patch-xt9-improved-punctuation-handling) (patch³)
* [Alternative UI for Pure Maps](https://openrepos.net/content/pichlo/patch-alternative-ui-pure-maps) (patch³)
* [System Monitor](https://openrepos.net/content/ade/system-monitor-fork)  (sys-tool)
* [Space Inspector](https://openrepos.net/content/ade/space-inspector)  (sys-tool)
* [Wifi Analyser](https://openrepos.net/content/osanwe/wifi-analyser)  (net-tool)

`Patch Manager` in `Web Catalog`:

* [quick fingerprint service restart](https://coderus.openrepos.net/pm2/project/utilities-quick-fp-restart) (patch³)
* [x10ii-iii-agps-config-emea](https://coderus.openrepos.net/pm2/project/x10ii-iii-agps-config-emea) (patch³, cfr. the `A-GPS` indoor section)
* [notification-preview-high-cpu-usage](https://coderus.openrepos.net/pm2/project/sailfishos-notification-preview-high-cpu-usage-patch) (patch³)

---

### WEB BROWSER

This can be quite an amusing Android web-browser with *Turbo Mode* to speed you up:

* [Rocket Lightweight Web Browser](https://apkpure.com/rocket%E2%80%94lightweight-web-browser/dev.rocketscientists.rocket) on `apkpure`.

created by the previous Firefox Lite team, it weighs only 6MB in APK size and grants:

* No data is shared with third parties
* Data is encrypted in transit
* No data was collected.

Moreover, it is an [open-source project](https://github.com/RocketScientists/Rocket) hosted on Github.

---

### GOOGLE CAMERA PORT

* [Gcam Hub](https://www.celsoazevedo.com/files/android/google-camera/dev-hasli/f/dl14/)
* [Gcam Service](https://f-droid.org/en/packages/de.lukaspieper.gcam.services/)

---

### PASSWORDLESS SSH

To gain a secure and fast password-less access to your device via a SSH session, read the instructions from this *Patch Manager* patch:

* https://coderus.openrepos.net/pm2/project/sshd-publickey-login-only

The SSHd service can be configured from

* Settings:System --> System:Developer mode --> enable --> Remote Connection

Add these two lines at the end of your `.bashrc` or `.profile` for your laptop/`PC` user:

<code>
ufish() { ssh root@192.168.2.15 "$@"; }<br>
wfish() { ssh root@172.28.172.1 "$@"; }
</code>

The next time you start a console, you will be able to use `ufish` or `wfish` to connect to or execute commands via `SSH` on your `SFOS` device.

> :heavy_exclamation_mark: **TODO**
> 
> Make a script that does this job for the user

---

### SYSTEM UPDATE

After having activated the `SSH` service, especially if `SFOS` has been recently installed on your smartphone, execute these commands by root user:

`pkcon refresh && pkcon update`

Suggested package to install, by root user:

<code>
pkcon -y remove busybox-symlinks-vi<br>
pkcon -y install --allow-reinstall \<br>
    rpm pigz xz patch htop vim-minimal harbour-gpsinfo zypper \<br>
    zypper-aptitude mce-tools harbour-file-browser harbour-todolist \<br>
    sailfish-filemanager sailfish-filemanager-l10n-all-translations<br>
</code>

---

### USER BACKUP

The following script allows you to make the backup of every user's home folder by `USB` (`192.168.2.15`) or `WiFi` tethering (`172.28.172.1`):

<code>
#!/bin/bash<br>
user=defaultuser<br>
dst_ip=192.168.2.15<br>
tar_opts="--numeric-owner -p"<br>
date_time=$(date +%F-%H-%M-%S)<br>
excl_list=".cache cache cache2 vungle_cache diskcache-v4 .mozilla/storage"\<br>
" $user/Pictures/Default $user/Videos/Default $user/.ssh $user/.tmp"<br>
for i in $excl_list; do tar_opts="$tar_opts --exclude '$i/&ast;'"; done<br>
echo "Creating backup-${user}-${date_time}.tar.gz by SSH/cat..."<br>
ssh $user@$dst_ip "time tar vc $tar_opts ~$user/"\<br>
" | pigz -4Ric" > backup-${user}-${date_time}.tar.gz<br>
echo "Syncing backup-${user}-${date_time}.tar.gz to storage..."<br>
sync backup-${user}-${date_time}.tar.gz<br>
echo "Checking backup-${user}-${date_time}.tar.gz for errors..."<br>
tar tzf backup-${user}-${date_time}.tar.gz >/dev/null && echo "OK" || echo "KO"
</code>

The script above requires `pigz`, the much faster parallel version of `gzip`. Unless the **SYSTEM UPDATE** procedure has been completed, the `pigz` should be installed by the root user with this command:

`pkcon install -y pigz`

or the script  edited for working with the much slower `gzip`.

<sup>________</sup>

**backup restore**

Once a backup is created in this way, it can be restored with this other script:

<code>
#!/bin/bash<br>
user=defaultuser<br>
dst_ip=192.168.2.15<br>
last_backup=$(ls -r1 backup-${user}-&ast;.tar.gz | head -n1 )
</code>

or these lines instead when `pigz` is not yet available:

`cat $last_backup | ssh $user@$dst_ip "gzip -dRrc | tar xv -C /; sync"`

The script takes the last backup available in the current folder.

---

### DNS CACHING

For `DNS` caching and proxying, you can install the [DNS Alternative](https://openrepos.net/content/kan/dns-alternative) which is a package available on `Chum` market.

However, if this solution does not fit your needs, there is a second choice: using `dnsmasq` directly and configuring it specifically for your needs.

<sup>________</sup>

**dnsmasq**

For every beginner in SFOS, who is used to using a GNU/Linux distribution, the first step is to install `dnsmasq`. Unfortunately, the `RPM` package available is not working `AS-IS` and a patch should be applied to avoid it conflicts with `connman`.

About `dnsmasq` integration with `connman`, read this `Patch Manager` patch description ([here](https://coderus.openrepos.net/pm2/project/dnsmasq-connman-integration))

> [!WARN]
> 
> Despite the fact that `Patch Manager` is not the right tool for this kind of patch, the `dnsmasq` and `connman` `RPM`s should be fixed instead. This patch seems to be working reliably as long as the systemd services start-up order is not changed far from the factory default. Rarely, because this patch is not applied unless `Patch Manager` completes his job, sometimes the `connman` and `dnsmasq` services will start before their `.service` files have been patched, and therefore the system will not be able to resolve the domain names. Moreover, the network restart from `SailFish Utilities` cannot solve the issue (unless patched), and rebooting might not solve it but usually does unless `systemd` is far away from the factory configuration.

---

### SAFE & PRIVACY DNS

About `DNS`, using those from your network provider (default) is not always the best choice. There are some more interesting alternatives:

* [Cloudflare](https://www.cloudflare.com/learning/dns/what-is-1.1.1.1/) uses `1.1.1.1` and `1.0.0.1` for its DNS service over IPv4, and their name resolution services have some extra features for safety. It claims to be the fastest DNS in the world.

* [AdGuard](https://adguard-dns.io/en/public-dns.html) uses `94.140.14.14` and `94.140.15.15` and offers an {advertising, malicious, malware} host resolution name blocking feature plus family protections on `94.140.14.15` and `94.140.15.16` but they also offer an unfiltered service (check the link).

* [Quad9](https://www.quad9.net/) uses `9.9.9.9` and `149.112.112.112` to offer a service that is a combination of the two above in their claims (fast and safe).

The best choice is alternating two coherent DNS services together - for reliability - and using a caching system configured for leveraging a large DNS cache to gain speed, privacy, and safety, depending on the services you choose.

<code>
#IPv4 nameservers<br>
nameserver  9.9.9.9<br>
nameserver  94.140.14.14<br>
nameserver  149.112.112.112<br>
nameserver  94.140.15.15<br>

#IPv6 nameservers<br>
nameserver  2620:fe::fe<br>
nameserver  2a10:50c0::ad1:ff<br>
nameserver  2620:fe::9<br>
nameserver  2a10:50c0::ad2:ff<br>
</code>

This is an example of `/etc/resolv.conf` for every host connected with an `IPv4` + `IPv6` network that alternates *AdGuard* and *Quad9* ad-blocking and safe-filtered `DNS`.

> [!WARN]
> 
> Usually the `/etc/resolv.conf` is not the right place to insert these values.

---

### VPN USE

The `SailFish OS` supports many clients to establish a `VPN` tunnel for your traffic. The most known and used is related to the `OpenVPN` standard. When a client is involved, a server is needed on the other side, in this case a VPN service provider.

About `VPN` services, there is a very [interesting post on `F-Droid` blog](https://web.archive.org/web/20230628153815/https://f-droid.org/en/2023/03/08/vpn-trust-requires-free-software.html) which refers to also others articles and independent studies. The article deserve to be read but for those are in hurry, this topic can be briefly summarized with these three statements:

* [proton.me](https://proton.me/) - a suite of SaaS services tailored for privacy with headquarters and data centers in Switzerland. Allows free accounts but is limited and includes a `VPN` compatible with `OpenVPN` but `IPv4` only.

* [VPNs with full `IPv6` support in 2023](https://restoreprivacy.com/vpn/best/ipv6/) - an article that presents three `VPN` providers that support the `IPv6` but do not have a free trial plan, which means you have to pay with your credit card (privacy but not anonymity).

Therefore, the only viable way to go with ProtonVPN relying on an `IPv6`-only network operator is using [CLAT](https://forum.sailfishos.org/t/testing-clat-for-ipv6-only-mobile-networks/14520/1) which is still under testing.

<sup>________</sup>

**Why using a VPN?**

The original [article](https://f-droid.org/en/packages/ch.protonvpn.android/) about `VPN`s posted into `F-Droid` blog has been removed (404) but the Wayback Machine of [Archive.org](Archive.org) did a copy, and the last version is on 28th June 2023. Later, the page came back, but it has been changed. Among other parts, this one has been removed:

> :information_source: **Note**
> 
> ProtonVPN is created by the CERN scientists behind ProtonMail, the world's largest encrypted email service with 20 million users, including many **activists** and **journalists** such as **Reporters Without Borders**.

You might think that privacy and security are only concerns of criminals, but reading these kinds of claims, you might drop that bias. It is about everyone of us, especially those of us that are more exposed, for the sake of many.

Now, we can easily imagine why [Archive.org](Archive.org) is facing a nasty and expensive trial in the USA about copyright violations: *it is easier to control those who have a short-only memory*.

---

### COMPASS CALIBRATION

The compass calibration feature can be seen in `GPSinfo`’s change log since the v0.9.0-1 release in 2019. Using the last version from the `Chum` market, the compass will be calibrated automatically, doing some oo-loops. Therefore [OrienteeringCompass](https://openrepos.net/node/10468) is redundant for this aim, but it can be installed for its main purpose.

---

### GPS & MAPS

The MLS data packaged and delivered from Jolla market can be outdated. Therefore, use `MLS Manager` to download the country or geographic area of your interest (cfr. update #2).

From `F-Droid` market install:

* [UnifiedNlp (GAPPS), a location provider middleware](https://f-droid.org/packages/org.microg.nlp/)
* [MozillaNlpBackend, an UnifiedNlp location provider by Mozilla](https://f-droid.org/packages/org.microg.nlp.backend.ichnaea/)
* [LocalGsmNlpBackend, a UnifiedNlp location provider for local GSM database](https://f-droid.org/packages/org.fitchfamily.android.gsmlocation/)
* [Déjà Vu, a local RF based backend for the µg with Mobile/cell and WLAN/WiFi](https://f-droid.org/packages/org.fitchfamily.android.dejavu/)
* [NominatimNlpBackend, a UnifiedNlp geocoding provider MapQuest Nominatim](https://f-droid.org/packages/org.microg.nlp.backend.nominatim/)

Then open the `UnifiedNlp` app, do the self-check, configure, and activate all the services.

Then open the `microG Settings` app, and in the Location menu, switch on all the options.

Install the `GPSinfo` app from the `Chum` market because the one in the Jolla market can be outdated (cfr. update #1), switch on the `GPS` and test it outdoors.

<sup>________</sup>

**freezing issue**

For those the [GPS satellite fix freezes and crashes](https://forum.sailfishos.org/t/xperia-x-10-ii-gpu-heavily-affected-by-gps-fix-pure-maps-and-other-gps-related-apps/15797) with `Pure Maps` the native navigation app, they can try this Android app, instead:

* [Mapy.cz navigation & off maps](https://play.google.com/store/apps/details?id=cz.seznam.mapy&hl=en&gl=US) (4.2&starf;, 5M+)

or they can try [Here WeGo](https://wego.here.com) which is a web service coupled with its [Android app](https://play.google.com/store/apps/details?id=com.here.app.maps) (3.6&starf;, 10M+) available from the Jolla store. It can be updated or downloaded from the `UpToDown` store, too.

Or they can make the `A-GPS` working (cfr. update #3) like described below, which greatly mitigates the issue, at least on [Sony Xperia X10 II](https://developer.sony.com/posts/xperia-10-ii-added-to-sonys-open-devices-program/) but reasonably also on other Sony smartphones.

---

### A-GPS INDOOR

You may experience problems with `GPS` fixing indoors. The current solution is to adopt the `A-GPS` approach, which needs a mobile data connection, thus exchanging data that can undermine your privacy about your position.

* [x10ii-iii-agps-config-emea](https://coderus.openrepos.net/pm2/project/x10ii-iii-agps-config-emea) (check the instruction)

> [!WARN]
> 
> Install the patch to be notified about updates, but do not use the Patch Manager to apply the patch because it is not the right tool for this kind of patch. Instead, explode this tarball in the root filesystem:

*  [t.ly/ZJMA](https://t.ly/ZJMA) (or scan the QR-code in the screenshots)

> [!WARN]
> 
> The filesystem LVM overlay tricks too old versions of filesystem utils like cp and tar but possibly also prevent modem/GPS from being correctly configured. Check this bug report [here](https://t.ly/omO0) for more information.

This approach can also be attempted for other Xperia devices, like `XA2`.

The `A-GPS` configuration here proposed is Google-free, it uses Qualcomm `SUPL` hosts, and it offers some other advantages ([here](https://forum.sailfishos.org/t/gps-stopped-working/1181/699)) respect the [suplpatcher](https://gitlab.com/nekrondev/suplpatcher) approach. Moreover, it uses the `HTTPS` encrypted protocol for data transfer by default.

> [!NOTE]
> 
> **Suggestion** -- Uploading the certificate keys with suplpatcher and keeping the size of the new `gps.conf` identical with the old, removing comments, and adding spaces or hashes at the end will allow you to bypass the overlay filesystem problem with modem/GPS (if it exists) and probably also shrink the time for the cold start.

---

**THE FOLLOWING PART OF THIS SECTION IS OBSOLETE**

Even if obsolete, it will remain for a while in order to be reworked as - advanced users section - to introduce the `SSH` / terminal / `qCommand` as universal tools to customize in depth on a SFOS smartphone. In the meantime, jump to the next section, which is **mobile data**.

<sup>________</sup>

**manual editing or copy**

> **@miau** wrote: This solution works with the Xperia 10 smartphone series and might work with other smartphones, but not with the XA2 which requires it, and for the XA2 the parameters are slightly different as. Therefore, XA2 users should ignore the following and follow the suplpatcher instructions.

<sup>________</sup>

The solution consists of changing some values into `/etc/gps.conf` or in `/vendor/etc/gps.conf`. You can check the real path using the `File Manager` included by default in `SFOS`. If both exist, one should be a link to the other.

`NTP_SERVER`, list of options:

* `time.izatcloud.net` (default)
* `time.google.com` (current)
* `asia.pool.ntp.org`
* `europe.pool.ntp.org`
* `oceania.pool.ntp.org`
* `north-america.pool.ntp.org`
* `south-america.pool.ntp.org`

The `SUPL_HOST:PORT`, list of options:

* `supl.google.com:7276` (default)
* `supl.grapheneos.org:7275`

To make these changes can be used the [terminal app](https://openrepos.net/content/lourens/fingerterm-terminal-app) that appears in the app menu when **developer mode** is enabled. Or a `SSH` session created using the developer tools. In both cases, it necessary to activate the **developer mode** and provide to the `defaultuser` a password:

> Settings:System --> System:Developer tools --> Developer Mode --> Remote connection --> Password:Create

Another way to access the terminal is by using `qCommand` and asking him to run `devel-su /bin/ash` in interactive mode. In interactive mode, it will always ask for the password, even if you choose to run `/bin/ash` as `root` and you save the password.

<sup>________</sup>

**ssh session**

Activate the `SSH` session. This allows you to connect to your `SailFish OS` device with an `SSH` connection using the `USB` cable, the `WiFi` tethering, or the `WiFi` home network. The most secure way is to use the `USB` cable while the smartphone is off-line.

<code>
ssh defaultuser@192.168.2.15<br>
remote]$ devel-su /bin/sh<br>
Download]# update-ca-trust<br>
remote]# vi /etc/gps.conf<br>
remote]# exit<br>
remote]$ exit<br>
</code>

Before changing those values, prepare yourself to use [vi the editor](https://web.mit.edu/merolish/Public/vi-ref.pdf) and make a backup copy of the original file. Or you can install `nano` and use it instead of `vi`, as kindly suggested by @miau following these instructions:

`remote]$ devel-su pkcon install nano`

Alternatively, you can download and copy the `gps.conf` as described in the next session and decide to modify it with your own hands. Instead of downloading the file, apply the `Patch Manager` patch cited above and then perform the changes you like.

<sup>________</sup>

**terminal app**

Visit this link for the [modified gps.conf](https://drive.google.com/file/d/1ZCheJadDhO38atpIFmRKMjBA42XYnUJT/view) and save it in `Downloads`. Then open the terminal and execute the following commands:

<code>
home]$ cd android_storage/Download<br>
Download]$ devel-su /bin/sh<br>
Download]# update-ca-trust<br>
Download]# cp /vendor/etc/gps.conf gps.conf.bak<br>
Download]# cat gps.conf >/vendor/etc/gps.conf<br>
Download]# exit<br>
Download]$ exit<br>
</code>

<sup>________</sup>

**after the changes**

After the changes, **disable** the developer mode and set the high precision mode for the `GPS`:

* Settings:System --> Connectivity:Location --> High-accuracy positioning

At this point, you can switch on the network, the `GPS` and give it a try indoors.

---

### MOBILE DATA

The first step you should take after having inserted the `SIM` into your new `SFOS` smartphone is to ask your network operator to send their mobile data configuration back to your device. Usually, you can do that by sending a `SMS` to a specific number.

<sup>________</sup>

**registration lag**

You might experience a sensible registration lag or sometimes even a complete failure. Deactivate the mobile network auto selection mode in this way:

* Settings:System → Connectivity:Mobile network:SIM# → Select network automatically:off

This will bring you to a new page on which - after a while - all the mobile networks found will be visible, and just some will be available. For example - if you are an `iliad italia` customer with 4G enabled - you will find `IT 88` and `IT 50`. You will also find that with 4G, you might not be able to register with `IT 88` but `IT 50` only. Select this one, and then the next registration will take a reasonable amount of time, even if not immediate.

Another solution that might work in your case is the following. Imagine that you have the `SIM1` that is slow in registering with the mobile network. You can try putting the slower `SIM` into slot #2 which means `SIM` exchange (1:faster, 2: slower), or you can skip the unlock `PIN` for the faster `SIM` and activate it after the slower one has completed the registration with the mobile network. Keep the faster SIM for 2nd to register and possibly use the auto-search for the mobile network because in this way `ofono` will preferably keep the current operator schema as long as possible, even better if the faster SIM is roaming.

<sup>________</sup>

**data on IPv4 only**

You might decide to limit your mobile data to using the `IPv4`.

> [!WARN]
> 
> **Every IPv4-only VPN leaks data over IPv6**
> 
> This can be a good idea, especially if you are using a free `VPN` service that tunnels the data over `IPv4` but leaks those over `IPv6` .

To limit your mobile data over IPv4, proceed in this way:

* Settings:System → Connectivity:Mobile network:SIM# --> Data / MMS

The `Data` and `MMS` access points changed the protocol field from `dual` to `IP`.

> [!WARN]
> 
> **TODO** -- Include the Linux kernel settings to disable `IPv6` for the whole system, leveraging the `/usr/lib/sysctl.d` configuration folder. Working in progress: testing.

---

### POWER SAVING

Section yet to be done; in the meantime, check out these posts below:

* [Energy saving for Xperia 10 II and III](todo/energy-saving-for-xperia-10-ii-and-iii.md)

* [Power saving templates and policies](todo/energy-saving-for-xperia-10-ii-and-iii.md#power-saving-templates)

* [Bluetooth power drain issue](todo/bluetooth-crazy-CPU-usage.md)

Here are a few hints to keep your `SFOS` smartphone lasting longer.

<sup>________</sup>

**display settings**

First of all, set the brightness of the screen to the minimum in auto-brightness mode, then install and activate the [Pure Black Backgrounds ](https://coderus.openrepos.net/pm2/project/patch-i-see-a-red-door) patch with `Patch Manager`. This setting is expected to save energy with an `OLED` display, which is the case for the Xperia 10 II and III. The display should be set to sleep after 30 seconds.

<sup>________</sup>

**energy saving mode**

Set the energy saving mode at 100% of battery threshold to let it stay active. The energy consumption will drop from 12%/h to a 8%/h which is 33% less on average and therefore a 50% of battery will last. At the moment, is is necessary to use `mcetool` from the command line:

* `mcetool --set-psm-threshold=100 --set-power-saving-mode=enabled`

Moreover, that tool should be installed before using it. This requires access to the smartphone with root privileges. Please refer to the **A-GPS INDOOR : manual editing or copy** to learn how.

* `devel-su pkcon install mce-tools`

Because `mcetool`does not need `root` privileges to change the battery threshold for enabling the energy-saving mode, it is possible to use `qCommand` to execute it in a non-interactive, non-root, ignore-output task. The `qCommand` allows you to create an icon for this specific task⁴ and it is useful because the energy-saving mode can be changed or disabled by Settings:System --> System:Battery menu but not set to 100% back by it.

<sup>________</sup>

**wireless settings**

Disable the 4G connection, Bluetooth, and wireless as much as possible. In dual-sim phones, the 2nd SIM could be registered in 2G if that service is still available and largely deployed, unless you plan to use it also for mobile data.

---

### ZRAM SWAP SIZE CHANGE

This `Patch Manager` patch will help you resize the `zRAM` swap while the system is running:

* https://coderus.openrepos.net/pm2/project/zram-swap-resize-script

After the `PM2` patch application executes the script with

* `devel-su /bin/bash zram_swap_resize.sh 1536`

The default value is 1024, other reasonable values are 512 or 1536. For example, by passing 1536 the size of the `zRAM` swap will be increased to 1.5GB, as you can see:

<tt>
[root@sfos ~]# zramctl | tail -n1 | tr -s ' '; free<br>
/dev/zram0 lz4 1.5G 222.9M 53.2M 66.7M 8 [SWAP]<br>
              total        used        free      shared  buff/cache   available<br>
Mem:        3643472     1571548     1243824       19744      828100     2078652<br>
Swap:       1572860      230624     1342236<br>
</tt>

but considering that the compressed ratio is about 3x or 4x times, this means that for the `1536` value, we can have:

*  `3558 + (1536 × 2.5) = 7398`

The available `RAM`+swap will grow up to 7GB with an **important drawback**: running apps and system services will be able to use just 2GB and the rest will be useful only to keep sleeping apps alive. Instead, reducing the size to 512MB (previous `SFOS` configuration), the available `RAM` will be 3GB and the total `RAM`+swap will be near 5GB.

In my personal case, which includes the use of `Android Support`, the [statistics collected](https://coderus.openrepos.net/media/screenshots/zram-swap-resize-script-ram-and-swap-usage.png) by [System Monitor](https://openrepos.net/content/ade/system-monitor-fork) indicate that 1GB of `zRAM` swap is large value because its use rarely will go over 60% of its full capacity. Probably the best value for my use style is 768MB or even 512MB with a swappiness of 5% instead of 25% (default).

<sup>________</sup>

**swap offloading**

Since `v0.0.8`, the offload parameter has been introduced that enforces, as far as possible, the dump of the `zRAM` swap in order to free it:

1. close all your applications
2. stop the `Android Support`
3. call the script with `offload`

It might fail, but usually in less than one minute, it will move all your Android apps sleeping in the background to the `RAM` with a high chance of being terminated by `OOM`. After this action, your smartphone will perform with native apps, like after a reboot.

---

### BOOKMARKS

These are a few websites that are worth having in your native browser bookmarks:

* [startpage.com](https://startpage.com) - an European based web search engine focused on privacy. It can be set as the default web search, and it allows several themes, including the dark one, plus it offers a translation service just by searching for *translate*.

* [time.is](https://time.is) - to get in sync with a real-time clock. The default time zone depends on your `IP` geo-localisation or on your current outgoing `VPN` server, but you can choose any city in the world.

* [ipleak.net](https://ipleak.net) - a website that shows you what data your browser or connection leaks out. It is impressive and useful for testing your VPN tunneling.

* [italia.fm](https://italia.fm) - webradio website, but you can easily switch to the German, Spanish, and Belgian versions with the related radio stations online.

* [proton.me](https://proton.me) -  a suite of `SaaS` services tailored for privacy with the headquarters and data-center in Switzerland. It allows accounts with a free plan, which includes a  `VPN` compatible with `OpenVPN` but `IPv4`-only (cfr. the `VPN` section).

* [paste.systemli.org](https://paste.systemli.org) - is a minimalist, open source online *pastebin* where the server has *zero knowledge* of pasted data. Data is en/decrypted in the browser using the 256 bits `AES` key.

* [privatebin.deblan.org](https://privatebin.deblan.org/) - the same as the one above but hosted by the Debian project.

* [webssh.de](https://webssh.de/) - is a minimal SSH web client by Robert Krause

* [qr.io](https://qr.io) - creates `QR` codes from text for many applications, in particular is useful to quickly transfer a link/clip text from your laptop to your smartphone using the `QR` code reader integrated into the default camera `SFOS` native app.

Feel free to propose your best choices or alternatives. As far as possible, I will update this list, which is a mere suggestion based on an evaluation done at the time of writing (2023.06.16) and could become outdated.

---

### USB MODES

This section is working in progress. Be patient. :blush:

<code>
pkcon install -y usb-moded-host-mode-jolla usb-moded-systemd-rescue-mode \<br>
    usb-moded-connection-sharing-android-config
</code>

or

`                  usb-moded-connection-sharing-android-connman-config`

---

### DEVELOPER MODE + USB TETHERING

Just in case you are annoyed to have too many `USB` modes to choose from and you wish not to install one of these with `pkcon`:

* `usb-moded-connection-sharing-android-connman-config`
* `usb-moded-connection-sharing-android-config`

then you can use the *developer mode* as `USB` tethering following sending this command to your smartphone, and here below the link is a `Patch Manager` patch that installs a shell script:

* https://coderus.openrepos.net/pm2/project/set-network-postroute

Follow the instructions on the description of the link above. Before that, take this notice into consideration:

> [!WARN]
> 
> Therefore, this patch is for expert users and developers. Until this feature is added to `SFOS` and managed by `connman`, it will be easier to install one of the packages listed above. Unless, you live in *developer mode* and you are acknowledged for how easy it is to crack `WiFi` passwords.

> [!WARN]
> 
> Check with `iptables -t nat -S` or `iptables -nvL -t nat` if the added iptables rules persist after a reboot and in the case, if they keep their position in the `NAT`ting.

---

### TIPS & HINTS

* the phone calls with wired headphones have an audio volume that is too high, even when it is at its minimum. Using a good Bluetooth earbud pair will solve the problem and free you from the wire.

* Sometimes when the data interface changes (e.g. switching from `4G` to `WiFi` or vice versa) or changes its state (airplane mode off), the network stack needs to be reset with the specific button in Settings:System --> Info:Utilities. However, after the smartphone reboot or after switching off the airplane mode, the SIM takes a very long time to register with the `4G` network, so it is time to follow the instructions in the **fixing the 4G registration** section.

* Unlocking the smartphone with your fingerprint is a great choice, especially for X10 II because the fingerprint reader is installed on the on/off button and is immediate to use but not totally reliable. In fact, sometimes the lockscreen suggests to *clean the fingerprint reader*. Instead, you will probably need to reset the fingerprint software stack with the specific button in Settings:System --> Info:Utilities

* Downloading and installing `APK`s from untrusted sources can seriously harm your privacy and security. In the best case, you will miss important future updates. Moreover, by default, this practice is not allowed unless you enable the option of *Allow to install from untrusted sources* but do not do that after this device post-installation customization.

* it is suggested to restore the `/bin/bash` symlink to the real `bash` shell by executing `devel-su pkcon remove busybox-symlinks-bash`. This may influence the whole system, but you can revert back to the system by reinstalling that package using `install` instead of `remove`: easy to do and easy to undo.

In conclusion, add to the top menu these two voices:

* Settings:System --> Info:Utilities
* Settings:System --> Info:Android support

because these shortcuts will be very useful, and you will use them often.

---

### LIST OF TASKS TO DO

This list of suggested changes is for those Sailors hackers or Jolla that wish to improve `SFOS` and has been moved here:

* [A collection of tasks to do and a request of changes](tasks-and-changes-todo.md)

Please take a look at that list and feel free to indicate the three that are the **most** important for you, or `SFOS` and the three that are the **least** important. To the 3+3 indications, add for each one a **brief** explanation about why, just to support your preference.

---

**NOTES**

- 1. it looks like the `Documents` app requires too many privileges: avoid it.
- 2. it requires a [Google account](https://www.google.com/account/about/) because the anonymous access is unreliable.
- 3. the patch should be applied later, using the `Patch Manager`.
- 4. such iconed task will not return immediately, but this is a harmless bug in `qCommand`.

+

## Share alike

&copy; 2023, **Roberto A. Foglietta** &lt;roberto.foglietta<span>@</span>gmail.com&gt;, [CC BY-NC-SA 4.0 license](https://creativecommons.org/licenses/by-nc-sa/4.0/).

</div>
