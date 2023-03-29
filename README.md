# scoop-neovim-nightly

Builds a [Scoop](https://scoop.sh) manifest for installing the latest nightly
version of [Neovim](https://neovim.io) from GitHub.

## Requirements

- [PowerShell](https://github.com/PowerShell/PowerShell)
- [Scoop](https://scoop.sh)

## Usage

```console
PS> pwsh .\build-manifest.ps1 -Version "$version"
PS> scoop install .\neovim-nightly.json
```

## Parameters

| **Name**      | **Required** | **Description**             | **Default Value**     |
|:--------------|:-------------|:----------------------------|:----------------------|
| `-Version`    | YES          | Specify application version | N/A                   |
| `-OutputFile` | NO           | Specify manifest filename   | `neovim-nightly.json` |
