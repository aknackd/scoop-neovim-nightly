param (
    [string] $Version = $(throw "-Version is required."),
    [string] $OutputFile = "neovim-nightly.json"
)

$GitHubApiHeaders = @{
    'Accept' = 'application/vnd.github+json'
    'X-GitHub-Api-Version' = '2022-11-28'
}

# Fetches the nightly release ID from the "nightly" tag so we can later fetch
# the commitish to append to the version number in the manifest.
function Get-Nightly-Release-ID () {
    $url = "https://api.github.com/repos/neovim/neovim/releases/tags/nightly"

    $response = Invoke-RestMethod    `
        -Uri "$url"                  `
        -Method Get                  `
        -Headers $GitHubApiHeaders

    return $response.id
}

# Fetches the commitish to append to the version in the manifest.
function Get-Nightly-Release-Commitsh () {
    $releaseId = Get-Nightly-Release-ID

    $releaseUrl = "https://api.github.com/repos/neovim/neovim/releases/${releaseId}"

    $response = Invoke-RestMethod  `
        -Uri $releaseUrl           `
        -Method Get                `
        -Headers $GitHubApiHeaders

    return $response.target_commitish
}

# Fetch and return the SHA256 checkusm of the current nightly release.
function Fetch-Nightly-Release-Checksum () {
    Write-Host "Fetching nightly release checksum"

    $checksumUrl = `
        "https://github.com/neovim/neovim/releases/download/nightly/nvim-win64.zip.sha256sum"

    try {
        $response = Invoke-WebRequest `
            -TimeoutSec 5             `
            -RetryIntervalSec 2       `
            -MaximumRetryCount 5      `
            -Method Get               `
            -Uri $checksumUrl

        if ($response.StatusCode -eq 200) {
            $contents = ([System.Text.Encoding]::UTF8.GetString($response.Content) -split "\n")[0]

            return ($contents -split "  ")[0]
        } else {
            # @@@ Throw exception
        }
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host -ForegroundColor Red "Failed to fetch checksum"
        Write-Host -ForegroundColor Red "Got a ${statusCode} status code, expected 200"
        Exit 1
    }
}

# Generates the scoop manifest.
function Generate-Scoop-Manifest () {
    # Extract the semver from the global -Version param and add the release
    # commitish so we get a unique version. Unfortunately we can't get the
    # number of commits since the last stable release like when neovim reports
    # on startup and on the first line of output from  "nvim --version" to get
    # a matching version.

    $commitish = $(Get-Nightly-Release-Commitsh).Substring(0, 9)

    $sanitizedVersion = $Version -replace "-.+$", ""
    $fullVersion = "${sanitizedVersion}-dev+g${commitish}"

    Write-Host "Generating Scoop manifest for ${fullVersion}"

    $nightlyChecksum = Fetch-Nightly-Release-Checksum

    @"
{
    "version": "${fullVersion}",
    "description": "Vim-fork focused on extensibility and usability",
    "homepage": "https://neovim.io/",
    "license": {
        "identifier": "Apache-2.0,Vim",
        "url": "https://github.com/neovim/neovim/blob/master/LICENSE"
    },
    "suggest": {
        "vcredist": "extras/vcredist2022"
    },
    "architecture": {
        "64bit": {
            "url": "https://github.com/neovim/neovim/releases/download/nightly/nvim-win64.zip",
            "hash": "${nightlyChecksum}"
        }
    },
    "extract_dir": "nvim-win64",
    "bin": [
        "bin\\nvim.exe"
    ],
    "checkver": {
        "github": "https://github.com/neovim/neovim"
    }
}
"@ | Out-File -FilePath "$OutputFile"
}

Generate-Scoop-Manifest

Write-Host "Wrote manifest to " -NoNewLine
Write-Host -ForegroundColor Blue "$OutputFile"
Write-Host "Install manifest via: " -NoNewLine
Write-Host -ForegroundColor Green "scoop install ${OutputFile}"
