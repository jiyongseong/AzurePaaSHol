# reference http://sql.pawlikowski.pro/2019/03/10/connecting-to-azure-data-lake-storage-gen2-from-powershell-using-rest-api-a-step-by-step-guide/

$StorageAccountName = "<<ADLS Gen 2 Name>>"
$FilesystemName = "<<container>>"
$AccessKey = "<<key>>"

$date = [System.DateTime]::UtcNow.ToString("R") # ex: Sun, 10 Mar 2019 11:50:10 GMT
 
$n = "`n"
$method = "GET"

$stringToSign = "$method$n" #VERB
$stringToSign += "$n" # Content-Encoding + "\n" +  
$stringToSign += "$n" # Content-Language + "\n" +  
$stringToSign += "$n" # Content-Length + "\n" +  
$stringToSign += "$n" # Content-MD5 + "\n" +  
$stringToSign += "$n" # Content-Type + "\n" +  
$stringToSign += "$n" # Date + "\n" +  
$stringToSign += "$n" # If-Modified-Since + "\n" +  
$stringToSign += "$n" # If-Match + "\n" +  
$stringToSign += "$n" # If-None-Match + "\n" +  
$stringToSign += "$n" # If-Unmodified-Since + "\n" +  
$stringToSign += "$n" # Range + "\n" + 
$stringToSign +=    
                    <# SECTION: CanonicalizedHeaders + "\n" #>
                    "x-ms-date:$date" + $n + 
                    "x-ms-version:2018-11-09" + $n # 
                    <# SECTION: CanonicalizedHeaders + "\n" #>
 
$stringToSign +=    
                    <# SECTION: CanonicalizedResource + "\n" #>
                    "/$StorageAccountName/$FilesystemName" + $n + 
                    "recursive:true" + $n +
                    "resource:filesystem"# 
                    <# SECTION: CanonicalizedResource + "\n" #>

$sharedKey = [System.Convert]::FromBase64String($AccessKey)

$hasher = New-Object System.Security.Cryptography.HMACSHA256
$hasher.Key = $sharedKey

$signedSignature = [System.Convert]::ToBase64String($hasher.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($stringToSign)))

$authHeader = "SharedKey ${StorageAccountName}:$signedSignature"

$headers = @{"x-ms-date"=$date} 
$headers.Add("x-ms-version","2018-11-09")
$headers.Add("Authorization",$authHeader)

$URI = "https://$StorageAccountName.dfs.core.windows.net/" + $FilesystemName + "?recursive=false&resource=filesystem"

$result = Invoke-RestMethod -method GET -Uri $URI -Headers $headers
$result.paths #| select name, contentLength, lastModified | Export-Csv -Path "SIL-ADLSG2.csv" -NoTypeInformation\
$result

#결과를 5000개까지만 반환, Continous token 사용 필요