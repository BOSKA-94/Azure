az group deployment create --template-file "C:\test\Vnet.json" --parameters "C:\test\VnetPar.json" -g Minsk

az group deployment create --template-file "C:\test\Storage.json" --parameters "C:\test\StoragePar.json" -g Minsk

az group deployment create --template-file "C:\test\main.json" -g Minsk