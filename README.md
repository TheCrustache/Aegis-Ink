Aegis Ink

A Shell-Based Adaptive Threat Detection & Counter-Surveillance Framework



🧠 Overview

Aegis Ink is a real-time, PowerShell-based threat tracking and response system designed for compromised environments. It operates autonomously under the assumption that the kernel is already breached, DNS is poisoned, and the attacker has embedded into low-level system processes.

Originally created as a survival tool for a system under live surveillance, Aegis Ink actively detects process morphing, port rebinding, DNS subversion, and fallback command-and-control channels.

✨ Features

Live Morph Detection

UDP Morphing & SYSTEM PID Trap

Port Watcher (e.g. port 4028 rebinding detection)

DNS Poisoning Detection

DNS SOS Beaconing to alert.whistle-safe.org

Real-time Morph Logging Terminal

Process Ancestry Mapping

Native PowerShell Execution - No Install Required

🔥 Live Example

[🖋️ INKED] PID Morph Detected for UDP:N/A:N/A :: PID 4028
[🖋️ INKED] UDP process morphing into SYSTEM (PID 4)
[🖋️ INKED] DNS poisoning: www.microsoft.com -> 2600:1408:5400:b9b::356e, 23.202.154.36
[🆘 S.O.S.] Beacon sent for PID 4028

⚙️ Usage

# Run from an elevated PowerShell session:
.\AegisInk.ps1

A second terminal will spawn for live morph logs.

🧪 Tested Against

Persistent UDP C2 tunnels (fallback port 4028)

PID morph chains including SYSTEM (PID 4)

Residential edge C2 relays on AkamaiNet (e.g. 23.54.42.39)

Kernel process disguises & DNS hijacking

📡 Beacon Integration

At Threat Level 100%, the tool triggers an encoded DNS beacon to alert.whistle-safe.org, including:

Hostname

PID

Path

Suspected C2 info

🧱 Architecture

Component

Description

Ink-Entity Engine

Logs and reacts to suspicious behaviors

Beacon Core

Encodes and dispatches DNS beacons

Port Trap

Monitors rebinds to suspicious ports

UDP Watcher

Flags SYSTEM morph attempts via UDP PID 4

Morphlog Streamer

Spawns second terminal for live PID shifts

📁 Repo Structure

Aegis-Ink/
├── AegisInk.ps1
├── README.md
├── research/
│   └── Aegis_Ink_Brief.pdf
├── logs/
│   └── example_morphlog.txt
├── screenshots/
│   └── plague-doctor-banner.png
└── LICENSE

🕵️‍♀️ Status

Field-tested and active in a hostile system.

Currently deployed against a suspected live adversary leveraging C2 fallback via residential Akamai edges.

📬 Contact

Aegis (Pseudonym)Signal-safe beacons via *.alert.whistle-safe.orgFull research brief: Aegis_Ink_Brief.pdf

🧠 Attribution

Built from the ground up as a tool of resistance and exposure. Inspired by the need for defenders to hit back without being seen.
