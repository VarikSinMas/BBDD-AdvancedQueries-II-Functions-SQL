USE ICX0_P3_6;

/*
Resolver con Combinaciones Externas:

Mostrar aquellos socios que no se han inscrito en ninguna actividad.
El listado deberá mostrar los siguientes campos:
idSocio, Nombre, Apellido1, Fecha de Alta.

*/

SELECT 
    s.id_socio AS idSocio, 
    s.nombre AS Nombre, 
    s.apellido1 AS Apellido1, 
    s.fecha_alta AS 'Fecha de Alta'
FROM 
    socio s
LEFT JOIN 
    inscripciones i ON s.id_socio = i.idSocio
WHERE 
    i.idSocio IS NULL;
    
/*

Mostrar aquellos monitores sin horas asignadas.
El listado deberá mostrar los siguientes campos:
id, nombre, apellidos, titulación(es), teléfono fijo, teléfono móvil.
    
*/

SELECT
    m.id_monitor AS id,
    m.nombre,
    m.apellidos,
    m.titulaciones AS titulacion,
    m.telefono_fijo,
    m.telefono_movil
FROM
    monitores m
LEFT JOIN horario h ON m.id_monitor = h.id_monitor
WHERE
    h.id_monitor IS NULL;


/*

Mostrar una lista con todos los monitores tengan o no horas asignadas

*/

SELECT 
    m.id_monitor,
    m.documento_identificacion,
    m.nombre,
    m.apellidos,
    COUNT(h.id_monitor) AS horas_asignadas
FROM 
    monitores m
LEFT JOIN 
    horario h ON m.id_monitor = h.id_monitor
GROUP BY 
    m.id_monitor;

/*
Mostrar una lista de socios que han sido recomendados el id, nombre y apellido de quien lo ha recomendado.
*/

SELECT 
    s.id_socio AS 'ID Socio Recomendado',
    s.nombre AS 'Nombre Socio Recomendado',
    s.apellido1 AS 'Apellido1 Socio Recomendado',
    s.apellido2 AS 'Apellido2 Socio Recomendado',
    r.id_socio AS 'ID Socio Recomendador',
    r.nombre AS 'Nombre Socio Recomendador',
    r.apellido1 AS 'Apellido1 Socio Recomendador',
    r.apellido2 AS 'Apellido2 Socio Recomendador'
FROM 
    socio s
INNER JOIN 
    socio r ON s.recomendado_por = r.id_socio
WHERE 
    s.recomendado_por IS NOT NULL;
    
/*
Resolver con Subconsultas:

Mostrar el idSocio, nombre, apellido1, apellido2 y la fecha de alta del socio corporativo más antiguo del gimnasio.

*/
SELECT 
  s.id_socio, 
  s.nombre, 
  s.apellido1, 
  s.apellido2, 
  s.fecha_alta
FROM 
  socio AS s
WHERE 
  s.fecha_alta = (
    SELECT MIN(s2.fecha_alta) 
    FROM socio AS s2
    WHERE s2.id_socio IN (
      SELECT c.id_socio 
      FROM corporativo AS c
    )
  )
LIMIT 1;


-- Indicar la sala (instalación) con el horario más reciente ocupado


SELECT denominacion
FROM instalacion
WHERE id_instalacion = (
    SELECT id_instalacion
    FROM horario
    WHERE (fecha, hora) = (
        SELECT MAX(fecha), MAX(hora)
        FROM horario
        WHERE fecha = (SELECT MAX(fecha) FROM horario)
    )
);

-- Indicar cuál es la sala con el aforo más pequeño

SELECT *
FROM `instalacion`
WHERE `aforo` = (
  SELECT MIN(`aforo`)
  FROM `instalacion`
);

/*
Resolver con Consultas de UNION
Crear una consulta de UNION producto de la combinación de las siguientes cuatro consultas:
Altas del mes: idSocio, Concepto="Matrícula", Mes, Año, Matrícula
Para aquellos socios que se han dado de alta en el mes y año especificado
Cuotas: idSocio, Concepto="Cuota Mensual", Mes, Año, CuotaMensual
Descuento: idSocio, Concepto="Descuento", MesDcto, AñoDcto, Importe
De la tabla Decuento
Actividades Extra: idSocio, Concepto="Extra", Mes, Año, precioSesión
De la tabla Actividades
Crear una consulta de UNION producto de la combinación de las siguientes dos consultas:
NIF, NombreEmpresa, Teléfono, EMail
DNI, Nombre+Apellidos Socio, Teléfono, EMail. Sólo socios principales

*/


-- Consulta para las Altas del mes de enero de 2022
SELECT 
    s.id_socio AS idSocio,
    'Matrícula' AS Concepto,
    MONTH(s.fecha_alta) AS Mes,
    YEAR(s.fecha_alta) AS Año,
    p.matricula AS Importe
