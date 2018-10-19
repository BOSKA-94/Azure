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
    $KeyVaultPath = "C:\Azure\Task9\KeyVault.json",

    [string]
    $KeyVaultParPath = "C:\Azure\Task9\KeyVaultPar.json",

    [string]
    $VM_VNetPath = "C:\Azure\Task9\Vm_VNet.json",

    [string]
    $AutomationPath = "C:\Azure\Task9\Automation.json",

    [string]
    $AutomationParPath = "C:\Azure\Task9\AutomationPar.json",

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
#Write-Host "Logging in...";
#Login-AzureRmAccount;

# select subscription
#Write-Host "Selecting subscription '$subscriptionId'";
#Select-AzureRmSubscription -SubscriptionID $subscriptionId;

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
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $KeyVaultPath -TemplateParameterFile $KeyVaultParPath;
Set-AzureKeyVaultSecret -VaultName 'Task9' -Name 'epam' -SecretValue $secretvalue


# Start the deployment Vm and VNet
Write-Host "Starting deployment VM and Vnet...";
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $Vm_VNetPath;


# Start the deployment Auromation Account
$password = Read-Host -AsSecureString
$JobGUID = [System.Guid]::NewGuid().toString()
New-AzureRmADAppCredential -ObjectId '60061f87-9334-4da4-82ac-1ee63154ac2f' -Password $password
Write-Host "Starting deployment Automation Account...";
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $AutomationPath -TemplateParameterFile $AutomationParPath  -Verbose -password $password -userName 'a2195fa2-c860-498b-b6a1-056fc1f7d517' -JobId $JobGUID 
