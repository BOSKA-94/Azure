param(
    [string]
    $subscriptionId = "1690b916-23f3-4f05-b9da-de926c56339c",

    [string]
    $resourceGroupName = "LC-CLAB-RG-DT",

    ################Storage Account################################################
    [string]
    $StoragePath = "C:\Users\Kiryl_Baskaulau\Desktop\Azure-1\DSC\VM_DSC.json",

    [string]
    $StorageParPath = "C:\Users\Kiryl_Baskaulau\Desktop\Azure-1\DSC\VM_DSCPar.json",

################DSC1################################################
    [string]
    $VM_DSC_Path = "C:\Users\Kiryl_Baskaulau\Desktop\Azure-1\DSC\VM_DSC.json",

    [string]
    $VM_DSCPar_Path = "C:\Users\Kiryl_Baskaulau\Desktop\Azure-1\DSC\VM_DSCPar.json"
)

$ErrorActionPreference = "Stop"

# sign in
Write-Host "Logging in...";
Login-AzAccount;

# select subscription
Write-Host "Selecting subscription '$subscriptionId'";
Select-AzSubscription -SubscriptionID $subscriptionId;

# Start the deployment Storage account
Write-Host "Starting deployment Storage account...";
if (Test-Path $StorageParPath) {
    New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $StoragePath -TemplateParameterFile $StorageParPath;
}
else {
    New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $StoragePath;
}

# Start the deployment DSC
Write-Host "Starting deployment DSC...";
if (Test-Path $VM_DSCPar_Path) {
    New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $VM_DSC_Path -TemplateParameterFile $VM_DSCPar_Path;
}
else {
    New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $VM_DSC_Path;
}
