Configuration BaseInstall
{
    param ($MachineName)
    import-DscResource -ModuleName 'PSDesiredStateConfiguration', 'xPSDesiredStateConfiguration'
    Node $MachineName
    {
        Script EnableTLS12 {
            SetScript  = {
                [ Net.ServicePointManager ]::SecurityProtocol = [ Net.ServicePointManager ]::SecurityProtocol.toString() + ' , ' + [ Net.SecurityProtocolType ]::Tls12
            }
            TestScript = {
                return ([ Net.ServicePointManager ]::SecurityProtocol -match ' Tls12 ' )
            }
            GetScript  = {
                return @{
                    Result = ([ Net.ServicePointManager ]::SecurityProtocol -match ' Tls12 ' )
                }
            }
        }

        Script InstallNotepadd {
            SetScript  = {
                #Check Install directory
                If (!(Test-Path -Path "C:\Install" -PathType Container)) {
                    New-Item -ItemType Directory -Path "C:\" -Name "Install"
                }
                Invoke-WebRequest -Uri "https://notepad-plus-plus.org/repository/7.x/7.6.2/npp.7.6.2.Installer.x64.exe" -OutFile "C:\Install"
                Start-Process 'C:\Install\adam\npp.7.6.2.Installer.x64' "/S"
            }
            TestScript = {
                (Test-Path 'C:\Program Files\Notepad++\notepad++.exe')
            }
            GetScript  = {
            }
        }
    }
}
BaseInstall -OutputPath C:\soft\mof
Start-DscConfiguration -Path C:\soft\mof -ComputerName $MachineName -Force -Verbose -wait