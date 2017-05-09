#Assumptions

#The script assumes that you have performed the following work:

#Configured ExpressRoute with a connection to your primary Virtual Network
#Added a /28 subnet into your target Virtual Network with the name “GatewaySubnet”
#Created a Virtual Network Gateway in your target Virtual Network of type “ExpressRoute”


#What the script does

#The PowerShell script below performs the following steps:

#Defines parameters for:
#Source – The primary subscription and Virtual Network that ExpressRoute is configured to communicate with
#Target – The subscription and Virtual Network that we would like to add a connection to
#Selects the source subscription
#Gets information about the existing circuit into a variable
#Creates an authorisation for a new connection and places the information into a variable
#Refreshes information about the circuit into the corresponding variable
#Selects the target subscription
#Gets information about the target gateway
#Creates a new Network Gateway connection









# Define Source Parameters
$SourceSubscriptionName='HWAN Sub 1 - Parent'
$SourceResourceGroupName='AZEH-MSS-RGP-DV'
 
$CircuitName='AZEH-GENERAL'
 
$AuthorisationName='AZEH-GENERAL-EDW'
 
# Define Target Parameters
$TargetResourceGroupName='AZEH-EDW-RGP-DV'
$TargetSubscriptionName='HWAN Sub 2 - Child'
$TargetGatewayName='AZEH-EDW-VGW-DV'
$TargetConnectionName='AZEH-EH-EDW-DV '
$TargetLocation='Australia East'
# End editable parameters
#Login-AzureRmAccount
 
# Select Source Subscription
Select-AzureRmSubscription `
-SubscriptionName $SourceSubscriptionName
 
Write-Host 'Getting initial variables'
# Get information about existing circuit
$Circuit = Get-AzureRmExpressRouteCircuit `
-Name $CircuitName `
-ResourceGroupName $SourceResourceGroupName
 
Write-Host 'Adding Authorisation'
# Add a authorisation request to the ExpressRoute Circuit
Add-AzureRmExpressRouteCircuitAuthorization `
-ExpressRouteCircuit $circuit `
-Name $AuthorisationName `
-Verbose
# Update the Circuit with the authorisation information
Set-AzureRmExpressRouteCircuit `
-ExpressRouteCircuit $circuit `
-Verbose
 
# Re-request information about the circuit
$circuit = Get-AzureRmExpressRouteCircuit `
-Name $CircuitName `
-ResourceGroupName $SourceResourceGroupName `
-Verbose
 
# Request information about the new authorisation
$auth1 = Get-AzureRmExpressRouteCircuitAuthorization `
-ExpressRouteCircuit $circuit `
-Name $AuthorisationName `
-Verbose
 
# Select Target Subscription
Select-AzureRmSubscription `
-SubscriptionName $TargetSubscriptionName
 
# Get information about the Target Gateway
$TargetGW = Get-AzureRmVirtualNetworkGateway `
-Name $TargetGatewayName `
-ResourceGroupName $TargetResourceGroupName
 
Write-Host 'Redeeming Key'
 
$connection = New-AzureRmVirtualNetworkGatewayConnection `
-Name $targetConnectionName `
-ResourceGroupName $TargetResourceGroupName `
-Location $TargetLocation `
-VirtualNetworkGateway1 $TargetGW `
-PeerId $Circuit.Id `
-ConnectionType ExpressRoute `
-AuthorizationKey $auth1.AuthorizationKey `
-Verbose