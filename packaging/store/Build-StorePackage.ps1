<#
.SYNOPSIS
  Builds the Microsoft Store package (MSIX) of NetworkWatchdog, and optionally a signed copy for a local test.
.EXAMPLE
  # local test: run PowerShell as administrator, uninstall the GitHub (Inno) version first
  .\packaging\store\Build-StorePackage.ps1 -SignForLocalTest
.EXAMPLE
  # package for Partner Center, with the values from "Product identity"
  .\packaging\store\Build-StorePackage.ps1 -IdentityName '<Package/Identity/Name>' -Publisher '<Package/Identity/Publisher>' -PublisherDisplayName 'Maksym Polishchuk'
#>
[CmdletBinding()]
param(
    [string]$Version,                                         # x.y.z, default = <Version> of the service csproj
    [string]$IdentityName = 'NetworkWatchdogLocalTest',       # Partner Center: Package/Identity/Name
    [string]$Publisher = 'CN=NetworkWatchdogLocalTest',       # Partner Center: Package/Identity/Publisher
    [string]$PublisherDisplayName = 'Local test',             # Partner Center: publisher display name
    [switch]$SignForLocalTest
)
$ErrorActionPreference = 'Stop'
$root     = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$svcProj  = Join-Path $root 'src\NetworkWatchdogService\NetworkWatchdogService.csproj'
$trayProj = Join-Path $root 'src\NetworkWatchdog.TrayApp\NetworkWatchdog.TrayApp.csproj'
$trayCode = Join-Path $root 'src\NetworkWatchdog.TrayApp\Program.cs'

if (-not (Select-String -Path $trayCode -Pattern 'STORE_BUILD' -Quiet)) {
    throw 'The tray code has no STORE_BUILD switch yet: the updater would end up in the Store package. Apply the STORE_BUILD patch first.'
}
if (-not $Version) {
    $m = [regex]::Match((Get-Content $svcProj -Raw), '<Version>\s*(\d+\.\d+\.\d+)\s*</Version>')
    if (-not $m.Success) { throw 'Cannot read <Version> from the service csproj; pass -Version x.y.z' }
    $Version = $m.Groups[1].Value
}
if ($Version -notmatch '^\d+\.\d+\.\d+$') { throw "Version must look like 1.10.0 (got '$Version')" }
$pkgVersion = "$Version.0"    # the Store reserves the 4th part: it must stay 0

function Find-SdkTool([string]$name) {
    $hit = Get-ChildItem "${env:ProgramFiles(x86)}\Windows Kits\10\bin" -Recurse -Filter $name -ErrorAction SilentlyContinue |
           Where-Object { $_.FullName -match '\\x64\\' } | Sort-Object FullName -Descending | Select-Object -First 1
    if (-not $hit) { throw "$name not found. Install the Windows 11 SDK (try: winget search Microsoft.WindowsSDK) and run again." }
    $hit.FullName
}
$makeappx = Find-SdkTool 'makeappx.exe'

$out    = Join-Path $root 'out\store'
$layout = Join-Path $out 'layout'
if (Test-Path $out) { Remove-Item $out -Recurse -Force }
New-Item -ItemType Directory -Path $layout | Out-Null

# 1. Publish both projects, self-contained (a Store package cannot rely on an installed .NET runtime), Store channel.
foreach ($proj in @($svcProj, $trayProj)) {
    & dotnet publish $proj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=false -p:DistributionChannel=Store -p:Version=$Version -o $layout
    if ($LASTEXITCODE -ne 0) { throw "dotnet publish failed for $proj" }
}
Get-ChildItem $layout -Filter *.pdb | Remove-Item -Force
Remove-Item (Join-Path $layout 'appsettings.Development.json') -ErrorAction SilentlyContinue
foreach ($exe in 'NetworkWatchdogService.exe', 'NetworkWatchdog.TrayApp.exe') {
    if (-not (Test-Path (Join-Path $layout $exe))) { throw "$exe missing from the publish output" }
}

