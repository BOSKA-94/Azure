param(
    [string]
    $subscriptionId = "1690b916-23f3-4f05-b9da-de926c56339c",

    [string]
    $resourceGroupName = "LC-CLAB-RG-DT",

    [string]
    $resourceGroupLocation,
################DSC1################################################
    [string]
    $VM_DSC_Path = "C:\Users\Kiryl_Baskaulau\Desktop\Azure\DSC\Azure\DSC\VM_DSC.json",

    [string]
    $VM_DSCPar_Path = "C:\Users\Kiryl_Baskaulau\Desktop\Azure\DSC\Azure\DSC\VM_DSCPar.json"
)
$ErrorActionPreference = "Stop"

# sign in
Write-Host "Logging in...";
Login-AzureRmAccount;

# select subscription
Write-Host "Selecting subscription '$subscriptionId'";
Select-AzureRmSubscription -SubscriptionID $subscriptionId;

# Start the deployment DSC
Write-Host "Starting deployment DSC...";
if (Test-Path $VM_DSCPar_Path) {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $VM_DSC_Path -TemplateParameterFile $VM_DSCPar_Path;
}
else {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $VM_DSC_Path;
}
