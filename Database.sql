-- BASE DE DATOS :: MySQL

SET FOREIGN_KEY_CHECKS = 0;

-- <Tablas sin relaciones>
-- La tabla "Usuario" no tiene relaciones
-- esta tabla es usada para la identificacion
-- de los usuarios del Sistema

DROP TABLE IF EXISTS usuarios;
CREATE TABLE usuarios (
  ID VARCHAR(15) NOT NULL,
  passwd BLOB NOT NULL,
  nivel TINYINT(1) UNSIGNED NOT NULL,
  PRIMARY KEY (ID)
)ENGINE=INNODB;

-- </Tablas sin relaciones>

-- <Tablas Primarias>
-- las tablas primarias son tablas
-- que no contienen datos dependientes
-- de otras tablas, por lo tanto no
-- contienen restricciones de claves
-- foraneas.

DROP TABLE IF EXISTS maestro_cliente;
CREATE TABLE maestro_cliente (
  Razon_Social VARCHAR(50) NOT NULL,
  RIF VARCHAR(12) NOT NULL,
  Direccion TEXT NOT NULL,
  passwd BLOB NOT NULL,
  PRIMARY KEY (RIF)
)ENGINE=INNODB;

DROP TABLE IF EXISTS forma_pago;
CREATE TABLE forma_pago (
  cod_pago TINYINT(2) UNSIGNED AUTO_INCREMENT NOT NULL,
  forma_pago VARCHAR(15) NOT NULL,
  dias_credito TINYINT(2) UNSIGNED,
  PRIMARY KEY (cod_pago)
)ENGINE=INNODB;

DROP TABLE IF EXISTS IVA;
CREATE TABLE IVA (
  id_IVA TINYINT(2) UNSIGNED AUTO_INCREMENT,
  IVA TINYINT(2) UNSIGNED NOT NULL,
  tipo_IVA BOOLEAN,
  PRIMARY KEY (id_IVA)
)ENGINE=INNODB;

DROP TABLE IF EXISTS proveedores;
CREATE TABLE proveedores (
  cod_proveedor TINYINT(2) UNSIGNED AUTO_INCREMENT NOT NULL,
  nombre_proveedor VARCHAR(50) NOT NULL,
  RIF_proveedor VARCHAR(12) NOT NULL,
  PRIMARY KEY (cod_proveedor),
  UNIQUE KEY nombre_proveedor (nombre_proveedor)
)ENGINE=INNODB;

-- </Tablas Primarias>

-- <Tablas Secundarias>
-- Las tablas secundarias son tablas
-- que contienen datos dependientes,
-- de otras tablas, esta dependencia
-- puede ser de tablas primarias
-- como de tablas secundarias, estas
-- contienen restricciones de claves
-- foraneas.

DROP TABLE IF EXISTS pedido;
CREATE TABLE pedido (
  numero_pedido BIGINT(10) UNSIGNED ZEROFILL AUTO_INCREMENT,
  RIF VARCHAR(12) NOT NULL,
  fecha DATE NOT NULL,
  vigencia DATE NOT NULL,
  direccion_envio TEXT NOT NULL,
  PRIMARY KEY (numero_pedido),
  INDEX (RIF),
  FOREIGN KEY (RIF)
	REFERENCES maestro_cliente (RIF)
	ON UPDATE CASCADE ON DELETE RESTRICT
)ENGINE=INNODB;

DROP TABLE IF EXISTS pedido_producto;
CREATE TABLE pedido_producto (
  numero_pedido BIGINT(10) UNSIGNED ZEROFILL NOT NULL,
  cod_producto VARCHAR(10),
  cantidad_producto SMALLINT(4),
  monto_unitario DOUBLE NOT NULL,
  id_IVA tinyint(2) unsigned NOT NULL,
  INDEX (id_IVA),
  FOREIGN KEY (id_IVA)
    REFERENCES IVA (id_IVA)
	ON UPDATE RESTRICT ON DELETE RESTRICT,
  INDEX (numero_pedido),
  FOREIGN KEY (numero_pedido)
	REFERENCES pedido (numero_pedido)
	ON UPDATE RESTRICT ON DELETE RESTRICT,
  INDEX (cod_producto),
  FOREIGN KEY (cod_producto)
	REFERENCES producto (cod_producto)
	ON UPDATE RESTRICT ON DELETE RESTRICT
)ENGINE=INNODB;

DROP TABLE IF EXISTS pedido_pago;
CREATE TABLE pedido_pago (
  numero_pedido BIGINT(10) UNSIGNED ZEROFILL NOT NULL,
  cod_pago TINYINT(2) UNSIGNED NOT NULL,
  monto_unitario DOUBLE UNSIGNED NOT NULL,
  confirmacion_pago BIGINT(10) UNSIGNED ZEROFILL NOT NULL,

  INDEX (numero_pedido),
  FOREIGN KEY (numero_pedido)
	REFERENCES pedido (numero_pedido)
	ON UPDATE RESTRICT ON DELETE RESTRICT,
  INDEX (cod_pago),
  FOREIGN KEY (cod_pago)
	REFERENCES forma_pago (cod_pago)
	ON UPDATE RESTRICT ON DELETE RESTRICT
)ENGINE=INNODB;

DROP TABLE IF EXISTS factura;
CREATE TABLE factura (
  numero_factura BIGINT(10) UNSIGNED ZEROFILL AUTO_INCREMENT NOT NULL,
  fecha DATE NOT NULL,
  numero_pedido BIGINT(10) UNSIGNED ZEROFILL NOT NULL,
  PRIMARY KEY (numero_factura),
  INDEX (numero_pedido),
  FOREIGN KEY (numero_pedido)
	REFERENCES pedido (numero_pedido)
	ON UPDATE RESTRICT ON DELETE RESTRICT
)ENGINE=INNODB;

DROP TABLE IF EXISTS factura_producto;
CREATE TABLE factura_producto (
  id_producto BIGINT UNSIGNED ZEROFILL AUTO_INCREMENT,
  numero_factura BIGINT(10) UNSIGNED ZEROFILL NOT NULL,
  cod_producto VARCHAR(10),
  cantidad_producto SMALLINT(4),
  monto_unitario DOUBLE NOT NULL,
  id_IVA TINYINT(2) UNSIGNED,
  PRIMARY KEY (id_producto),
  INDEX (id_IVA),
  FOREIGN KEY (id_IVA)
    REFERENCES IVA (id_IVA)
	ON UPDATE RESTRICT ON DELETE RESTRICT,
  INDEX (numero_factura),
  FOREIGN KEY (numero_factura)
	REFERENCES factura (numero_factura)
	ON UPDATE RESTRICT ON DELETE RESTRICT,
  INDEX (cod_producto),
  FOREIGN KEY (cod_producto)
	REFERENCES producto (cod_producto)
	ON UPDATE RESTRICT ON DELETE RESTRICT
)ENGINE=INNODB;

DROP TABLE IF EXISTS factura_pago;
CREATE TABLE factura_pago (
  id_pago BIGINT UNSIGNED ZEROFILL AUTO_INCREMENT,
  numero_factura BIGINT(10) UNSIGNED ZEROFILL NOT NULL,
  cod_pago TINYINT(2) UNSIGNED NOT NULL,
  monto_unitario DOUBLE UNSIGNED NOT NULL,
  confirmacion_pago BIGINT(10) UNSIGNED ZEROFILL,

  PRIMARY KEY (id_pago),
  INDEX (numero_factura),
  FOREIGN KEY (numero_factura)
	REFERENCES factura (numero_factura)
	ON UPDATE RESTRICT ON DELETE RESTRICT,
  INDEX (cod_pago),
  FOREIGN KEY (cod_pago)
	REFERENCES forma_pago (cod_pago)
	ON UPDATE RESTRICT ON DELETE RESTRICT
)ENGINE=INNODB;

DROP TABLE IF EXISTS cuentas_cobrar;
CREATE TABLE cuentas_cobrar (
  id_pago BIGINT UNSIGNED ZEROFILL NOT NULL,
  pagado BOOLEAN NOT NULL,
  PRIMARY KEY (id_pago),
  INDEX (id_pago),
  FOREIGN KEY (id_pago)
	REFERENCES factura_pago (id_pago)
	ON UPDATE RESTRICT ON DELETE RESTRICT
)ENGINE=INNODB;

DROP TABLE IF EXISTS nota_credito;
CREATE TABLE nota_credito (
  numero_factura BIGINT(10) UNSIGNED ZEROFILL NOT NULL,
  numero_nota_credito BIGINT(10) UNSIGNED ZEROFILL AUTO_INCREMENT NOT NULL,
  fecha DATE NOT NULL,
  PRIMARY KEY (numero_nota_credito),
  INDEX (numero_factura),
  FOREIGN KEY (numero_factura)
	REFERENCES factura (numero_factura)
	ON UPDATE RESTRICT ON DELETE RESTRICT
)ENGINE=INNODB;

DROP TABLE IF EXISTS nota_credito_producto;
CREATE TABLE nota_credito_producto (
  id_producto BIGINT UNSIGNED ZEROFILL,

  numero_nota_credito BIGINT(10) UNSIGNED ZEROFILL NOT NULL,
  cantidad_producto SMALLINT(4) UNSIGNED NOT NULL,
  monto_unitario DOUBLE UNSIGNED NOT NULL,
  PRIMARY KEY (id_producto),
  INDEX (id_producto),
  FOREIGN KEY (id_producto)
	REFERENCES factura_producto (id_producto)
	ON UPDATE RESTRICT ON DELETE RESTRICT,
  INDEX (numero_nota_credito),
  FOREIGN KEY (numero_nota_credito)
	REFERENCES nota_credito (numero_nota_credito)
	ON UPDATE RESTRICT ON DELETE RESTRICT
)ENGINE=INNODB;

DROP TABLE IF EXISTS factura_proveedor;
CREATE TABLE factura_proveedor (
  numero_factura_proveedor BIGINT(10) UNSIGNED ZEROFILL NOT NULL,
  fecha DATE NOT NULL,
  cod_proveedor TINYINT(2) UNSIGNED NOT NULL,
  PRIMARY KEY (numero_factura_proveedor),
  INDEX (cod_proveedor),
  FOREIGN KEY (cod_proveedor)
	REFERENCES proveedores (cod_proveedor)
	ON UPDATE RESTRICT ON DELETE RESTRICT
)ENGINE=INNODB;

