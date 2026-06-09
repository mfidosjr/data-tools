# OCR Tools

Scripts de pré-processamento OCR para documentos escaneados.

## scp_ocr.sh

Converte PDFs de provas manuscritas em arquivos `.txt` usando Tesseract.
Criado para o projeto SCP (Sistema de Correção de Portfólio), mas funciona para qualquer pasta de PDFs escaneados em português.

### Dependências

```bash
brew install poppler tesseract tesseract-lang
```

### Uso

```bash
chmod +x scp_ocr.sh

# Processar uma pasta
./scp_ocr.sh "/caminho/para/pasta"

# Reprocessar mesmo que TXT já exista
./scp_ocr.sh "/caminho/para/pasta" --force
```

Os arquivos `.txt` são gerados na mesma pasta dos PDFs, com o mesmo nome de base.

### Qualidade do OCR

- Resolução: 200 DPI (bom para manuscritos)
- Idiomas: português + inglês (`por+eng`)
- Textos manuscritos produzem ~60–80% de acurácia — suficiente para correção por LLM
