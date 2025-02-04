# GOS // Gaming Optimization Script
![2](https://github.com/user-attachments/assets/7c9a08cb-5b20-46ae-81af-c404b2ea79c8)




GOS is a comprehensive PowerShell script created for Windows users to streamline their gaming setup, enhance network performance, repair the Windows environment, and revert changes to default settings when needed.

![image](https://github.com/user-attachments/assets/0b7e0c99-4597-4d41-95e8-a9140e3cdf90)












# Launch command

## PowerShell
```ps1
iwr "https://raw.githubusercontent.com/ltx0101/GOS/refs/heads/main/GOS.ps1" -OutFile "GOS.ps1"; .\GOS.ps1
```
<details>
<summary>❗Error "Running Scripts is Disabled on this System❗"</summary>

### Run this command in PowerShell:

```ps1
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
```
</details>




## Features

The script provides a range of optimization and maintenance options:

1. **Enable Game Mode**  
   Activates settings to boost gaming performance by reducing background processes and optimizing system resources.


2. **Clean Windows**  
   Cleans unnecessary temp files, DirectX Cache, old Windows update files, etc.


3. **Optimize Network** 
   Optimizes network settings by modifying registry keys, disabling unnecessary and potentially performance-impacting features, tweaking TCP/IP configurations, disabling network adapter offload features and flushing the DNS cache. A system restart is required afterwards


4. **Repair Windows**  
   Runs a series of maintenance commands to repair the system environment, restore health, and clear unnecessary files. A system restart is recommended after this option to finalize repairs.


5. **Restore Default**  
   Re-enables any services or settings disabled during optimization, restoring the system to its default state. A restart is recommended afterward.


6. **Shortcut**  
   Creates a Desktop GOS Shortcut.

 
## Requirements

- Windows 10/11 operating system with Command Prompt (cmd) support.
- Administrator privileges are required to run certain commands effectively, such as system repairs and network modifications.
