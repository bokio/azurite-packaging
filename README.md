# azurite-packaging
This project contains some minimal supporting tools around [Azurite](https://github.com/Azure/Azurite) for use on developer machines and build servers if you can't use the linux docker container packaging, which is preferred.

## Setup

### Prerequisites
* Node XX (or newer)
* Yarn XX (or newer)
* Windows Powershell 4 (or newer - comes pre-installed on modern Windows systems)

### Setup

    yarn install

## Scripts

* `yarn azurite` to start Azurite in the current console with default settings
* `yarn addlogontask` to add (if missing) a Windows task scheduler task that starts Azurite on logon for the current user. Will self-elevate (UAC) for administrative access.
* `yarn addstartuptask` to add (if missing) a Windows task scheduler task that starts Azurite on system startup. Will self-elevate (UAC) for administrative access.
* `yarn addlogonorstartuptask` to add (if missing) a Windows task scheduler task that starts Azurite on system startup OR logon by the current user. Will self-elevate (UAC) for administrative access.
* `yarn removetask` to remove the Windows task scheduler task that any of the "add" scripts added
* `yarn start` to start azurite in a new process in a hidden window and save the process id in a pidfile. Optional parameter is -StartPort NN to set the three port numbers
* `yarn start-visible` to start azurite in a new process in a visible window and save the process id in a pidfile
* `yarn stop` to stop azurite given a process id in the pidfile created by `start`. The pidfile is removed.

## Noteworthy
Windows task scheduler doesn't stop the process properly since it doesn't stop the child processes started from the cmd process that the azurite launcher is executed in,
so the tasks created are mostly just good for ensuring that azurite is launched.
For more control, use the start and stop commands.
