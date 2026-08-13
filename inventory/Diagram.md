1. High‑Level Architecture Diagram (4‑Role System)

                   ┌──────────────────────────────┐
                   │      lvm-expand.yml          │
                   │  (Orchestration Playbook)    │
                   └───────────────┬──────────────┘
                                   │
                                   ▼
        ┌────────────────────────────────────────────────────┐
        │                    Input Variables                  │
        │ lvm_disk, lvm_vg, lvm_lv, lvm_resize, lvm_mount     │
        └────────────────────────────────────────────────────┘
                                   │
                                   ▼
        ┌────────────────────────────────────────────────────┐
        │                    Role: lvm_pv                    │
        │  • Validate disk                                   │
        │  • Create PV (pvcreate)                            │
        └────────────────────────────────────────────────────┘
                                   │
                                   ▼
        ┌────────────────────────────────────────────────────┐
        │                    Role: lvm_vg                    │
        │  • Validate VG                                     │
        │  • Extend VG (vgextend)                            │
        └────────────────────────────────────────────────────┘
                                   │
                                   ▼
        ┌────────────────────────────────────────────────────┐
        │                    Role: lvm_lv                    │
        │  • Validate resize (+XG only)                      │
        │  • Grow LV + FS (lvextend -r)                      │
        └────────────────────────────────────────────────────┘
                                   │
                                   ▼
        ┌────────────────────────────────────────────────────┐
        │                    Role: lvm_fs                    │
        │  • Detect filesystem                               │
        │  • Grow XFS or EXT4                                │
        └────────────────────────────────────────────────────┘
                                   │
                                   ▼
                   ┌──────────────────────────────┐
                   │      Expanded Storage         │
                   │  PV + VG + LV + Filesystem    │
                   └──────────────────────────────┘

2. Detailed Step‑By‑Step Workflow Diagram

This shows the exact execution path when you run:
ansible-playbook lvm-expand.yml

┌──────────────────────────────────────────────────────────────┐
│                     Playbook Starts                           │
└──────────────────────────────────────────────────────────────┘
                │
                ▼
┌──────────────────────────────────────────────────────────────┐
│ Load Variables                                                │
│  • lvm_disk=/dev/sdc                                          │
│  • lvm_vg=vgdata                                              │
│  • lvm_lv=lvstore                                             │
│  • lvm_resize=+2G                                             │
│  • lvm_mount=/mnt/store                                       │
└──────────────────────────────────────────────────────────────┘
                │
                ▼
┌──────────────────────────────────────────────────────────────┐
│ Role: lvm_pv                                                  │
│ 1. Check disk exists                                           │
│ 2. pvcreate /dev/sdc                                           │
│ 3. PV created successfully                                     │
└──────────────────────────────────────────────────────────────┘
                │
                ▼
┌──────────────────────────────────────────────────────────────┐
│ Role: lvm_vg                                                  │
│ 4. vgextend vgdata /dev/sdc                                   │
│ 5. VG now has free extents                                    │
└──────────────────────────────────────────────────────────────┘
                │
                ▼
┌──────────────────────────────────────────────────────────────┐
│ Role: lvm_lv                                                  │
│ 6. Validate resize is grow-only (+XG)                         │
│ 7. lvextend -r -L +2G /dev/vgdata/lvstore                     │
│ 8. LV grows and filesystem grows automatically                │
└──────────────────────────────────────────────────────────────┘
                │
                ▼
┌──────────────────────────────────────────────────────────────┐
│ Role: lvm_fs                                                  │
│ 9. Detect filesystem type (XFS or EXT4)                       │
│ 10. Run xfs_growfs or resize2fs if needed                     │
└──────────────────────────────────────────────────────────────┘
                │
                ▼
┌──────────────────────────────────────────────────────────────┐
│                     Storage Expansion Complete                │
│  • PV created                                                 │
│  • VG extended                                                │
│  • LV expanded                                                │
│  • Filesystem grown                                           │
└──────────────────────────────────────────────────────────────┘
