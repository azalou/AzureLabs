# Set your Key Vault name
$keyVaultName = "kv-azou8506-Secrets"

# List of users (replace with your actual user keys)
$userList = @(
  # "AliceSmith001" ,
  "AliceSmith002" #,
  #  "BobJohnson001",
  #  "CarolLee001",
  #  "DavidKim001",
  #  "EvaBrown001",
  #  "FrankGreen001",
  #  "GraceWhite001",
  #  "HenryBlack001",
  #  "IvyScott001",
  #  "JackWilson001"
)
function GeneratePassword {
  $t1 = @("Blue", "Red", "Green", "Silver", "Purple", "Golden", "Pink", "Brown", "White", "Black")
  $t2 = @("Ocean", "Fire", "Lake", "River", "Grass", "Bird", "Tiger", "Fish", "Thunder", "Car", "Hammer")
  $t3 = @("3", "22", "33", "55", "33", "55", "76", "55", "23", "78", "54", "23", "45", "77", "88", "33", "23", "99", "89", "76", "55", "34", "12", "34", "12", "34", "23", "44", "999", "888")
  $t4 = @("UK", "BR", "CH", "US", "TW", "KK", "ZE", "AU", "PK", "RX")
  $t5 = @("$", "#", "@", "!", "%", "+", "&", "%%", "@@", "##")
  $r1 = Get-Random -Maximum $t1.Count
  $r2 = Get-Random -Maximum $t2.Count
  $r3 = Get-Random -Maximum $t3.Count
  $r4 = Get-Random -Maximum $t4.Count
  $r5 = Get-Random -Maximum $t5.Count
  $passvector = $t1[$r1], $t2[$r2], $t3[$r3], $t4[$r4], $t5[$r5]
  $shuffledvector = $passvector | Sort-Object { Get-Random }

  return $shuffledvector -join ""
}
foreach ($user in $userList) {
  # Generate a random password 
  $password = GeneratePassword   
  # Store password in Key Vault
  az keyvault secret set `
    --vault-name $keyVaultName `
    --name "userpwd-$user" `
    --value $password | Out-Null

  Write-Host "Password for $user stored in Key Vault."
  #Write-Host "Password for $user is $password"
}