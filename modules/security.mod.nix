# Kernel and OS hardening adapted from RGBCube's ncc
# from https://github.com/RGBCube/ncc/tree/dentride
# Copyright (c) 2023-present RGBCube, MIT licensed
#
# Credits:
# - https://github.com/NotAShelf/nyx/blob/main/modules/core/common/system/security/kernel.nix

{
  lib,
  ...
}:
{
  flake.module.security = {
    nixos = {

      security.rtkit.enable = true;
      security.sudo.extraConfig = "Defaults pwfeedback";
      security.pam.services.sshd.unixAuth = lib.mkForce true;

      boot.kernel.sysctl = {
        # Enable Magic SysRq fully (1 = all functions). Low-level kernel
        # commands accessible via keyboard even when the system is hung —
        # needed to recover (Alt+SysRq+R E I S U B) from GPU hard-freezes
        # instead of holding the power button. Nothing is allowed via sysrq
        # that root could not already do through other means.
        "kernel.sysrq" = 1;

        # Hide kernel pointers even from processes with CAP_SYSLOG.
        # 1 = hidden from unprivileged; 2 = hidden from everyone including root.
        "kernel.kptr_restrict" = 2;

        # Disable the BPF JIT compiler to eliminate JIT spray attacks.
        "net.core.bpf_jit_enable" = false;

        # Disable ftrace debugging — reduces kernel attack surface.
        "kernel.ftrace_enabled" = false;

        # Prevent kernel address exposure via dmesg for unprivileged users.
        "kernel.dmesg_restrict" = 1;

        # Prevent unintentional writes to FIFOs in sticky world-writable dirs
        # (e.g. /tmp). 2 = even if you own the FIFO, open fails if it's in a
        # sticky dir you don't own.
        "fs.protected_fifos" = 2;
        "fs.protected_regular" = 2;

        # Disable core dumps for SUID binaries — prevents secrets leaking
        # via crash dumps.
        "fs.suid_dumpable" = 0;

        # Restrict kernel performance profiling. 3 = no perf_event_open()
        # without CAP_SYS_ADMIN + CAP_PERFMON, kernel events blocked entirely.
        "kernel.perf_event_paranoid" = 3;

        # Prevent unprivileged users from creating BPF programs. Once any BPF
        # program is loaded (even by root), unprivileged BPF is locked until
        # next reboot.
        "kernel.unprivileged_bpf_disabled" = 1;
      };

      # https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html
      #
      # The LSM parameter uses mkAfter so it appears last on the kernel
      # command line, overriding NixOS's own lsm= default.
      boot.kernelParams = lib.mkMerge [
        [
          # Randomize the kernel stack offset on every syscall — makes
          # stack-based attacks much harder to pull off reliably.
          "randomize_kstack_offset=on"

          # Disable the legacy vsyscall page (fixed kernel address in
          # userspace). Deprecated since 2016; breaks pre-2011
          # statically-linked binaries.
          "vsyscall=none"

          # Prevent the kernel from merging slab caches of similar-sized
          # objects from different subsystems. Limits cross-subsystem heap
          # exploitation.
          "slab_nomerge"

          # Require valid signatures on all kernel modules.
          "module.sig_enforce=1"

          # Kernel lockdown — confidentiality mode: prevents even root from
          # reading or modifying kernel memory (/dev/mem, /dev/kmem, kexec).
          "lockdown=confidentiality"

          # Fill freed pages with poison (0xAA) and check on allocation —
          # detects use-after-free and prevents info leaks from freed memory.
          "page_poison=1"

          # Randomize free page allocation order — makes kernel heap
          # grooming attacks unreliable.
          "page_alloc.shuffle=1"

          # Ensure SysRq is controlled by kernel.sysrq, not unconditionally
          # on.
          "sysrq_always_enabled=0"

          # Disable access-time updates on rootfs (performance + reduces
          # observable timing side-channels).
          "rootflags=noatime"

          # Prevent the kernel from blanking Plymouth out of the
          # framebuffer during boot.
          "fbcon=nodefer"
        ]

        (lib.mkAfter [
          # Linux Security Modules — ordered list.
          # landlock: unprivileged sandboxing from userspace
          # lockdown: kernel integrity/confidentiality (see above)
          # yama: ptrace restrictions
          # integrity: IMA (Integrity Measurement Architecture)
          # apparmor: mandatory access control
          # bpf: BPF LSM hooks
          # tomoyo, selinux: available but unused alongside apparmor
          "lsm=landlock,lockdown,yama,integrity,apparmor,bpf,tomoyo,selinux"
        ])
      ];

      # Every kernel module is attack surface. These are protocols,
      # filesystems, and hardware buses we don't use — blacklisting them
      # prevents accidental or malicious loading.
      boot.blacklistedKernelModules = [
        # Obscure / legacy network protocols — each has a kernel protocol
        # handler reachable via crafted packets.
        "af_802154" # IEEE 802.15.4
        "appletalk" # AppleTalk
        "atm" # Asynchronous Transfer Mode
        "ax25" # Amateur radio X.25
        "can" # Controller Area Network (automotive/industrial)
        "dccp" # Datagram Congestion Control Protocol
        "decnet" # DECnet
        "econet" # Econet
        "ipx" # Internetwork Packet Exchange (Novell)
        "n-hdlc" # High-level Data Link Control
        "netrom" # NetRom
        "p8022" # IEEE 802.3
        "p8023" # Novell raw IEEE 802.3
        "psnap" # Subnetwork Access Protocol
        "rds" # Reliable Datagram Sockets (Oracle)
        "rose" # ROSE
        "sctp" # Stream Control Transmission Protocol
        "tipc" # Transparent Inter-Process Communication
        "x25" # X.25 packet switching

        # Old / rare / insufficiently audited filesystems. Every filesystem
        # driver parses untrusted on-disk structures — fewer drivers = less
        # attack surface from malicious USB sticks, images, or network shares.
        "adfs"
        "affs"
        "befs"
        "bfs"
        "cramfs"
        "efs"
        "erofs"
        "exofs"
        "f2fs"
        "freevxfs"
        "gfs2"
        "hfs"
        "hfsplus"
        "hpfs"
        "jffs2"
        "jfs"
        "ksmbd" # In-kernel SMB server
        "minix"
        "nfs"
        "nfsv3"
        "nfsv4"
        "nilfs2"
        "omfs"
        "qnx4"
        "qnx6"
        "sysv"
        "udf"
        "vivid" # Virtual Video Test Driver (unnecessary)

        # Disable Thunderbolt and FireWire to prevent DMA attacks.
        # A malicious device plugged into these ports can read/write system
        # memory directly, bypassing the CPU and OS entirely.
        "firewire-core"
        "thunderbolt"
      ];
    };
  };
}
