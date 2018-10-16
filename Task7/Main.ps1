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
    $KeyVaultPath = "https://raw.githubusercontent.com/BOSKA-94/Azure/master/Task7/KeyVault.json",

    [string]
    $KeyVaultParPath = "https://raw.githubusercontent.com/BOSKA-94/Azure/master/Task7/KeyVaultPar.json",

    [string]
    $StoragePath = "https://raw.githubusercontent.com/BOSKA-94/Azure/master/Task7/Storage.json",

    [string]
    $StorageParPath = "https://raw.githubusercontent.com/BOSKA-94/Azure/master/Task7/StoragePar.json",

    [string]
    $mainPath = "https://raw.githubusercontent.com/BOSKA-94/Azure/master/Task7/main.json",

    [string]
    $recoveryPath = "https://raw.githubusercontent.com/BOSKA-94/Azure/master/Task7/RecoveryMain.json",

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
if (Test-Path $KeyVaultParPath) {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $KeyVaultPath -TemplateParameterFile $KeyVaultParPath;
}
else {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $KeyVaultPath;
}
Set-AzureKeyVaultSecret -VaultName 'Task7' -Name 'DevOps' -SecretValue $secretvalue

# Start the deployment Storage account
Write-Host "Starting deployment Storage account...";
if (Test-Path $StorageParPath) {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $StoragePath -TemplateParameterFile $StorageParPath;
}
else {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $StoragePath;
}

# Start the deployment VM and Recovery service
Write-Host "Starting deployment VM and Recovery service...";
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $mainPath;

# Backup VM
Get-AzureRmRecoveryServicesVault -Name "RecoveryTask7" | Set-AzureRmRecoveryServicesVaultContext;
$schPol = Get-AzureRmRecoveryServicesBackupSchedulePolicyObject -WorkloadType "AzureVM";
$retPol = Get-AzureRmRecoveryServicesBackupRetentionPolicyObject -WorkloadType "AzureVM";
New-AzureRmRecoveryServicesBackupProtectionPolicy -Name "BackupPolicy" -WorkloadType "AzureVM" -RetentionPolicy $retPol -SchedulePolicy $schPol;
$pol = Get-AzureRmRecoveryServicesBackupProtectionPolicy -Name "BackupPolicy";
start-sleep -seconds 60;
Enable-AzureRmRecoveryServicesBackupProtection -Policy $pol -Name "comp1" -ResourceGroupName $resourceGroupName;
$namedContainer = Get-AzureRmRecoveryServicesBackupContainer  -ContainerType "AzureVM" -Status "Registered" -FriendlyName "comp1";
$backupitem = Get-AzureRmRecoveryServicesBackupItem -Container $namedContainer  -WorkloadType "AzureVM";
Backup-AzureRmRecoveryServicesBackupItem -Item $backupitem
Write-Host "Waiting for backup complete"
do {
    $joblist = Get-AzureRmRecoveryservicesBackupJob –Status "InProgress"
    start-sleep -seconds 15
    Write-Host -NoNewline "."
} while ($joblist) 


# Restore VHD
$rp = Get-AzureRmRecoveryServicesBackupRecoveryPoint -Item $backupitem ;
$restorejob = Restore-AzureRmRecoveryServicesBackupItem -RecoveryPoint $rp[0] -StorageAccountName "baskaulau" -StorageAccountResourceGroupName $resourceGroupName;
$restorejob

#Create a VM from restored disks
New-AzureRmResourceGroup -Name Backup -Location "North Europe"
Write-Host "Starting deployment VM from restored disks...";
New-AzureRmResourceGroupDeployment -ResourceGroupName Backup -TemplateFile $recoveryPath

