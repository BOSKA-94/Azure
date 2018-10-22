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
    $KeyVault_VNet = "https://raw.githubusercontent.com/BOSKA-94/Azure/master/Task9/KeyVault_VNet.json",

    [string]
    $AutomationPath = "C:\Azure\Task9\Automation.json",

    [string]
    $VM1 = "C:\Azure\Task9\VM.json",

    [string]
    $VMParPath1 = "C:\Azure\Task9\VMpar.json",

    [string]
    $VM2 = "C:\Azure\Task9\VM2.json",

    [string]
    $VMParPath2 = "C:\Azure\Task9\VMpar2.json",

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


# Start the deployment Key Vault and Vnet
Write-Host "Starting deployment Key Vault and Vnet...";
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $KeyVault_VNet;
Set-AzureKeyVaultSecret -VaultName 'Task9' -Name 'epam' -SecretValue $secretvalue


# Start the deployment Automation Account
$JobGUID = [System.Guid]::NewGuid().toString()
$AppRegestration = Get-AzureRmADApplication -DisplayName "Hanka"
$AppRegestration
$ObjectId = $AppRegestration.ObjectId
$AppliccationId = $AppRegestration.ApplicationId
New-AzureRmADAppCredential -ObjectId $ObjectId -Password $secretvalue
Write-Host "Starting deployment Automation Account...";
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $AutomationPath -password $secretvalue -userName $AppliccationId -JobId $JobGUID 
$automationAccountKey = ConvertTo-SecureString -AsPlainText ((Get-AzureRmAutomationAccount -ResourceGroupName $resourceGroupName | Get-AzureRmAutomationRegistrationInfo).PrimaryKey) -Force
$automationAccountUrl = ConvertTo-SecureString -AsPlainText ((Get-AzureRmAutomationAccount -ResourceGroupName $resourceGroupName | Get-AzureRmAutomationRegistrationInfo).Endpoint) -Force


#DSC
$AutomationAccount = (Get-AzureRmAutomationAccount).AutomationAccountName
Import-AzureRmAutomationDscConfiguration -SourcePath 'C:\Azure\Task9\TestConfig.ps1' -ResourceGroupName $resourceGroupName -AutomationAccountName $AutomationAccount -Published;
Start-AzureRmAutomationDscCompilationJob -ConfigurationName 'TestConfig' -ResourceGroupName $resourceGroupName -AutomationAccountName $AutomationAccount;


# Start the deployment Vm with ISS
Write-Host "Starting deployment Vm with ISS...";
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $VM1 -TemplateParameterFile $VMParPath1 -automationAccountKey $automationAccountKey -automationAccountUrl $automationAccountUrl;

# Start the deployment Vm without ISS
Write-Host "Starting deployment Vm without ISS...";
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $VM2 -TemplateParameterFile $VMParPath2 -automationAccountKey $automationAccountKey -automationAccountUrl $automationAccountUrl;

