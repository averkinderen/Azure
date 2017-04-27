$policyName = Read-Host "Specify the name of the policy";
$policyDescription = Read-Host "Specify the description of the policy"
$policyFile = Read-Host "Path to json policy file";

#Login to the Azure Resource Management Account
Login-AzureRmAccount

#region Get Azure Subscriptions
$subscriptions = Get-AzureRmSubscription
$menu = @{}
for ($i = 1;$i -le $subscriptions.count; $i++) 
{
  Write-Host -Object "$i. $($subscriptions[$i-1].SubscriptionName)"
  $menu.Add($i,($subscriptions[$i-1].SubscriptionId))
}

[int]$ans = Read-Host -Prompt 'Enter selection'
$subscriptionID = $menu.Item($ans)
$subscription = Get-AzureRmSubscription -SubscriptionId $subscriptionID
Set-AzureRmContext -SubscriptionName $subscription.SubscriptionName
#endregion

$subId = (Get-AzureRmContext).Subscription.SubscriptionId
$subName = (Get-AzureRmContext).Subscription.SubscriptionName

Write-host "Policy is applied to the resource group: $resourceGroup in subscription: $subName"
$policy = New-AzureRmPolicyDefinition -Name $policyName -Description $policyDescription -Policy $policyFile;

Write-host "Sleeping for 10 seconds"
Start-Sleep -s 10
#Assign the Azure Policy
New-AzureRmPolicyAssignment -Name $policyName -PolicyDefinition $policy -Scope "/subscriptions/$subid"
