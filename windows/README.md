# AAB → BIN Signing (Windows)

This guide explains how to generate a `.bin` file from an Android App Bundle (`.aab`) using CafeBazaar's `bundlesigner`.

The script simplifies the process by guiding you through file selection, securely storing credentials in **macOS Keychain**, running the signing command, and producing the final `.bin` file automatically.

## Requirements

- Java installed
- [bundlesigner.jar](https://github.com/cafebazaar/bundle-signer)
- A valid Android keystore
- PowerShell


## Troubleshooting

### PowerShell blocks running the script

On some Windows systems, PowerShell may prevent scripts from running due to the execution policy.

If you see an error similar to 

you can use one of the following options.

---

This runs the script without modifying your PowerShell configuration.
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```
