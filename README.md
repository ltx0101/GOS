# GOS
## Gaming Optimization Script
![2](https://github.com/user-attachments/assets/7c9a08cb-5b20-46ae-81af-c404b2ea79c8)




GOS is a comprehensive batch script created for Windows users to streamline their gaming setup, enhance network performance, repair the Windows environment, and revert changes to default settings when needed.

![image](https://github.com/user-attachments/assets/bd4a63c7-0972-4873-ac74-845d796dadf2)









# Launch command

### PowerShell
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

2. **Network Optimize** 
   Optimizes network settings by modifying registry keys, disabling unnecessary and potentially performance-impacting features, tweaking TCP/IP configurations, disabling network adapter offload features and flushing the DNS cache. A system restart is required afterwards

3. **Repair Windows**  
   Runs a series of maintenance commands to repair the system environment, restore health, and clear unnecessary files. A system restart is recommended after this option to finalize repairs.

4. **Restore Default Settings**  
   Re-enables any services or settings disabled during optimization, restoring the system to its default state. A restart is recommended afterward.

5. **Create GOS Shortcut**  
   Creates a Desktop GOS Shortcut.
 
## Requirements

- Windows 10/11 operating system with Command Prompt (cmd) support.
- Administrator privileges are required to run certain commands effectively, such as system repairs and network modifications.
