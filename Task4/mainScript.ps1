Connect-AzureRmAccount
Select-AzureRmSubscription -SubscriptionName "4712ca89-5e08-4d78-9f70-35f10bec642b"
New-AzureRmResourceGroupDeployment -ResourceGroupName Minsk -TemplateFile C:\Azure\Task4\mainVM.json