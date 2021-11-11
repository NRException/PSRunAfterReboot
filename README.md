# PSRunAfterReboot

This project facilitates the installation of a powershell module that allows you to register commands / scripts to run on next reboot.
The underlying scheduled task removes itself automatically upon next reboot, however some management tools are included.

All included commands support -Verbose for further information.

Note: You are required to run any component / wrapper scripts as administrator!

## Getting Started

Download the included RebootJob.psm1
Run Import-Module .\RebootJob.psm1 to import the command library

### Prerequisites

```
Powershell V3 on target machine.
Deployment platform of your choice.
Administrative permission on your target machine.
```

### Deploying / Installing

This powershell module should be installed using the following commands:

```
Import-Module RebootJob.psm1
```

### Adding startup scripts

Add a powershell ScriptBlock to run at next reboot (Be aware of using unsanitised quotes!):

```
Add-RebootJob -PSScriptBlock {Get-Childitem 'C:\'}
```

Add a raw windows command to run at next reboot (you can also target exe's etc)

```
Add-RebootJob -Execute cmd.exe -Argument "/c"
```

### Get registered startup scripts

```
Get-RebootJob
```

### Remove registered startup scripts

```
Remove-RebootJob -TaskName "d4d84b40-6f91-4912-8db2-73bf5f55e261"
```

## Built With

* [Microsoft Powershell](https://code.visualstudio.com/) - The main IDE and RTE used.

## Contributing

Just submit your pulls!

## Authors

* **Cameron Huggett** - *Complete work* - [NRException](https://github.com/NRException)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
