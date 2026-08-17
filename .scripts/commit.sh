#!/usr/bin/env bash

# Script interativo para criação de commits padronizados (Emoji + Conventional Commit)

echo "Selecione o tipo de commit:"
echo "1. ✨ feat: Novo recurso"
echo "2. 🐛 fix: Correção de bug"
echo "3. 📚 docs: Documentação"
echo "4. 🧪 test: Testes"
echo "5. ➕ build: Dependências / Build"
echo "6. ⚡ perf: Performance"
echo "7. 🎨 style: Estilo de código"
echo "8. ♻️ refactor: Refatoração"
echo "9. 🔧 chore: Tarefas/Configurações"
echo "10. 🧱 ci: Integração contínua"
echo "11. 🗃️ raw: Dados RAW"
echo "12. 🧹 cleanup: Limpeza de código"
echo "13. 🗑️ remove: Remoção de arquivos"
echo ""

read -p "Digite o número correspondente: " commit_type

case $commit_type in
  1) type="feat"; emoji="✨";;
  2) type="fix"; emoji="🐛";;
  3) type="docs"; emoji="📚";;
  4) type="test"; emoji="🧪";;
  5) type="build"; emoji="➕";;
  6) type="perf"; emoji="⚡";;
  7) type="style"; emoji="🎨";;
  8) type="refactor"; emoji="♻️";;
  9) type="chore"; emoji="🔧";;
  10) type="ci"; emoji="🧱";;
  11) type="raw"; emoji="🗃️";;
  12) type="cleanup"; emoji="🧹";;
  13) type="remove"; emoji="🗑️";;
  *) echo "Tipo de commit inválido."; exit 1;;
esac

read -p "Digite o escopo (opcional, pressione Enter para pular): " scope
read -p "Digite a descrição do commit: " message

if [ -n "$scope" ]; then
  commit_message="$emoji $type($scope): $message"
else
  commit_message="$emoji $type: $message"
fi

if git commit -m "$commit_message"; then
  echo "Commit criado com sucesso: $commit_message"
else
  echo "ERRO: falha ao criar o commit (nada para commitar ou hook rejeitou a mensagem)." >&2
  exit 1
fi