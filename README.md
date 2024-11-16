# GOS
Gaming Optimization Script

GOS is a comprehensive batch script created for Windows users to streamline their gaming setup, enhance network performance, repair the Windows environment, and revert changes to default settings when needed. This script also offers convenient options to install the Windows Package Manager (winget) and perform system cleanup.
![GOS](https://github.com/user-attachments/assets/41bce2c9-08f8-420d-95ae-63a1702abfa8)

# Launch command

### PowerShell
```ps1
iwr "https://raw.githubusercontent.com/ltx0101/GOS/refs/heads/main/GOS.bat" -OutFile "GOS.bat"; .\GOS.bat
```
### CMD
```ps1
PowerShell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/ltx0101/GOS/refs/heads/main/GOS.bat' -OutFile 'GOS.bat'; Start-Process -FilePath 'GOS.bat'"
```
## Features

The script provides a range of optimization and maintenance options:

1. **Enable Game Mode**  
   Activates settings to boost gaming performance by reducing background processes and optimizing system resources.

2. **Game Mode + Network Optimization**  
   Extends Game Mode with network optimizations, ideal for players who experience network lag or connection issues during gameplay.

3. **Repair Windows**  
   Runs a series of maintenance commands to repair the system environment, restore health, and clear unnecessary files. A system restart is recommended after this option to finalize repairs.

4. **Restore Default Settings**  
   Re-enables any services or settings disabled during optimization, restoring the system to its default state. A restart is recommended afterward.

5. **Install Winget**  
   Checks for and installs the Windows Package Manager (winget), if not already present, allowing for easy installation and upgrading of Windows applications.

6. **Exit**  
   Exits the script without making changes.

## Requirements

- Windows 10/11 operating system with Command Prompt (cmd) support.
- Administrator privileges are required to run certain commands effectively, such as system repairs and network modifications.
