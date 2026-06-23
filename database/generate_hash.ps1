param(
    [Parameter(Mandatory = $true)]
    [string]$Password
)

$salt = New-Object Byte[] 16
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$rng.GetBytes($salt)

$iterationCount = 310000
$pbkdf2 = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($Password, $salt, $iterationCount, [System.Security.Cryptography.HashAlgorithmName]::SHA256)
$subkey = $pbkdf2.GetBytes(32)

$hashBytes = New-Object Byte[] 61 # 1 (format) + 4 (prf) + 4 (iter) + 4 (salt size) + 16 (salt) + 32 (subkey)
$hashBytes[0] = 1 # Format V3

# PRF = 1 (HMAC-SHA256) -> Big Endian [0,0,0,1]
$hashBytes[1] = 0; $hashBytes[2] = 0; $hashBytes[3] = 0; $hashBytes[4] = 1

# Iterations.
$hashBytes[5] = [byte](($iterationCount -shr 24) -band 255)
$hashBytes[6] = [byte](($iterationCount -shr 16) -band 255)
$hashBytes[7] = [byte](($iterationCount -shr 8) -band 255)
$hashBytes[8] = [byte]($iterationCount -band 255)

# Salt size = 16 -> Big Endian [0,0,0,16]
$hashBytes[9] = 0; $hashBytes[10] = 0; $hashBytes[11] = 0; $hashBytes[12] = 16

[Array]::Copy($salt, 0, $hashBytes, 13, 16)
[Array]::Copy($subkey, 0, $hashBytes, 29, 32)

$base64 = [Convert]::ToBase64String($hashBytes)
Write-Output $base64
