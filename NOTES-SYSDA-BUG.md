# SYSDA Allocation Bug — Investigation Notes

## Symptom

Step 11 (ISPF installation via MVP) fails with a 30-minute timeout. The ISPOPT5
sub-package tries to allocate a dataset with `UNIT=SYSDA` (no `VOL=SER=`), and
MVS rejects all online volumes:

```
IEF244I ISPOPT5 OBJFILE - UNABLE TO ALLOCATE 1 UNIT(S)
AT LEAST 1 OFFLINE UNIT(S) NEEDED.
IEF238D ISPOPT5 - REPLY DEVICE NAME OR 'CANCEL'.
```

The WTOR is never answered, MVP times out after 120s, and the cascade failure
takes down MINIZIP and NJE38 as well.

## Confirmed: Not ZP60041

Initial hypothesis was that usermod ZP60041 (which modifies IEAVAP00, the VATLST
processor) was breaking volume mount processing. This was disproven:

- Reordering steps so ISPF runs before ZP60041 produces the **same failure**
- A full clean rebuild from step 1 (with corrected VATLST from commit 8d06ceb)
  also fails identically

The bug exists in the base system configuration, independent of ZP60041.

## Root Cause: Volume Mount Attribute

`D U,DASD,ONLINE` after IPL shows the definitive state:

```
UNIT TYPE STATUS  VOLSER VOLSTATE   UNIT TYPE STATUS  VOLSER VOLSTATE
150  3350 S       MVSRES  PUB/RSDNT 151  3350 A       MVS000  PUB/RSDNT
152  3350 A       PAGE00  PUB/RSDNT 153  3350 A       SPOOL1  PUB/RSDNT
180  3380 O       PUB000  PUB/RSERV 190  3390 O       PUB001  PUB/RSERV
220  2314 O       SORTW1  PUB/RSERV 221  2314 O       SORTW2  PUB/RSERV
222  2314 O       SORTW3  PUB/RSERV 223  2314 O       SORTW4  PUB/RSERV
224  2314 O       SORTW5  PUB/RSERV 225  2314 O       SORTW6  PUB/RSERV
250  3350 O       SMP000  PUB/RSDNT 251  3350 O       WORK00  PUB/RSDNT
252  3350 O       WORK01  PUB/RSDNT 253  3350 A       SYSCPK  PUB/RSDNT
```

All volumes are either `PUB/RSDNT` (permanently resident) or `PUB/RSERV`
(reserved). **None are `PUB/REMOV` (removable).**

In MVS 3.8J, `UNIT=SYSDA` scratch allocation (no `VOL=SER=`) requires a
**PUBLIC, REMOVABLE** volume. Permanently resident and reserved volumes are
excluded from scratch allocation by design.

## VATLST00 vs Actual State

The VATLST00 in `jcl/sysgen04.jcl` specifies `MOUNT=1` (removable) for the
work volumes:

```
WORK00,1,1,3350    ,N        WORK PACK (PUBLIC)
WORK01,1,1,3350    ,N        WORK PACK (PUBLIC)
```

Format: `volser,USE,MOUNT,devtype,special` where MOUNT: 0=resident, 1=removable, 2=reserved.

But MVS shows them as `PUB/RSDNT` (permanently resident = MOUNT=0). The VATLST
MOUNT=1 attribute is not being applied — something is overriding it, or NIP is
not processing VATLST correctly for these volumes.

## What We Tried

1. **Operator MOUNT commands** (`/m 251,vol=(sl,work00),use=public`) — ran as a
   started task through JES2 but produced no IEE302I confirmation. Did not
   change volume state.

2. **HAO auto-reply to IEF238D with device 251** — MVS responded with
   `IEF490I ISPOPT5 - INVALID REPLY` for every attempt, creating a runaway
   reply loop (*25 through *44). Device 251 is genuinely not recognized as a
   valid allocation target.

3. **HAO auto-reply with CANCEL** — would work for ISPOPT5 but NJE38 also has
   extensive `UNIT=SYSDA` usage, so this doesn't solve the broader problem.

4. **Step reorder (ISPF before ZP60041)** — same failure. Disproved ZP60041
   hypothesis.

5. **Upstream VATLST fix (commit 8d06ceb)** — changed MOUNT field from 0/2 to 1
   for all volumes. Full clean rebuild still fails. The fix is already in our
   tree but doesn't resolve the issue.

## Key Observations

- SYSDA allocation **does work** in earlier steps (e.g., step 7 dynproc uses
  `UNIT=SYSDA` for SMP work datasets and succeeds)
- The failure only manifests in step 10+ when MVP sub-jobs need scratch SYSDA
- The `D U` output shows volumes as RSDNT/RSERV despite VATLST specifying
  MOUNT=1 (removable)
- `dasdls` confirms WORK00 is empty (plenty of space) and has correct volser
- All devices are properly attached in Hercules (confirmed via sysgen.log
  EOS00414I messages)
- The bug reproduces identically on both Eos and Hercules

## Open Questions

1. Why does VATLST MOUNT=1 not result in REMOV status? Is something in the VTOC
   (Format-4 DSCB) overriding it? Or is NIP ignoring the MOUNT field?

2. Why does SYSDA allocation work in step 7 (dynproc) but fail in step 10?
   Is the volume state different, or is dynproc's SYSDA allocation landing on
   a different volume?

3. Does upstream's Docker build actually succeed through step 11, or does it
   skip/work around this somehow?

## Next Steps

- Clone upstream repo and run their Docker build
- Compare log files (especially `D U,DASD,ONLINE` output) between upstream
  Docker build and our build to identify differences
- Check if upstream's Docker build uses different Hercules config, different
  DASD initialization, or different step ordering

## Files Involved

- `sysgen.py` — orchestration (custjobs_ipl at ~line 1801, step_10/11 at ~2162)
- `sysgen.conf` — customization2 section (line 178) defines device addresses
- `jcl/sysgen04.jcl:163-180` — VATLST00 definition
- `jcl/sysgen01.jcl:449-462` — SYSDA UNITNAME group definition
- `jcl/smp4p44.jcl:173-175` — ICKDSF ANALYZE for work volume initialization
- `MVSCE/MVP/packages/ISPOPT5:11851-11856` — failing OBJFILE allocation

## Diagnostic Added

A temporary `D U,DASD,ONLINE` command was added to `custjobs_ipl()` after
`$HASP099` (with `time.sleep(3)`) to capture volume status during IPL. This
should be removed once the bug is resolved.
