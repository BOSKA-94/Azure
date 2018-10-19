workflow Shutdown-ARM-VMs-Parallel
{

	$SubscriptionId         = "4712ca89-5e08-4d78-9f70-35f10bec642b"
    $TenantID               = "b41b72d0-4e9f-4c26-8a69-f949f367c91d"
    $CredentialAssetName    = "Kiryl"
   


	"CredentialAssetName: $CredentialAssetName"
	#Get the credential with the above name from the Automation Asset store
    $Cred = Get-AutomationPSCredential -Name $CredentialAssetName;
    if(!$Cred) {
        Throw "Could not find an Automation Credential Asset named '${CredentialAssetName}'. Make sure you have created one in this Automation Account."
    }

    #Connect to your Azure Account
	$Account = Login-AzureRmAccount -Credential $Cred -TenantId $TenantID -ServicePrincipal 
    
    $subscription = Get-AzureRmSubscription | Where-Object {$_.Id -eq $SubscriptionId} | Set-AzureRmContext

	$vms = Get-AzureRmVM
	
	Foreach -Parallel ($vm in $vms){
	    Write-Output "Stopping $($vm.Name)";		
	    Stop-AzureRmVm -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Force;
	}
}