(use-modules (gnu)
	     (guix store))
(use-package-modules
 ;; my private packages
 my-own linux-vanilla
 ;; generic guix packages modules
 admin autotools avahi base bash commencement cryptsetup connman curl
 emacs enlightenment gdb glib gnutls gnuzilla grub links linux lsh mail
 mc patchutils slim synergy texinfo version-control video wget wicd
 xfce xorg dwm avahi ssh xorg vpn openssl)
(use-service-modules
 avahi base dbus networking ssh xorg)

(operating-system
 (host-name "venom")
 (timezone "Europe/Prague")
 (locale "cs_CZ.utf8")
 (bootloader (grub-configuration
	      (device "/dev/sda")
	      (menu-entries
	       (list
		(menu-entry
		 (label "Gentoo")
		 (linux "/vmlinuz-gentoo")
		 (linux-arguments (list
				   "root=/dev/venom/gentoo"
				   "init=/usr/lib/systemd/systemd"))
		 (initrd "/initramfs-gentoo")
		 )))))
;; (logical-volume-groups "venom")
 (mapped-devices
  (list
   (mapped-device
    (source "")
    (target "venom")
    (type lvm-mapping))))
 
 (file-systems (append (list (file-system
			      (device "/dev/sda3") ; or partition label
			      (mount-point "/")
			      (type "ext4"))
			     (file-system
			      (device "/dev/venom/home")
			      (mount-point "/home")
			      (type "ext4"))
			     )
		     %base-file-systems))
 (swap-devices '("/dev/sda2"))
 (users (list (user-account
	       (name "tcech")
	       (uid 1000) (group "users")
	       (comment "Tomas Cech")
	       (password "password")
	       (home-directory "/home/tcech"))))
 (packages
  (append
   (list
    ;; absolutely necessary
    emacs lvm2 bash texinfo
    grub nss-mdns procps cryptsetup alsa-utils
    
    ;; networking
    iw iproute wicd links wpa-supplicant dbus connman
    vpnc openconnect openssl lsh
    
    ;; minimal Xorg
    slim xrandr xterm my-dwm slock
    
    ;; mail
    mutt mu gnutls

    ;; web
    icecat wget curl
    
    ;; enlightenment
    terminology enlightenment

    ;; xfce
    xfce

    ;; other X stuff
    synergy
    ;; multimedia
    mplayer mplayer2 vlc
    ;; mpv
    ;; development
    git magit subversion cvs rcs quilt patchutils patch gcc-toolchain-4.9 gnu-make
    automake autoconf gdb
    strace ltrace

    ;; console
    htop mc
    ;; not packaged yet
    ;; isync cmus cscope ctags the-silver-searcher
    )
   %base-packages))
 (services
  (append
   (list
    (lsh-service #:port-number 22 #:root-login? #t #:initialize? #t)
    (slim-service #:default-user "tcech" #:auto-login? #t)
    (wicd-service)
    (dbus-service (list wpa-supplicant wicd connman))
    (mingetty-service "ttyS0"
		      #:motd (text-file "motd" "
This is the GNU operating system, welcome!\n\n")))
   %base-services))
 (kernel linux-vanilla)
 )


