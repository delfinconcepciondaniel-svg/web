const express = require('express');
const cors = require('cors');
const mysql = require('mysql2/promise');

const app = express();
app.use(cors());
app.use(express.json({ limit: '2mb' }));

const pool = mysql.createPool({
  host: process.env.DB_HOST || '127.0.0.1',
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'rutaexpress',
  waitForConnections: true,
  connectionLimit: 10,
  decimalNumbers: true,
  timezone: 'local',
  namedPlaceholders: true,
});

const CLIENTE = 'id, nombre, documento, telefono, correo, direccion';
const EMPLEADO = 'id, nombre, cargo, correo, telefono';
const REPARTIDOR = 'id, nombre, telefono, disponible';
const RUTA = 'id, zona, fecha, descripcion, repartidor_id AS repartidorId';
const ENVIO = 'id, cliente_id AS clienteId, origen, destino, fecha, tarifa, estado, empleado_id AS empleadoId, ruta_id AS rutaId, repartidor_id AS repartidorId, confirmacion';
const PAQUETE = 'id, envio_id AS envioId, descripcion, peso, dimensiones, valor_declarado AS valorDeclarado';
const PAGO = 'id, envio_id AS envioId, importe, metodo, estado, fecha';

function handler(fn) {
  return (req, res) => Promise.resolve(fn(req, res)).catch((error) => {
    console.error(error);
    res.status(500).json({ error: error.message });
  });
}

function falla(res, codigo, mensaje) {
  return res.status(codigo).json({ error: mensaje });
}

async function siguienteId(tabla, columna, prefijo, ancho = 3) {
  const [filas] = await pool.query(`SELECT ${columna} AS id FROM ${tabla} ORDER BY ${columna} DESC LIMIT 1`);
  let n = 1;
  if (filas.length) {
    const coincidencia = String(filas[0].id).match(/(\d+)$/);
    if (coincidencia) n = parseInt(coincidencia[1], 10) + 1;
  }
  return prefijo + String(n).padStart(ancho, '0');
}

function texto(valor) {
  return valor == null ? '' : String(valor).trim();
}

function fechaSql(valor) {
  if (!valor) return new Date().toISOString().slice(0, 19).replace('T', ' ');
  return String(valor).replace('T', ' ').split('.')[0].split('Z')[0];
}

app.get('/api/salud', handler(async (req, res) => {
  await pool.query('SELECT 1');
  res.json({ ok: true, base: 'rutaexpress' });
}));

app.get('/api/datos', handler(async (req, res) => {
  const [clientes] = await pool.query(`SELECT ${CLIENTE} FROM clientes ORDER BY id`);
  const [empleados] = await pool.query(`SELECT ${EMPLEADO} FROM empleados ORDER BY id`);
  const [repartidores] = await pool.query(`SELECT ${REPARTIDOR} FROM repartidores ORDER BY id`);
  const [rutas] = await pool.query(`SELECT ${RUTA} FROM rutas ORDER BY id`);
  const [envios] = await pool.query(`SELECT ${ENVIO} FROM envios ORDER BY id`);
  const [paquetes] = await pool.query(`SELECT ${PAQUETE} FROM paquetes ORDER BY id`);
  const [pagos] = await pool.query(`SELECT ${PAGO} FROM pagos ORDER BY id`);
  res.json({ clientes, empleados, repartidores, rutas, envios, paquetes, pagos });
}));