DROP TABLE IF EXISTS producto;
CREATE TABLE producto (
  cod_producto VARCHAR(10) NOT NULL,
  descripcion TEXT NOT NULL,
  nombre VARCHAR(30) NOT NULL,
  id_IVA TINYINT(2) UNSIGNED NOT NULL,
  PRIMARY KEY (cod_producto),
  INDEX (id_IVA),
  FOREIGN KEY (id_IVA)
	REFERENCES IVA (id_IVA)
	ON UPDATE RESTRICT ON DELETE RESTRICT
)ENGINE=INNODB;

DROP TABLE IF EXISTS inventario;
CREATE TABLE inventario (
  cod_producto VARCHAR(10) NOT NULL,
  cod_lote BIGINT(10) UNSIGNED ZEROFILL AUTO_INCREMENT,
  cantidad_actual SMALLINT(4) NOT NULL,
  cantidad_inicial SMALLINT(4) UNSIGNED DEFAULT NULL,
  precio_compra DOUBLE UNSIGNED DEFAULT NULL,
  precio_venta double unsigned NOT NULL,
  numero_factura_proveedor BIGINT(10) UNSIGNED ZEROFILL DEFAULT NULL,
  PRIMARY KEY (cod_lote),
  INDEX (cod_producto),
  FOREIGN KEY (cod_producto)
	REFERENCES producto (cod_producto)
	ON UPDATE RESTRICT ON DELETE RESTRICT,
  INDEX (numero_factura_proveedor),
  FOREIGN KEY (numero_factura_proveedor)
	REFERENCES factura_proveedor (numero_factura_proveedor)
	ON UPDATE RESTRICT ON DELETE RESTRICT
)ENGINE=INNODB;

DROP TABLE IF EXISTS seriales;
CREATE TABLE seriales (
  cod_lote BIGINT(10) UNSIGNED NOT NULL,
  serial VARCHAR(10) NOT NULL,
  numero_nota_entrega BIGINT(10) UNSIGNED ZEROFILL DEFAULT NULL,
  PRIMARY KEY (serial),
  INDEX (numero_nota_entrega),
  FOREIGN KEY (numero_nota_entrega)
    REFERENCES nota_entrega (numero_nota_entrega)
	ON UPDATE RESTRICT ON DELETE SET NULL,
  INDEX (cod_lote),
  FOREIGN KEY (cod_lote)
    REFERENCES inventario (cod_lote)
	ON UPDATE RESTRICT ON DELETE RESTRICT
)ENGINE=INNODB;

DROP TABLE IF EXISTS nota_entrega;
CREATE TABLE nota_entrega (
  numero_nota_entrega BIGINT(10) UNSIGNED ZEROFILL AUTO_INCREMENT,
  fecha DATE NOT NULL,
  numero_factura BIGINT(10) UNSIGNED ZEROFILL NOT NULL,
  PRIMARY KEY (numero_nota_entrega),
  INDEX (numero_factura),
  FOREIGN KEY (numero_factura)
    REFERENCES factura (numero_factura)
	ON UPDATE RESTRICT ON DELETE RESTRICT
)ENGINE=INNODB;

DROP TABLE IF EXISTS telefonos;
CREATE TABLE telefonos (
  numero BIGINT(11) UNSIGNED ZEROFILL NOT NULL,
  contacto VARCHAR(30) NOT NULL,
  RIF VARCHAR(12) NOT NULL,
  UNIQUE KEY numero (numero),
  INDEX (RIF),
  FOREIGN KEY (RIF)
    REFERENCES maestro_cliente (RIF)
	ON UPDATE CASCADE ON DELETE RESTRICT
)ENGINE=INNODB;

-- </Tablas Secundarias>

DELIMITER //

-- <Procedimientos de Almacenado (Tablas sin Relaciones)>
-- estos son los procedimientos de almacenado
-- que trabajan con las tablas sin relaciones
-- de la base de datos.

DROP FUNCTION IF EXISTS AUTENTICAR;//

CREATE FUNCTION AUTENTICAR(ID VARCHAR(15), pass BLOB) RETURNS TINYINT(1)
BEGIN
IF pass=(SELECT aes_decrypt(passwd,usuarios.ID) FROM usuarios WHERE usuarios.ID=ID) THEN
RETURN (SELECT nivel FROM usuarios WHERE usuarios.ID=ID);
ELSE
RETURN 0;
END IF;
END //

DROP PROCEDURE IF EXISTS crear_usuario;//

CREATE PROCEDURE crear_usuario(ID VARCHAR(15),passwd BLOB,nivel TINYINT(1))
BEGIN
INSERT INTO usuarios VALUES (ID,AES_ENCRYPT(passwd,ID),nivel);
END //

DROP PROCEDURE IF EXISTS consultar_usuario;//

CREATE PROCEDURE consultar_usuario(ID VARCHAR(15))
BEGIN
IF ID IS NULL THEN
SELECT u.ID AS `ID`, u.nivel AS `Nivel de Acceso` FROM usuarios u;
ELSE
SELECT u.ID AS `ID`, u.nivel AS `Nivel de Acceso` FROM usuarios u WHERE u.ID=ID;
END IF;
END //

DROP PROCEDURE IF EXISTS actualizar_usuario;//

CREATE PROCEDURE actualizar_usuario(ID VARCHAR(15), nivel TINYINT(1))
BEGIN
UPDATE usuarios u
SET u.nivel=nivel
WHERE u.ID=ID;
END //

DROP TRIGGER IF EXISTS validar_usuario;//

CREATE TRIGGER validar_usuario BEFORE INSERT ON usuarios
FOR EACH ROW BEGIN
IF (NEW.nivel>3) THEN
SET NEW.nivel = 0;
END IF;

END //

-- </Procedimientos de Almacenado (Tablas sin Relaciones)>

-- <Procedimientos de Almacenado (Tablas Primarias)>
-- estos son los procedimientos de almacenado
-- que trabajan con las tablas primarias de la
-- base de datos.

DROP FUNCTION IF EXISTS LOGIN;//

CREATE FUNCTION LOGIN(pass BLOB, RIF VARCHAR(12)) RETURNS TINYINT(1)
BEGIN
IF pass=(SELECT aes_decrypt(passwd,maestro_cliente.RIF) FROM maestro_cliente WHERE maestro_cliente.RIF=RIF) THEN
RETURN 1;
ELSE
RETURN 0;
END IF;
END //

DROP PROCEDURE IF EXISTS ingresar_cliente;//

CREATE PROCEDURE ingresar_cliente(nombre VARCHAR(50), RIF VARCHAR(12), direccion text, pass BLOB)
BEGIN
INSERT INTO maestro_cliente VALUES(nombre,RIF,direccion, aes_encrypt(pass,RIF));
END //

DROP PROCEDURE IF EXISTS actualizar_cliente;//

CREATE PROCEDURE actualizar_cliente(RIF VARCHAR(12), nombre VARCHAR(50), direccion text)
BEGIN
UPDATE maestro_cliente m
SET m.Razon_Social=nombre,
m.direccion=direccion
WHERE m.RIF=RIF;
END //

DROP PROCEDURE IF EXISTS consultar_cliente;//

CREATE PROCEDURE consultar_cliente(RIF VARCHAR(12))
BEGIN
IF RIF IS NULL THEN
SELECT m.RIF AS `RIF`, m.Razon_Social AS `Razon Social`, m.direccion AS `Direccion` FROM maestro_cliente m;
ELSE
SELECT m.RIF AS `RIF`, m.Razon_Social AS `Razon Social`, m.direccion AS `Direccion` FROM maestro_cliente m WHERE m.RIF=RIF;
END IF;
END //

DROP PROCEDURE IF EXISTS ingresar_IVA;//

CREATE PROCEDURE ingresar_IVA(IVA TINYINT(2),tipo_iva BOOLEAN)
BEGIN
INSERT INTO IVA VALUES (NULL,IVA,tipo_iva);
END //

DROP PROCEDURE IF EXISTS consultar_IVA;//

CREATE PROCEDURE consultar_IVA(id_IVA TINYINT(2))
BEGIN
IF id_IVA IS NULL THEN
SELECT a.id_IVA AS `ID IVA`, a.IVA AS `Tasa de IVA`, IF(a.tipo_IVA IS NULL,'EXENTO',IF(a.tipo_IVA IS TRUE,'INCLUIDO','EXCLUIDO')) AS `Tipo de IVA` FROM IVA a;
ELSE
SELECT a.id_IVA AS `ID IVA`, a.IVA AS `Tasa de IVA`, IF(a.tipo_IVA IS NULL,'EXENTO',IF(a.tipo_IVA IS TRUE,'INCLUIDO','EXCLUIDO')) AS `Tipo de IVA` FROM IVA a WHERE a.id_IVA=id_IVA;
END IF;
END //

DROP PROCEDURE IF EXISTS ingresar_forma_pago;//

CREATE PROCEDURE ingresar_forma_pago(FormaPago VARCHAR(15), DiasCredito TINYINT(2))
BEGIN
IF ((FormaPago='DESCUENTO' OR FormaPago='INCREMENTO') AND NOT EXISTS(SELECT * FROM forma_pago f WHERE f.forma_pago=FormaPago)) OR NOT EXISTS(SELECT * FROM forma_pago f WHERE f.forma_pago=FormaPago) THEN
INSERT INTO forma_pago VALUES (NULL,FormaPago,DiasCredito);
END IF;
END //

DROP PROCEDURE IF EXISTS actualizar_forma_pago;//

CREATE PROCEDURE actualizar_forma_pago(CodPago TINYINT(2), FormaPago VARCHAR(15), DiasCredito TINYINT(2))
BEGIN
IF FormaPago <> 'DESCUENTO' AND FormaPago <> 'INCREMENTO' AND NOT EXISTS(SELECT * FROM forma_pago f WHERE cod_pago=CodPago AND forma_pago='DESCUENTO' AND forma_pago='INCREMENTO' ) THEN
UPDATE forma_pago f
SET f.dias_credito=DiasCredito,
f.forma_pago=FormaPago
WHERE f.cod_pago=CodPago; 
END IF;
END //

DROP PROCEDURE IF EXISTS consultar_forma_pago;//

