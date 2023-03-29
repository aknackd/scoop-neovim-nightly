param (
    [string] $Version = $(throw "-Version is required."),
    [string] $OutputFile = "neovim-nightly.json"
)

# Fetch and return the SHA256 checkusm of the current nightly release
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

# Builds the scoop manifest
function Build-Manifest () {
    Write-Host "Building manifest"

    $nightlyChecksum = Fetch-Nightly-Release-Checksum

    $sanitizedVersion = $Version -replace "-.+$", ""

    $manifest = @"
{
    "version": "${sanitizedVersion}-nightly",
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
        "bin\\nvim.exe",
        "bin\\nvim-qt.exe"
    ],
    "shortcuts": [
        [
            "bin\\nvim-qt.exe",
            "Neovim"
        ]
    ],
    "checkver": {
        "github": "https://github.com/neovim/neovim"
    }
}
"@

    $manifest | Out-File -FilePath "$OutputFile"
}

Build-Manifest

Write-Host "Wrote manifest to " -NoNewLine
Write-Host -ForegroundColor Blue "$OutputFile"
Write-Host "Install manifest via: " -NoNewLine
Write-Host -ForegroundColor Green "scoop install ${OutputFile}"
