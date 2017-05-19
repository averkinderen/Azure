#variables
$ResourgeGroupName = Read-Host "Please provide name of ResourgeGroup that will be used for saving the NSG logs"
$StorageAccountLogs = Read-Host "Please provide name of Storage Account that will be used for saving the NSG logs"
$retentionperiod = Read-Host "Please provide retention period"


#Login to the Azure Resource Management Account
#Login-AzureRmAccount
Register-AzureRmResourceProvider -ProviderNamespace Microsoft.Insights

#region Get Azure Subscriptions
$subscriptions = Get-AzureRmSubscription
$menu = @{}
for ($i = 1;$i -le $subscriptions.count; $i++) 
{
  Write-Host -Object "$i. $($subscriptions[$i-1].Name)"
  $menu.Add($i,($subscriptions[$i-1].Id))
}

[int]$ans = Read-Host -Prompt 'Enter selection'
$subscriptionID = $menu.Item($ans)
$subscription = Get-AzureRmSubscription -SubscriptionId $subscriptionID
Set-AzureRmContext -SubscriptionName $subscription.Name
#endregion

$subId = (Get-AzureRmContext).Subscription.Id
$subName = (Get-AzureRmContext).Subscription.Name

#regionGet Azure details details

$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $ResourgeGroupName -Name $StorageAccountLogs
$NWs = Get-AzurermNetworkWatcher -ResourceGroupName NetworkWatcherRg 

#endregion

Foreach($NW in $NWs){

$NWlocation = $NW.location
write-host "Looping trough $NWlocation" -ForegroundColor Yellow


#region Enable NSG Flow Logs

$nsgs = Get-AzureRmNetworkSecurityGroup | Where-Object {$_.Location -eq $NWlocation}

Foreach($nsg in $nsgs)
    {
    Get-AzureRmNetworkWatcherFlowLogStatus -NetworkWatcher $NW -TargetResourceId $nsg.Id
    Set-AzureRmNetworkWatcherConfigFlowLog -NetworkWatcher $NW -TargetResourceId $nsg.Id -StorageAccountId $storageAccount.Id -EnableFlowLog $true -EnableRetention $true -RetentionInDays $retentionperiod
    write-host "Diagnostics enabled for $nsg.Name " -BackgroundColor Green
    }

#endregion


}