CREATE PROCEDURE consultar_forma_pago(CodPago TINYINT(2))
BEGIN
IF CodPago IS NULL THEN
SELECT f.cod_pago AS `Cod. de Forma de Pago`, f.forma_pago AS `Forma de Pago`, f.dias_credito AS `Dias de Credito` FROM forma_pago f;
ELSE
SELECT f.cod_pago AS `Cod. de Forma de Pago`, f.forma_pago AS `Forma de Pago`, f.dias_credito AS `Dias de Credito` FROM forma_pago f WHERE f.cod_pago=CodPago;
END IF;
END //

DROP PROCEDURE IF EXISTS ingresar_proveedor;//

CREATE PROCEDURE ingresar_proveedor(nombre VARCHAR(50), RIF VARCHAR(12))
BEGIN
INSERT INTO proveedores VALUES (NULL,nombre,RIF);
END //

DROP PROCEDURE IF EXISTS actualizar_proveedor;//

CREATE PROCEDURE actualizar_proveedor(cod_proveedor TINYINT(2), nombre VARCHAR(50), RIF VARCHAR(12))
BEGIN
UPDATE proveedores p
SET p.nombre_proveedor=nombre,
p.RIF_proveedor=RIF
WHERE p.cod_proveedor=cod_proveedor;
END //

DROP PROCEDURE IF EXISTS consultar_proveedor;//

CREATE PROCEDURE consultar_proveedor(codp TINYINT(2))
BEGIN
IF codp IS NULL THEN
SELECT cod_proveedor AS `Cod. del Proveedor`, RIF_proveedor AS `RIF del Proveedor`, nombre_proveedor AS `Razon Social`  FROM proveedores;
ELSE
SELECT cod_proveedor AS `Cod. del Proveedor`, RIF_proveedor AS `RIF del Proveedor`, nombre_proveedor AS `Razon Social`  FROM proveedores WHERE cod_proveedor=codp;
END IF;
END //

-- </Procedimientos de Almacenado (Tablas Primarias)>

-- <Procedimientos de Almacenado (Tablas Secundarias)>
-- estos son los procedimientos de almacenado
-- que trabajan con las tablas secundarias de la
-- base de datos.

DROP PROCEDURE IF EXISTS ingresar_telefono;//

CREATE PROCEDURE ingresar_telefono(numero BIGINT(11), contacto VARCHAR(30), RIF VARCHAR(12))
BEGIN
INSERT INTO telefonos VALUES(numero,contacto,RIF);
END //

DROP PROCEDURE IF EXISTS buscar_telefono;//

CREATE PROCEDURE buscar_telefono(RIF VARCHAR(12))
BEGIN
SELECT t.numero AS `Numero de Telefono`, t.contacto AS `Persona de Contacto` FROM
telefonos t WHERE t.RIF=RIF;
END //

DROP PROCEDURE IF EXISTS ingresar_producto;//

CREATE PROCEDURE ingresar_producto(codp VARCHAR(10),des text,nom VARCHAR(30),id_IVA TINYINT(2))
BEGIN
INSERT INTO producto VALUES (codp,des,nom,id_IVA);
END //

DROP PROCEDURE IF EXISTS actualizar_producto;//

CREATE PROCEDURE actualizar_producto(codp VARCHAR(10),des text,nom VARCHAR(30),id_IVA TINYINT(2))
BEGIN
UPDATE producto p
SET p.descripcion=des,
p.nombre=nom,
p.id_IVA=id_IVA
WHERE cod_producto=codp;
END //

DROP PROCEDURE IF EXISTS consultar_productos;//

CREATE PROCEDURE consultar_productos(codp VARCHAR(10))
BEGIN
IF codp IS NULL THEN
SELECT p.cod_producto AS `Cod. del Producto`,
p.nombre AS `Producto`,
p.descripcion AS `Descripcion del Producto`,
a.IVA AS `IVA del Producto`,
IF(a.tipo_IVA IS NULL,'EXENTO',IF(a.tipo_IVA IS TRUE,'INCLUIDO','EXCLUIDO')) AS `Tipo de IVA`  FROM producto p
INNER JOIN IVA a USING (id_IVA);
ELSE
SELECT p.cod_producto AS `Cod. del Producto`,
p.nombre AS `Producto`,
p.descripcion AS `Descripcion del Producto`,
a.IVA AS `IVA del Producto`,
IF(a.tipo_IVA IS NULL,'EXENTO',IF(a.tipo_IVA IS TRUE,'INCLUIDO','EXCLUIDO')) AS `Tipo de IVA`  FROM producto p
INNER JOIN IVA a USING (id_IVA) WHERE p.cod_producto=codp;
END IF;
END //

DROP PROCEDURE IF EXISTS productos_disponibles;//

CREATE PROCEDURE productos_disponibles()
BEGIN
SELECT cod_producto AS `Cod. del Producto`,
nombre AS `Producto`,
descripcion AS `Descripcion del Producto`,
MAX(i.precio_venta)*(IF(a.tipo_IVA IS NULL,1,IF(a.tipo_IVA IS TRUE,1,(1+(IVA/100))))) AS `Precio de Venta`,
IVA AS `IVA del Producto`,
IF(a.tipo_IVA IS NULL,'EXENTO',IF(a.tipo_IVA IS TRUE,'INCLUIDO','EXCLUIDO')) AS `Tipo de IVA`,
IF(EXISTS(SELECT cantidad_actual FROM inventario WHERE cantidad_actual>0 AND cod_producto=i.cod_producto),'SI','NO') AS `Disponibilidad`
FROM inventario i JOIN producto p USING(cod_producto) JOIN IVA a USING(id_IVA)
WHERE i.cantidad_actual>0 OR i.numero_factura_proveedor IS NULL OR i.precio_venta=ALL(SELECT monto_unitario FROM pedido_producto WHERE cod_producto=i.cod_producto GROUP BY cod_producto HAVING MAX(id_producto)) GROUP BY i.cod_producto /*HAVING MAX(i.precio_venta)*/;
END //

DROP PROCEDURE IF EXISTS ingresar_factura_compra;//

CREATE PROCEDURE ingresar_factura_compra(NumFacturaProveedor BIGINT(10),fecha DATE, CodProveedor TINYINT(2))
BEGIN
INSERT INTO factura_proveedor VALUES (NumFacturaProveedor,fecha,CodProveedor);
END //

DROP PROCEDURE IF EXISTS consultar_factura_compra;//

CREATE PROCEDURE consultar_factura_compra(NumFactura BIGINT(10))
BEGIN
IF NumFactura IS NULL THEN
SELECT f.numero_factura_proveedor AS `Nro. Factura Proveedor`,
f.fecha AS `Fecha del Documento`,
p.nombre_proveedor AS `Razon Social`,
p.RIF_proveedor AS `RIF`
FROM factura_proveedor f JOIN proveedores p USING(cod_proveedor);
ELSE
SELECT f.numero_factura_proveedor AS `Nro. Factura Proveedor`,
f.fecha AS `Fecha del Documento`,
p.nombre_proveedor AS `Razon Social`,
p.RIF_proveedor AS `RIF`
FROM factura_proveedor f JOIN proveedores p USING(cod_proveedor)
WHERE f.numero_factura_proveedor=NumFactura;
END IF;
END //

DROP PROCEDURE IF EXISTS ingresar_inventario;//

CREATE PROCEDURE ingresar_inventario(codp VARCHAR(10),cant SMALLINT(4),precom DOUBLE,preven DOUBLE,numf BIGINT(10))
BEGIN
DECLARE cantidad SMALLINT(4);
IF EXISTS (SELECT * FROM inventario WHERE cod_producto=codp AND numero_factura_proveedor IS NULL) THEN
SET cantidad = -(SELECT cantidad_actual FROM inventario WHERE cod_producto=codp AND numero_factura_proveedor IS NULL);
IF cantidad>(cant) THEN
UPDATE inventario
SET cantidad_actual=-(cantidad-(cant))
WHERE cod_producto=(codp) AND numero_factura_proveedor IS NULL;
INSERT INTO inventario VALUES (codp,NULL,0,cant,precom,preven,numf);
ELSE
DELETE FROM inventario WHERE cod_producto=(codp) AND numero_factura_proveedor IS NULL;
INSERT INTO inventario VALUES (codp,NULL,((cant)-cantidad),cant,precom,preven,numf);
END IF;
ELSE
INSERT INTO inventario VALUES (codp,NULL,cant,cant,precom,preven,numf);
END IF;
END //

DROP PROCEDURE IF EXISTS actualizar_precios;//

CREATE PROCEDURE actualizar_precios(Lote BIGINT(10),Precio DOUBLE)
BEGIN
UPDATE inventario
SET precio_venta=Precio
WHERE cod_lote=Lote;
END //

DROP PROCEDURE IF EXISTS consultar_inventario;//

CREATE PROCEDURE consultar_inventario(NumFactura BIGINT(10))
BEGIN
IF NumFactura IS NULL THEN
SELECT i.cod_producto AS `Cod. Producto`,
p.nombre AS `Nombre del Producto`,
i.cod_lote AS `Cod. Lote`,
i.cantidad_actual AS `Cantidad Actual`,
i.cantidad_inicial AS `Cantidad Inicial`,
i.precio_compra AS `Precio de Compra`,
i.precio_venta AS `Precio de Venta`,
i.numero_factura_proveedor AS `Nro. de Factura del Proveedor` 
FROM inventario i JOIN producto p USING(cod_producto);
ELSE
SELECT i.cod_producto AS `Cod. Producto`,
p.nombre AS `Nombre del Producto`,
i.cod_lote AS `Cod. Lote`,
i.cantidad_actual AS `Cantidad Actual`,
i.cantidad_inicial AS `Cantidad Inicial`,
i.precio_compra AS `Precio de Compra`,
i.precio_venta AS `Precio de Venta`,
i.numero_factura_proveedor AS `Nro. de Factura del Proveedor` 
FROM inventario i JOIN producto p USING(cod_producto)
WHERE numero_factura_proveedor=NumFactura;
END IF;
END //

DROP PROCEDURE IF EXISTS ingresar_serial;//

CREATE PROCEDURE ingresar_serial(codl BIGINT(10),serial VARCHAR(10))
BEGIN
INSERT INTO seriales VALUES (codl,serial,NULL);
END //

DROP PROCEDURE IF EXISTS consultar_serial;//

