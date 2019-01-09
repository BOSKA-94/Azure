Configuration BaseInstall
{
    param ($MachineName)
    import-DscResource -ModuleName 'PSDesiredStateConfiguration', 'xPSDesiredStateConfiguration'
    Node $MachineName
    {
     #Added Notepad++
     xRemoteFile Notepad
     {
         DestinationPath = "D:\npp.7.5.6.Installer.x64.exe"
         Uri = "https://notepad-plus-plus.org/repository/7.x/7.5.6/npp.7.5.6.Installer.x64.exe"
         MatchSource = $false
     }
     Package Notepad
     {
         Ensure = "Present"
         Name = "Notepad++ (64-bit x64)"
         Path = "D:\npp.7.5.6.Installer.x64.exe"
         ProductId = ''
         Arguments = "/S"
         DependsOn = "[xRemoteFile]Notepad"
         
     }   
    }
}
BaseInstall
Start-DscConfiguration .\BaseInstall -ComputerName 'localhost' -Force -Verbose -wait