param(
    [string]
    $subscriptionId = "4712ca89-5e08-4d78-9f70-35f10bec642b",

    [string]
    $resourceGroupName = "Minsk",

    [string]
    $resourceGroupLocation,

    [string]
    $KeyVaultPath = "https://raw.githubusercontent.com/BOSKA-94/Azure/master/Task8/KeyVault.json",

    [string]
    $KeyVaultParPath = "https://raw.githubusercontent.com/BOSKA-94/Azure/master/Task8/KeyVaultPar.json",

    [string]
    $mainPath = "https://raw.githubusercontent.com/BOSKA-94/Azure/master/Task8/main.json",

    [Parameter(Mandatory = $True)]
    [SecureString]
    $secretvalue
)
Connect-AzureRmAccount
Select-AzureRmSubscription -SubscriptionName $subscriptionId
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $KeyVaultPath -TemplateParameterFile $KeyVaultParPath;
Set-AzureKeyVaultSecret -VaultName 'Task8' -Name 'DevOps' -SecretValue $secretvalue;
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $mainPath;