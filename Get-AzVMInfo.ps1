#==============================================================================
# スクリプト名 : Get-AzVMInfo.ps1
# 概　　　要   : 指定したリージョン内のリソースグループと仮想マシンの情報を一覧表示する
# パラメータ   : -Location  対象リージョン (既定値: japaneast)
# 出　　　力   : テナント名・サブスクリプション名、RG 一覧、VM 名・サイズ・電源状態
#==============================================================================

[CmdletBinding()]
Param(
    [String]$Location = "japaneast"
)

# 資格情報、コンテキストをクリアし、Azure に接続
Clear-AzContext
$AzProfile = Connect-AzAccount

# 現在のコンテキスト情報を取り出しサブスクリプション名、テナントを取り出し
$SubscriptionName = $AzProfile.Context.Subscription.Name
$TenantId = $AzProfile.Context.Tenant.Id
$Tenant = Get-AzTenant -TenantId $TenantId
$TenantName = $Tenant.Name

# テナント名、サブスクリプション名を表示
Write-Host "■テナント：`t`t $TenantName"
Write-Host "■サブスクリプション：`t $SubscriptionName"

# 指定されたローケーションのリソースグループを取り出し
$ResourceGroups = Get-AzResourceGroup -Location $Location | Sort-Object ResourceGroupName

# リソースグループがなければ、メッセージを表示して終了
if ($null -eq $ResourceGroups -or $ResourceGroups.Count -eq 0) {
    Write-Host "指定されたロケーションには、リソースグループは存在しません。"
    exit
}
Write-Host "■$Location のリソースグループ一覧:"
[int]$ResourceGroupIndex = 1
# リソースグループの数だけ仮想マシンを取り出す
foreach ($RG in $ResourceGroups) {

    $RGName = $RG.ResourceGroupName
    $AzVMs = Get-AzVM -ResourceGroupName $RGName -Status
    
    Write-Host "`t $ResourceGroupIndex) $RGName リソースグループ"
    # リソースグループに仮想マシンが存在しない場合
    if ($null -eq $AzVMs -or $AzVMs.Count -eq 0) {
        Write-Host "`t`t・仮想マシンは存在しません。"
    # リソースグループに仮想マシンが存在したら仮想マシンの数だけ情報を表示
    } else {
        foreach ($VM in $AzVMs) {
            $VMName = $VM.Name
            $PowerState = $VM.PowerState
            $VMSize = $VM.HardwareProfile.VmSize
            Write-Host "`t`t・仮想マシン名:`t  $VMName"
            Write-Host "`t`t`t(サイズ: $VMSize  状態: $PowerState )"
        }
    }
    $ResourceGroupIndex++  
}