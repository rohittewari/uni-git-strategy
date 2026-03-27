$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent (Split-Path -Parent $scriptDir)
$wrapperDir = Join-Path $repoRoot "gradle\wrapper"
$wrapperProperties = Join-Path $wrapperDir "gradle-wrapper.properties"

if (-not (Test-Path $wrapperProperties)) {
    throw "Missing Gradle wrapper properties at $wrapperProperties"
}

$distributionUrl = (
    Get-Content $wrapperProperties |
    Where-Object { $_ -match "^distributionUrl=" } |
    Select-Object -First 1
)

if (-not $distributionUrl) {
    throw "distributionUrl was not found in $wrapperProperties"
}

$distributionUrl = $distributionUrl.Substring("distributionUrl=".Length).Replace("\:", ":")
$distributionFile = [System.IO.Path]::GetFileName($distributionUrl)
$versionMatch = [System.Text.RegularExpressions.Regex]::Match(
    $distributionFile,
    "^gradle-(?<version>.+)-(?<type>bin|all)\.zip$"
)

if (-not $versionMatch.Success) {
    throw "Unable to parse Gradle version from distribution URL: $distributionUrl"
}

$version = $versionMatch.Groups["version"].Value
$wrapperJar = Join-Path $wrapperDir "gradle-wrapper-$version.jar"
$versionedWrapperProperties = Join-Path $wrapperDir "gradle-wrapper-$version.properties"
$legacyWrapperJar = Join-Path $wrapperDir "gradle-wrapper.jar"

if (Test-Path $wrapperJar) {
    if (-not (Test-Path $versionedWrapperProperties)) {
        Copy-Item $wrapperProperties $versionedWrapperProperties
    }
    exit 0
}

if (Test-Path $legacyWrapperJar) {
    Move-Item -Force $legacyWrapperJar $wrapperJar
    Copy-Item $wrapperProperties $versionedWrapperProperties
    exit 0
}

$tagCandidates = [System.Collections.Generic.List[string]]::new()
$tagCandidates.Add("v$version")
if ($version -match '^\d+\.\d+$') {
    $tagCandidates.Add("v$version.0")
}

New-Item -ItemType Directory -Force -Path $wrapperDir | Out-Null

$tempFile = [System.IO.Path]::GetTempFileName()
try {
    $downloaded = $false
    Write-Host "Downloading Gradle wrapper JAR for Gradle $version..."
    foreach ($tag in $tagCandidates | Select-Object -Unique) {
        $candidateUrl = "https://raw.githubusercontent.com/gradle/gradle/$tag/gradle/wrapper/gradle-wrapper.jar"
        try {
            Invoke-WebRequest -Uri $candidateUrl -OutFile $tempFile
            Move-Item -Force $tempFile $wrapperJar
            Copy-Item $wrapperProperties $versionedWrapperProperties
            $downloaded = $true
            break
        } catch {
            if (Test-Path $tempFile) {
                Remove-Item -Force $tempFile
            }
            $tempFile = [System.IO.Path]::GetTempFileName()
        }
    }

    if (-not $downloaded) {
        throw "Unable to resolve a wrapper JAR download URL for Gradle $version"
    }
} finally {
    if (Test-Path $tempFile) {
        Remove-Item -Force $tempFile
    }
}
