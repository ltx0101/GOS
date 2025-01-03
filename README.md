# GOS
## Gaming Optimization Script
![2](https://github.com/user-attachments/assets/7c9a08cb-5b20-46ae-81af-c404b2ea79c8)




GOS is a comprehensive batch script created for Windows users to streamline their gaming setup, enhance network performance, repair the Windows environment, and revert changes to default settings when needed. This script also offers convenient options to install the Windows Package Manager (winget) and perform system cleanup.

![Capture](https://github.com/user-attachments/assets/81613314-6525-4d0b-b06a-cb5fa56b4a8f)








# Launch command (Stable)

### PowerShell
```ps1
iwr "https://raw.githubusercontent.com/ltx0101/GOS/refs/heads/main/GOS.bat" -OutFile "GOS.bat"; .\GOS.bat
```
### CMD
```ps1
PowerShell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/ltx0101/GOS/refs/heads/main/GOS.bat' -OutFile 'GOS.bat'; Start-Process -FilePath 'GOS.bat'"
```
# Launch command (Beta) **(NOT RECOMMENDED)**

### PowerShell
```ps1
iwr "https://raw.githubusercontent.com/ltx0101/GOS/refs/heads/main/GOSbeta.bat" -OutFile "GOSbeta.bat"; .\GOSbeta.bat
```



## Features

The script provides a range of optimization and maintenance options:

1. **Enable Game Mode**  
   Activates settings to boost gaming performance by reducing background processes and optimizing system resources.

2. **Game Mode + Network Fix**  
   Extends Game Mode with network optimizations, ideal for players who experience network lag or connection issues during gameplay.

3. **Repair Windows**  
   Runs a series of maintenance commands to repair the system environment, restore health, and clear unnecessary files. A system restart is recommended after this option to finalize repairs.

4. **Restore Default Settings**  
   Re-enables any services or settings disabled during optimization, restoring the system to its default state. A restart is recommended afterward.

5. **Network Optimize**  
   Optimizes network settings by modifying registry keys, disabling unnecessary and potentially performance-impacting features, tweaking TCP/IP configurations, disabling network adapter offload features and flushing the DNS cache. A system restart is required afterwards

6. **Enable Windows Update**
   Start the "Windows Update" service, it also starts a predefined list of other services and configures specific services to start on demand. A restart is recommended afterward.

7. **Create GOS Shortcut**  
   Creates a Desktop GOS Shortcut.
 
8. **Winget Installer**  
   Installs Winget, then prompts the user to update all apps using Winget in a separate PowerShell window.
   
9. **Exit**  
   Exits the script without making any changes.
## Requirements

- Windows 10/11 operating system with Command Prompt (cmd) support.
- Administrator privileges are required to run certain commands effectively, such as system repairs and network modifications.
