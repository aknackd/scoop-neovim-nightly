# scoop-neovim-nightly

Builds a [Scoop](https://scoop.sh) manifest for installing the latest nightly
version of [Neovim](https://neovim.io) from GitHub.

## Requirements

- Go
- make
- [Scoop](https://scoop.sh)

## Usage

```console
$ make
$ .\build-manifest.exe
$ scoop install .\neovim-nightly.json
```

### Overriding manifest filename

By default, a `neovim-nightly.json` file will be generated but it can be
overridden by specifying `-output <path>`. For example:

```console
$ .\build-manifest.exe -output neovim.json
$ scoop install neovim.json
```

### Overriding manifest version

The [Makefile](./Makefile) contains a `VERSION` flag that's used to populate
the `Version` key in the generated manifest. To override this value, either
update the value in the Makefile or specify it while running `make`, for example:

```console
$ make VERSION=0.9.0-dev
```
