;; my work notebook
(use-modules (gnu)
             (gnu packages base) ;; for canonical-package
	     (gnu system)
             (gnu system linux-initrd)
             (guix gexp)
	     (guix store)
             (srfi srfi-1))

(use-package-modules
 admin
 autotools
 avahi
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
 guile-xyz
 linux
 linux-vanilla
 mail
 mc
 ncdu
 nfs
 patchutils
 pulseaudio
 shells
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
 xorg
 xorg
)

(use-service-modules
 avahi
 base
 desktop
 mcron
 networking
 ssh
 xorg
)


(define monitorplug-udev-rules
  (file->udev-rule
   "98-monitor-hotplug.rules"
   (local-file "./doom-monitor-hotplug.rules")))

(define personal-mail-sync-job
  #~(job "*/5 * * * *" "/home/tcech/bin/stahni_postu.sh"
         #:user "tcech"))

;; for special-files-service-type
(define-syntax module-package
  (syntax-rules ()
    ((_ module (package output))
     (list (@ module package) output))
    ((_ module package)
     (@ module package))))

(define-syntax-rule (guix-package module-part package)
  "Return PACKAGE from (gnu packages MODULE-PART) module."
  (module-package (gnu packages module-part) package))

(operating-system
 (host-name "doom")
 (timezone "Europe/Prague")
 (locale "cs_CZ.UTF-8")
;; prepare configuration but don't install bootloader
 (bootloader
  (bootloader-configuration
   (bootloader
    (bootloader
     (inherit grub-bootloader) (installer #~(const #t))))))
;; luks root mapping
 (mapped-devices
  (list (mapped-device
         (source (uuid "627480b1-0aaa-4711-a922-162b91798360"))
         (target "cr_guix")
         (type luks-device-mapping))))
;; root filesystem
 (file-systems (append (list (file-system
;;                              (title 'device)
                              (device "/dev/mapper/cr_guix")
                              (mount-point "/")
                              (type "ext4")
                              (dependencies mapped-devices)
                              (needed-for-boot? #t)))
                       %base-file-systems))
 (swap-devices '("/dev/nvme0n1p2"))
 (users (cons (user-account
               (name "tcech")
	       (uid 1000) (group "users")
               (supplementary-groups '("lp" "wheel" "netdev"
                                       "audio" "video"))
	       (comment "Tomáš Čech")
	       (password "password")
               (shell (file-append zsh "/bin/zsh"))
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
    iptables links wpa-supplicant dbus
    ;; connman
    vpnc openconnect openssl ;; for config in /etc
    network-manager network-manager-openvpn openvpn
    zsh ;; better shell as login shell
    ;;;;; other ;;;;;
    nfs-utils btrfs-progs ;; programs required by filesystems
    slock ;; required here because of setuid bit
    xrandr ;; for monitor udev rule hook
    wget curl ;; default web access from scripts or command line
    i3-wm ;; if not system-wide, can't be use for login session
    htop mc ncdu ;; basic system tools

    pulseaudio
    bluez
    )
   %base-packages))
 (services
  (cons* (gnome-desktop-service)
         (xfce-desktop-service)
         (bluetooth-service)
         (service mcron-service-type
                  (mcron-configuration (mcron mcron) (jobs (list personal-mail-sync-job))))
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
         (modify-services %desktop-services
                          (elogind-service-type config =>
                                                (elogind-configuration
                                                 (handle-lid-switch 'ignore)
                                                 (lid-switch-ignore-inhibited? #f)))
                          (udev-service-type config =>
                                             (udev-configuration
                                              (inherit config)
                                              (rules (cons*
                                                      monitorplug-udev-rules (udev-configuration-rules config))))))))
 
 (sudoers-file
  (plain-file "sudoers"
              "root ALL=(ALL) ALL
%wheel ALL=(ALL) ALL
tcech ALL = NOPASSWD: /usr/local/bin/local_suspend.sh
tcech ALL = NOPASSWD: /usr/local/bin/brightness.sh
"))

 (name-service-switch %mdns-host-lookup-nss)
 (kernel linux-doom)
 (initrd-modules '()))
