;; my work notebook
(use-modules (gnu)
	     (gnu system)
             (gnu system linux-initrd)
             (guix gexp)
	     (guix store)
             (srfi srfi-1))

(use-package-modules
 admin
 autotools
 avahi
 base
 bash
 bootloaders
 certs
 code
 commencement
 connman
 cryptsetup
 curl
 display-managers
 emacs
 enlightenment
 gdb
 glib
 gnome
 gnuzilla
 linux
 linux-vanilla
 mail
 mc
 patchutils
 ssh
 suckless
 synergy
 texinfo
 tls
 version-control
 video
 vpn
 web-browsers
 wget
 wm
 xfce
 xorg)

(use-service-modules
 avahi
 base
 desktop
 networking
 ssh
 xorg)


(operating-system
 (host-name "vulture")
 (timezone "Europe/Prague")
 (locale "cs_CZ.utf8")
;; prepare configuration but don't install bootloader
 (bootloader
  (bootloader-configuration
   (bootloader
    (bootloader
     (inherit grub-bootloader) (installer #~(const #t))))))
;; root filesystem
 (file-systems (append (list (file-system
                              (title 'device)
                              (device "/dev/sda3")
                              (mount-point "/")
                              (type "ext4")
                              (needed-for-boot? #t)))
                       %base-file-systems))
 (swap-devices '("/dev/sda2"))
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
    ;;;; absolutely necessary ;;;;;
    emacs lvm2 bash texinfo
    grub nss-mdns procps cryptsetup alsa-utils

    ;;;; networking ;;;;
    iw iproute links wpa-supplicant dbus
    ;; connman
    vpnc openconnect openssl ;; for config in /etc

    ;;;;; other ;;;;;
    slock ;; required here because of setuid bit
    xrandr ;; for monitor udev rule hook
    wget curl ;; default web access from scripts or command line
    i3-wm ;; if not system-wide, can't be use for login session
    htop mc ncdu ;; basic system tools
    )
   %base-packages))
 (services (cons* (gnome-desktop-service)
                  (xfce-desktop-service)
                  ;; Using 'canonical-package' as bash and coreutils
                  ;; canonical packages are already a part of
                  ;; '%base-packages'.
                  (service special-files-service-type
                           `(("/bin/sh"
                              ,(file-append (canonical-package
                                             (guix-package bash bash))
                                            "/bin/bash"))
                             ("/bin/bash"
                              ,(file-append (canonical-package
                                             (guix-package bash bash))
                                            "/bin/bash"))
                             ("/usr/bin/env"
                              ,(file-append (canonical-package
                                             (guix-package base coreutils))
                                            "/bin/env"))))
                  %desktop-services))
 (name-service-switch %mdns-host-lookup-nss)
 (kernel linux-vulture)
 (initrd-modules '()))
