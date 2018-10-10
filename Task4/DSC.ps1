Configuration Task 
{
    param ($MachineName)
    $sitename = "Default Web Site" 

    Import-DscResource -ModuleName PsDesiredStateConfiguration 
    Import-DscResource -ModuleName xWebadministration

    Node $MachineName {

        WindowsFeature WebServer {
            Ensure = "Present"
            Name   = "Web-Server"
        }

        WindowsFeature ASP {
            Ensure    = "Present"
            Name      = "Web-Asp-Net45"
            DependsOn = "[WindowsFeature ]WebServer"
        }
        xWebsite MainHTTPWebsite {  
            Ensure          = "Present"  
            Name            = $sitename
            ApplicationPool = "DefaultAppPool" 
            State           = "Started"  
            PhysicalPath    = "%SystemDrive%\inetpub\wwwroot\iisstart.htm"  
            BindingInfo     = @(MSFT_xWebBindingInformation {
                    Protocol  = 'HTTP'
                    Port      = '8080'
                    IPAddress = '*'
                    HostName  = 'http://localhost/'
                }
            )
            DependsOn       = "[WindowsFeature ]WebServer"
        }
    }
}

