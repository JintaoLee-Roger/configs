# configs

## Windows

### `powershell`

- `Microsoft.PowerShell_profile.ps1`
    * simulate linux's commands and add alias
    * edit: `vim $PROFILE`
    * update: `. $PROFILE`
    * This file is usually located at `C:\Users\<username>\Documents\WindowsPowerShell\`


### open-ssh settings, open powershell by **administrator**

1. install OpenSSH client
`Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0`

2. install OpenSSH server
`Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0`

3. verify
`Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'`
this will show:
```text
Name  : OpenSSH.Client~~~~0.0.1.0
State : Installed

Name  : OpenSSH.Server~~~~0.0.1.0
State : Installed
```

4. Start server
`Set-Service -Name sshd -StartupType 'Automatic'`

5. firewall
`if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) { Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..." New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 } else { Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists." }`
this will show:
```text
Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists.
```

6. [options] stop/start/restart
```powershell
# 1. stop
net stop sshd

# 2. start
net start  sshd

# 3. restart
Restart-Service -Name sshd
```

### SSH password-free login to Windows

1. generate ssh keys
`ssh-keygen -t rsa`

2. create `authorized_keys` file
```powershell
cd .ssh
New-Item authorized_keys
```

3. copy `id_rsa.pub` from other machine into `authorized_keys` 

4. change the right of `authorized_keys`: Right-click on the file, properties - Security - Advanced - click "Disable inheritance" - when prompted, select "Convert inherited permissions to explicit permissions for this object". Then delete the permission entries until only "SYSTEM", your own account, and "Administrators" are left. (In this step, I default to these three users, so I only need to modify it to disable inheritance)

5. restart server (powershell by **administrator**)
`Restart-Service -Name sshd`

6. modify the config file of sshd - `C:\ProgramData\ssh\sshd_config`
```yaml
# Make sure the following 3 items are not commented
PubkeyAuthentication yes
AuthorizedKeysFile	.ssh/authorized_keys
PasswordAuthentication no

# Make sure the following 2 items are commented out
# Match Group administrators
#   AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys
```

7. restart server (powershell by **administrator**)
`Restart-Service -Name sshd`


### set powershell as the default shell (useful when using ssh)

```powershell
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
```

