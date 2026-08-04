param(
    [Parameter(Mandatory = $true)]
    [string]$Version,

    [Parameter(Mandatory = $true)]
    [string]$TargetDir
)

$ErrorActionPreference = "Stop"

$architecture = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString()
$target = switch ($architecture) {
    "X64" { "x86_64-pc-windows-msvc" }
    "Arm64" { "aarch64-pc-windows-msvc" }
    default { throw "Unsupported Windows architecture: '$architecture'" }
}

$archiveName = "richclip_v${Version}_${target}.zip"
$url = "https://github.com/beeender/richclip/releases/download/v${Version}/${archiveName}"
$archivePath = Join-Path ([System.IO.Path]::GetTempPath()) $archiveName

New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
try {
    Invoke-WebRequest -Uri $url -OutFile $archivePath
    Expand-Archive -LiteralPath $archivePath -DestinationPath $TargetDir -Force
}
finally {
    Remove-Item -LiteralPath $archivePath -Force -ErrorAction SilentlyContinue
}
