#!/bin/bash
# cfdisk
# mkfs.ext4 /dev/sda3
# mount /dev/sda3 /mnt
# mkdir usb && mount -t vfat /dev/sdb1 usb
# ./usb/archlinux/arch.sh setup
function setup(){
	# 本地源
	sed -i '/^\[core\]/{s@^@#@;n;s@^@#@}' /etc/pacman.conf
	sed -i '/^\[extra\]/{s@^@#@;n;s@^@#@}' /etc/pacman.conf
	sed -i '/^\[community\]/{s@^@#@;n;s@^@#@}' /etc/pacman.conf
	sed -i "/^#\[custom\]/{s@^#@@;n;s@^#@@;n;s@^.*@Server = file://$usbdir/pkg@}" /etc/pacman.conf
	# 选择安装镜像
	cat <<-end-of-mirrorlist > /etc/pacman.d/mirrorlist
	Server = http://mirrors.163.com/archlinux/\$repo/os/\$arch
	Server = http://mirrors.aliyun.com/archlinux/\$repo/os/\$arch
	Server = http://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch
	end-of-mirrorlist
	# 安装基本系统
	pacstrap /mnt base base-devel grub-bios $pkg 8192cu-dkms ttf-dejavusansmono-powerline-git xcursor-pulse-glass
	# 生成 fstab
	#genfstab -U -p /mnt >> /mnt/etc/fstab
	cat <<-end-of-fstab >> /mnt/etc/fstab
	/dev/sda3 /          ext4    rw,relatime,data=ordered                   0 0
	/dev/sda1 /mnt/win/C ntfs-3g defaults,noatime,nofail,locale=zh_CN.UTF-8 0 0
	/dev/sda5 /mnt/win/D ntfs-3g defaults,noatime,nofail,locale=zh_CN.UTF-8 0 0
	/dev/sda6 /mnt/win/E ntfs-3g defaults,noatime,nofail,locale=zh_CN.UTF-8 0 0
	end-of-fstab
	# Chroot 并开始配置新系统
	arch-chroot /mnt /bin/bash <<-end-of-chroot
	# Locale
	sed -i '/^#en_US\.UTF-8 UTF-8/{s@^#@@}' /etc/locale.gen
	sed -i '/^#zh_CN\.UTF-8 UTF-8/{s@^#@@}' /etc/locale.gen
	sed -i '/^#zh_TW\.UTF-8 UTF-8/{s@^#@@}' /etc/locale.gen
	locale-gen
	echo LANG=en_US.UTF-8 > /etc/locale.conf
	# 时区
	ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
	# 硬件时间
	hwclock --systohc --utc
	# Hostname
	echo arch > /etc/hostname
	# 创建初始 ramdisk 环境
	mkinitcpio -p linux
	# 设置 Root 密码
	(echo "123456";sleep 1;echo "123456") | passwd
	# 安装并配置 bootloader
	grub-install --target=i386-pc --recheck /dev/sda
	#grub-mkconfig -o /boot/grub/grub.cfg
	# 添加用户
	useradd -m -G wheel -s /usr/bin/zsh year
	(echo "123456";sleep 1;echo "123456") | passwd year
	sed -i '/^# %wheel ALL=(ALL) NOPASSWD: ALL/{s@^#@@}' /etc/sudoers
	# 启动服务
	systemctl enable lightdm.service netctl-auto@enp0s29f7u1.service
	# SSH
	ssh-keygen -t rsa -C "yearharvest@163.com"
	end-of-chroot
	# 配置文件
	cp -rf $usbdir/archlinux/grub/. /mnt/boot/grub
	cp -rf $usbdir/archlinux/netctl/. /mnt/etc/netctl
	cp -rf $usbdir/archlinux/lightdm/. /mnt/etc/lightdm
	cp -rf $usbdir/archlinux/dotfile/. /mnt/home/year
	arch-chroot /mnt chown -R year /home/year
}
function repo(){
	rm -rf ~/newsys ~/pkg $usbdir/pkg
	mkdir -p ~/newsys/var/lib/pacman ~/pkg
	pacman --root ~/newsys --cachedir ~/pkg --noconfirm -Syyw base base-devel grub-bios $pkg
	rename : _ ~/pkg/*.pkg.tar.xz
	cp -rf ~/pkg $usbdir
	cp -rf $usbdir/*.pkg.tar.xz $usbdir/pkg
	cd $usbdir/pkg
	repo-add custom.db.tar.gz *.pkg.tar.xz
}
usbdir=$(df -h /dev/sdb1 | grep -v 'Mounted\|挂载点' | awk '{print $6}')
pkg="xorg-utils xorg-server xorg-server-utils xf86-video-intel mesa alsa-utils xf86-input-synaptics wpa_supplicant wpa_actiond ntfs-3g dkms linux-headers \
     zsh lightdm lightdm-gtk3-greeter fvwm habak scrot wqy-microhei ttf-dejavu xterm tmux fcitx-im pcmanfm gvfs xarchiver p7zip unrar unzip tint2 volumeicon conky lxappearance faenza-icon-theme \
     abs git openssh emacs mplayer firefox firefox-i18n-zh-cn flashplugin wiznote"
pkg_aur="packer 8192cu-dkms ttf-dejavusansmono-powerline-git xcursor-pulse-glass stark-gtk-git xnviewmp"
[[ "setup,repo" =~ $1 ]] && $1 || echo "Parameter error"
