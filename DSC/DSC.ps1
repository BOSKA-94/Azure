Configuration BaseInstall
{
    param ($MachineName)
    import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Node $MachineName
    {
        $zipUri = 'https://www.7-zip.org/a/7z1805-x64.msi'
        $JreUri = 'https://javadl.oracle.com/webapps/download/AutoDL?BundleId=235727_2787e4a523244c269598db4e85c51e0c'
        $zipOut = '7z1805-x64.msi'
        $JreOut = 'jre-8u191-windows-x64.exe'
        $InstallDir = 'C:\Install'

        Script downloadSoft {
            SetScript  = {
                If (!(Test-Path -Path "C:\Install" -PathType Container)) { 
                    New-Item -ItemType Directory -Path "C:\" -Name "Install"
                }
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                Invoke-WebRequest -Uri $zipUri -OutFile "C:\Install\7z1805-x64.msi" -UseBasicParsing -Verbose 
            }
            TestScript = {
                Test-Path -Path "C:\Install\7z1805-x64.msi"
            }
            GetScript  = {
                #Something
            }
        }
    }
}
BaseInstall
Start-DscConfiguration .\BaseInstall -ComputerName 'localhost' -Force -Verbose -wait