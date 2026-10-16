# BeamNG.drive - Linux Audio Fixer

Utilitário em Bash para corrigir automaticamente problemas comuns de áudio em mods do **BeamNG.drive** rodando no Linux (via Proton/Wine ou nativo).

---

## 🎯 Motivação

Muitos mods de veículos do BeamNG.drive utilizam arquivos de áudio codificados em formatos que podem falhar ou ficar mudos no Linux (como certas variações de WAV ADPCM). Além disso, alguns mods possuem erros de digitação em arquivos de configuração de som (`.sfxBlend2D.json`), apontando para caminhos inexistentes (ex: referenciando `/dec/` em vez de `/acc/`).

Este script automatiza o processo de reparo sem que você precise extrair, converter e recompactar arquivos manualmente.

---

## ⚙️ O que o script faz?

1. **Backup Automático**: Cria uma cópia de segurança do mod original (`.zip.bak` ou `.zip.bak.<timestamp>`) antes de qualquer alteração.
2. **Extração Segura**: Descompacta o mod em um diretório temporário isolado.
3. **Conversão de Áudio**: Converte todos os arquivos `*.wav` para **PCM 16-bit uncompressed (`pcm_s16le`)** usando o `ffmpeg`.
4. **Correção de Configuração JSON**: Ajusta inconsistências de caminhos conhecidas em arquivos `*.sfxBlend2D.json` (ex: corrige `/dec/EngineLoop_Acc_` para `/acc/EngineLoop_Acc_`).
5. **Reempacotamento**: Recria o arquivo `.zip` original otimizado, descartando arquivos indesejados (como metadados do macOS `__MACOSX`).
6. **Limpeza**: Remove automaticamente os diretórios temporários criados.

---

## 📋 Pré-requisitos

Certifique-se de que as seguintes ferramentas estejam instaladas no seu sistema:

- `bash`
- `zip`
- `unzip`
- `ffmpeg`
- `find`
- `sed`

### Como instalar as dependências

#### Ubuntu / Debian / Pop!_OS / Linux Mint:
```bash
sudo apt update
sudo apt install zip unzip ffmpeg
```

#### Arch Linux / Manjaro:
```bash
sudo pacman -S zip unzip ffmpeg
```

#### Fedora:
```bash
sudo dnf install zip unzip ffmpeg
```

---

## 🚀 Como Usar

1. Dê permissão de execução ao script (se ainda não tiver):
   ```bash
   chmod +x convert_mod.sh
   ```

2. Execute o script passando o caminho do arquivo `.zip` do mod:
   ```bash
   ./convert_mod.sh /caminho/para/o/mod.zip
   ```

### Exemplo:
```bash
./convert_mod.sh ~/.local/share/BeamNG.drive/mods/meu_carro_mod.zip
```

---

## 🔄 Restaurando o Backup

Caso queira reverter para o arquivo original do mod:

```bash
mv /caminho/para/o/mod.zip.bak /caminho/para/o/mod.zip
```
*(Ou use o arquivo correspondente caso possua timestamp no nome).*
