# rdum

This is a shell script which provides an indication of available updates on a dpkg system. It shows status with an icon in the system tray which indicates if any updates are available and whether any are security updates. The system tray icon tooltip says how many updates are available. Right clicking on the system tray icon shows a menu allowing the updates to be installed. Other menu options are to show list of available updates, force a check for new updates and to refresh the icon (in case background check has found updates). The icon refreshes it state every 10 minutes but depends on a backgournd task to check for new updates automatically.

Depends on:
* yud - Provides the system tray interface
* xterm - Displays apt commands
* awk - Decoding, etc.

This is a simple implementation of the version of the update notifier that I feel was optimal. As a desktop / GUI user I want to know when updates are available, what type of update they are (security / normal) and be able to simply install the updates. There areother  update notifiers available but script uses very few resources with few dependencies.

I would prefer to remove the xterm dependency but for now it serves a purpose.
