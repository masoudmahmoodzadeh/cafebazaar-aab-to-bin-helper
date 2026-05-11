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

---

## Script

Paste the following AppleScript into **Script Editor** and run it.

```applescript
on getSecret(serviceName, promptText, isHidden)
  try
    return do shell script "security find-generic-password -a bundlesigner -s " & quoted form of serviceName & " -w"
  on error
    if isHidden then
      display dialog promptText default answer "" with hidden answer
    else
      display dialog promptText default answer ""
    end if
    
    set val to text returned of result
    
    do shell script "security add-generic-password -U -a bundlesigner -s " & quoted form of serviceName & " -w " & quoted form of val
    
    return val
  end try
end getSecret


on deleteSecret(serviceName)
  try
    do shell script "security delete-generic-password -a bundlesigner -s " & quoted form of serviceName
  end try
end deleteSecret


try
  
  -- Select files
  set aabFilePath to POSIX path of (choose file with prompt "Select the AAB file:" of type {"aab"})
  
  set ksFilePath to POSIX path of (choose file with prompt "Select the keystore file:" of type {"jks"})
  
  set jarFilePath to POSIX path of (choose file with prompt "Select bundlesigner.jar:" of type {"jar"})
  
  set saveFolder to POSIX path of (choose folder with prompt "Select output folder:")
  
  
  -- Build output names
  set aabName to name of (info for (POSIX file aabFilePath))
  set baseName to text 1 thru ((length of aabName) - 4) of aabName
  
  if saveFolder does not end with "/" then
    set saveFolder to saveFolder & "/"
  end if
  
  set tempFolder to saveFolder & baseName
  set outputFile to saveFolder & baseName & ".bin"
  
  
  -- Confirm overwrite
  try
    do shell script "test -f " & quoted form of outputFile
    
    set overwriteResult to button returned of (display dialog "The output file already exists." buttons {"Cancel", "Replace"} default button "Replace")
    
    if overwriteResult is "Cancel" then error number -128
    
    do shell script "rm -f " & quoted form of outputFile
    
  end try
  
  
  repeat
    
    set ksAlias to getSecret("ks_alias", "Enter keystore alias:", false)
    
    set ksPass to getSecret("ks_pass", "Enter keystore password:", true)
    
    set aliasPass to getSecret("alias_pass", "Enter key password:", true)
    
    
    set command to "java -jar " & quoted form of jarFilePath & " genbin -v" & ¬
      " --bundle " & quoted form of aabFilePath & ¬
      " --bin " & quoted form of tempFolder & ¬
      " --v2-signing-enabled true --v3-signing-enabled true" & ¬
      " --ks " & quoted form of ksFilePath & ¬
      " --ks-key-alias " & quoted form of ksAlias & ¬
      " --ks-pass pass:" & quoted form of ksPass & ¬
      " --key-pass pass:" & quoted form of aliasPass & ¬
      " --pass-encoding utf-8"
    
    
    try
      
      do shell script command
      
      exit repeat
      
      
    on error errMsg
      
      if errMsg contains "password" or errMsg contains "Keystore was tampered" then
        
        deleteSecret("ks_alias")
        deleteSecret("ks_pass")
        deleteSecret("alias_pass")
        
        display dialog "Incorrect keystore credentials. Please try again."
        
      else
        error errMsg
      end if
      
    end try
    
  end repeat
  
  
  -- Find generated BIN file
  set generatedBin to do shell script "find " & quoted form of tempFolder & " -name '*.bin' | head -n 1"
  
  
  -- Move BIN file to final destination
  do shell script "mv " & quoted form of generatedBin & " " & quoted form of outputFile
  
  
  -- Remove temporary folder
  do shell script "rm -rf " & quoted form of tempFolder
  
  
  -- Success dialog
  set dialogResult to display dialog "✅ Signing completed successfully." buttons {"Close", "Show File"} default button "Show File"
  
  
  if button returned of dialogResult is "Show File" then
    do shell script "open -R " & quoted form of outputFile
  end if
  
  
on error errMsg number errNum
  
  if errNum is -128 then
    
    display dialog "Operation cancelled."
    
  else
    
    display dialog "Error:" & return & return & errMsg
    
  end if
  
end try
```

