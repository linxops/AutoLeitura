CREATE DATABASE db_autoleitura;

CREATE TABLE tb_usuarios(
   id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   local CHAR(1) NOT NULL,
   nome VARCHAR(100) NOT NULL,
   celular VARCHAR(11) NOT NULL,
   email VARCHAR(100) NULL
   )ENGINE = innodb;
  
CREATE TABLE tb_leituras(
   id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   mes VARCHAR(12) NOT NULL,
   leitura INTEGER NOT NULL,
   data DATE NOT NULL,
   codigo INT NOT NULL REFERENCES  tb_usuarios(id)
   )ENGINE = innodb;
   



CREATE TABLE tb_valor(
   id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   valor NUMERIC(6,2) NOT NULL,
   data DATE NOT NULL
   )ENGINE = innodb;
   


CREATE TABLE tb_contas(
   id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   mesreferencia VARCHAR(13) NOT NULL,
   dataemissao DATE NOT NULL,
   datavencimento DATE NOT NULL,
   valorconta NUMERIC(6,2) NOT NULL,
   valormetrocubico NUMERIC(4,2) NOT NULL,
   leituraatual INTEGER NOT NULL,
   leituraanterior INTEGER NOT NULL,
   mensagem VARCHAR(250) NULL,
   codigouser INTEGER NOT NULL REFERENCES  tb_usuarios(id)
   )ENGINE = innodb;
   
   
  
  
