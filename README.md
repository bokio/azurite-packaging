# azurite-packaging
Some packaging tools around [Azurite](https://github.com/Azure/Azurite) for use on developer machines and build servers

## Setup

###Prerequisites
* Node XX (or newer)
* Yarn XX (or newer)
* Windows Powershell for the Task Scheduler scripts

###First time setup
`yarn install`

## Scripts
`yarn azurite` to start Azurite with default settings
`yarn addlogontask` to add (or just verify) a Windows task scheduler task that starts Azurite on logon for the current user