FROM 
    socio s
JOIN 
    plan p ON s.id_plan = p.id_plan
WHERE 
    YEAR(s.fecha_alta) = 2022 AND MONTH(s.fecha_alta) = 1

UNION ALL

-- Consulta para las Cuotas del mes de enero de 2022
SELECT 
    s.id_socio,
    'Cuota Mensual' AS Concepto,
    1 AS Mes,  -- Enero
    2022 AS Año, -- Año específico
    p.cuota_mensual AS Importe
FROM 
    socio s
JOIN 
    plan p ON s.id_plan = p.id_plan
WHERE 
    YEAR(s.fecha_alta) <= 2022 AND MONTH(s.fecha_alta) <= 1

UNION ALL

-- Consulta para los Descuentos en enero de 2022
SELECT 
    d.idSocio,
    'Descuento' AS Concepto,
    MONTH(d.fechaDescuento) AS Mes,
    YEAR(d.fechaDescuento) AS Año,
    d.Importe
FROM 
    descuentos d
WHERE 
    YEAR(d.fechaDescuento) = 2022 AND MONTH(d.fechaDescuento) = 1

UNION ALL

-- Consulta para Actividades Extra en enero de 2022
SELECT 
    i.idSocio,
    'Extra' AS Concepto,
    MONTH(i.fechaSesion) AS Mes,
    YEAR(i.fechaSesion) AS Año,
    i.importe AS Importe
FROM 
    inscripciones i
JOIN 
    actividad a ON i.idActividad = a.id_actividad
WHERE 
    a.tipo = 'Extra' AND YEAR(i.fechaSesion) = 2022 AND MONTH(i.fechaSesion) = 1;
    
/*
Crear una consulta de UNION producto de la combinación de las siguientes dos consultas:
NIF, NombreEmpresa, Teléfono, EMail
DNI, Nombre+Apellidos Socio, Teléfono, EMail. Sólo socios principales
*/

-- Consulta para datos de empresa
SELECT 
    e.nif AS NIF,
    e.empresa AS NombreEmpresa,
    e.telefono AS Teléfono,
    e.email AS EMail
FROM 
    empresa e

UNION

-- Consulta para datos de socios principales
SELECT 
    s.documento_identidad AS DNI,
    CONCAT(s.nombre, ' ', IFNULL(s.apellido1, ''), ' ', IFNULL(s.apellido2, '')) AS NombreApellidosSocio,
    s.telefono_contacto AS Teléfono,
    s.email AS EMail
FROM 
    socio s
LEFT JOIN 
    corporativo c ON s.id_socio = c.id_socio
WHERE 
    c.id_socio IS NULL;  -- Esto asegura que sólo se seleccionen socios principales
    
/*
Resolver con Vistas
Utilizando la consulta de UNION del punto anterior más la tabla de Socios, crear una vista que agregue los campos idSocio, nombre Completo, Plan y NIF (en caso de ser un socio corporativo).
Grabar la vista con el nombre Facturación
*/

CREATE VIEW Facturacion AS
SELECT 
    s.id_socio,
    CONCAT(s.nombre, ' ', IFNULL(s.apellido1, ''), ' ', IFNULL(s.apellido2, '')) AS nombreCompleto,
    p.plan,
    COALESCE(c.nif, 'No Corporativo') AS NIF,
    e.telefono AS Teléfono,
    e.email AS EMail,
    'Datos de Empresa' AS Origen
FROM 
    socio s
JOIN 
    plan p ON s.id_plan = p.id_plan
LEFT JOIN 
    corporativo c ON s.id_socio = c.id_socio
LEFT JOIN 
    empresa e ON c.nif = e.nif

UNION

SELECT 
    s.id_socio,
    CONCAT(s.nombre, ' ', IFNULL(s.apellido1, ''), ' ', IFNULL(s.apellido2, '')),
    p.plan,
    COALESCE(c.nif, 'No Corporativo'),
    s.telefono_contacto AS Teléfono,
    s.email AS EMail,
    'Datos de Socio' AS Origen
FROM 
    socio s
JOIN 
    plan p ON s.id_plan = p.id_plan
LEFT JOIN 
    corporativo c ON s.id_socio = c.id_socio
WHERE 
    c.id_socio IS NULL;
    
    
/*
Crear una vista a partir de la tabla HORARIOS que muestre el día de la semana (Lunes-Domingo), fecha, hora y nombre de la actividad
*/

CREATE VIEW VistaHorarios AS
SELECT 
    DAYNAME(h.fecha) AS DiaSemana,
    h.fecha,
    h.hora,
    a.actividad AS NombreActividad
FROM 
    horario h
JOIN 
    actividad a ON h.id_actividad = a.id_actividad;



