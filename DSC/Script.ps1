param(
    [string]
    $subscriptionId = "1690b916-23f3-4f05-b9da-de926c56339c",

    [string]
    $resourceGroupName = "LC-CLAB-RG-DT",

    [string]
    $resourceGroupLocation,
################DSC1################################################
    [string]
    $VM_DSC_Path = "C:\Users\Kiryl_Baskaulau\Desktop\Azure\DSC\Azure\VM_DSC.json",

    [string]
    $VM_DSCPar_Path = "C:\Users\Kiryl_Baskaulau\Desktop\Azure\DSC\Azure\VM_DSCPar.json"
)
$ErrorActionPreference = "Stop"

# sign in
Write-Host "Logging in...";
Login-AzureRmAccount;

# select subscription
Write-Host "Selecting subscription '$subscriptionId'";
Select-AzureRmSubscription -SubscriptionID $subscriptionId;

#Create or check for existing resource group
$resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if (!$resourceGroup) {
    Write-Host "Resource group '$resourceGroupName' does not exist. To create a new resource group, please enter a location.";
    if (!$resourceGroupLocation) {
        $resourceGroupLocation = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'";
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation
}
else {
    Write-Host "Using existing resource group '$resourceGroupName'";
}

# Start the deployment DSC1
Write-Host "Starting deployment DSC1...";
if (Test-Path $VM_DSCPar_Path) {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $VM_DSC_Path -TemplateParameterFile $VM_DSCPar_Path;
}
else {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $VM_DSC_Path;
}
