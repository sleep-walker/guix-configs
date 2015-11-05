(use-modules (gnu)
	     (gnu system)
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
		 (label "openSUSE")
		 (linux "/vmlinuz")
		 (linux-arguments (list
				   "root=/dev/venom/opensuse"
				   "init=/usr/lib/systemd/systemd"))
		 (initrd "/initrd")
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
			      (type "ext4")
			      (needed-for-boot? #t))
			     (file-system
			      (device "/dev/venom/home")
			      (mount-point "/home")
			      (type "ext4")
      			      (needed-for-boot? #t))
			     (file-system
			      (device "/dev/venom/devel")
			      (mount-point "/Devel")
			      (type "ext4")
			      (needed-for-boot? #t))
			     (file-system
			      (device "/dev/venom/opensuse")
			      (mount-point "/opensuse")
			      (type "ext4")
			      (needed-for-boot? #t))
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
    ;; slim xrandr xterm my-dwm slock
    
    ;; mail
    mutt mu gnutls isync

    ;; web
    ;; icecat
    wget curl
    
    ;; enlightenment
    ;; terminology enlightenment

    ;; xfce
    ;; xfce

    ;; other X stuff
    ;; synergy
    ;; multimedia
    ;; mplayer mplayer2 vlc
    ;; mpv

    ;; development
    git magit subversion cvs rcs quilt patchutils patch gcc-toolchain-4.9 gnu-make
    automake autoconf gdb
    strace ltrace
    the-silver-searcher
    global

    ;; console
    htop mc
    ;; not packaged yet
    ;; cmus cscope ctags
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
