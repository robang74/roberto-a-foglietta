<div id="firstdiv" created="2025-03-01:EN" style="max-width: 800px; margin: auto; white-space: pre-wrap; text-align: justify;">
<style>#printlink { display: inline; } @page { size: legal; margin: 0.50in 13.88mm 0.50in 13.88mm; zoom: 100%; } @media print { html { zoom: 100%; } }</style>

<div align="center"><img class="bwsketch" src="img/305-thinkpad-x390-thunderbolt-netac-usbstick-img-001.png" width="800"><br></div>

## ThinkPad X390 BIOS USB-C full bandwidth

Published initially on LinkedIn and on [Facebook](https://www.facebook.com/plugins/post.php?href=https%3A%2F%2Fwww.facebook.com%2Froberto.a.foglietta%2Fposts%2Fpfbid0e8pbVkLx9L9XbmX1VCoFqRM1M5JTEVv4WufrHFQQPnX8d49had1FxQSyQ3qc3Posl) on 1st March 2025, then updated and collected here.

---

I have noticed a drastic drop in performance on my X390 USB-C Thunderbolt port when I have enabled that system in full and in particular the option which is marked with a green circle. I do not want to convince anyone that disabling that option can 2x increase the performance on that port. Just give it a try, and judge by yourself on Ubuntu 22.04 with 6.08 kernel and Netac US9 512GB as USB 3.2 drive.

This is the Grok3 explanation about my experience and it is totally coherent with what I have seen on my own and in my case. Which confirms my feeling that it is better keep the Thunderbolt disabled as long as it is not used (changing that settings requires 15s for the BIOS and a reboot).

[!INFO]

#### Why It Affects USB Performance

Your Netac US9 is a USB 3.2 drive (likely Gen 2, 10 Gbps), not a Thunderbolt device, but it’s using the X390’s USB-C Thunderbolt 3 port. Here’s how enabling pre-boot Thunderbolt activation could throttle it.

#### Prioritization of Thunderbolt Protocol

When enabled, the BIOS might configure the Thunderbolt controller to assume a Thunderbolt device is attached, prioritizing PCIe tunneling or Thunderbolt signaling over USB SuperSpeed. USB-C ports multiplex USB and Thunderbolt over the same pins/lanes. If Thunderbolt gets precedence, the USB SuperSpeed pairs (SSRX/SSRX+ and SSTX/SSTX+) might not negotiate at their full potential, capping the port at USB 3.0 (5 Gbps) instead of USB 3.2 Gen 2 (10 Gbps).

####  Lane Misconfiguration

Thunderbolt 3 uses up to 4 PCIe lanes, dynamically allocated with USB and DisplayPort. Pre-boot activation might reserve or misalign these lanes, leaving fewer or slower paths for USB data. Your 300-500 MB/s matches USB 3.0’s real-world limit (400-500 MB/s with overhead), suggesting it’s stuck at 5 Gbps instead of 10 Gbps (800-1000 MB/s in real-world).

####  Latency or Overhead

Enabling pre-boot Thunderbolt could introduce controller polling or initialization delays, adding latency to USB transfers. This might not drop the theoretical speed but could reduce effective throughput, especially on a non-Thunderbolt device like your Netac.

####  Negotiation Downgrade:

The kernel (xhci_hcd) relies on the hardware’s initial state. If the BIOS hands over a port pre-configured for Thunderbolt, USB 3.2 negotiation might fail or downgrade to USB 3.0 (Gen 1), as seen in your ~300-500 MB/s range.

[/INFO]

---

### Thunderbolt firmware upgrade

After Ubuntu proposed to me the Thunderbolt firmware upgrade 20.00 --> 23.00, and I accepted it, I did not manage to go above 560Mb/s while - before the upgrade - I hit the 900MB/s and a little above. Check in the comments the screenshot about the firmware upgrade.

While moving on lowlatency kernel, the system did something better but still did not see the top v20.00 Thunderbolt Firmware performance.

- `268435456 bytes (268 MB, 256 MiB) copied, 0.314098 s, 855 MB/s`

Plus adding this into Linux kernel command line:

- `usbcore.autosuspend=-1`

which is fine in AC mode but it would be better to have "1" on battery to save power, the max speed achieved is near the nominal value of the usbkey:

- `268435456 bytes (268 MB, 256 MiB) copied, 0.279603 s, 960 MB/s`

Which is not bad at all, but it requires a deeper investigation. Therefore, here below a bash script to check the average data transfer speed.

[!CODE]
&num; variables
f=/tmp/usbkey.tst
d=/dev/sda
n=10
&nbsp;
&num; test 10 or 100 tries
umount $d&ast; 2>/dev/null; for i in $(seq $n); do
dd if=$d bs=1M count=256 skip=$[RANDOM%256] of=/dev/null 2>&1 |\
 &nbsp; grep bytes; done | tee $f
&nbsp;
&num; maths
str=$(cat $f | cut -d, -f4 | sort -n)
min=$(echo "$str" | head -n1); max=$(echo "$str" | tail -n1)
let sum=$(sed -ne "s/.&ast; s, \([0-9]&ast;\) .&ast;/\\1+/p" $f | tr -d '\n')0
if [ $sum -eq 0 ]; then
let sum=$(sed -ne "s/.&ast; s, \([0-9.,]&ast;\) .&ast;/\\1+/p" $f | tr -d '\n',.)0
let n*=10; fi; avg=$[sum/n].$[sum%n]
&nbsp;
&num; results
printf "\n min:%s, avg: %s MB/s, max:%s \n\n" "$min" $avg "$max"
[/CODE]

#### Results print out & comments

Because the direct access to the device is not cached

- `min: 194 MB/s, avg: 838.45 MB/s, max: 960 MB/s` with `usbcore.autosuspend=-1`
- `min: 407 MB/s, avg: 856.91 MB/s, max: 963 MB/s` with `intel_iommu=on iommu=pt`

the average data transfer speed is looking quite impressive!

Anyway, here we are testing the USB data speed transfer.

The use of a real USB stick like Netac US9 is just for bragging... {:-D}

---

### ThinkPad X390 tweaks

All the changes presented here requires the `root` permission.

#### 1. snpd warning in dmesg

In case you Linux kernel `dmeg` log reports a problem with `snapd` configuration you can apply this change:

[!CODE]
&num; with systemd v254+, skip going through failed state during restart
&num;RestartMode=direct
&num;Restart=always
Restart=on-failure
RestartSec=5s
[/CODE]


#### 2. i915 granted in initramfs

This is optional and might create troubles, apply only if necessary:

[!CODE]
echo "
drm_kms_helper
drm_fb_helper
i915" >> /etc/initramfs-tools/modules
echo blacklist elan_i2c >> /etc/modprobe.d/blacklist.conf
echo blacklist thunderbolt >> /etc/modprobe.d/blacklist.conf
update-initramfs -u # -k all # only after giving a test
[/CODE]

Having a 2nd kernel for testing and boot the system when the 1st fails, it is a good habit.

#### 3. non-US keyboard mapping

[!CODE]
kbd.map=it # choose your keyboard layout
update-grub
[/CODE]

#### 4. avoid logo shown at boot

[!CODE]
bgrt_disable=1
update-grub
[/CODE]

+++++

## An useful USB-C hub

Ask me why I am so happy with little gadget...

|x|>
<img src="img/305-thinkpad-x390-thunderbolt-netac-usbstick-img-002.jpg" width="400">
+
<sup>right click menu to (2x) enlarge the image</sup>
<|x|

I will tell you what I do not like about it - the HDMI - is a duplication for my Thinkpad X390 or X280 and I wish I had found the version with a USB-C port, instead. Cheaper and more useful for me. However, I understand that a lot of people out there that have not yet joined the Cult (of having a Thinkpad as their laptop) desperately need a HDMI port and this adapter provides it to them.

The 2x USB 3.0 ports are valuable but they seem to work at 5 Gbits each. If they can sustain that speed simultaneously, then it starts to be reasonable.

- `min: 276 MB/s, avg: 424.29 MB/s, max: 445 MB/s`

Again, for most people this is enough. For those who have an X390 or X280 this little guy can charge the laptop while functioning as a hub therefore a USB 3.2 at 10Gbits became available. Moreover, few devices can really fully leverage 10Gbits data transfer.

Having a SD and MMC reader, especially because both are functional at the same time, is something nice to have. Especially for those who are still using dedicated digital photo cameras. I paid €4.99 for such a reader, alone. So the two main reasons I bought this USB hub is because:

1. it uses the PD 3.0 10Gbits UBS-C port for powering the laptop, leaving the other one free;
2. it provides a Ethernet 1Gbits RJ45 and 2x USB 3.0 5Gbits ports, a SD/MMC cards reader.

And it is a real gigabits network which are another five bucks but takes away a USB port:

- `dd if=/dev/zero bs=1500 count=16M | nc -N 10.10.10.2 1111`
- `25165824000 bytes (25 GB, 23 GiB) copied, 213.972 s, 118 MB/s`

Please, keep in consideration that Ubuntu 22.04 on the Esprimo P910 is running with a whole CPU core dedicated to the kernel and IRQ management while the X390 is using a low-latency kernel and both are leveraging Intel IOMMU passthrough.

Last but not least, it costs €8.15 on Temu and it is sent within Europe using the Amazon 2-days delivery service (islands, apart) at the extra price of €2.99.

+

## Share alike

&copy; 2025, **Roberto A. Foglietta** &lt;roberto.foglietta<span>@</span>gmail.com&gt;, [CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/)

</div>

