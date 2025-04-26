# scoop-neovim-nightly

Builds a [Scoop](https://scoop.sh) manifest for installing the latest nightly
version of [Neovim](https://neovim.io) from GitHub.

## Requirements

- [PowerShell](https://github.com/PowerShell/PowerShell)
- [Scoop](https://scoop.sh)

## Usage

```console
PS> pwsh .\generate-manifest.ps1 -Version "$version"
PS> scoop install .\neovim-nightly.json
```

To update neovim, simply execute the `generate-manifest.ps1` script again and run:

```console
PS> scoop update neovim-nightly --force
```

## Parameters

| **Name**      | **Required** | **Description**             | **Default Value**     |
|:--------------|:-------------|:----------------------------|:----------------------|
| `-Version`    | YES          | Specify application version | N/A                   |
| `-OutputFile` | NO           | Specify manifest filename   | `neovim-nightly.json` |
