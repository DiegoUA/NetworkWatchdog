# Privacy Policy: Network Watchdog

Last updated: 2026-11-03
Publisher: Maksym Polishchuk (GitHub: DiegoUA)
Contact: https://github.com/DiegoUA/NetworkWatchdog/issues

Network Watchdog is a Windows service with a tray dashboard. It watches how many network sockets each process on your PC holds open, and can restart or end a process that leaks sockets.

## In short

- No account, no advertising, no analytics, no telemetry.
- The Microsoft Store version has no update check and makes no internet connections of its own. Updates come only through the Microsoft Store.
- Everything the app records stays on your PC, in `%ProgramData%\NetworkWatchdogService`, which only administrators and the system can open.
- The only data that can leave your PC is the optional syslog message described below, which you set up yourself.

## What the app reads

On your PC, at the interval you configure (default: every 15 seconds): process names and IDs, how many TCP/UDP sockets and handles each process holds, and the state of the services it is set to watch. It does not read the content of network traffic, your files, your browsing or your messages.

## What the app stores (locally only)

- **Logs and telemetry:** process names, IDs, socket counts, timestamps and restart events.
- **Settings:** threshold, whitelist and evidence options.
- **Evidence cases:** created when you press "Collect Evidence", or automatically before a restart if you switch that option on in Settings. A case is a ZIP with diagnostic files about the affected process (for example process and connection lists) and can include a memory dump of that process. A memory dump can contain anything the process held in memory, including personal data. Keep cases private and review them before sharing. The app keeps at most 5 cases, never uploads them and exports one only when you choose to.

## Optional syslog

Off by default. If you enter a server address and switch it on, the app sends short UDP messages (process name, process ID, socket count, alert text) to that server. You choose the destination. Neither Microsoft nor the publisher receives anything.

## Sharing

The publisher does not receive, collect or share any of your data.

## Retention and deletion

Data stays until you remove it. After uninstalling the app, delete the folder `%ProgramData%\NetworkWatchdogService` if it is still there.

## Children

The app is a system utility and is not directed at children.

## Changes

Changes to this policy are published in this repository, with the date above updated.