CREATE PROCEDURE consultar_serial(CodLote BIGINT(10))
BEGIN
(SELECT s.cod_lote AS `Codigo de Lote`,
NULL AS `Cantidad Inicial`,
s.serial AS `Seriales`
FROM seriales s, inventario i WHERE s.cod_lote=CodLote AND s.cod_lote=i.cod_lote ORDER BY i.cod_lote)
UNION
(SELECT i.cod_lote AS `Codigo de Lote`,
i.cantidad_inicial AS `Cantidad Inicial`,
(SELECT COUNT(serial) FROM seriales WHERE cod_lote=CodLote LIMIT 1) AS `Seriales`
FROM inventario i WHERE i.cod_lote=CodLote ORDER BY i.cod_lote);
END //

DROP FUNCTION IF EXISTS ingresar_nota_entrega;//

CREATE FUNCTION ingresar_nota_entrega(numf BIGINT(10)) RETURNS BIGINT(10)
BEGIN
DECLARE fecha DATE;
SET fecha =(SELECT curdate());
INSERT INTO nota_entrega VALUES (NULL,fecha,numf);
RETURN LAST_INSERT_ID();
END //

DROP PROCEDURE IF EXISTS despachar;//

CREATE PROCEDURE despachar(serial VARCHAR(10), NumNota BIGINT(10))
BEGIN
UPDATE seriales
SET numero_nota_entrega = NumNota
WHERE seriales.serial=serial;
END //

DROP PROCEDURE IF EXISTS consultar_nota_entrega;//

CREATE PROCEDURE consultar_nota_entrega(NumNota BIGINT(10), NumFactura BIGINT(10))
BEGIN
IF NumNota IS NULL THEN
SELECT p.RIF AS `RIF`,
e.numero_factura AS `Nro. de Factura`,
e.numero_nota_entrega AS `Nro. Nota de Entrega`,
e.fecha AS `Fecha`
FROM nota_entrega e JOIN factura f USING(numero_factura) JOIN pedido p USING(numero_pedido)
WHERE f.numero_factura=NumFactura;
ELSEIF NumFactura IS NULL THEN
SELECT p.RIF AS `RIF`,
e.numero_factura AS `Nro. de Factura`,
e.numero_nota_entrega AS `Nro. Nota de Entrega`,
e.fecha AS `Fecha`
FROM nota_entrega e JOIN factura f USING(numero_factura) JOIN pedido p USING(numero_pedido)
WHERE e.numero_nota_entrega=NumNota;
END IF;
END //

DROP PROCEDURE IF EXISTS consultar_seriales_nota_entrega;//

CREATE PROCEDURE consultar_seriales_nota_entrega(NumNota BIGINT(10))
BEGIN
SELECT s.numero_nota_entrega AS `Nro. Nota de Entrega`,
i.cod_producto AS `Cod. Producto`,
p.nombre AS `Nombre del Producto`,
s.serial AS `Serial`
FROM seriales s JOIN inventario i USING(cod_lote) JOIN producto p USING(cod_producto) WHERE numero_nota_entrega=NumNota;
END //

DROP PROCEDURE IF EXISTS productos_por_entregar;//

CREATE PROCEDURE productos_por_entregar(NumFactura BIGINT(10))
BEGIN
SELECT f.cod_producto AS `Cod. Producto`,
(SELECT p.nombre FROM producto p WHERE p.cod_producto=f.cod_producto) AS `Producto`,
(f.cantidad_producto-(SELECT IF(COUNT(s.serial) IS NULL,0,COUNT(s.serial)) AS `serial` FROM seriales s JOIN inventario i USING(cod_lote) JOIN nota_entrega n USING(numero_nota_entrega) WHERE n.numero_factura=f.numero_factura AND i.cod_producto=f.cod_producto LIMIT 1)) AS `Cantidad`
FROM factura_producto f
WHERE f.numero_factura=NumFactura AND f.cantidad_producto>=ALL(SELECT IF(COUNT(s.serial) IS NULL,0,COUNT(s.serial)) AS `serial` FROM seriales s JOIN inventario i USING(cod_lote) JOIN nota_entrega n USING(numero_nota_entrega) WHERE n.numero_factura=f.numero_factura AND i.cod_producto=f.cod_producto);
END //

DROP PROCEDURE IF EXISTS seriales_disponibles;//

CREATE PROCEDURE seriales_disponibles(CodProducto VARCHAR(10))
BEGIN
IF CodProducto IS NULL THEN
SELECT i.cod_producto, s.cod_lote, s.serial FROM seriales s JOIN inventario i USING(cod_lote) WHERE s.numero_nota_entrega IS NULL;
ELSE
SELECT i.cod_producto, s.cod_lote, s.serial FROM seriales s JOIN inventario i USING(cod_lote) WHERE s.numero_nota_entrega IS NULL AND i.cod_producto=CodProducto;
END IF;
END //

DROP FUNCTION IF EXISTS ingresar_pedido;//

CREATE FUNCTION ingresar_pedido(RIF VARCHAR(12),vig DATE, dir text) RETURNS BIGINT(10)
BEGIN
DECLARE fecha DATE;
SET fecha=(SELECT curdate());
INSERT INTO pedido VALUES(NULL,RIF,fecha,vig,dir);
RETURN LAST_INSERT_ID();
END //

DROP PROCEDURE IF EXISTS ingresar_pedido_pago;//

CREATE PROCEDURE ingresar_pedido_pago(nump BIGINT(10),codpago TINYINT(2),monto DOUBLE, confirmacion BIGINT(10))
BEGIN
IF EXISTS(SELECT * FROM forma_pago WHERE cod_pago=codpago AND forma_pago='INCREMENTO') THEN
INSERT INTO pedido_pago VALUES(NULL,nump,codpago,monto,NULL);
INSERT INTO pedido_producto VALUES(NULL,nump,NULL,NULL,monto);
ELSEIF EXISTS(SELECT * FROM pedido_pago WHERE numero_pedido=nump AND cod_pago=codpago) AND monto=0 THEN
DELETE FROM pedido_pago WHERE numero_pedido=nump AND cod_pago=codpago;
ELSEIF EXISTS(SELECT * FROM pedido_pago WHERE numero_pedido=nump AND cod_pago=codpago) AND monto>0 THEN
UPDATE pedido_pago
SET monto_unitario=monto
WHERE numero_pedido=nump AND cod_pago=codpago;
ELSE
INSERT INTO pedido_pago VALUES(NULL,nump,codpago,monto,confirmacion);
END IF;
END //

DROP PROCEDURE IF EXISTS modificar_pedido_pago;//

CREATE PROCEDURE modificar_pedido_pago(IdPago BIGINT,monto DOUBLE,confirmacion BIGINT(10))
BEGIN
IF (NOT EXISTS(SELECT f.numero_factura FROM pedido p JOIN pedido_pago a USING(numero_pedido) JOIN factura f ON p.numero_pedido=f.numero_pedido WHERE a.id_pago=IdPago AND NOT EXISTS(SELECT numero_nota_credito FROM nota_credito WHERE numero_factura=f.numero_factura))) THEN
IF monto=0 THEN
DELETE FROM pedido_pago WHERE p.id_pago=IdPago;
ELSE
UPDATE pedido_pago
SET monto_unitario=monto,
confirmacion_pago=confirmacion
WHERE id_pago=IdPago;
END IF;
END IF;
END//

DROP PROCEDURE IF EXISTS ingresar_pedido_producto;//

CREATE PROCEDURE ingresar_pedido_producto(NumPedido BIGINT(10), CodProducto VARCHAR(10), Cant SMALLINT(4))
BEGIN
DECLARE precio DOUBLE;
IF EXISTS(SELECT * FROM inventario WHERE cod_producto=CodProducto AND cantidad_actual>0) THEN
SET precio = (SELECT MAX(precio_venta) FROM inventario WHERE cod_producto=CodProducto AND cantidad_actual>0 GROUP BY cod_producto LIMIT 1);
ELSEIF EXISTS(SELECT * FROM inventario WHERE cod_producto=CodProducto AND numero_factura_proveedor IS NULL) THEN
SET precio = (SELECT precio_venta FROM inventario WHERE cod_producto=CodProducto AND numero_factura_proveedor IS NULL LIMIT 1);
ELSE
SET precio = (SELECT monto_unitario FROM pedido_producto WHERE cod_producto=CodProducto GROUP BY cod_producto HAVING MAX(id_producto) LIMIT 1);
END IF;
IF EXISTS(SELECT * FROM pedido_producto WHERE numero_pedido=NumPedido AND cod_producto=CodProducto) AND Cant=0 THEN
DELETE FROM pedido_producto WHERE numero_pedido=NumPedido AND cod_producto=CodProducto;
ELSEIF EXISTS(SELECT * FROM pedido_producto WHERE numero_pedido=NumPedido AND cod_producto=CodProducto) AND Cant>0 THEN
UPDATE pedido_producto
SET cantidad_producto=Cant, monto_unitario=precio
WHERE numero_pedido=NumPedido AND cod_producto=CodProducto LIMIT 1;
ELSE
INSERT INTO pedido_producto VALUES(NULL,NumPedido,CodProducto,cant,precio);
END IF;
END //

DROP PROCEDURE IF EXISTS modificar_pedido_producto;//

CREATE PROCEDURE modificar_pedido_producto(IdProducto BIGINT,cant SMALLINT(4))
BEGIN
IF NOT EXISTS(SELECT f.numero_factura FROM pedido p JOIN pedido_producto o USING(numero_pedido) JOIN factura f ON p.numero_pedido=f.numero_pedido WHERE o.id_producto=IdProducto AND NOT EXISTS(SELECT numero_nota_credito FROM nota_credito WHERE numero_factura=f.numero_factura)) THEN
IF cant=0 THEN
DELETE FROM pedido_producto WHERE id_producto=IdProducto;
ELSE
UPDATE pedido_producto
SET cantidad_producto=cant
WHERE id_producto=IdProducto;
END IF;
END IF;
END//

DROP EVENT IF EXISTS reintegrar_inventario;//