for (const [recurso, tabla, columnas, campos] of [
  ['clientes', 'clientes', CLIENTE, ['nombre', 'documento', 'telefono', 'correo', 'direccion']],
  ['empleados', 'empleados', EMPLEADO, ['nombre', 'cargo', 'correo', 'telefono']],
  ['repartidores', 'repartidores', REPARTIDOR, ['nombre', 'telefono', 'disponible']],
  ['rutas', 'rutas', RUTA, ['zona', 'fecha', 'descripcion', 'repartidorId']],
  ['pagos', 'pagos', PAGO, ['envioId', 'importe', 'metodo', 'estado', 'fecha']],
]) {
  app.get(`/api/${recurso}`, handler(async (req, res) => {
    const [filas] = await pool.query(`SELECT ${columnas} FROM ${tabla} ORDER BY id`);
    res.json(filas);
  }));

  app.post(`/api/${recurso}`, handler(async (req, res) => {
    const prefijo = { clientes: 'C', empleados: 'E', repartidores: 'RP', rutas: 'R', pagos: 'PG' }[recurso];
    let id = texto(req.body.id);
    if (!id) id = await siguienteId(tabla, 'id', prefijo);
    const valores = campos.map((c) => {
      const v = req.body[c];
      if (c === 'disponible') return v ? 1 : 0;
      if (c === 'fecha') return v ? String(v).slice(0, 10) : null;
      return texto(v);
    });
    await pool.query(`INSERT INTO ${tabla} (id, ${campos.map((c) => c === 'repartidorId' ? 'repartidor_id' : c === 'envioId' ? 'envio_id' : c).join(', ')}) VALUES (?, ${campos.map(() => '?').join(', ')})`, [id, ...valores]);
    const [filas] = await pool.query(`SELECT ${columnas} FROM ${tabla} WHERE id = ?`, [id]);
    res.status(201).json(filas[0]);
  }));

  app.put(`/api/${recurso}/:id`, handler(async (req, res) => {
    const valores = campos.map((c) => {
      const v = req.body[c];
      if (c === 'disponible') return v ? 1 : 0;
      if (c === 'fecha') return v ? String(v).slice(0, 10) : null;
      return texto(v);
    });
    const asignaciones = campos.map((c) => `${c === 'repartidorId' ? 'repartidor_id' : c === 'envioId' ? 'envio_id' : c} = ?`).join(', ');
    await pool.query(`UPDATE ${tabla} SET ${asignaciones} WHERE id = ?`, [...valores, req.params.id]);
    const [filas] = await pool.query(`SELECT ${columnas} FROM ${tabla} WHERE id = ?`, [req.params.id]);
    if (!filas.length) return falla(res, 404, 'Registro no encontrado');
    res.json(filas[0]);
  }));

  app.delete(`/api/${recurso}/:id`, handler(async (req, res) => {
    await pool.query(`DELETE FROM ${tabla} WHERE id = ?`, [req.params.id]);
    res.json({ ok: true });
  }));
}

app.get('/api/envios', handler(async (req, res) => {
  const [filas] = await pool.query(`SELECT ${ENVIO} FROM envios ORDER BY id`);
  res.json(filas);
}));

app.post('/api/envios', handler(async (req, res) => {
  const paquete = req.body.paquete || {};
  let id = texto(req.body.id);
  if (!id) id = await siguienteId('envios', 'id', 'ENV-', 4);
  let idPaquete = texto(paquete.id);
  if (!idPaquete) idPaquete = await siguienteId('paquetes', 'id', 'P');
  const clienteId = texto(req.body.clienteId);
  const empleadoId = texto(req.body.empleadoId);
  const fecha = fechaSql(req.body.fecha);
  const tarifa = Number(req.body.tarifa);
  const peso = Number(paquete.peso);
  if (!clienteId || !empleadoId) return falla(res, 400, 'RN03: el envio necesita cliente y responsable');
  if (!numeroValido(tarifa) || tarifa < 0) return falla(res, 400, 'RN06: la tarifa no puede ser negativa');
  if (!numeroValido(peso) || peso <= 0) return falla(res, 400, 'RN05: el peso debe ser mayor que cero');
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    await conn.query(
      'INSERT INTO envios (id, cliente_id, origen, destino, fecha, tarifa, estado, empleado_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [id, clienteId, texto(req.body.origen), texto(req.body.destino), fecha, tarifa, 'Registrado', empleadoId],
    );
    await conn.query(
      'INSERT INTO paquetes (id, envio_id, descripcion, peso, dimensiones, valor_declarado) VALUES (?, ?, ?, ?, ?, ?)',
      [idPaquete, id, texto(paquete.descripcion), peso, texto(paquete.dimensiones), Number(paquete.valorDeclarado) || 0],
    );
    await conn.commit();
  } catch (error) {
    await conn.rollback();
    throw error;
  } finally {
    conn.release();
  }
  const [filas] = await pool.query(`SELECT ${ENVIO} FROM envios WHERE id = ?`, [id]);
  res.status(201).json(filas[0]);
}));

