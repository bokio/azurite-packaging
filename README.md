# azurite-packaging
This project contains some minimal supporting tools around [Azurite](https://github.com/Azure/Azurite) for use on developer machines and build servers.

## Setup

### Prerequisites
* Node XX (or newer)
* Yarn XX (or newer)
* Windows Powershell 4 (comes pre-installed on modern Windows systems)

### First time setup

    yarn install

## Scripts

* `yarn azurite` to start Azurite with default settings
* `yarn addlogontask` to add (if missing) a Windows task scheduler task that starts Azurite on logon for the current user. Will self-elevate (UAC) for administrative access.
* `yarn addstartuptask` to add (if missing) a Windows task scheduler task that starts Azurite on system startup. Will self-elevate (UAC) for administrative access.
* `yarn addlogonorstartuptask` to add (if missing) a Windows task scheduler task that starts Azurite on system startup OR logon by the current user. Will self-elevate (UAC) for administrative access.
* `yarn removetask` to remove the Windows task scheduler task that any of the "add" scripts added