CREATE EVENT reintegrar_inventario
ON SCHEDULE EVERY 1 DAY DO
BEGIN
DECLARE cant SMALLINT(4);
DECLARE num INTEGER;
SET num=(SELECT MAX(id_producto) FROM pedido_producto);
WHILE (num>0) DO
IF ((SELECT CURDATE())=ALL(SELECT a.vigencia FROM pedido a JOIN pedido_producto b USING(numero_pedido) WHERE b.id_producto=num AND NOT EXISTS(SELECT * FROM factura WHERE numero_pedido=a.numero_pedido))) THEN
SET cant=(SELECT b.catidad_producto FROM pedido_producto b WHERE b.id_producto=num);
WHILE cant>0 DO
IF cant<ANY(SELECT (cantidad_inicial-cantidad_actual) FROM inventario WHERE precio_venta=(SELECT precio_unitario FROM pedido_producto WHERE id_producto=num) AND cod_producto=(SELECT cod_producto FROM pedido_producto WHERE id_producto=num) AND cantidad_inicial>cantidad_actual) THEN
UPDATE inventario
SET cantidad_actual=cantidad_actual+cant
WHERE precio_venta=(SELECT precio_unitario FROM pedido_producto WHERE id_producto=num LIMIT 1) AND cod_producto=(SELECT cod_producto FROM pedido_producto WHERE id_producto=num LIMIT 1) AND cantidad_inicial>cantidad_actual LIMIT 1;
SET cant=0;
ELSE
SET cant=cant-(SELECT (cantidad_inicial-cantidad_actual) FROM inventario WHERE precio_venta=(SELECT precio_unitario FROM pedido_producto WHERE id_producto=num LIMIT 1) AND cod_producto=(SELECT cod_producto FROM pedido_producto WHERE id_producto=num LIMIT 1) AND cantidad_inicial>cantidad_actual LIMIT 1);
UPDATE inventario
SET cantidad_actual=cantidad_inicial
WHERE precio_venta=(SELECT precio_unitario FROM pedido_producto WHERE id_producto=num LIMIT 1) AND cod_producto=(SELECT cod_producto FROM pedido_producto WHERE id_producto=num LIMIT 1) AND cantidad_inicial>cantidad_actual LIMIT 1;
END IF;
END WHILE;
END IF;
SET num=num-1;
END WHILE; 
END //

DROP TRIGGER IF EXISTS validar_modificar_pedido_producto;//

CREATE TRIGGER validar_modificar_pedido_producto BEFORE UPDATE ON pedido_producto
FOR EACH ROW BEGIN
DECLARE precio DOUBLE;
DECLARE existencia SMALLINT(4);
DECLARE cant SMALLINT(4);
IF NEW.cantidad_producto>ALL(SELECT cantidad_producto FROM pedido_producto WHERE numero_pedido=OLD.numero_pedido AND cod_producto=OLD.cod_producto) THEN
SET cant = (NEW.cantidad_producto-OLD.cantidad_producto);
--
WHILE (cant>0) DO
IF EXISTS(SELECT cantidad_actual FROM inventario WHERE cod_producto=NEW.cod_producto AND cantidad_actual>0) THEN
SET precio=(SELECT MIN(precio_venta) FROM inventario WHERE cod_producto=NEW.cod_producto AND cantidad_actual>0 LIMIT 1);
SET existencia=(SELECT cantidad_actual FROM inventario WHERE cod_producto=NEW.cod_producto AND cantidad_actual>0 AND precio_venta=precio LIMIT 1);
--
IF cant>=existencia THEN
SET cant=cant-existencia;
UPDATE inventario
SET cantidad_actual=0
WHERE cod_producto=NEW.cod_producto AND cantidad_actual>0 AND precio_venta=precio LIMIT 1;
ELSEIF cant<existencia THEN
UPDATE inventario
SET cantidad_actual=(cantidad_actual-cant)
WHERE cod_producto=NEW.cod_producto AND cantidad_actual>0 AND precio_venta=precio LIMIT 1;
SET cant=0;
END IF;
--
ELSEIF EXISTS(SELECT * FROM inventario WHERE cod_producto=NEW.cod_producto AND numero_factura_proveedor IS NULL LIMIT 1) THEN
UPDATE inventario
SET cantidad_actual=(cantidad_actual-(cant))
WHERE cod_producto=NEW.cod_producto AND numero_factura_proveedor IS NULL;
SET cant=0;
ELSE
INSERT INTO inventario VALUES(NEW.cod_producto,NULL,-(cant),NULL,NULL,(NEW.monto_unitario),NULL);
SET cant=0;
END IF;
END WHILE;
--
ELSEIF NEW.cantidad_producto<ALL(SELECT cantidad_producto FROM pedido_producto WHERE numero_pedido=OLD.numero_pedido AND cod_producto=OLD.cod_producto) THEN
UPDATE inventario
SET cantidad_actual = cantidad_actual + NEW.cantidad_producto
WHERE precio_venta=OLD.monto_unitario AND NEW.cantidad_producto<=(cantidad_inicial-cantidad_actual) AND cod_producto=OLD.cod_producto LIMIT 1;
END IF;
END//

DROP TRIGGER IF EXISTS validar_borrar_pedido_producto;//

CREATE TRIGGER validar_borrar_pedido_producto BEFORE DELETE ON pedido_producto
FOR EACH ROW BEGIN
UPDATE inventario
SET cantidad_actual = cantidad_actual + OLD.cantidad_producto
WHERE precio_venta=OLD.monto_unitario AND OLD.cantidad_producto<=(cantidad_inicial-cantidad_actual) AND cod_producto=OLD.cod_producto LIMIT 1;
END //

DROP TRIGGER IF EXISTS validar_pedido_producto;//

CREATE TRIGGER validar_pedido_producto BEFORE INSERT ON pedido_producto
FOR EACH ROW BEGIN
DECLARE precio DOUBLE;
DECLARE existencia SMALLINT(4);
DECLARE cant SMALLINT(4);
SET cant = NEW.cantidad_producto;
--
WHILE (cant>0) DO
IF EXISTS(SELECT cantidad_actual FROM inventario WHERE cod_producto=NEW.cod_producto AND cantidad_actual>0) THEN
SET precio=(SELECT MIN(precio_venta) FROM inventario WHERE cod_producto=NEW.cod_producto AND cantidad_actual>0 LIMIT 1);
SET existencia=(SELECT cantidad_actual FROM inventario WHERE cod_producto=NEW.cod_producto AND cantidad_actual>0 AND precio_venta=precio LIMIT 1);
IF cant>=existencia THEN
SET cant=cant-existencia;
UPDATE inventario
SET cantidad_actual=0
WHERE cod_producto=NEW.cod_producto AND cantidad_actual>0 AND precio_venta=precio LIMIT 1;
ELSEIF cant<existencia THEN
UPDATE inventario
SET cantidad_actual=(cantidad_actual-cant)
WHERE cod_producto=NEW.cod_producto AND cantidad_actual>0 AND precio_venta=precio LIMIT 1;
SET cant=0;
END IF;
ELSEIF EXISTS(SELECT * FROM inventario WHERE cod_producto=NEW.cod_producto AND numero_factura_proveedor IS NULL LIMIT 1) THEN
UPDATE inventario
SET cantidad_actual=(cantidad_actual-(cant))
WHERE cod_producto=NEW.cod_producto AND numero_factura_proveedor IS NULL;
SET cant=0;
ELSE
INSERT INTO inventario VALUES(NEW.cod_producto,NULL,-(cant),NULL,NULL,(NEW.monto_unitario),NULL);
SET cant=0;
END IF;
END WHILE;
END //

DROP PROCEDURE IF EXISTS consultar_pedido;//

CREATE PROCEDURE consultar_pedido(NumPedido BIGINT(10))
BEGIN
IF NumPedido IS NULL THEN
SELECT p.numero_pedido AS `N. Pedido`,
p.RIF AS `RIF`,
m.Razon_Social AS `Razon Social`,
p.direccion_envio AS `Direccion de Envio`,
p.fecha AS `Fecha`,
p.vigencia AS `Vigencia`,
IF(EXISTS(SELECT * FROM factura a WHERE a.numero_pedido=p.numero_pedido AND NOT EXISTS(SELECT * FROM nota_credito n WHERE n.numero_factura=a.numero_factura AND NOT EXISTS(SELECT * FROM nota_credito_producto WHERE numero_nota_credito=n.numero_nota_credito))),'FACTURADO','NO FACTURADO') AS `Status`
FROM pedido p JOIN maestro_cliente m USING(RIF);
ELSE
SELECT p.numero_pedido AS `N. Pedido`,
p.RIF AS `RIF`,
m.Razon_Social AS `Razon Social`,
p.direccion_envio AS `Direccion de Envio`,
p.fecha AS `Fecha`,
p.vigencia AS `Vigencia`,
IF(EXISTS(SELECT * FROM factura a WHERE a.numero_pedido=p.numero_pedido AND NOT EXISTS(SELECT * FROM nota_credito n WHERE n.numero_factura=a.numero_factura AND NOT EXISTS(SELECT * FROM nota_credito_producto WHERE numero_nota_credito=n.numero_nota_credito))),'FACTURADO','NO FACTURADO') AS `Status`
FROM pedido p JOIN maestro_cliente m USING(RIF) WHERE p.numero_pedido=NumPedido;
END IF;
END //

DROP PROCEDURE IF EXISTS consultar_pedido_pago;//

CREATE PROCEDURE consultar_pedido_pago(NumPedido BIGINT(10))
BEGIN
SELECT p.id_pago AS `ID Pago`,
p.numero_pedido AS `Nro. de Pedido`,
f.cod_pago AS `Cod. de Pago`,
f.forma_pago AS `Forma de Pago`,
p.monto_unitario AS `Monto`,
p.confirmacion_pago AS `Nro. de confirmacion`,
f.dias_credito AS `Dias de Credito`
FROM pedido_pago p JOIN forma_pago f USING(cod_pago) WHERE numero_pedido=NumPedido;
END //

DROP PROCEDURE IF EXISTS consultar_pedido_productos;//

