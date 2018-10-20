param(
    [string]
    $subscriptionId = "4712ca89-5e08-4d78-9f70-35f10bec642b",

    [string]
    $resourceGroupName = "Minsk",

    [string]
    $resourceGroupLocation,

    [string]
    $deploymentName = "Task9",

    [string]
    $KeyVaultPath = "https://raw.githubusercontent.com/BOSKA-94/Azure/master/Task9/KeyVault.json",

    [string]
    $KeyVaultParPath = "https://raw.githubusercontent.com/BOSKA-94/Azure/master/Task9/KeyVaultPar.json",

    [string]
    $VM_VNetPath = "https://raw.githubusercontent.com/BOSKA-94/Azure/master/Task9/Vm_VNet.json",

    [string]
    $AutomationPath = "https://raw.githubusercontent.com/BOSKA-94/Azure/master/Task9/Automation.json",

    [string]
    $AutomationParPath = "https://raw.githubusercontent.com/BOSKA-94/Azure/master/Task9/AutomationPar.json",

    [Parameter(Mandatory = $True)]
    [SecureString]
    $secretvalue
)
Function RegisterRP {
    Param(
        [string]$ResourceProviderNamespace
    )

    Write-Host "Registering resource provider '$ResourceProviderNamespace'";
    Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace;
}

$ErrorActionPreference = "Stop"

# sign in
Write-Host "Logging in...";
Login-AzureRmAccount;

# select subscription
Write-Host "Selecting subscription '$subscriptionId'";

Select-AzureRmSubscription -SubscriptionID $subscriptionId;

# Register RPs
$resourceProviders = @("microsoft.keyvault");
if ($resourceProviders.length) {
    Write-Host "Registering resource providers"
    foreach ($resourceProvider in $resourceProviders) {
        RegisterRP($resourceProvider);
    }
}

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


# Start the deployment Key Vault
Write-Host "Starting deployment Key Vault...";
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $KeyVaultPath -TemplateParameterUri $KeyVaultParPath;
Set-AzureKeyVaultSecret -VaultName 'Task9' -Name 'epam' -SecretValue $secretvalue


# Start the deployment Vm and VNet
Write-Host "Starting deployment VM and Vnet...";
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $Vm_VNetPath;


# Start the deployment Automation Account
$password = Read-Host "Password for automation account" -AsSecureString
$JobGUID = [System.Guid]::NewGuid().toString()
$AppRegestration = Get-AzureRmADApplication -DisplayName "Hanka"
$AppRegestration
$ObjectId = $AppRegestration.ObjectId
$AppliccationId = $AppRegestration.ApplicationId
New-AzureRmADAppCredential -ObjectId $ObjectId -Password $password
Write-Host "Starting deployment Automation Account...";
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $AutomationPath -TemplateParameterUri $AutomationParPath -password $password -userName $AppliccationId -JobId $JobGUID 
