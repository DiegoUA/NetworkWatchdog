# Notes for certification

Paste the text between the lines into Partner Center > Submission options > Notes for certification (limit 2,000 characters).
Re-check the "BEHAVIOR" section against the final Store defaults before every submission.

---
Network Watchdog = Windows service + tray dashboard that finds processes leaking TCP sockets. No sign-in or internet needed to test.

RESTRICTED CAPABILITIES
- runFullTrust: classic .NET desktop app (WinForms tray + worker service).
- packagedServices: the package contains ONE Windows service, NetworkWatchdogService (auto start), the product's core background monitor. It is the app's own service; no drivers and no third-party services (policy 10.2.4).
- localSystemServices: the service must run as LocalSystem to read the socket table of all processes, restart or end leaking processes of any user or service, and write diagnostics to a protected folder (%ProgramData%\NetworkWatchdogService, admin/SYSTEM only). A user-level service cannot do this.

HOW TO TEST (3 minutes)
1. Install. PowerShell: Get-Service NetworkWatchdogService -> Running.
2. Start menu > Network Watchdog (tray icon). For all features: right-click > Run as administrator.
3. Dashboard > Live Processes: processes with socket counts; footer shows the build version.
4. Settings & Whitelist: change the whitelist, Save. Please keep the default threshold: lowering it makes the app restart busy processes, by design.
5. Uninstall removes the service.

BEHAVIOR
- Restart/terminate happens only when a process exceeds the threshold (default 1000 sockets), with a 120 s cooldown, quarantine after 3 restarts per 60 min, and a user whitelist.
- "Collect Evidence" is a user button; it writes a local ZIP that may contain a process memory dump. Nothing is uploaded.
- This build has no updater and makes no internet connections of its own; the only network feature is optional syslog forwarding, off by default, sent only to a server the user enters. Privacy policy: https://github.com/DiegoUA/NetworkWatchdog/blob/main/PRIVACY.md
---