CREATE PROCEDURE consultar_pedido_productos(NumPedido BIGINT(10))
BEGIN
SELECT a.id_producto AS `ID Producto`,
a.numero_pedido AS `Nro. de Pedido`,
a.cod_producto AS `Cod. del Producto`,
a.cantidad_producto AS `Cantidad del Producto`,
IF(a.cantidad_producto IS NULL,a.monto_unitario,a.monto_unitario*IF(EXISTS(SELECT * FROM IVA v JOIN producto p USING(id_IVA) WHERE v.tipo_IVA IS NULL AND a.cod_producto=p.cod_producto),1,IF(EXISTS(SELECT * FROM IVA v JOIN producto p USING(id_IVA) WHERE v.tipo_IVA IS TRUE AND a.cod_producto=p.cod_producto),1,(1+((SELECT v.IVA FROM IVA v JOIN producto p USING(id_IVA) WHERE a.cod_producto=p.cod_producto LIMIT 1)/100))))) AS `Monto Unitario`,
a.cantidad_producto*(a.monto_unitario*IF(EXISTS(SELECT * FROM IVA v JOIN producto p USING(id_IVA) WHERE v.tipo_IVA IS NULL AND a.cod_producto=p.cod_producto),1,IF(EXISTS(SELECT * FROM IVA v JOIN producto p USING(id_IVA) WHERE v.tipo_IVA IS TRUE AND a.cod_producto=p.cod_producto),1,(1+((SELECT v.IVA FROM IVA v JOIN producto p USING(id_IVA) WHERE a.cod_producto=p.cod_producto LIMIT 1)/100))))) AS `Total`,
(SELECT v.IVA FROM IVA v JOIN producto p USING(id_IVA) WHERE a.cod_producto=p.cod_producto LIMIT 1) AS `IVA del Producto`,
IF(a.cantidad_producto IS NULL,NULL,IF(EXISTS(SELECT * FROM IVA v JOIN producto p USING(id_IVA) WHERE v.tipo_IVA IS NULL AND a.cod_producto=p.cod_producto),'EXENTO',IF(EXISTS(SELECT * FROM IVA v JOIN producto p USING(id_IVA) WHERE v.tipo_IVA IS TRUE AND a.cod_producto=p.cod_producto),'INCLUIDO','EXCLUIDO'))) AS `Tipo de IVA`
FROM pedido_producto a WHERE a.numero_pedido=NumPedido;
END //

DROP PROCEDURE IF EXISTS ingresar_factura;//

CREATE PROCEDURE ingresar_factura(NumPedido BIGINT(10))
BEGIN
DECLARE fecha DATE;
DECLARE monto DOUBLE;
DECLARE precio DOUBLE;
SET fecha = (SELECT curdate());
SET monto = (SELECT SUM(IF(a.cantidad_producto IS NULL,1,a.cantidad_producto)*IF(a.cantidad_producto IS NULL,a.monto_unitario,(a.monto_unitario*IF(EXISTS(SELECT * FROM IVA v JOIN producto p USING(id_IVA) WHERE v.tipo_IVA IS NULL AND a.cod_producto=p.cod_producto),1,IF(EXISTS(SELECT * FROM IVA v JOIN producto p USING(id_IVA) WHERE v.tipo_IVA IS TRUE AND a.cod_producto=p.cod_producto),1,(1+((SELECT v.IVA FROM IVA v JOIN producto p USING(id_IVA) WHERE a.cod_producto=p.cod_producto LIMIT 1)/100))))))) FROM pedido_producto a  WHERE a.numero_pedido=NumPedido LIMIT 1);
SET precio = (SELECT SUM(monto_unitario) FROM pedido_pago WHERE numero_pedido=NumPedido LIMIT 1);
IF monto=precio THEN
INSERT INTO factura VALUES (NULL,fecha,NumPedido);
END IF;
END //

DROP PROCEDURE IF EXISTS ingresar_factura_pago;//

CREATE PROCEDURE ingresar_factura_pago(NumPedido BIGINT(10))
BEGIN
INSERT INTO factura_pago (id_pago,numero_factura,cod_pago,monto_unitario,confirmacion_pago)
SELECT NULL,f.numero_factura,p.cod_pago,p.monto_unitario,p.confirmacion_pago FROM pedido_pago p JOIN factura f ON p.numero_pedido=f.numero_pedido WHERE f.numero_pedido=NumPedido;
END //

DROP TRIGGER IF EXISTS validar_factura_pago;//

CREATE TRIGGER validar_factura_pago AFTER INSERT ON factura_pago
FOR EACH ROW BEGIN
IF EXISTS(SELECT dias_credito FROM forma_pago WHERE dias_credito IS NOT NULL AND cod_pago=NEW.cod_pago LIMIT 1) THEN
INSERT INTO cuentas_cobrar VALUES(NEW.id_pago,FALSE);
END IF;
END //

DROP PROCEDURE IF EXISTS ingresar_factura_producto;//

CREATE PROCEDURE ingresar_factura_producto(NumPedido BIGINT(10))
BEGIN
INSERT INTO factura_producto (id_producto,numero_factura,cod_producto,cantidad_producto,monto_unitario,id_IVA)
SELECT NULL,f.numero_factura,p.cod_producto,p.cantidad_producto,p.monto_unitario,(SELECT x.id_IVA FROM producto x WHERE x.cod_producto=p.cod_producto) AS `IVA` FROM pedido_producto p JOIN factura f ON p.numero_pedido=f.numero_pedido WHERE f.numero_pedido=NumPedido;
END //

DROP TRIGGER IF EXISTS validar_factura_producto;//

CREATE TRIGGER validar_factura_producto BEFORE INSERT ON factura_producto
FOR EACH ROW BEGIN
DECLARE precio DOUBLE;
DECLARE existencia SMALLINT(4);
DECLARE cant SMALLINT(4);
DECLARE fecha DATE;
SET cant = NEW.cantidad_producto;
SET fecha=CURDATE();
IF fecha>=ALL(SELECT p.vigencia FROM factura f JOIN pedido p USING(numero_pedido) WHERE numero_factura=NEW.numero_factura) THEN
WHILE (cant>0) DO
IF EXISTS(SELECT cantidad_actual FROM inventario WHERE cod_producto=NEW.cod_producto AND cantidad_actual>0) THEN
SET precio=(SELECT MIN(precio_venta) FROM inventario WHERE cod_producto=NEW.cod_producto AND cantidad_actual>0 LIMIT 1);
SET existencia=(SELECT cantidad_actual FROM inventario WHERE cod_producto=NEW.cod_producto AND cantidad_actual>0 AND precio_venta=precio LIMIT 1);
IF cant>existencia THEN
SET cant=cant-existencia;
UPDATE inventario
SET cantidad_actual=0
WHERE cod_producto=NEW.cod_producto AND cantidad_actual>0 AND precio_venta=precio LIMIT 1;
ELSEIF cant<existencia THEN
UPDATE inventario
SET cantidad_actual=(cantidad_actual-cant)
WHERE cod_producto=NEW.cod_producto AND cantidad_actual>0 AND precio_venta=precio LIMIT 1;
SET cant=0;
END IF;
ELSEIF EXISTS(SELECT * FROM inventario WHERE cod_producto=NEW.cod_producto AND numero_factura_proveedor IS NULL LIMIT 1) THEN
UPDATE inventario
SET cantidad_actual=(cantidad_actual-(cant))
WHERE cod_producto=NEW.cod_producto AND numero_factura_proveedor IS NULL;
SET cant=0;
ELSE
INSERT INTO inventario VALUES(NEW.cod_producto,NULL,-(cant),NULL,NULL,(NEW.monto_unitario),NULL);
SET cant=0;
END IF;
END WHILE;
END IF;
END //

DROP PROCEDURE IF EXISTS consultar_factura;//

CREATE PROCEDURE consultar_factura(NumFactura BIGINT(10))
BEGIN
IF NumFactura IS NULL THEN
SELECT p.RIF AS `RIF`,
m.Razon_Social AS `Razon Social`,
f.fecha AS `Fecha`,
f.numero_factura AS `N. Factura`,
f.numero_pedido AS `N. Pedido`,
IF(exists(SELECT * FROM nota_credito a WHERE a.numero_factura=f.numero_factura LIMIT 1),
IF(exists(SELECT * FROM nota_credito_producto a JOIN factura_producto b USING(id_producto) WHERE b.numero_factura=f.numero_factura LIMIT 1),
IF(exists(SELECT * FROM nota_credito_producto a JOIN factura_producto b USING(id_producto) WHERE b.numero_factura=f.numero_factura AND b.monto_unitario>a.monto_unitario LIMIT 1)
,'DIFERENCIA DE PRECIO','DEVOLUCION'),'ANULACION'),'NINGUNA') AS `Coreccion`,
IF(EXISTS(SELECT serial FROM seriales s JOIN nota_entrega a USING(numero_nota_entrega) WHERE a.numero_factura=f.numero_factura LIMIT 1),
IF((SELECT IF(COUNT(serial) IS NULL,0,COUNT(serial)) AS `serial` FROM seriales s JOIN nota_entrega a USING(numero_nota_entrega) WHERE a.numero_factura=f.numero_factura LIMIT 1)<>(SELECT IF(SUM(cantidad_producto) IS NULL,0,SUM(cantidad_producto)) AS `Cantidad` FROM factura_producto WHERE numero_factura=f.numero_factura LIMIT 1),
'PARCIALMENTE','SI'),'NO') AS `Despachado`
FROM factura f JOIN pedido p USING(numero_pedido) JOIN maestro_cliente m USING(RIF);
ELSE

SELECT p.RIF AS `RIF`,
m.Razon_Social AS `Razon Social`,
f.fecha AS `Fecha`,
f.numero_factura AS `N. Factura`,
f.numero_pedido AS `N. Pedido`,
IF(exists(SELECT * FROM nota_credito a WHERE a.numero_factura=f.numero_factura LIMIT 1),
IF(exists(SELECT * FROM nota_credito_producto a JOIN factura_producto b USING(id_producto) WHERE b.numero_factura=f.numero_factura LIMIT 1),
IF(exists(SELECT * FROM nota_credito_producto a JOIN factura_producto b USING(id_producto) WHERE b.numero_factura=f.numero_factura AND b.monto_unitario>a.monto_unitario LIMIT 1)
,'DIFERENCIA DE PRECIO','DEVOLUCION'),'ANULACION'),'NINGUNA') AS `Coreccion`,
IF(EXISTS(SELECT serial FROM seriales s JOIN nota_entrega a USING(numero_nota_entrega) WHERE a.numero_factura=f.numero_factura LIMIT 1),
IF((SELECT IF(COUNT(serial) IS NULL,0,COUNT(serial)) AS `serial` FROM seriales s JOIN nota_entrega a USING(numero_nota_entrega) WHERE a.numero_factura=f.numero_factura LIMIT 1)<>(SELECT IF(SUM(cantidad_producto) IS NULL,0,SUM(cantidad_producto)) AS `Cantidad` FROM factura_producto WHERE numero_factura=f.numero_factura LIMIT 1),
'PARCIALMENTE','SI'),'NO') AS `Despachado`
FROM factura f JOIN pedido p USING(numero_pedido) JOIN maestro_cliente m USING(RIF) WHERE f.numero_factura=NumFactura;
END IF;
END//

