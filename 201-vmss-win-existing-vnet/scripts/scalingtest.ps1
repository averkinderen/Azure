#################################################
# Author: Alexandre Verkinderen
# Company: cubesys
# date: 05/09/2017
################################################


Login-AzureRmAccount

#region variables
$rgName = "MTPASA"
$scalesetename = "mtpasass7"
$vmss = Get-AzureRmVmss -ResourceGroupName $rgName -VMScaleSetName $scalesetename
$csv = "C:\Dropbox\My Documents\OneDrive - cubesys\AEMO\aemo.csv"
#endregion

$capacity = import-csv $csv

$vmss.sku.capacity = $capacity.servers
Update-AzureRmVmss -ResourceGroupName $rgName -Name "scale set name" -VirtualMachineScaleSet $vmss 