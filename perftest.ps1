$numberOfObjects  = 100000
$numberOfTestRuns = 20
$numberOfProps    = 3
$randomLength     = 3

$ran     = [random]::new()
$charmap = ''
[char[]] ([char]'a'..[char]'f') | ForEach-Object { $charmap += $_ }

$properties = foreach($prop in 1..$numberOfProps) {
    "Prop$prop"
}

$dataSet = foreach($i in 0..$numberOfObjects) {
    $out = [ordered]@{}
    foreach($prop in $properties) {
        $junk = [char[]]::new($randomLength)
        for($i = 0; $i -lt $randomLength; $i++) {
            $junk[$i] = $charmap[$ran.Next($charmap.Length)]
        }
        $out[$prop] = [string]::new($junk)
    }

    [pscustomobject] $out
}

$tests = @{
    'Select-Unique' = {
        $dataSet | Select-Unique -On *
    }
    'Sort-Object -Unique' = {
        $dataSet | Sort-Object * -Unique
    }
}

$results = 1..$numberOfTestRuns | ForEach-Object {
    foreach($test in $tests.GetEnumerator()) {
        [pscustomobject]@{
            TestRun           = $_
            Test              = $test.Key
            TotalMilliseconds = [math]::Round((Measure-Command { & $test.Value }).TotalMilliseconds, 2)
        }
    }
} | Sort-Object TotalMilliseconds

$results | Group-Object Test | ForEach-Object {
    [pscustomobject]@{
        Test    = $_.Name
        Average = [Linq.Enumerable]::Average([double[]] $_.Group.TotalMilliseconds)
    }
} | Sort-Object Average