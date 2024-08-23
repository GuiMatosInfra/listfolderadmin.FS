Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Função para mostrar uma caixa de diálogo para seleção de pastas
function Get-FolderBrowserDialog {
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "Selecione o diretório raiz:"
    $dialog.ShowNewFolderButton = $true

    [void]$dialog.ShowDialog()
    return $dialog.SelectedPath
}

# Função para mostrar uma caixa de diálogo para salvar arquivos
function Get-SaveFileDialog {
    $dialog = New-Object System.Windows.Forms.SaveFileDialog
    $dialog.Title = "Salvar arquivo de texto"
    $dialog.Filter = "Arquivos de Texto (*.txt)|*.txt|Todos os Arquivos (*.*)|*.*"
    $dialog.DefaultExt = "txt"
    $dialog.AddExtension = $true

    [void]$dialog.ShowDialog()
    return $dialog.FileName
}

# Obter o diretório raiz através da caixa de diálogo
$diretorioRaiz = Get-FolderBrowserDialog
if (-not $diretorioRaiz) {
    Write-Error "Nenhum diretório selecionado. O script será encerrado."
    exit
}

# Obter o caminho do arquivo de texto de saída através da caixa de diálogo
$caminhoArquivoTxt = Get-SaveFileDialog
if (-not $caminhoArquivoTxt) {
    Write-Error "Nenhum local de arquivo selecionado. O script será encerrado."
    exit
}

# Lista para armazenar as informações
$informacoes = @()

# Função para obter o proprietário de uma pasta
function Obter-Proprietario {
    param (
        [string]$caminho
    )

    $acl = Get-Acl -Path $caminho
    $proprietario = $acl.Owner
    return $proprietario
}

# Obter apenas as pastas no diretório raiz (sem subpastas)
$pastas = Get-ChildItem -Path $diretorioRaiz -Directory

foreach ($pasta in $pastas) {
    $proprietario = Obter-Proprietario -caminho $pasta.FullName
    $informacoes += "{0}`t{1}" -f $pasta.FullName, $proprietario
}

# Salvar as informações em um arquivo de texto
$informacoes | Out-File -FilePath $caminhoArquivoTxt -Encoding utf8

Write-Output "A listagem de pastas e proprietários foi salva em $caminhoArquivoTxt"
