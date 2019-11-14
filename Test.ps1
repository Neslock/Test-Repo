Get-NaVol | Select @{Name="Vol Name";Expression={$_.name}}, @{Name="Vol Capacity (GB)";Expression={[math]::Round([decimal]$_.SizeTotal/1gb,2)}}, @{Name="Vol Used (GB)";Expression={[math]::Round([decimal]$_.SizeUsed/1gb,2)}} | Format-Table -auto 

[decimal]$volTotalCapacity = 0
[decimal]$volTotalUsed = 0

ForEach ($vol in Get-NaVol){
	$volName = $_.name
	[decimal]$volCapacity = @({[math]::Round([decimal]$_.SizeTotal/1gb,2)})
	[decimal]$volUsed = @({[math]::Round([decimal]$_.SizeUsed/1gb,2)})

	Write-Host $volName, $volCapacity, $volUsed

	# Sums
	$volTotalCapacity = $volTotalCapacity + $volCapacity
	$volTotalUsed = $volTotalUsed + $volUsed
}

Write-Host $volTotalCapacity, $volTotalUsed
