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

## 5. Submission pages (Partner Center layout of November 2026)
- Pricing and availability: Free; all worldwide markets; public audience and discoverable (a probe may use direct link only); schedule as soon as possible; both organizational licensing boxes off.
- Properties: category Utilities + tools (subcategory optional); "uses personal information" Yes with the privacy policy URL; support website; contact, phone and address empty. There is no minimum-OS field (the manifest supplies it). Product declarations: tick nothing, untick the pre-ticked OneDrive backup; System requirements: untick Minimum > Mouse.
- Age ratings: IARC, All Other App Types, every question No (see LISTING_en-US.md).
- Packages: upload the unsigned .msix; the warning that runFullTrust, packagedServices and localSystemServices need approval is expected; device family Windows 10/11 Desktop only.
- Store listings: English (United States) ONLY (each extra language needs a full listing and blocks submission); text from LISTING_en-US.md; at least 1 screenshot (PNG, 1366x768 or larger; we use 4 with captions); logos: Box art 1080 and App tile icon 300 from packaging/store/icons; skip poster art, hero art, trailers, Xbox images.
- Submission options: hold = "Don't publish this submission until I select Publish now"; one box per restricted capability, 500 characters maximum each; the testing notes go on the separate Additional Testing Information page (Save description); credentials stay empty. All texts are in CERTIFICATION_NOTES.md.
- Then Submit for certification. Never click Publish now without a decision.
## 6. Record the outcome
Pass, fail or questions from the certification team: paste the exact text into PROJECT_STATUS.md. A rejection citing a restricted capability or policy 10.2.4 means the MSIX route is closed for this account; the fallback is the EXE/MSI route (own installer, signed with a CA certificate).
