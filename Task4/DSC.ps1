Configuration Task {

    Import-DscResource -ModuleName PsDesiredStateConfiguration

    Node 'localhost' {

        WindowsFeature WebServer {
            Ensure = "Present"
            Name   = "Web-Server"
        }

        WindowsFeature ASP
        {
          Ensure = "Present"
          Name = "Web-Asp-Net45"
        }

    WindowsFeature WebServerManagementConsole
    {
        Name = "Web-Mgmt-Console"
        Ensure = "Present"
    }  
    }
}