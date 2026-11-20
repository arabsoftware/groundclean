# GroundClean 1.1.3

Remediation tool for the `Win32/Grenam` (`Ground.exe`) file infector.
Windows 7 SP1 through Windows 11, x86 and x64, C99, Win32 only.

Grenam renames `<name>.<ext>` to a hidden, system-flagged `g<name>.<ext>` and
drops a ~522 KB PE stub in place of the original. Version 1.1.3 extends the
tool from `.exe` to icon and image resources (`.ico`, `.cur`, `.jpg`, `.jpeg`,
`.png`, `.bmp`, `.gif`), proves every hidden sibling with magic-byte and
structural validation before swapping, and recovers stranded originals whose
visible counterpart an antivirus already deleted.

## Module map
```
GroundClean/
├─ CMakeLists.txt              primary build (MSVC + MinGW, x86/x64, static CRT)
├─ Makefile                    MinGW-w64 fallback build
├─ build.cmd                   one-shot MSVC x86 + x64 build & verify
├─ README.md                   layout, build matrix, coding rules
├─ .gitignore
├─ .editorconfig
├─ include/                    public contracts only, no logic
│  ├─ gc_types.h               shared constants, enums, Options/Stats/Ctx
│  ├─ gc_common.h              bounded strings, paths, time, attributes
│  ├─ gc_log.h                 logger + LOG* macros
│  ├─ gc_priv.h                elevation, privileges, environment probes
│  ├─ gc_pe.h                  PE + asset validation engine
│  ├─ gc_quarantine.h          quarantine store and rollback
│  ├─ gc_remediate.h           pair / standalone / dispatch
│  ├─ gc_reg.h                 Run keys, Winlogon, shell flags, .reg writer
│  ├─ gc_startup.h             Startup folders and .lnk resolution
│  ├─ gc_autorun.h             autorun.inf
│  ├─ gc_scan.h                recursive volume scanner, orphan recovery
│  └─ gc_cli.h                 banner, usage, argument parsing
├─ src/
│  ├─ gc_common.c
│  ├─ gc_log.c
│  ├─ gc_priv.c
│  ├─ gc_pe.c
│  ├─ gc_quarantine.c
│  ├─ gc_remediate.c
│  ├─ gc_reg.c
│  ├─ gc_startup.c
│  ├─ gc_autorun.c
│  ├─ gc_scan.c
│  ├─ gc_cli.c
│  └─ main.c
└─ res/
   ├─ groundclean.rc
   ├─ groundclean.manifest
   └─ version.h
```

| Layer | Header | Source | Responsibility |
|---|---|---|---|
| 0 | `gc_types.h` | – | constants, enums, `Options`/`Stats`/`Ctx` |
| 1 | `gc_common.h` | `gc_common.c` | bounded strings, paths, time, attributes |
| 2 | `gc_log.h` | `gc_log.c` | audit log, colour, mutex |
| 3 | `gc_priv.h` | `gc_priv.c` | elevation, privileges, host probes |
| 4 | `gc_pe.h` | `gc_pe.c` | PE verdicts, asset magic, `ValidateOriginal` |
| 5 | `gc_proc.h` | `gc_proc.c` | freeze-then-terminate watchdog pair |
| 6 | `gc_quarantine.h` | `gc_quarantine.c` | hashed blobs, CSV manifest, rollback |
| 7 | `gc_remediate.h` | `gc_remediate.c` | pair / standalone / stub dispatch |
| 8 | `gc_reg.h` | `gc_reg.c` | Run keys, Winlogon, shell flags, `.reg` writer |
| 8 | `gc_startup.h` | `gc_startup.c` | Startup folders, `.lnk` resolution |
| 8 | `gc_autorun.h` | `gc_autorun.c` | `autorun.inf`, sibling restore |
| 8 | `gc_scan.h` | `gc_scan.c` | recursive scan, orphan recovery |
| 9 | `gc_cli.h` | `gc_cli.c` | banner, usage, argument parsing |
| 10 | – | `main.c` | phase sequencing, summary, exit codes |

Include direction is strictly downward. A module may include layers below
itself and its own header, never a peer it does not call.

## Build

### MSVC

```bat
cmake -S . -B build\x64 -A x64 -DGC_STATIC_RUNTIME=ON
cmake --build build\x64 --config Release
