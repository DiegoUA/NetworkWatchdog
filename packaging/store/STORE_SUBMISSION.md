# Microsoft Store probe: step by step

Goal: learn whether the Store accepts NetworkWatchdog (a Windows service) from an individual account, without releasing it.

## 0. Before anything else
- [ ] Identity verification finished, Partner Center account active.
- [ ] STORE_BUILD patch applied to src\NetworkWatchdog.TrayApp\Program.cs (the build script refuses to run without it).
- [ ] Windows 11 SDK and .NET 10 SDK installed (the script finds makeappx.exe and signtool.exe).

## 1. Reserve the name
Partner Center > Apps and games > New product > MSIX or PWA app > reserve "Network Watchdog". Then open Product management > Product identity and note Package/Identity/Name, Package/Identity/Publisher and the publisher display name.

## 2. Local test of the packaged service (administrator PowerShell)
1. Uninstall the GitHub (Inno) version first. Both use the service name NetworkWatchdogService and cannot coexist.
2. `.\packaging\store\Build-StorePackage.ps1 -SignForLocalTest`
3. `Add-AppxPackage -Path .\out\store\NetworkWatchdog_<version>.0_x64_LOCALTEST.msix`
4. Check: `Get-Service NetworkWatchdogService` is Running; Start menu entry "Network Watchdog" opens the tray; the dashboard lists processes and the footer shows the build; run as administrator, add a whitelist entry, Save, restart the service, entry is still there; `C:\ProgramData\NetworkWatchdogService` exists with files; Collect Evidence produces a case.
5. Remove: `Get-AppxPackage NetworkWatchdogLocalTest | Remove-AppxPackage`; the service is gone.

## 3. Certification kit
`& "${env:ProgramFiles(x86)}\Windows Kits\10\App Certification Kit\appcert.exe" test -appxpackagepath .\out\store\NetworkWatchdog_<version>.0_x64.msix -reportoutputpath .\out\store\wack.xml`
Keep wack.xml; fix every FAIL before submitting (warnings about restricted capabilities are expected).

## 4. Store package
`.\packaging\store\Build-StorePackage.ps1 -IdentityName '<Name>' -Publisher '<Publisher>' -PublisherDisplayName '<display name>'`
Upload out\store\NetworkWatchdog_<version>.0_x64.msix (unsigned; the Store signs it).

## 5. Submission pages
- Pricing and availability: Free; markets as you like; if a visibility option exists, choose the most restricted one for the probe.
- Properties: category; privacy policy URL; system requirements (Windows 10 2004 or later, x64).
- Age ratings: IARC questionnaire (see LISTING_en-US.md).
- Packages: upload the .msix; answer the restricted-capability prompts.
- Store listings: LISTING_en-US.md, screenshots, icons.
- Submission options: paste CERTIFICATION_NOTES.md; set publishing to manual so a pass does not release the app.

## 6. Record the outcome
Pass, fail or questions from the certification team: paste the exact text into PROJECT_STATUS.md. A rejection citing a restricted capability or policy 10.2.4 means the MSIX route is closed for this account; the fallback is the EXE/MSI route (own installer, signed with a CA certificate).
