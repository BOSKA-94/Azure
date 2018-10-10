Configuration Binding
{
Import-DscResource -ModuleName PsDesiredStateConfiguration
Import-DSCResource -ModuleName xWebsite

param ($MachineName)

Node $MachineName {

$sitename = "Default Web Site" 
xWebsite MainHTTPWebsite  
{  
    Ensure          = "Present"  
    Name            = $sitename
    ApplicationPool = "DefaultAppPool" 
    State           = "Started"  
    PhysicalPath    = "%SystemDrive%\inetpub\wwwroot\iisstart.htm"  
    BindingInfo     =
                        @(MSFT_xWebBindingInformation
                            {
                                Protocol              = "HTTP"
                                Port                  = 8080
                                HostName              = "http://localhost/"
                            }
                        )
}
}
}