# 2. Logos from the tray icon.
Add-Type -AssemblyName System.Drawing
$assets = Join-Path $layout 'Assets'
New-Item -ItemType Directory -Path $assets | Out-Null
$listing = Join-Path $out 'listing-icons'
New-Item -ItemType Directory -Path $listing | Out-Null
$icon = New-Object System.Drawing.Icon -ArgumentList (Join-Path $root 'src\NetworkWatchdog.TrayApp\app.ico'), 256, 256
$srcBmp = $icon.ToBitmap()
function Save-Png([int]$size, [string]$path) {
    $bmp = New-Object System.Drawing.Bitmap $size, $size
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = 'HighQualityBicubic'; $g.SmoothingMode = 'HighQuality'; $g.PixelOffsetMode = 'HighQuality'
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.DrawImage($srcBmp, 0, 0, $size, $size)
    $g.Dispose(); $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose()
}
Save-Png 44  (Join-Path $assets 'Square44x44Logo.png')
Save-Png 150 (Join-Path $assets 'Square150x150Logo.png')
Save-Png 50  (Join-Path $assets 'StoreLogo.png')
Save-Png 300  (Join-Path $listing 'Icon_300.png')
Save-Png 1080 (Join-Path $listing 'Icon_1080.png')

# 3. Manifest.
$tpl = Get-Content (Join-Path $PSScriptRoot 'AppxManifest.template.xml') -Raw -Encoding UTF8
$esc = { param($s) [System.Security.SecurityElement]::Escape($s) }
$xml = $tpl.Replace('{{IDENTITY_NAME}}', (& $esc $IdentityName)).Replace('{{PUBLISHER}}', (& $esc $Publisher)).Replace('{{PUBLISHER_DISPLAY_NAME}}', (& $esc $PublisherDisplayName)).Replace('{{VERSION}}', $pkgVersion)
[IO.File]::WriteAllText((Join-Path $layout 'AppxManifest.xml'), $xml, (New-Object Text.UTF8Encoding $false))

# 4. Pack (unsigned: the Store signs it).
$msix = Join-Path $out ("NetworkWatchdog_{0}_x64.msix" -f $pkgVersion)
& $makeappx pack /d $layout /p $msix /o
if ($LASTEXITCODE -ne 0) { throw 'makeappx failed' }
Write-Host "Store package: $msix" -ForegroundColor Green

# 5. Optional: signed copy for a local test (needs an administrator PowerShell to trust the test certificate).
if ($SignForLocalTest) {
    $signtool = Find-SdkTool 'signtool.exe'
    $cert = Get-ChildItem Cert:\CurrentUser\My | Where-Object { $_.Subject -eq $Publisher -and $_.NotAfter -gt (Get-Date) } | Select-Object -First 1
    if (-not $cert) {
        $cert = New-SelfSignedCertificate -Type Custom -Subject $Publisher -KeyUsage DigitalSignature -FriendlyName 'NetworkWatchdog local test' `
                  -CertStoreLocation 'Cert:\CurrentUser\My' -TextExtension @('2.5.29.37={text}1.3.6.1.5.5.7.3.3', '2.5.29.19={text}')
    }
    $cer = Join-Path $out 'NetworkWatchdog_LocalTest.cer'
    Export-Certificate -Cert $cert -FilePath $cer | Out-Null
    Import-Certificate -FilePath $cer -CertStoreLocation 'Cert:\LocalMachine\TrustedPeople' | Out-Null
    $test = Join-Path $out ("NetworkWatchdog_{0}_x64_LOCALTEST.msix" -f $pkgVersion)
    Copy-Item $msix $test
    & $signtool sign /fd SHA256 /sha1 $cert.Thumbprint /s My $test
    if ($LASTEXITCODE -ne 0) { throw 'signtool failed' }
    Write-Host "Local test package: $test" -ForegroundColor Green
    Write-Host "Install:   Add-AppxPackage -Path '$test'     (administrator PowerShell)"
    Write-Host "Remove:    Get-AppxPackage $IdentityName | Remove-AppxPackage"
}

Get-ChildItem $out -Filter *.msix | ForEach-Object {
    '{0}  {1:N1} MB  sha256={2}' -f $_.Name, ($_.Length / 1MB), (Get-FileHash $_.FullName -Algorithm SHA256).Hash.ToLower()
}
