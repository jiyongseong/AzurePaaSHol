key="###storage account key###"
accountName="<<storage account name>>"
container="<<container name>>"

## blob 생성 > upload > tagging
for run in {1..6000}; do
    tick=$(( ( RANDOM % 6000 )  + 1 ))
    createdDate=$(date -u -d "${tick} seconds" "+%Y-%m-%dT%H:%M:%S.%NZ")
    fileName=$(echo $createdDate | sed 's/://g' | sed 's/-//g')
    file="./${fileName}"
    echo "tick : ${tick}"
    echo "createdDate : ${createdDate}"
    echo "fileName : ${fileName}"
    echo "--------------------------"
    touch "${fileName}"

    az storage blob upload --account-name $accountName --container-name $container --account-key $key --auth-mode key --file $file --name $fileName
    az storage blob tag set --account-name $accountName --container-name $container --account-key $key --auth-mode key --name $fileName --tags "createdDate"=${createdDate}
done

## tag를 이용한 blob 검색
az storage blob filter --account-name $accountName --account-key $key --auth-mode key --tag-filter "@container= '${container}' AND "createdDate">='2021-07-16T13:36:24.513654500Z'" 
az storage blob filter --account-name $accountName --account-key $key --auth-mode key --tag-filter "@container= '${container}' AND "createdDate">='2021-07-16T13:36:24.513654500Z'" | jq length