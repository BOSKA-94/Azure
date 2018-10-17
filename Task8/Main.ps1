param(
    [string]
    $subscriptionId = "4712ca89-5e08-4d78-9f70-35f10bec642b",

    [string]
    $resourceGroupName = "MC_Minsk_Task8_northeurope",

    [string]
    $resourceGroupLocation,

    [string]
    $KeyVaultPath = "C:\Azure\Task8\KeyVault.json",

    [string]
    $KeyVaultParPath = "C:\Azure\Task8\KeyVaultPar.json",

    [string]
    $mainPath = "C:\Azure\Task8\main.json",

    [Parameter(Mandatory = $True)]
    [SecureString]
    $secretvalue
)
#Connect-AzureRmAccount
#Select-AzureRmSubscription -SubscriptionName $subscriptionId
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $KeyVaultPath -TemplateParameterFile $KeyVaultParPath;
Set-AzureKeyVaultSecret -VaultName 'Task8' -Name 'DevOps' -SecretValue $secretvalue;
New-AzureRmResourceGroup -Name MC_Minsk_Task8_northeurope -Location "North Europe"
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile C:\Azure\Task8\main.json -Verbose;