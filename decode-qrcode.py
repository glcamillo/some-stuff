#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Leitor de QRCode usando:
#  libzbar: biblioteca de sistema (QR code/bar code scanner and decoder (library))
#  QReader: biblioteca Python para detectar e extrar indo de QRCodes
#           https://pypi.org/project/qreader/

# Instalação Dependências
#  sudo apt-get install libzbar0
#  pip install qreader


from qreader import QReader
import cv2

def decode_qrcode(image_path):

    # Cria uma instância de QReader
    qreader = QReader()

    # Lê e obtem a imagem do arquivo de imagem
    image = cv2.cvtColor(cv2.imread(image_path), cv2.COLOR_BGR2RGB)

    # Detecta e decodifica código QRCode presente na imagem
    decoded_text = qreader.detect_and_decode(image=image)

    print(f"Conteúdo do QRCode: {decoded_text}")


if __name__ == '__main__':
    
    print("--- Extração e Decodificação de QRCodes ---")
    print("------      de imagens PNG.      ----------")
    image_path = input("Entre com o nome de arquivo de imagem formato PNG: ")

    decode_qrcode(image_path)


