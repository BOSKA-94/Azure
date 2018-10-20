Configuration Task9
{
    Import-DscResource -ModuleName xNetworking, xWebAdministration, PSDesiredStateConfiguration

    Node comp2 {

        xFirewall IIS_8080 {
            Name        = 'IIS'
            DisplayName = 'IIS'
            Action      = 'Allow'
            Direction   = 'Inbound'
            LocalPort   = '8080'
            Protocol    = 'TCP'
            Profile     = 'Any'
            Enabled     = 'True'
        }

        WindowsFeature IIS {
            Ensure = "Present"
            Name   = "Web-Server"
        }

        WindowsFeature ASP {
            Ensure    = "Present"
            Name      = "Web-Asp-Net45"
            DependsOn = '[WindowsFeature]IIS'
        }

        WindowsFeature WebServerManagementConsole {
            Name   = "Web-Mgmt-Console"
            Ensure = "Present"
        }
    }
}