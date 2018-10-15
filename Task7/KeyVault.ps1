param(
 [string]
 $subscriptionId = "4712ca89-5e08-4d78-9f70-35f10bec642b",

 [string]
 $resourceGroupName = "Minsk",

 [string]
 $resourceGroupLocation,

 [string]
 $deploymentName = "Task7",

 [string]
 $KeyVaultPath = "C:\Azure\Task7\KeyVault.json",

 [string]
 $KeyVaultParPath = "C:\Azure\Task7\KeyVaultPar.json",

 [string]
 $StoragePath = "C:\Azure\Task7\Storage.json",

 [string]
 $StorageParPath = "C:\Azure\Task7\StoragePar.json",

 [string]
 $mainPath = "C:\Azure\Task7\main.json",

 [Parameter(Mandatory=$True)]
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
if($resourceProviders.length) {
    Write-Host "Registering resource providers"
    foreach($resourceProvider in $resourceProviders) {
        RegisterRP($resourceProvider);
    }
}

#Create or check for existing resource group
$resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if(!$resourceGroup)
{
    Write-Host "Resource group '$resourceGroupName' does not exist. To create a new resource group, please enter a location.";
    if(!$resourceGroupLocation) {
        $resourceGroupLocation = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'";
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation
}
else{
    Write-Host "Using existing resource group '$resourceGroupName'";
}

# Start the deployment Key Vault
Write-Host "Starting deployment Key Vault...";
if(Test-Path $KeyVaultParPath) {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $KeyVaultPath -TemplateParameterFile $KeyVaultParPath;
} else {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $KeyVaultPath;
}
Set-AzureKeyVaultSecret -VaultName 'Task7' -Name 'DevOps' -SecretValue $secretvalue

# Start the deployment Storage account
Write-Host "Starting deployment Storage account...";
if(Test-Path $StorageParPath) {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $StoragePath -TemplateParameterFile $StorageParPath;
} else {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $StoragePath;
}

# Start the deployment VM and Recovery service
Write-Host "Starting deployment VM and Recovery service...";
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $mainPath;

# Backup VM
Get-AzureRmRecoveryServicesVault -Name "RecoveryTask7" | Set-AzureRmRecoveryServicesVaultContext
$schPol = Get-AzureRmRecoveryServicesBackupSchedulePolicyObject -WorkloadType "AzureVM"
$retPol = Get-AzureRmRecoveryServicesBackupRetentionPolicyObject -WorkloadType "AzureVM"
New-AzureRmRecoveryServicesBackupProtectionPolicy -Name "BackupPolicy" -WorkloadType "AzureVM" -RetentionPolicy $retPol -SchedulePolicy $schPol
$pol = Get-AzureRmRecoveryServicesBackupProtectionPolicy -Name "BackupPolicy"
Enable-AzureRmRecoveryServicesBackupProtection -Policy $pol -Name "comp1" -ResourceGroupName "Minsk"