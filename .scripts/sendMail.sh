#!/usr/bin/env bash

sendEmail -f sidney.oliveira.projeto@zohomail.com \
  -t  sidneyoliveirajunior@gmail.com \
  -s smtp.zoho.com:587 \
  -u "Versão Homologação Auto Leitura" \
  -m "<h1>Uma nova Versão de homologação está disponivel para ser instalado!!</h1>" \
  -a  ./.deploy_homol/app-release.apk \
  -xu sidney.oliveira.projeto@zohomail.com \
  -xp '**********' \
  -o tls=yes
  
