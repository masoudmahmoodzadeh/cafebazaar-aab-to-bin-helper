# AAB → BIN Signing (macOS)

This guide explains how to sign an Android App Bundle (`.aab`) and generate a `.bin` file using CafeBazaar's `bundle-signer` tool with AppleScript automation.

The script simplifies the entire process by:

* Guiding you through file selection
* Securely storing credentials in macOS Keychain
* Running the signing command automatically
* Generating the final `.bin` file

---

## Prerequisites

Before running the script, make sure you have:

* macOS
* Java installed
* `bundle-signer.jar`
* An Android App Bundle (`.aab`)
* A keystore file (`.jks` or `.keystore`)

---

## Script

Paste the following AppleScript into **Script Editor** and run it.

```applescript
...
```

---

## How It Works

The script automates the entire signing process:

1. Select the `.aab` file
2. Select the keystore file
3. Select the `bundle-signer.jar` file
4. Choose an output directory
5. Enter:

   * Keystore Alias
   * Keystore Password
   * Key Password
6. Credentials are securely stored in macOS Keychain
7. The signing process runs automatically
8. The final `.bin` file is generated
9. Temporary files are cleaned up automatically

After completion, the generated `.bin` file can be revealed in Finder.

---

## Usage

1. Open **Script Editor**
2. Create a new script
3. Paste the AppleScript code
4. Click **Run**

---

## Security

This script does not store passwords inside the source code or repository.

Instead, it uses macOS Keychain:

* Passwords are securely encrypted
* Credentials are stored only for the current user
* Secrets are never committed to the repository

If credentials become invalid, the script automatically removes them from Keychain and requests new values.

---

## Troubleshooting

### Java Not Found

Run:

```bash
java -version
```

If the command is not found, install Java:

* https://www.java.com

---

### bundle-signer Fails

Make sure:

* `bundle-signer.jar` exists
* The selected path is correct
* The keystore file is valid
* The keystore credentials are correct

---

### Wrong Password

If stored credentials become invalid:

1. Open **Keychain Access**
2. Search for entries related to `bundlesigner`
3. Delete the saved credentials

The script will request the credentials again on the next run.

---

### Permission Issues

If macOS blocks the script:

1. Open **System Settings**
2. Go to **Privacy & Security**
3. Allow **Script Editor** if prompted
