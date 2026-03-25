# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MVS Community Edition (MVS/CE) sysgen — a Python-driven build system that performs a full MVS 3.8J system generation on an emulated IBM System/370. This fork targets **Eos**, a System/370-focused fork of SDL Hercules Hyperion.

The companion automation library [automvs](https://github.com/MVS-sysgen/automvs) may also require adaptation and is available via `--add-dir`. The Eos source tree is available via `--add-dir` for reference when needed.

## Build Commands

Activate the Eos environment first (sets executable and library paths):
```bash
source /home/robert/eos-qa/activate.sh
```

Full sysgen (can take hours; retries on Hercules crashes):
```bash
until ./sysgen.py --hercules eos --CONTINUE; do echo "Failed, rerunning"; done
```

List all steps and substeps:
```bash
./sysgen.py --list
```

Resume from a specific step/substep:
```bash
./sysgen.py --step step_07_customization --substep brexx
```

Key flags: `--hercules <path>`, `--timeout <seconds>` (default 1800), `--version <string>`, `--release`, `--no-compress`, `--keep-backup`, `--keep-temp`, `--username`/`--password`.

There are no unit tests or linting configured for this project.

## Architecture

### sysgen.py (~2600 lines, single-file)

The entire build is orchestrated by `sysgen.py`, which contains:
- A `sysgen` class that wraps a Hercules subprocess, manages stdin/stdout/stderr via threads and queues, and drives each build step
- 12 sequential steps (`step_01_build_starter` through `step_12_cleanup`), each IPLing MVS at various stages and submitting JCL jobs
- Hercules interaction methods: `send_herc()` (raw commands), `send_oper()` (console `/` prefix), `send_reply()` (auto-numbered replies), `wait_for_string()`, `wait_for_psw()`
- Job submission via TCP socket to the card reader (port 3505): `submit()`, `submit_file()`, `submit_file_binary()`
- A `.step` file persists progress so `--CONTINUE` / `-C` can resume after failure

### sysgen.conf (multi-section config)

Not a standard Hercules config — it's a custom format parsed by `read_configs()`. Sections are delimited by `## SECTION: <name>` comments. Each section defines Hercules settings and device attachments for a specific build phase (e.g., `build_starter`, `smp1`, `smp2`, `sysgen`, `customization`, `customization2`). The top-level `hercules.cnf` is a dummy placeholder.

### conf/ — runtime configuration

- `local.cnf` — the real Hercules config used by the finished MVS/CE system (device map, DASD paths, console, TSO 3270s)
- `mvsce.rc` — Hercules run-commands file for automated IPL and HAO rules
- `herclogo.template` — 3270 connection logo with `@@@@@VERSION@@@@@` placeholder

### JCL and usermods

- `jcl/` — JCL decks submitted during sysgen steps (smpjob00-07, sysgen00-06, customization, etc.)
- `usermods/` — individual SMP usermod JCL files (ZP60xxx, JLMxxxx, SLBxxxx, etc.) applied in step 5
- `sajobs/` — standalone jobs for initial DASD volume setup (step 1)
- **JCL files run inside MVS on emulated S/370 hardware — do NOT modify them for Eos rebranding**

### Supporting data

- `tape/` — HET tape images (distribution tapes, starter system, PTFs)
- `gz/` — compressed archives extracted during build
- `dasd/` — seed DASD image(s)
- `xmi/` — XMIT-format packages (BREXX)
- `users.conf` / `profiles.conf` — TSO user definitions and RAKF security profiles

### Build output

Generated under `MVSCE/` (gitignored): DASD images, config, startup script, README. Backup DASD snapshots in `backup/`, temp files in `temp/`.

## Eos Rebranding Rules

Eos is a rebrand of SDL Hercules Hyperion with s/390 and z/Arch removed. For this sysgen project (which targets MVS 3.8J on S/370), the changes are almost entirely naming:

### Executable

| Eos              | Hercules         |
|------------------|------------------|
| `eos`            | `hercules`       |

- `herclin` and `hercifc` keep their names.
- All utilities (`dasdcopy`, `dasdload`, `hetget`, etc.) keep their names.
- A `hercules` → `eos` symlink exists but prefer the native name.

### Message Codes

All `HHC` prefixed message codes become `EOS`, same 5-digit number:

- `HHC01234` → `EOS01234`
- This applies to string matching in Python/REXX automation (e.g., `wait_for_string()` calls in automvs).
- There is **no** backward-compatibility flag — Eos always emits `EOS` prefix.

### Environment Variables

| Purpose                | Eos (use this)  | Hercules (fallback) |
|------------------------|-----------------|---------------------|
| Configuration file     | `EOS_CNF`       | `HERCULES_CNF`      |
| Run-commands file      | `EOS_RC`        | `HERCULES_RC`       |
| Module library path    | `EOS_LIB`       | `HERCULES_LIB`      |
| Logo file              | `EOSLOGO`       | `HERCLOGO`          |

Eos still honors the `HERCULES_*` names as fallback, but prefer Eos-native names.

### Configuration Files

| Eos (prefer)     | Hercules (fallback) |
|------------------|---------------------|
| `eos.cnf`        | `hercules.cnf`      |
| `eos.rc`         | `hercules.rc`       |
| `eoslogo.txt`    | `herclogo.txt`      |

Config file **syntax is identical** — only filenames change.

### Console

- Prompt changed: `herc =====>` → `eos =====>`
- `herclogo` command aliased as `eoslogo` (prefer `eoslogo`)
- `--herclogo=` aliased as `--eoslogo=` (prefer `--eoslogo=`)
- All other console commands are unchanged.

### REXX Address Environment

```rexx
Address EOS "command"          /* preferred */
Address HERCULES "command"     /* still works */
```

### Shared Libraries (if referenced in build scripts)

| Eos            | Hercules        |
|----------------|-----------------|
| `libeoss.so`   | `libhercs.so`   |
| `libeosu.so`   | `libhercu.so`   |
| `libeost.so`   | `libherct.so`   |
| `libeosd.so`   | `libhercd.so`   |
| `libeose.so`   | `libherc.so`    |

Module install directory: `$LIBDIR/eos/` (was `$LIBDIR/hercules/`).

## What Does NOT Change

These are critical — do not modify any of the following:

- **JCL files** — these run inside MVS on emulated S/370 hardware. MVS does not know what emulator is hosting it. Leave all JCL untouched.
- **REXX scripts running inside MVS** (BREXX/370) — same reason as JCL.
- **Configuration file syntax** — all device definitions, statements, and options are identical. Only the filename changes.
- **Device types and addresses** — 3215-C, 2540R, 1403, 3211, 3350, 3330, etc.
- **DASD image formats** — CKD, FBA, CCKD unchanged.
- **HET tape format** — "Hercules Emulated Tape" is a format name, not branding. Do NOT rename `.het` files or HET references.
- **Utility names** — `dasdcopy`, `dasdload`, `dasdls`, `hetget`, `hetmap`, `tapemap`, etc. are unchanged.
- **Test infrastructure** — `.tst` files, `runtest`, `redtest.rexx` unchanged.
- **Console command syntax** — all commands work the same way.

## Rebranding Strategy

1. **Inventory first** — `grep -rn` for all Hercules-specific references across the project before changing anything. Present findings grouped by category (message codes, executable name, env vars, config filenames, build steps, documentation/comments).
2. **Separate functional changes from cosmetic** — distinguish between changes that affect runtime behavior (message string matching, executable invocation, env vars) vs. documentation/comments.
3. **Validate incrementally** — after each category of changes, confirm the scripts are internally consistent before moving on.
4. **automvs changes** — the `automvs` Python library needs the same treatment, especially `send_herc()` calls and any string matching against `HHC` message codes.
