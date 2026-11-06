# Notes for certification (Partner Center layout of November 2026)

The notes are entered in THREE places in Partner Center, not in one box. Re-check the BEHAVIOR lines of the testing notes against the final Store defaults before every submission.

1. **Submission options > Restricted capabilities:** one box per capability, 500 characters maximum each (the form cuts longer text). Texts in section 1 below.
2. **Additional Testing Information > Notes for Certification > Description:** the text between the two lines of section 2, then click Save description. Credentials stay empty (the app has no sign-in).
3. **Submission options > Publishing hold options:** select "Don't publish this submission until I select Publish now" for a probe or whenever the release should be decided by hand.

## 1. Restricted capabilities (maximum 500 characters each)

### runFullTrust (421 characters)
```
Classic .NET desktop app (not UWP): a WinForms tray dashboard (NetworkWatchdog.TrayApp.exe) and a worker service (NetworkWatchdogService.exe). The service reads the system TCP socket table and process list and can restart or end a process above a user-set socket threshold; the dashboard shows live data over a named pipe and edits the threshold and whitelist. The UWP container cannot do this, so full trust is required.
```

### packagedServices (396 characters)
```
The package declares one Windows service, NetworkWatchdogService (Automatic start). It is the core of the product: a background monitor that checks every process's socket count every 15 seconds and acts only above a user-set threshold, whether or not the tray app is open. It is the app's own service: no drivers, no other or third-party services (policy 10.2.4). Uninstalling the app removes it.
```

### localSystemServices (470 characters)
```
The service runs as LocalSystem to read the socket table of all processes (other users, system services), restart or end a leaking process, and capture diagnostic evidence on user request (including a process memory dump). Data is written to %ProgramData%\NetworkWatchdogService, restricted to administrators and SYSTEM. A normal-user service cannot do this. Actions occur only above a user-set threshold (default 1000 sockets) with cooldown, quarantine and a whitelist.
```

## 2. Testing notes (Additional Testing Information)

---
Network Watchdog = Windows service + tray dashboard that finds processes leaking TCP sockets. No sign-in or internet needed to test. The three restricted capabilities (runFullTrust, packagedServices, localSystemServices) are explained in Submission options > Restricted capabilities.

HOW TO TEST (3 minutes)
1. Install. PowerShell: Get-Service NetworkWatchdogService -> Running.
2. Start menu > Network Watchdog (tray icon). For all features: right-click > Run as administrator.
3. Dashboard > Live Processes: processes with socket counts; footer shows the build version. The list can be empty on an idle PC (it shows only processes with a notable socket count). To see a row, run this in PowerShell (about 100 loopback sockets for 10 minutes, below the default threshold):
$l=[Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback,9998);$l.Start();$k=@();1..25|%{$c=[Net.Sockets.TcpClient]::new();$c.Connect('127.0.0.1',9998);$k+=$c;$k+=$l.AcceptTcpClient()};Start-Sleep 600
4. Settings & Whitelist: change the whitelist, Save. Please keep the default threshold: lowering it makes the app restart busy processes, by design.
5. Uninstall removes the service.

BEHAVIOR
- Restart/terminate happens only when a process exceeds the threshold (default 1000 sockets), with a 120 s cooldown, quarantine after 3 restarts per 60 min, and a user whitelist.
- "Collect Evidence" is a user button; it writes a local ZIP that may contain a process memory dump. Nothing is uploaded.
- This build has no updater and makes no internet connections of its own; the only network feature is optional syslog forwarding, off by default, sent only to a server the user enters. Privacy policy: https://github.com/DiegoUA/NetworkWatchdog/blob/main/PRIVACY.md
---

## 3. Facts behind the texts (verified in the code or in tests, 2026-11-04/05)
- Defaults: scan every 15 s, cooldown 120 s, global threshold 1000, quarantine after 3 restarts in 60 min, syslog off (`WatchdogConfig.cs`).
- The service runs as LocalSystem from the WindowsApps package folder; the data folder `%ProgramData%\NetworkWatchdogService` is readable by administrators and SYSTEM only (a normal user gets Access Denied).
- Without administrator rights the dashboard cannot save settings (Access Denied message); started with Run as administrator it can.
- The Live Processes grid hides processes below a small socket count (hard-coded filter), so it can be empty on an idle PC.
