# AAB to BIN Signer

Unlike Google Play App Signing, [CafeBazaar](https://cafebazaar.ir) does not store developers' signing keys on its servers.
Instead, CafeBazaar provides an open‑source tool called [bundle-signer](https://github.com/cafebazaar/bundle-signer) that allows developers to perform the signing process locally and generate a `.bin` file required for app publishing.

This repository provides a simple tool that automates signing an `.aab` file and generating the required `.bin` file using the `bundlesigner` tool.

This repository provides instructions for:

- [macOS](./macOS/README.md)
- Windows

## What this repository teaches

- How `aab` signing works
- How to use `bundle-signer`
- How to generate `bin` files
- How to automate the process on macOS and Windows