DROP PROCEDURE IF EXISTS consultar_factura_pago;//

CREATE PROCEDURE consultar_factura_pago(NumFactura BIGINT(10))
BEGIN
SELECT f.id_pago AS `ID. Pago`,
f.numero_factura AS `Nro. de Factura`,
p.forma_pago AS `Forma de Pago`,
f.monto_unitario AS `Monto Unitario`,
f.confirmacion_pago AS `Nro. de Confirmacion`,
p.dias_credito AS `Dias de Credito`,
IF(p.dias_credito IS NOT NULL,
(SELECT b.pagado FROM cuentas_cobrar b WHERE b.id_pago=f.id_pago),NULL) AS `Pagado`
FROM factura_pago f JOIN forma_pago p USING(cod_pago) WHERE numero_factura=NumFactura;
END //

DROP PROCEDURE IF EXISTS consultar_factura_productos;//

CREATE PROCEDURE consultar_factura_productos(NumFactura BIGINT(10))
BEGIN
(SELECT f.id_producto AS `ID Producto`,
f.numero_factura AS `N. Factura`,
f.cod_producto AS `Cod. del Producto`,
(SELECT p.nombre FROM producto p WHERE p.cod_producto=f.cod_producto) AS `Producto`,
f.cantidad_producto AS `Cantidad`,
IF(f.cantidad_producto IS NULL,f.monto_unitario,f.monto_unitario*IF(EXISTS(SELECT * FROM IVA v WHERE v.tipo_IVA IS NULL AND v.id_IVA=f.id_IVA),1,IF(EXISTS(SELECT * FROM IVA v WHERE v.tipo_IVA IS TRUE AND v.id_IVA=f.id_IVA),1,(1+((SELECT v.IVA FROM IVA v WHERE v.id_IVA=f.id_IVA LIMIT 1)/100))))) AS `Monto Unitario`,
(f.cantidad_producto*(f.monto_unitario*IF(EXISTS(SELECT * FROM IVA v JOIN producto p USING(id_IVA) WHERE v.tipo_IVA IS NULL AND f.cod_producto=p.cod_producto),1,IF(EXISTS(SELECT * FROM IVA v JOIN producto p USING(id_IVA) WHERE v.tipo_IVA IS TRUE AND f.cod_producto=p.cod_producto),1,(1+((SELECT v.IVA FROM IVA v JOIN producto p USING(id_IVA) WHERE f.cod_producto=p.cod_producto LIMIT 1)/100)))))) AS `Total producto`,
(SELECT v.IVA FROM IVA v WHERE v.id_IVA=f.id_IVA LIMIT 1) AS `IVA`,
IF(f.cantidad_producto IS NULL,NULL,IF(EXISTS(SELECT * FROM IVA v WHERE v.tipo_IVA IS NULL AND v.id_IVA=f.id_IVA),'EXENTO',IF(EXISTS(SELECT * FROM IVA v WHERE v.tipo_IVA IS TRUE AND v.id_IVA=f.id_IVA),'INCLUIDO','EXCLUIDO'))) AS `Tipo de IVA`
FROM factura_producto f WHERE f.numero_factura=NumFactura)
UNION(
SELECT '-----' AS `ID Producto`,
'-----' AS `N. Factura`,
'-----' AS `Cod. del Producto`,
'-----' AS `Producto`,
'TOTAL:' AS `Cantidad`,
(SELECT SUM(f.monto_unitario*(IF(a.tipo_iva IS NULL,(1),IF(a.tipo_iva IS TRUE,(1-(a.IVA/100)),(1)))))
FROM factura_producto f JOIN producto p USING(cod_producto) JOIN IVA a ON f.id_IVA=a.id_IVA WHERE numero_factura=NumFactura) AS `Monto`,
concat('+ ',(SELECT SUM(f.monto_unitario*(IF(a.tipo_iva IS NULL,(0),IF(a.tipo_iva IS TRUE,(a.IVA/100),(a.IVA/100)))))
FROM factura_producto f JOIN producto p USING(cod_producto) JOIN IVA a ON f.id_IVA=a.id_IVA WHERE numero_factura=NumFactura)) AS `IVA`,
concat('= ',(SELECT SUM(f.monto_unitario*(IF(a.tipo_iva IS NULL,(1),IF(a.tipo_iva IS TRUE,(1),(1+(a.IVA/100))))))
FROM factura_producto f JOIN producto p USING(cod_producto) JOIN IVA a ON f.id_IVA=a.id_IVA WHERE numero_factura=NumFactura)) AS `Tipo de IVA`);
END //

DROP PROCEDURE IF EXISTS actualizar_cuentas_cobrar;//

CREATE PROCEDURE actualizar_cuentas_cobrar(id_pago BIGINT)
BEGIN
UPDATE cuentas_cobrar c
SET c.pagado=true
WHERE c.id_pago=id_pago;
END //

DROP PROCEDURE IF EXISTS consultar_cuentas_cobrar;//

CREATE PROCEDURE consultar_cuentas_cobrar(RIF VARCHAR(12))
BEGIN
IF RIF IS NULL THEN
SELECT p.RIF AS `RIF`,
c.id_pago AS `ID Pago`,
o.forma_pago AS `Forma de Pago`,
a.monto_unitario AS `Monto`,
IF(o.dias_credito<=30,IF(c.pagado IS FALSE,'NO','SI'),NULL) AS `30 o menos`,
IF((o.dias_credito<=45 AND o.dias_credito>30),IF(c.pagado IS FALSE,'NO','SI'),NULL) AS `45 o menos`,
IF((o.dias_credito<=60 AND o.dias_credito>45),IF(c.pagado IS FALSE,'NO','SI'),NULL) AS `60 o menos`,
IF((o.dias_credito<=90 AND o.dias_credito>60),IF(c.pagado IS FALSE,'NO','SI'),NULL) AS `90 o menos`,
IF(o.dias_credito>90,IF(c.pagado IS FALSE,'NO','SI'),NULL) AS `mas de 90`
FROM factura f
JOIN pedido p ON p.numero_pedido=f.numero_pedido
JOIN factura_pago a ON a.numero_factura=f.numero_factura
JOIN cuentas_cobrar c ON c.id_pago=a.id_pago
JOIN forma_pago o ON o.cod_pago=a.cod_pago;
ELSE
SELECT p.RIF AS `RIF`,
c.id_pago AS `ID Pago`,
o.forma_pago AS `Forma de Pago`,
a.monto_unitario AS `Monto`,
IF(o.dias_credito<=30,IF(c.pagado IS FALSE,'NO','SI'),NULL) AS `30 o menos`,
IF((o.dias_credito<=45 AND o.dias_credito>30),IF(c.pagado IS FALSE,'NO','SI'),NULL) AS `45 o menos`,
IF((o.dias_credito<=60 AND o.dias_credito>45),IF(c.pagado IS FALSE,'NO','SI'),NULL) AS `60 o menos`,
IF((o.dias_credito<=90 AND o.dias_credito>60),IF(c.pagado IS FALSE,'NO','SI'),NULL) AS `90 o menos`,
IF(o.dias_credito>90,IF(c.pagado IS FALSE,'NO','SI'),NULL) AS `mas de 90`
FROM factura f
JOIN pedido p ON p.numero_pedido=f.numero_pedido
JOIN factura_pago a ON a.numero_factura=f.numero_factura
JOIN cuentas_cobrar c ON c.id_pago=a.id_pago
JOIN forma_pago o ON o.cod_pago=a.cod_pago
WHERE p.RIF=RIF;
END IF;
END //

DROP PROCEDURE IF EXISTS ingresar_nota_credito;//

CREATE PROCEDURE ingresar_nota_credito(NumFactura BIGINT(10))
BEGIN
DECLARE fecha DATE;
SET fecha=(SELECT curdate());
INSERT INTO nota_credito VALUES (NumFactura,NULL,fecha);
END //

DROP PROCEDURE IF EXISTS ingresar_nota_credito_producto;//

CREATE PROCEDURE ingresar_nota_credito_producto(NumFactura BIGINT(10),id_producto BIGINT,cant SMALLINT(4),monto DOUBLE)
BEGIN
DECLARE NumeroNota BIGINT(10);
SET NumeroNota = (SELECT numero_nota_credito FROM nota_credito WHERE numero_factura=NumFactura);
INSERT INTO nota_credito_producto VALUES (id_producto,NumeroNota,cant,monto);
END //

DROP PROCEDURE IF EXISTS consultar_nota_credito;//

CREATE PROCEDURE consultar_nota_credito(NumeroNota BIGINT(10))
BEGIN
IF NumeroNota IS NULL THEN
SELECT p.RIF AS `RIF`,
m.Razon_Social AS `Razon Social`,
n.numero_factura AS `N. Factura`,
n.numero_nota_credito AS `N. Nota de Credito`,
n.fecha AS `Fecha`,
IF(n.numero_nota_credito = ANY(SELECT numero_nota_credito FROM nota_credito_producto),
IF(n.numero_nota_credito = ANY(SELECT b.numero_nota_credito FROM nota_credito_producto b JOIN nota_credito a USING(numero_nota_credito) JOIN factura c USING(numero_factura) JOIN factura_producto d ON d.numero_factura=c.numero_factura WHERE d.monto_unitario>b.monto_unitario),'DIFERENCIA DE PRECIO','DEVOLUCION'),'ANULACION') AS `Tipo de Documento` 
FROM nota_credito n JOIN factura f USING(numero_factura) JOIN pedido p USING(numero_pedido) JOIN maestro_cliente m USING(RIF);
ELSE

