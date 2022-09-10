$numberOfObjects  = 100000
$numberOfTestRuns = 10
$numberOfProps    = 4
$randomLength     = 3

$ran     = [random]::new()
$charmap = ''
[char[]] ([char]'a'..[char]'d') | ForEach-Object { $charmap += $_ }

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
        ($dataSet | Select-Unique -On *).Count
    }
    'Sort-Object -Unique' = {
        ($dataSet | Sort-Object * -Unique).Count
    }
}

$allTests = 1..$numberOfTestRuns | ForEach-Object {
    foreach($test in $tests.GetEnumerator()) {
        [pscustomobject]@{
            TestRun           = $_
            Test              = $test.Key
            TotalMilliseconds = [math]::Round((Measure-Command { & $test.Value }).TotalMilliseconds, 2)
        }
    }
} | Sort-Object TotalMilliseconds

$average = $allTests | Group-Object Test | ForEach-Object {
    [pscustomobject]@{
        Test          = $_.Name
        Average       = [Linq.Enumerable]::Average([double[]] $_.Group.TotalMilliseconds)
        RelativeSpeed = 0
    }
} | Sort-Object Average

for($i = 0; $i -lt $average.Count; $i++) {
    if($i) {
        $average[$i].RelativeSpeed = ($average[$i].Average / $average[0].Average).ToString('N2') + 'x'
        return
    }
    $average[$i].RelativeSpeed = '1x'
}

$allTests | Format-Table -AutoSize
$average  | Format-Table -AutoSize