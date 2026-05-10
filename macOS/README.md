# AAB → BIN Signing (macOS)

This guide explains how to sign an **Android App Bundle (.aab)** and generate a **.bin** file using **bundlesigner** with the provided AppleScript automation.

The script simplifies the process by guiding you through file selection, securely storing credentials in **macOS Keychain**, running the signing command, and producing the final `.bin` file automatically.

# Requirements

Before running the script, make sure you have the following:

- macOS
- Java installed
- bundlesigner tool
- An Android App Bundle (.aab)
- A keystore file (.jks or .keystore)

# Script

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

# How It Works
The script automates the entire signing process:

1. Prompts you to select the AAB file.
2. Prompts you to select the keystore file.
3. Requests the following information:
   Keystore Alias
   Keystore Password
   Alias Password
4. Passwords are stored securely in macOS Keychain.
5. The script runs the bundlesigner command in the background.
6. The .bin output is generated automatically.
7. Temporary folders created by bundlesigner are cleaned up.
8. The final .bin file remains in the output location.
   
After completion, you can reveal the result in Finder.
