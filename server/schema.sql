CREATE DATABASE IF NOT EXISTS rutaexpress CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE rutaexpress;

DROP TABLE IF EXISTS pagos;
DROP TABLE IF EXISTS paquetes;
DROP TABLE IF EXISTS envios;
DROP TABLE IF EXISTS rutas;
DROP TABLE IF EXISTS repartidores;
DROP TABLE IF EXISTS empleados;
DROP TABLE IF EXISTS clientes;

CREATE TABLE clientes (
  id VARCHAR(10) NOT NULL PRIMARY KEY,
  nombre VARCHAR(120) NOT NULL,
  documento VARCHAR(20) NOT NULL UNIQUE,
  telefono VARCHAR(30) NOT NULL,
  correo VARCHAR(120) NOT NULL,
  direccion VARCHAR(200) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE empleados (
  id VARCHAR(10) NOT NULL PRIMARY KEY,
  nombre VARCHAR(120) NOT NULL,
  cargo VARCHAR(60) NOT NULL,
  correo VARCHAR(120) NOT NULL,
  telefono VARCHAR(30) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE repartidores (
  id VARCHAR(10) NOT NULL PRIMARY KEY,
  nombre VARCHAR(120) NOT NULL,
  telefono VARCHAR(30) NOT NULL,
  disponible TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB;

CREATE TABLE rutas (
  id VARCHAR(10) NOT NULL PRIMARY KEY,
  zona VARCHAR(120) NOT NULL,
  fecha DATE NOT NULL,
  descripcion VARCHAR(200) NOT NULL,
  repartidor_id VARCHAR(10) NULL,
  CONSTRAINT fk_rutas_repartidor FOREIGN KEY (repartidor_id) REFERENCES repartidores(id)
) ENGINE=InnoDB;

CREATE TABLE envios (
  id VARCHAR(20) NOT NULL PRIMARY KEY,
  cliente_id VARCHAR(10) NOT NULL,
  origen VARCHAR(120) NOT NULL,
  destino VARCHAR(120) NOT NULL,
  fecha DATETIME NOT NULL,
  tarifa DECIMAL(10,2) NOT NULL,
  estado ENUM('Registrado','Clasificado','En ruta','Entregado','Cancelado') NOT NULL,
  empleado_id VARCHAR(10) NOT NULL,
  ruta_id VARCHAR(10) NULL,
  repartidor_id VARCHAR(10) NULL,
  confirmacion VARCHAR(200) NULL,
  CONSTRAINT fk_envios_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(id),
  CONSTRAINT fk_envios_empleado FOREIGN KEY (empleado_id) REFERENCES empleados(id),
  CONSTRAINT fk_envios_ruta FOREIGN KEY (ruta_id) REFERENCES rutas(id),
  CONSTRAINT fk_envios_repartidor FOREIGN KEY (repartidor_id) REFERENCES repartidores(id),
  CONSTRAINT chk_envios_tarifa CHECK (tarifa >= 0)
) ENGINE=InnoDB;

CREATE TABLE paquetes (
  id VARCHAR(10) NOT NULL PRIMARY KEY,
  envio_id VARCHAR(20) NOT NULL,
  descripcion VARCHAR(150) NOT NULL,
  peso DECIMAL(8,2) NOT NULL,
  dimensiones VARCHAR(60) NOT NULL,
  valor_declarado DECIMAL(10,2) NOT NULL DEFAULT 0,
  CONSTRAINT fk_paquetes_envio FOREIGN KEY (envio_id) REFERENCES envios(id),
  CONSTRAINT chk_paquetes_peso CHECK (peso > 0),
  CONSTRAINT chk_paquetes_valor CHECK (valor_declarado >= 0)
) ENGINE=InnoDB;

CREATE TABLE pagos (
  id VARCHAR(10) NOT NULL PRIMARY KEY,
  envio_id VARCHAR(20) NOT NULL,
  importe DECIMAL(10,2) NOT NULL,
  metodo VARCHAR(40) NOT NULL,
  estado ENUM('Pendiente','Pagado','Anulado') NOT NULL,
  fecha DATETIME NOT NULL,
  CONSTRAINT fk_pagos_envio FOREIGN KEY (envio_id) REFERENCES envios(id),
  CONSTRAINT chk_pagos_importe CHECK (importe >= 0)
) ENGINE=InnoDB;

INSERT INTO clientes (id, nombre, documento, telefono, correo, direccion) VALUES
('C001','María Elena Ramírez','87654321','987 654 321','maria.ramirez@correo.com','Av. Lima 245, Miraflores'),
('C002','Carlos Alberto Flores','10234567','944 120 883','carlos.flores@correo.com','Jr. Ayacucho 1180, Breña'),
('C003','Lucía Mendoza Vargas','45871239','912 556 740','lucia.mendoza@correo.com','Calle Real 329, San Isidro'),
('C004','Jorge Luis Castro','20145678','998 340 112','jorge.castro@correo.com','Av. Brasil 1750, Jesús María'),
('C005','Ana Patricia Rojas','76543210','935 781 204','ana.rojas@correo.com','Psje. Los Olivos 45, Surco');

INSERT INTO empleados (id, nombre, cargo, correo, telefono) VALUES
('E001','Rosa Villanueva','Atención al Cliente','rosa.villanueva@rutaexpress.com','911 222 333'),
('E002','Miguel Ángel Soto','Operaciones','miguel.soto@rutaexpress.com','922 333 444'),
('E003','Fernanda Ríos','Clasificación','fernanda.rios@rutaexpress.com','933 444 555');

INSERT INTO repartidores (id, nombre, telefono, disponible) VALUES
('RP01','Diego Fernando Paredes','944 555 666',1),
('RP02','Andrea Salazar','955 666 777',1),
('RP03','Pedro Nolasco','966 777 888',0);

INSERT INTO rutas (id, zona, fecha, descripcion, repartidor_id) VALUES
('R01','Miraflores - San Isidro','2026-11-17','Reparto zona norte','RP01'),
('R02','Breña - Jesús María','2026-11-17','Reparto zona céntrica','RP02'),
('R03','Surco - Barranco','2026-11-17','Reparto zona sur',NULL);

INSERT INTO envios (id, cliente_id, origen, destino, fecha, tarifa, estado, empleado_id, ruta_id, repartidor_id, confirmacion) VALUES
('ENV-1001','C001','Miraflores','San Isidro','2026-11-16 09:30:00',25.00,'En ruta','E001','R01','RP01',NULL),
('ENV-1002','C002','Breña','Jesús María','2026-11-15 14:10:00',18.50,'Entregado','E002','R02','RP02','Recibido por el cliente'),
('ENV-1003','C003','San Isidro','Surco','2026-11-17 08:00:00',32.00,'Clasificado','E003',NULL,NULL,NULL),
('ENV-1004','C004','Jesús María','Miraflores','2026-11-17 11:45:00',15.00,'Registrado','E001',NULL,NULL,NULL),
('ENV-1005','C005','Surco','Barranco','2026-11-14 10:20:00',21.00,'Entregado','E002','R03','RP01','Recibido por receptor autorizado'),
('ENV-1006','C001','Miraflores','Breña','2026-11-12 16:00:00',28.50,'Cancelado','E003',NULL,NULL,NULL),
('ENV-1007','C003','San Isidro','Jesús María','2026-11-17 14:00:00',19.00,'Registrado','E001',NULL,NULL,NULL);

INSERT INTO paquetes (id, envio_id, descripcion, peso, dimensiones, valor_declarado) VALUES
('P001','ENV-1001','Caja de documentos',2.50,'30 x 20 x 15 cm',120.00),
('P002','ENV-1001','Libros',3.20,'25 x 20 x 18 cm',80.00),
('P003','ENV-1002','Ropa',1.80,'40 x 30 x 20 cm',150.00),
('P004','ENV-1003','Repuestos',4.10,'35 x 25 x 20 cm',320.00),
('P005','ENV-1004','Sobres administrativos',0.60,'35 x 25 x 3 cm',30.00),
('P006','ENV-1005','Electrónica',2.90,'30 x 22 x 12 cm',450.00),
('P007','ENV-1006','Caja de vidrio',5.50,'40 x 40 x 30 cm',200.00),
('P008','ENV-1007','Muestras comerciales',1.20,'20 x 15 x 10 cm',95.00);

INSERT INTO pagos (id, envio_id, importe, metodo, estado, fecha) VALUES
('PG001','ENV-1001',25.00,'Yape','Pagado','2026-11-16 09:35:00'),
('PG002','ENV-1002',18.50,'Efectivo','Pagado','2026-11-15 14:15:00'),
('PG003','ENV-1003',32.00,'Transferencia','Pendiente','2026-11-17 08:05:00'),
('PG004','ENV-1004',15.00,'Tarjeta','Pendiente','2026-11-17 11:50:00'),
('PG005','ENV-1005',21.00,'Yape','Pagado','2026-11-14 10:25:00'),
('PG006','ENV-1006',28.50,'Efectivo','Anulado','2026-11-12 16:05:00');
