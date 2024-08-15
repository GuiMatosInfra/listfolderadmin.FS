# Define o diretório principal onde você deseja listar os donos e acessos das pastas
$directory = "C:\Caminho\Para\Seu\DiretorioPrincipal"

# Define o caminho do arquivo onde a saída será salva
$outputFile = "C:\Caminho\Para\Seu\ArquivoDeSaida.txt"

# Verifica se o diretório principal existe
if (-Not (Test-Path $directory)) {
    Write-Host "O diretório especificado não existe."
    exit
}

# Cria ou limpa o arquivo de saída
"Folder Path, Owner, Access Rights" | Out-File -FilePath $outputFile -Force

# Função para obter o dono e as permissões de uma pasta
function Get-FolderDetails {
    param (
        [string]$folderPath
    )

    if (Test-Path $folderPath) {
        $acl = Get-Acl -Path $folderPath
        $owner = $acl.Owner

        # Cria uma lista de permissões
        $accessRights = $acl.Access | ForEach-Object {
            "$($_.IdentityReference): $($_.FileSystemRights) ($($_.AccessControlType))"
        } -join "; "

        return "$folderPath, $owner, $accessRights"
    } else {
        return "$folderPath, Folder not found, N/A"
    }
}

# Percorre todas as pastas no diretório principal
Get-ChildItem -Path $directory -Recurse -Directory | ForEach-Object {
    $folderPath = $_.FullName
    $folderDetails = Get-FolderDetails -folderPath $folderPath
    
    # Adiciona a saída ao arquivo
    $folderDetails | Out-File -FilePath $outputFile -Append
}

Write-Host "A listagem dos donos e permissões das pastas foi concluída. Verifique o arquivo: $outputFile"