app.put('/api/envios/:id', handler(async (req, res) => {
  await pool.query(
    'UPDATE envios SET cliente_id = ?, origen = ?, destino = ?, fecha = ?, tarifa = ?, empleado_id = ? WHERE id = ?',
    [texto(req.body.clienteId), texto(req.body.origen), texto(req.body.destino), fechaSql(req.body.fecha), Number(req.body.tarifa), texto(req.body.empleadoId), req.params.id],
  );
  const [filas] = await pool.query(`SELECT ${ENVIO} FROM envios WHERE id = ?`, [req.params.id]);
  if (!filas.length) return falla(res, 404, 'Envio no encontrado');
  res.json(filas[0]);
}));

app.patch('/api/envios/:id/estado', handler(async (req, res) => {
  const estado = texto(req.body.estado);
  const permitidos = ['Registrado', 'Clasificado', 'En ruta', 'Entregado', 'Cancelado'];
  if (!permitidos.includes(estado)) return falla(res, 400, 'Estado no valido');
  const [filas] = await pool.query(`SELECT ${ENVIO} FROM envios WHERE id = ?`, [req.params.id]);
  if (!filas.length) return falla(res, 404, 'Envio no encontrado');
  const envio = filas[0];
  if (estado === 'En ruta' && (!envio.rutaId || !envio.repartidorId)) {
    return falla(res, 400, 'RN07: asigne una ruta y un repartidor antes de pasar a En ruta');
  }
  const confirmacion = estado === 'Entregado' ? (texto(req.body.confirmacion) || 'Entrega confirmada') : envio.confirmacion;
  await pool.query('UPDATE envios SET estado = ?, confirmacion = ? WHERE id = ?', [estado, confirmacion, req.params.id]);
  const [actualizado] = await pool.query(`SELECT ${ENVIO} FROM envios WHERE id = ?`, [req.params.id]);
  res.json(actualizado[0]);
}));

app.patch('/api/envios/:id/asignacion', handler(async (req, res) => {
  const rutaId = texto(req.body.rutaId) || null;
  const repartidorId = texto(req.body.repartidorId) || null;
  await pool.query('UPDATE envios SET ruta_id = ?, repartidor_id = ? WHERE id = ?', [rutaId, repartidorId, req.params.id]);
  const [filas] = await pool.query(`SELECT ${ENVIO} FROM envios WHERE id = ?`, [req.params.id]);
  res.json(filas[0]);
}));

app.get('/api/paquetes', handler(async (req, res) => {
  const [filas] = await pool.query(`SELECT ${PAQUETE} FROM paquetes ORDER BY id`);
  res.json(filas);
}));

app.post('/api/paquetes', handler(async (req, res) => {
  let id = texto(req.body.id);
  if (!id) id = await siguienteId('paquetes', 'id', 'P');
  const peso = Number(req.body.peso);
  if (!numeroValido(peso) || peso <= 0) return falla(res, 400, 'RN05: el peso debe ser mayor que cero');
  await pool.query(
    'INSERT INTO paquetes (id, envio_id, descripcion, peso, dimensiones, valor_declarado) VALUES (?, ?, ?, ?, ?, ?)',
    [id, texto(req.body.envioId), texto(req.body.descripcion), peso, texto(req.body.dimensiones), Number(req.body.valorDeclarado) || 0],
  );
  const [filas] = await pool.query(`SELECT ${PAQUETE} FROM paquetes WHERE id = ?`, [id]);
  res.status(201).json(filas[0]);
}));

app.put('/api/paquetes/:id', handler(async (req, res) => {
  await pool.query(
    'UPDATE paquetes SET descripcion = ?, peso = ?, dimensiones = ?, valor_declarado = ? WHERE id = ?',
    [texto(req.body.descripcion), Number(req.body.peso), texto(req.body.dimensiones), Number(req.body.valorDeclarado), req.params.id],
  );
  const [filas] = await pool.query(`SELECT ${PAQUETE} FROM paquetes WHERE id = ?`, [req.params.id]);
  res.json(filas[0]);
}));

function numeroValido(valor) {
  return typeof valor === 'number' && Number.isFinite(valor);
}

const puerto = Number(process.env.PORT || 3001);
app.listen(puerto, () => {
  console.log(`API RutaExpress en http://localhost:${puerto}`);
});

