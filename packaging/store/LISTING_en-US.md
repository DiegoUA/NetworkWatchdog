# Store listing text (en-US)

Paste into Partner Center > Store listings. Character limits are checked at the bottom.

## Product name
Network Watchdog

## Short description (max 200 characters)
Finds the process that leaks your PC's network sockets, shows live counts and can restart it, with one-click diagnostic evidence.

## Description
Network Watchdog finds the program that quietly uses up your PC's network sockets, and deals with it.

Some programs leak TCP sockets until Windows cannot open new connections: pages stop loading, games disconnect, apps hang. Network Watchdog watches every process, shows live socket counts and, at a threshold you control, can restart a leaking service or end the process. It can also collect the diagnostic evidence you need for a bug report.

WHAT IT DOES
- Background Windows service that checks the socket count of every process (default: every 15 seconds)
- Tray icon and dashboard: live process table, session logs, history, evidence cases and settings
- Adjustable threshold (default 1,000 sockets), cooldown, and quarantine for processes that keep leaking
- Whitelist for apps that legitimately use many connections, such as browsers and game launchers
- One-click diagnostic evidence for bug reports, stored on your PC only
- Optional syslog alerts to a server you choose
- No account, no ads, no telemetry. Nothing is sent anywhere unless you set up syslog alerts.

GOOD TO KNOW
- The service runs as Local System so it can see every process. For control actions, run the dashboard as administrator (right-click, Run as administrator).
- When a process exceeds the threshold, the app can restart or end it. Add apps you never want touched to the whitelist.
- Network Watchdog is a diagnostic and recovery tool. It is not an antivirus or a firewall and does not inspect network traffic.
- Evidence cases can contain a memory dump of the affected process. They stay on your PC until you export them.

Open source: https://github.com/DiegoUA/NetworkWatchdog

## What's new in this version
First Microsoft Store release.

## Search terms (max 7)
socket leak
tcp connections
network monitor
watchdog
process monitor
diagnostics
windows service

## Other fields
- Category: Utilities & tools (pick the system or network utility subcategory if one is offered)
- Price: Free
- Support website: https://github.com/DiegoUA/NetworkWatchdog
- Privacy policy URL: https://github.com/DiegoUA/NetworkWatchdog/blob/main/PRIVACY.md
- Screenshots: at least 1, PNG, 1366x768 or larger (maximize the dashboard); suggested: Live Processes, Settings & Whitelist, Evidence Cases
- Icons: out\store\listing-icons\Icon_300.png and Icon_1080.png (made by the build script)
- Age rating (IARC questionnaire): no violence, no sexual content, no user-generated content, no purchases, no location, no personal-data sharing

## Product features (entered 2026-11-05)
- Live socket counts for every process
- Adjustable threshold, cooldown and quarantine
- Whitelist for browsers and game launchers
- One-click diagnostic evidence, stored on your PC
- Tray icon, dashboard, session logs and history
- No account, no ads, no telemetry. Nothing is sent anywhere unless you set up syslog alerts.

## Screenshot captions (Desktop, entered 2026-11-05)
1. Live process table with socket counts and health status
2. Settings: threshold slider and a whitelist for apps you never want touched
3. Historical archive of past socket-limit events
4. Evidence cases captured for bug reports, stored on your PC
