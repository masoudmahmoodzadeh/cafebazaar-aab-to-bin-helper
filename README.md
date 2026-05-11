# CafeBazaar AAB to BIN Helper

Unlike Google Play App Signing, [CafeBazaar](https://cafebazaar.ir) does not store developers' signing keys on its servers.

Instead, CafeBazaar provides an open-source tool called [bundle-signer](https://github.com/cafebazaar/bundle-signer), which allows developers to locally sign their Android App Bundles (`.aab`) and generate the `.bin` file required for publishing applications.

This repository provides simple scripts and step-by-step instructions to automate the process of generating `.bin` files from `.aab` files on different operating systems.

## Supported Platforms

* [macOS](./macOS/README.md)
* [Windows](./windows/README.md)

## What You Will Learn

* How Android App Bundle (`.aab`) signing works in CafeBazaar
* How to use `bundle-signer`
* How to generate `.bin` files
* How to automate the signing process on macOS and Windows
