# Select-Unique

## Description

PowerShell function that helps getting unique objects by one or multiple properties. Similar to [`Sort-Object -Unique`](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/sort-object?view=powershell-7.2) but without any sorting and a bit faster.

## Parameters

| Parameter | Description |
| --- | --- |
| `InputObject` | The function is intented to work taking input from pipeline, this parameter bounds from pipeline and should not be used manually.
| `On` | Property names used to filter for unique values on the objects. This parameter allows wildcards. See [`PSMemberInfoCollection<T>.Match` Method](https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.psmemberinfocollection-1.match?view=powershellsdk-7.0.0#system-management-automation-psmemberinfocollection-1-match(system-string)). |
| `CaseSensitive` | Specifies if the filtering should be case sensitive when this switch is activated. |
| `Select` | Similar usage as [`Select-Object`](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/select-object?view=powershell-7.2). Allows the use of _calculated properties_. |

## Examples

- Get unique processes on `ProcessName` property:

```powershell
Get-Process | Select-Unique -On ProcessName
```

- Get unique processes on `ProcessName` and `Id` properties:

```powershell
Get-Process | Select-Unique -On ProcessName, Id
```

- Get unique processes on any property __starting with__ `Process` and `Id` property:

```powershell
Get-Process | Select-Unique -On Process*, Id
```

- Get unique processes on `ProcessName` property and select property `ProcessName` as `Name`:

   - <u>Note</u>: for _calculated properties_, the hashtable __Keys__ will be the new property name and the __Value__ can be a string representating the original object property name or a _expression_ ([`ScriptBlock`](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_script_blocks?view=powershell-7.2)). The example after this one demonstrates the use of a `ScriptBlock` in a calculated property.

```powershell
Get-Process | Select-Unique -On ProcessName -Select @{ Name = 'ProcessName' }
```

- Get unique processes on `Id` property and select property `ProcessName` as `Name` and property `WorkingSet64` using a _calculated expression_ to convert the values from _bytes to megabytes_:

```powershell
Get-Process | Select-Unique -On Id -Select @(
    @{ Name = 'ProcessName' }
    @{ MemoryUsage = { [string]::Format('{0:N0} Mb', ($_.WorkingSet64 / 1Mb)) }}
)
```

- `-CaseSensitive` filtering:

```powershell
$test = @(
    [pscustomobject]@{ foo = 'Hello'; bar = 'World' }
    [pscustomobject]@{ foo = 'Hello'; bar = 'World' }
    [pscustomobject]@{ foo = 'Hello'; bar = 'WORLD' }
    [pscustomobject]@{ foo = 'Hello'; bar = 'WORLD' }
    [pscustomobject]@{ foo = 'HELLO'; bar = 'WORLD' }
    [pscustomobject]@{ foo = 'HELLO'; bar = 'WORLD' }
)

$test | Select-Unique -On * -CaseSensitive

foo   bar
---   ---
Hello World
Hello WORLD
HELLO WORLD

$test | Select-Unique -On *

foo   bar
---   ---
Hello World
```