SELECT p.RIF AS `RIF`,
m.Razon_Social AS `Razon Social`,
n.numero_factura AS `N. Factura`,
n.numero_nota_credito AS `N. Nota de Credito`,
n.fecha AS `Fecha`,
IF(n.numero_nota_credito = ANY(SELECT numero_nota_credito FROM nota_credito_producto),
IF(n.numero_nota_credito = ANY(SELECT b.numero_nota_credito FROM nota_credito_producto b JOIN nota_credito a USING(numero_nota_credito) JOIN factura c USING(numero_factura) JOIN factura_producto d ON d.numero_factura=c.numero_factura WHERE d.monto_unitario>b.monto_unitario),'DIFERENCIA DE PRECIO','DEVOLUCION'),'ANULACION') AS `Tipo de Documento` 
FROM nota_credito n JOIN factura f USING(numero_factura) JOIN pedido p USING(numero_pedido) JOIN maestro_cliente m USING(RIF) WHERE n.numero_nota_credito=NumeroNota;
END IF;
END //

DROP PROCEDURE IF EXISTS consultar_nota_credito_producto;//

CREATE PROCEDURE consultar_nota_credito_producto(NumeroNota BIGINT(10),NumeroFactura BIGINT(10))
BEGIN
IF NumeroNota IS NULL THEN
SELECT f.id_producto AS `ID Producto`,
f.cod_producto AS `Cod. Producto`,
n.numero_nota_credito AS `Nro. Nota Credito`,
n.cantidad_producto AS `Cantidad (Coreccion)`,
IF(a.tipo_IVA IS NULL,n.monto_unitario,IF(a.tipo_IVA IS true,n.monto_unitario,(n.monto_unitario*(1+(a.IVA/100))))) AS `Monto (Coreccion)`,
a.IVA AS `IVA`,
IF(a.tipo_IVA IS NULL,'EXENTO',IF(a.tipo_IVA IS true,'INCLUIDO','EXCLUIDO')) AS `Tipo de IVA`
FROM nota_credito_producto n JOIN factura_producto f USING(id_producto) JOIN IVA a USING(id_IVA)
WHERE f.numero_factura=NumeroFactura;
ELSE

SELECT f.id_producto AS `ID Producto`,
f.cod_producto AS `Cod. Producto`,
n.numero_nota_credito AS `Nro. Nota Credito`,
n.cantidad_producto AS `Cantidad (Coreccion)`,
IF(a.tipo_IVA IS NULL,n.monto_unitario,IF(a.tipo_IVA IS true,n.monto_unitario,(n.monto_unitario*(1+(a.IVA/100))))) AS `Monto (Coreccion)`,
a.IVA AS `IVA`,
IF(a.tipo_IVA IS NULL,'EXENTO',IF(a.tipo_IVA IS true,'INCLUIDO','EXCLUIDO')) AS `Tipo de IVA`
FROM nota_credito_producto n JOIN factura_producto f USING(id_producto) JOIN IVA a USING(id_IVA)
WHERE n.numero_nota_credito=NumeroNota;
END IF;
END //

DROP PROCEDURE IF EXISTS reintegrar;//

CREATE PROCEDURE reintegrar(seria VARCHAR(10))
BEGIN

DECLARE lote BIGINT(10);
DECLARE NumeroNota BIGINT(10);
SET lote = (SELECT cod_lote FROM seriales s WHERE s.serial = seria);
SET NumeroNota = (SELECT numero_nota_entrega FROM seriales s WHERE s.serial = seria);
DELETE FROM seriales WHERE serial=seria;
IF NOT EXISTS(SELECT * FROM seriales WHERE numero_nota_entrega=NumeroNota LIMIT 1) THEN
DELETE FROM nota_entrega WHERE numero_nota_entrega=NumeroNota;
END IF;
INSERT INTO seriales VALUES(lote,seria,NULL);
UPDATE inventario
SET cantidad_actual = cantidad_actual + 1
WHERE cod_lote = lote;
END //

DROP PROCEDURE IF EXISTS anular_factura;//

CREATE PROCEDURE anular_factura(NumFactura BIGINT(10))
BEGIN
DECLARE fecha DATE;
SET fecha=(SELECT curdate());
INSERT INTO nota_credito VALUES (NumFactura,NULL,fecha);
DELETE FROM nota_entrega WHERE numero_factura=NumFactura;
END//

DROP PROCEDURE IF EXISTS reporte_utilidades_brutas;//

CREATE PROCEDURE reporte_utilidades_brutas(desde DATE, hasta DATE)
BEGIN
DECLARE NotaCredito DOUBLE;
DECLARE Costos DOUBLE;
DECLARE Facturado DOUBLE;
DECLARE CuentasCobrar DOUBLE;
DECLARE NoCobrado DOUBLE;
IF desde<hasta THEN
SET NotaCredito = (SELECT SUM(p.monto_unitario) FROM nota_credito_producto p JOIN nota_credito c USING(numero_nota_credito) WHERE c.fecha>desde AND c.fecha<hasta LIMIT 1);
SET Costos = (SELECT SUM(i.precio_compra*(i.cantidad_inicial-i.cantidad_actual)) FROM inventario i JOIN factura_proveedor f USING(numero_factura_proveedor) WHERE f.fecha>desde AND f.fecha<hasta LIMIT 1);
SET Facturado = (SELECT SUM(p.monto_unitario) FROM factura_pago p JOIN factura f USING(numero_factura) JOIN forma_pago o USING(cod_pago) WHERE f.fecha>desde AND f.fecha<hasta AND o.dias_credito IS NULL LIMIT 1);
SET CuentasCobrar = (SELECT SUM(p.monto_unitario) FROM factura_pago p JOIN factura f USING(numero_factura) JOIN cuentas_cobrar c USING(id_pago) WHERE f.fecha>desde AND f.fecha<hasta AND c.pagado IS TRUE LIMIT 1);
SET NoCobrado = (SELECT SUM(p.monto_unitario) FROM factura_pago p JOIN factura f USING(numero_factura) JOIN cuentas_cobrar c USING(id_pago) WHERE f.fecha>desde AND f.fecha<hasta AND c.pagado IS FALSE LIMIT 1);
(SELECT '+ Total Facturado (No incluye credito)' AS `Descripcion`, IF(Facturado IS NULL,0,Facturado) AS `Monto`, NULL AS `TOTAL`)UNION
(SELECT '+ Total cuentas por cobrar cobradas' AS `Descripcion`, IF(CuentasCobrar IS NULL,0,CuentasCobrar) AS `Monto`, NULL AS `TOTAL`)UNION
(SELECT '- Total Notas de Credito' AS `Descripcion`, IF(NotaCredito IS NULL,0,NotaCredito) AS `Monto`, NULL AS `TOTAL`)UNION
(SELECT '- Total Costo de la Mercancia' AS `Descripcion`, IF(Costos IS NULL,0,Costos) AS `Monto`, NULL AS `TOTAL`)UNION
(SELECT '= Total utilidades brutas' AS `Descripcion`, NULL AS `Monto`, ((IF(Facturado IS NULL,0,Facturado)+IF(CuentasCobrar IS NULL,0,CuentasCobrar))-(IF(NotaCredito IS NULL,0,NotaCredito)+IF(Costos IS NULL,0,Costos))) AS `TOTAL`)UNION
(SELECT 'Margen de utilidades brutas (%)' AS `Descripcion`, (((IF(Facturado IS NULL,0,Facturado)+IF(CuentasCobrar IS NULL,0,CuentasCobrar))-(IF(NotaCredito IS NULL,0,NotaCredito)+IF(Costos IS NULL,0,Costos)))/IF(Facturado IS NULL,0,Facturado)) AS `Monto`, NULL AS `TOTAL`)UNION
(SELECT 'Periodo de cobranza promedio (dias)' AS `Descripcion`, (IF(NoCobrado IS NULL,0,NoCobrado)/(IF(Facturado IS NULL,0,Facturado)/(DATEDIFF(hasta,desde)))) AS `Monto`, NULL AS `TOTAL`);
ELSE
SELECT 'PERIODO DE TIEMPO INCORRECTO' AS `ADVERTENCIA`;
END IF;

END//

DROP PROCEDURE IF EXISTS reporte_inventario;//

CREATE PROCEDURE reporte_inventario(desde DATE, hasta DATE)
BEGIN
DECLARE Costos DOUBLE;
DECLARE Inventario DOUBLE;
SET Costos = (SELECT SUM(i.precio_compra*(i.cantidad_inicial-i.cantidad_actual)) FROM inventario i JOIN factura_proveedor f USING(numero_factura_proveedor) WHERE f.fecha>desde AND f.fecha<hasta LIMIT 1);
SET Inventario = (SELECT SUM(i.precio_venta*i.cantidad_actual) FROM inventario i JOIN factura_proveedor f USING(numero_factura_proveedor) WHERE f.fecha>desde AND f.fecha<hasta LIMIT 1);
IF desde<hasta THEN
(SELECT o.cod_producto AS `Cod. Producto`,
(100*(SUM(p.cantidad_producto*(p.monto_unitario*(IF(a.tipo_IVA IS NULL,1,IF(a.tipo_IVA IS TRUE,1,1+(a.IVA/100))))))/(SELECT SUM(x.monto_unitario) FROM factura_pago x JOIN factura y USING(numero_factura) WHERE y.fecha>desde AND y.fecha<hasta LIMIT 1))) AS `Representacion del producto en las ventas (%)`,
SUM(p.cantidad_producto) AS `Cantidad vendida`,
AVG(DISTINCT p.monto_unitario) AS `Media del Precio`,
NULL AS `Promedio de rotacion del inventario`
FROM pedido_producto p JOIN producto o USING(cod_producto) JOIN IVA a USING(id_IVA) JOIN pedido i USING(numero_pedido)
WHERE i.fecha>desde AND i.fecha<hasta GROUP BY o.cod_producto)UNION
(SELECT NULL AS `Cod. Producto`,
NULL AS `Representacion del producto en las ventas`,
NULL AS `Cantidad vendida`,
NULL AS `Media del Precio`,
IF(Costos>Inventario AND Inventario>0,(IF(Costos IS NULL,0,Costos)/IF(Inventario IS NULL,0,Inventario)),NULL) AS `Promedio de rotacion del inventario`);
ELSE
SELECT 'PERIODO DE TIEMPO INCORRECTO' AS `ADVERTENCIA`;
END IF;
END//

-- </Procedimientos de Almacenado (Tablas Secundarias)>

DELIMITER ;

SET FOREIGN_KEY_CHECKS = 1;

CALL crear_usuario('administrador','17922875',1);
CALL ingresar_forma_pago('DESCUENTO',NULL);
CALL ingresar_forma_pago('INCREMENTO',NULL);