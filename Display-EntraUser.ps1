Connect-MgGraph -Scopes "User.Read.All" -NoWelcome

$users = Get-MgUser -All -Property DisplayName,CompanyName,Department,JobTitle,Mail,MobilePhone |
    Where-Object { $_.CompanyName -and $_.Department } |
    Sort-Object CompanyName, Department, DisplayName

$currentCompany = $null
$currentDept = $null

foreach ($u in $users) {
    if ($u.CompanyName -ne $currentCompany) {
        $currentCompany = $u.CompanyName
        $currentDept = $null
        Write-Host "`n[$currentCompany]"
    }
    if ($u.Department -ne $currentDept) {
        $currentDept = $u.Department
        Write-Host "  [$currentDept]"
    }
    Write-Host "    $($u.DisplayName), $($u.JobTitle), $($u.Mail), $($u.MobilePhone)"
}
