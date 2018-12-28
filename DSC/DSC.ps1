Configuration BaseInstall
{
    param ($MachineName)
    Import-DscResource -Module PSDesiredStateConfiguration, xWebAdministration


    Node $MachineName
    {
        # Install .NET
        WindowsFeature installdotNet35
        {
            Ensure      = "Present"
            Name        = "Net-Framework-Core"
        }

        # Install NET-HTTP-Activation
        WindowsFeature NETHTTPActivation
        {
            Ensure      = "Present"
            Name        = "NET-HTTP-Activation"
            DependsOn = '[WindowsFeature]installdotNet35'
        }

        # Install IIS
        WindowsFeature IIS {
            Ensure = "Present"
            Name   = "Web-Server"
        }

        # Install the ASP .NET 4.5 role
        WindowsFeature ASP {
            Ensure    = "Present"
            Name      = "Web-Asp-Net45"
            DependsOn = '[WindowsFeature]IIS'
        }

        # Install the Management Console
        WindowsFeature WebServerManagementConsole {
            Name   = "Web-Mgmt-Console"
            Ensure = "Present"
            DependsOn = '[WindowsFeature]IIS'
        }

        # Install the Management Compatibility
        WindowsFeature WebServerManagementCompatibility {
            Name   = "Web-Mgmt-Compat"
            Ensure = "Present"
        }

        # Windows Authentification
        WindowsFeature EnableWinAuth {
            Name = "Web-Windows-Auth"
            Ensure = "Present"
        }

        # Install the HTTPRedirection
        WindowsFeature HTTPRedirection {
            Name = "Web-Http-Redirect"
            Ensure = "Present"
            DependsOn = "[WindowsFeature]IIS"
        }

        # Install the Web-ODBC-Logging
        WindowsFeature WebODBCLogging {
            Name = "Web-ODBC-Logging"
            Ensure = "Present"
            DependsOn = "[WindowsFeature]IIS"
        }

        # Install the Dynamic Content Compression
        WindowsFeature WebDynCompression {
            Name = "Web-Dyn-Compression"
            Ensure = "Present"
        }

        # Install the File and Storage services
        WindowsFeature FileAndStorageServices {
            Name = "FileAndStorage-Services"
            Ensure = "Present"
        }

        # Install the File and iSCSI Services
        WindowsFeature FileAndiSCSIServices {
            Name = "File-Services"
            Ensure = "Present"
        }

        # Install the File Server Resource Manager
        WindowsFeature FSResourceManager {
            Name = "FS-Resource-Manager"
            Ensure = "Present"
        }

         # Install the Background Intelligent Transfer Service
         WindowsFeature BITS {
            Name = "BITS"
            Ensure = "Present"
        }

        # Install the Message Queuing
        WindowsFeature MSMQ {
            Name = "MSMQ"
            Ensure = "Present"
        }

        # Install the Remote Server Administration Tools
        WindowsFeature RSAT {
            Name = "RSAT"
            Ensure = "Present"
        }

        # Install the SMB 1.0/CIFS File Sharing Support
        WindowsFeature SMB {
            Name = "FS-SMB1"
            Ensure = "Present"
        }

        # Install the SMTP Server
        WindowsFeature SMTP {
            Name = "SMTP-Server"
            Ensure = "Present"
        }

        # Install the Telnet Client
        WindowsFeature Telnet {
            Name = "Telnet-Client"
            Ensure = "Present"
        }

         # Install the Windows Identity Foundation 3.5
         WindowsFeature WindowsIdentityFoundation {
            Name = "Windows-Identity-Foundation"
            Ensure = "Present"
        }

        # Install the WinRM IIS Extension
        WindowsFeature WinRMIISExtension {
            Name = "WinRM-IIS-Ext"
            Ensure = "Present"
        }

        # Install the File Services Tools
        WindowsFeature RSATFileServices {
            Name = "RSAT-File-Services"
            Ensure = "Present"
        }

         # Install the BITS Server Extensions Tools
         WindowsFeature RSATBitsServer {
            Name = "RSAT-Bits-Server"
            Ensure = "Present"
            DependsOn = "[WindowsFeature]RSAT"
        }

        # Install the HTTP Support
        WindowsFeature MSMQHTTPSupport {
            Name = "MSMQ-HTTP-Support"
            Ensure = "Present"
            DependsOn = "[WindowsFeature]MSMQ"
        }
        Script download {
            SetScript  = {
                $installDir = "C:\Install"
                If (!(Test-Path -Path "$installDir" -PathType Container)) { 
                    New-Item -ItemType Directory -Path "C:\" -Name "Install"
                }
                $GhostScriptUri = "https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs921/gs921w64.exe"
                $JDKUri = "https://download.oracle.com/otn-pub/java/jdk/8u191-b12/2787e4a523244c269598db4e85c51e0c/jdk-8u191-windows-x64.exe"
                $SolrUri = "https://archive.apache.org/dist/lucene/solr/4.9.0/solr-4.9.0.zip"
                $Notepad = "https://notepad-plus-plus.org/repository/7.x/7.6.1/npp.7.6.1.Installer.x64.exe"
                $ImageMagickUri = "https://launchpad.net/imagemagick/main/6.9.3-1/+download/ImageMagick-6.9.3-1.tar.gz"
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                Invoke-WebRequest -Uri $GhostScriptUri -OutFile $installDir -Verbose 
                #Invoke-WebRequest -Uri $JDKUri -OutFile $installDir -Verbose 
                Invoke-WebRequest -Uri $SolrUri -OutFile $installDir -Verbose 
                Invoke-WebRequest -Uri $Notepad -OutFile $installDir -Verbose 
                Invoke-WebRequest -Uri $ImageMagickUri -OutFile $installDir -Verbose
            }
            TestScript = {
                Test-Path "C:\Install"
            }
            GetScript  = {
                #Something             
            }
        }
    }
}
BaseInstall
Start-DscConfiguration  .\BaseInstall -Verbose -Wait -Force -ComputerName $MachineName