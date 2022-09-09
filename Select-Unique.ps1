using namespace System.Collections.Generic
using namespace System.Collections

function Select-Unique {
    [CmdletBinding()]
    [alias('unique')]
    param(
        [parameter(Mandatory, ValueFromPipeline, DontShow)]
        [object] $InputObject,

        [parameter(Position = 0)]
        [string[]] $On = '*',

        [parameter()]
        [switch] $CaseSensitive,

        [parameter()]
        [object[]] $Select
    )

    begin {
        class PSCustomObjectComparer : IEqualityComparer[object] {
            [CultureAwareComparer] $Comparer = [StringComparer]::InvariantCultureIgnoreCase

            PSCustomObjectComparer() { }
            PSCustomObjectComparer([CultureAwareComparer] $Comparer) {
                $this.Comparer = $Comparer
            }

            [bool] Equals([object] $xObject, [object] $yObject) {
                if(-not $xObject.Count.Equals($yObject.Count)) {
                    return $false
                }

                return ([IStructuralEquatable] $xObject).Equals($yObject, $this.Comparer)
            }

            [int] GetHashCode([object] $xObject) {
                return ([IStructuralEquatable] $xObject).GetHashCode($this.Comparer)
            }
        }

        $comparer = [PScustomObjectComparer]::new()
        if($CaseSensitive.IsPresent) {
            $comparer.Comparer = [StringComparer]::InvariantCulture
        }

        $hasher         = [HashSet[object]]::new($comparer)
        $wildCardSearch = $false
        $properties     = [List[string]]::new()

        foreach($item in $On) {
            if($item.Contains('*')) {
                $wildCardSearch = $true
                continue
            }
            $properties.Add($item)
        }
    }

    process {
        if($wildCardSearch) {
            foreach($item in $On) {
                if(-not $item.Contains('*')) {
                    continue
                }
                foreach($property in $InputObject.PSObject.Properties.Match($item).Name) {
                    $properties.Add($property)
                }
            }
            $wildCardSearch = $false
        }

        $values = foreach($property in $properties) {
            $InputObject.$property
        }

        if(-not $hasher.Add($values)) {
            return
        }

        if(-not $PSBoundParameters.ContainsKey('Select')) {
            return $InputObject
        }

        $out = [ordered]@{}
        foreach($item in $Select) {
            if($item -isnot [hashtable]) {
                $pair = $InputObject.PSObject.Properties.Item($item)
                $out[$pair.Name] = $pair.Value
                continue
            }
            foreach($key in $item.PSBase.Keys) {
                if($item[$key] -is [scriptblock]) {
                    $out[$key] = $InputObject | & $item[$key]
                    break
                }

                $out[$key] = $InputObject.($item[$key])
            }
        }
        [pscustomobject] $out
    }
}