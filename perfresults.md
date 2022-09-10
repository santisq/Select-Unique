# Average Results

```powershell
Test                Average RelativeSpeed
----                ------- -------------
Select-Unique       2027.93 1x
Sort-Object -Unique 2895.26 1.43x
```

# Results per Test Run

```powershell
TestRun Test                TotalMilliseconds
------- ----                -----------------
      5 Select-Unique                 1721.21
      6 Select-Unique                 1888.72
     10 Select-Unique                 1936.01
      7 Select-Unique                 1955.06
      4 Select-Unique                 1987.50
      9 Select-Unique                 2091.29
      2 Select-Unique                 2092.39
      1 Select-Unique                 2161.01
      8 Select-Unique                 2181.42
      3 Select-Unique                 2264.70
      6 Sort-Object -Unique           2308.48
      7 Sort-Object -Unique           2487.59
      9 Sort-Object -Unique           2506.77
      5 Sort-Object -Unique           2521.78
      8 Sort-Object -Unique           2900.03
     10 Sort-Object -Unique           2906.09
      4 Sort-Object -Unique           2995.09
      2 Sort-Object -Unique           3200.70
      3 Sort-Object -Unique           3258.97
      1 Sort-Object -Unique           3867.10
```