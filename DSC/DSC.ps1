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
#EnableTLS 1.2 
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
#7zip
xRemoteFile Zip {
    DestinationPath = "$InstallDir"
    Uri             = $zipUri
    MatchSource = $false
}
    }
}