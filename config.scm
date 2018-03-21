(use-modules (gnu)
	     (gnu system)
             (gnu system linux-initrd)
	     (guix store))

(use-package-modules
 ;; my private packages
 ;;my-own
 wm
 linux-vanilla
 bootloaders
 ;; generic guix packages modules
 certs
 admin autotools avahi base bash code commencement cryptsetup connman
 curl emacs enlightenment gdb glib tls gnuzilla gnome
 ;;grub
 ;;links
 web-browsers
 linux ssh
 mail mc patchutils
 display-managers
 synergy texinfo version-control video wget
 xfce xorg suckless avahi xorg vpn)
(use-service-modules
 avahi base networking ssh xorg desktop)


(operating-system
 (host-name "doom")
 (timezone "Europe/Prague")
 (locale "cs_CZ.utf8")
;; prepare configuration but don't install bootloader
 (bootloader
  (bootloader-configuration
   (bootloader
    (bootloader
     (inherit grub-bootloader) (installer #~(const #t))))))
  (mapped-devices
   (list (mapped-device
          (source (uuid "0455fc07-8df6-4752-aa9b-70a04c573568"))
          (target "guix-root")
          (type luks-device-mapping))))

  (file-systems (append (list (file-system
                               (title 'device)
                               (device "/dev/mapper/guix-root")
                               (mount-point "/")
                               (type "ext4")
                               (dependencies mapped-devices)
                               (needed-for-boot? #t)))
		     %base-file-systems))
;; (swap-devices '("/dev/sda2"))
 (users (cons (user-account
	       (name "tcech")
	       (uid 1000) (group "users")
               (supplementary-groups '("wheel" "netdev"
                                       "audio" "video"))
	       (comment "Tomáš Čech")
	       (password "password")
	       (home-directory "/home/tcech"))
              %base-user-accounts))

 (packages
  (append
   (list
    nss-certs
    ;; absolutely necessary
    emacs lvm2 bash texinfo
    grub nss-mdns procps cryptsetup alsa-utils

    ;; networking
    iw iproute links wpa-supplicant dbus
    ;;connman
    vpnc openconnect openssl
    ;;lsh

    ;; minimal Xorg
    ;; slim xrandr xterm my-dwm slock

    ;; mail
    ;; mutt mu gnutls isync

    ;; web
    ;; icecat
    wget curl

    ;; enlightenment
    ;; terminology enlightenment

    ;; xfce
    ;; xfce

    ;; if not system-wide, can't be use for login session
    i3-wm
    ;; other X stuff
    ;; synergy
    ;; multimedia
    ;; mplayer mplayer2 vlc
    ;; mpv

    ;; development
    ;; git magit subversion cvs rcs patchutils
    ;; gcc-toolchain-4.9 gnu-make
    ;; automake autoconf gdb
    ;; strace ltrace
    ;; the-silver-searcher
    ;; global
    ;; console
    htop mc
    ;; not packaged yet
    ;; cmus cscope ctags
    )
   %base-packages))
 (services (cons* (gnome-desktop-service)
                  (xfce-desktop-service)
                  %desktop-services))
 (name-service-switch %mdns-host-lookup-nss)
 (kernel linux-x1-sw1)
 (initrd-modules '()))
