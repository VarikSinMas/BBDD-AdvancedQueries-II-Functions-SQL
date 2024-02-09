USE ICX0_P3_6;

/*
9.
Mostrar aquellos socios que cumplen años en el mes en curso.
El listado deberá mostrar los siguientes campos: idSocio, Nombre, Apellido1, Email, FechaNacimiento, Cumpleaños (sí/no) Ordenado por Día de nacimiento.
*/

SELECT
    id_socio AS idSocio,
    nombre AS Nombre,
    apellido1 AS Apellido1,
    email AS Email,
    fecha_nacimiento AS FechaNacimiento,
    CASE
        WHEN MONTH(fecha_nacimiento) = MONTH(CURDATE()) AND DAY(fecha_nacimiento) = DAY(CURDATE()) THEN 'Sí'
        ELSE 'No'
    END AS Cumpleaños
FROM socio
WHERE
    MONTH(fecha_nacimiento) = MONTH(CURDATE())
ORDER BY
    DAY(fecha_nacimiento);

/*
10.
Contar cuántos socios mujeres y hombres han recomendado a otros socios, agrupados por PLAN.
El plan debe ser tipo 'P' (socios principales) La salida de la consulta deberá ser la siguiente.
Utilizar la función IF y agrupar.
*/

SELECT
    p.plan AS Plan,
    COUNT(IF(s.sexo = 'M', 1, NULL)) AS Hombres_Recomendadores,
    COUNT(IF(s.sexo = 'F', 1, NULL)) AS Mujeres_Recomendadoras
FROM socio s
INNER JOIN historico h ON s.id_socio = h.id_socio
INNER JOIN plan p ON h.plan_anterior = p.id_plan
WHERE
    h.tipo_socio = 1 -- Tipo de socio principal
    AND p.tipo = 'P' -- Tipo de plan 'P' (socios principales)
GROUP BY
    p.plan;
    
/*
11.
Mostrar una lista de monitores donde se especifique si imparten una o más de una actividad.
La salida de la consulta deberá ser la siguiente. Utilizar la función CASE y agrupar.
*/
SELECT
    m.id_monitor,
    m.nombre,
    m.apellidos,
    CASE
        WHEN COUNT(am.id_actividad) > 1 THEN 'Más de una actividad'
        ELSE 'Una actividad'
    END AS actividades
FROM
    monitores m
LEFT JOIN actividad_monitor am ON m.id_monitor = am.id_monitor
GROUP BY
    m.id_monitor,
    m.nombre,
    m.apellidos
ORDER BY
    m.id_monitor;

/*
12.
Inventar una consulta que haga uso de una de las siguientes funciones: COALESCE, IFNULL, NULLIF.
Explicar su objetivo en los comentarios de la plantilla .sql
*/

-- Consulta utilizando COALESCE: Obtener la lista de actividades junto con su precio por sesión, mostrando 'No especificado' en caso de que el precio sea nulo.
SELECT 
    actividad,
    COALESCE(CAST(precio_sesion AS CHAR), 'No especificado') AS precio_por_sesion
FROM 
    actividad;
    
-- Consulta utilizando IFNULL: Mostrar el documento de identidad y el nombre completo de los monitores, mostrando 'Sin nombre' en caso de que el nombre sea nulo.
SELECT 
    documento_identificacion,
    IFNULL(CONCAT(nombre, ' ', apellidos), 'Sin nombre') AS nombre_completo
FROM 
    monitores;

-- Consulta utilizando IFNULL: Mostrar el documento de identidad y el nombre completo de los monitores, mostrando 'Sin nombre' en caso de que el nombre sea nulo.
SELECT 
    documento_identificacion,
    IFNULL(CONCAT(nombre, ' ', apellidos), 'Sin nombre') AS nombre_completo
FROM 
    monitores;
    
-- Consulta utilizando NULLIF: Obtener la lista de socios con su identificación y estado de actividad, mostrando 'Inactivo' si el socio está inactivo, de lo contrario, muestra 'Activo'.
SELECT 
    documento_identidad,
    IF(NULLIF(activo, 1), 'Inactivo', 'Activo') AS estado_actividad
FROM 
    socio;
    
/*
Funciones UDF

13.
Crear una función UDF llamada Nombre Resumido que reciba como parámetros un nombre y un apellido y retorne un nombre en formato (Inicial de Nombre + "." + Apellido en mayúsculas. Ejemplo: L. LANAU).
Probar la función en dos consultas, una contra la tabla de monitores y otra contra la tabla de socios. Ambas consultas deberán mostrar el id del Socio o Monitor (según sea el caso), 
el Nombre Resumido además de sus nombres y apellidos y estar ordenadas por este campo.
*/

DELIMITER //

CREATE FUNCTION NombreResumido(nombre VARCHAR(30), apellido VARCHAR(40))
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE inicial_nombre CHAR(1);
    DECLARE apellido_mayus VARCHAR(40);
    SET inicial_nombre = UPPER(SUBSTRING(nombre, 1, 1));
    SET apellido_mayus = UPPER(apellido);
    RETURN CONCAT(inicial_nombre, '. ', apellido_mayus);
END//

DELIMITER ;

-- Monitores
SELECT id_monitor, NombreResumido(nombre, apellidos) AS Nombre_Completo_Resumido, nombre, apellidos
FROM monitores
ORDER BY Nombre_Completo_Resumido;

-- Socios
SELECT id_socio, NombreResumido(nombre, apellido1) AS Nombre_Completo_Resumido, nombre, apellido1
FROM socio
ORDER BY Nombre_Completo_Resumido;

/*
14.
Crear una función UDF llamada Pases cortesía. Se regalarán 3 pases de cortesía a aquellas empresas que tengan más de 10 empleados afiliados al gimnasio.
Hacer la consulta pertinente para probar la función.
*/

DELIMITER //

CREATE FUNCTION PasesCortesia(nif_empresa VARCHAR(15))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE num_empleados INT;

    SELECT COUNT(*) INTO num_empleados
    FROM corporativo
    WHERE nif = nif_empresa;

    IF num_empleados > 10 THEN
        RETURN 3; -- Otorgar 3 pases de cortesía a empresas con más de 10 empleados afiliados
    ELSE
        RETURN 0; -- No otorgar pases de cortesía
    END IF;
END//

DELIMITER ;

SELECT empresa.nif, empresa.empresa, PasesCortesia(empresa.nif) AS Pases_Cortesia
FROM empresa;

/*
15.
Crear una función UDF llamada Kit Cortesía. Se regalarán un kit de cortesía a aquellos socios que cumplan años durante el mes (que recibirá la función por parámetro) según los siguientes criterios:

Planes premium: (3 y 4) Una entrada para dos personas para Parque acuático (de abril a noviembre) o Pista de Esquí (de diciembre a marzo)
Resto de planes: Botella de agua + toalla.
Hacer la consulta pertinente para probar la función.
*/

DELIMITER //

CREATE FUNCTION KitCortesia(fecha_cumpleaños date)
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE tipo_plan INT;
    DECLARE kit VARCHAR(255);

    -- Obtener el tipo de plan del socio
    SELECT id_plan INTO tipo_plan
    FROM socio
    WHERE MONTH(fecha_cumpleaños) = MONTH(fecha_nacimiento)
    LIMIT 1;

    -- Definir el kit de cortesía según el tipo de plan y la fecha de cumpleaños
    IF tipo_plan IN (3, 4) THEN
        IF MONTH(fecha_cumpleaños) BETWEEN 4 AND 11 THEN
            SET kit = 'Una entrada para dos personas para Parque acuático';
        ELSE
            SET kit = 'Una entrada para dos personas para Pista de Esquí';
        END IF;
    ELSE
        SET kit = 'Botella de agua + toalla';
    END IF;

    RETURN kit;
END//

DELIMITER ;

-- Supongamos que queremos verificar el kit de cortesía para los socios que cumplen años en el mes de diciembre (mes 12)
SELECT id_socio, fecha_nacimiento, KitCortesia(CONCAT(YEAR(CURDATE()), '-12-01')) AS Kit_Cortesia
FROM socio
WHERE MONTH(fecha_nacimiento) = 12;

/*
16.
Crear una función UDF llamada Grasa Corporal que recibirá un parámetro de entrada en referencia al porcentaje de grasa corporal y lo traducirá de la siguiente manera:

HOMBRES: Baja (0.04 a 0.09), Saludable (0.1 a 0.19), Sobrepeso (0.2 a 0.24), Obesidad (>0.24)
MUJERES: Baja (0.09 a 0.16), Saludable (0.17 a 0.29), Sobrepeso (0.3 a 0.34), Obesidad (>0.34)

Probar la función con una consulta contra la tabla de seguimiento, donde se encuentra un campo llamado 'porcentaje_grasa_corporal'. 
La salida de la consulta deberá tener el id del Socio, su nombre y apellido, el porcentaje de grasa corporal, el resultado de la función Grasa Corporal y estar ordenada por id_socio, año y semana.
*/

DELIMITER //

CREATE FUNCTION GrasaCorporal(genero CHAR(1), porcentaje DECIMAL(10,2))
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE resultado VARCHAR(50);

    IF genero = 'H' THEN
        IF porcentaje BETWEEN 0.04 AND 0.09 THEN
            SET resultado = 'Baja';
        ELSEIF porcentaje BETWEEN 0.1 AND 0.19 THEN
            SET resultado = 'Saludable';
        ELSEIF porcentaje BETWEEN 0.2 AND 0.24 THEN
            SET resultado = 'Sobrepeso';
        ELSE
            SET resultado = 'Obesidad';
        END IF;
    ELSEIF genero = 'M' THEN
        IF porcentaje BETWEEN 0.09 AND 0.16 THEN
            SET resultado = 'Baja';
        ELSEIF porcentaje BETWEEN 0.17 AND 0.29 THEN
            SET resultado = 'Saludable';
        ELSEIF porcentaje BETWEEN 0.3 AND 0.34 THEN
            SET resultado = 'Sobrepeso';
        ELSE
            SET resultado = 'Obesidad';
        END IF;
    ELSE
        SET resultado = 'Género no válido';
    END IF;

    RETURN resultado;
END//

DELIMITER ;

SELECT s.id_socio, s.nombre, s.apellido1, seguimiento.porcentaje_grasa_corporal,
       GrasaCorporal(s.sexo, seguimiento.porcentaje_grasa_corporal) AS 'Resultado Grasa Corporal'
FROM socio s
JOIN seguimiento ON s.id_socio = seguimiento.id_socio
ORDER BY s.id_socio, seguimiento.anno, seguimiento.semana;

/*
Variables de @Usuario
17.
Hacer una vista llamada cumpleanhos con la lista de cumpleañeros del mes. La consulta de la vista, deberá tener los siguientes campos: id_socio, nombre, apellido1, id_plan, plan, tipo, fecha_nacimiento
*/

CREATE VIEW cumpleanhos AS
SELECT 
    socio.id_socio,
    socio.nombre,
    socio.apellido1,
    socio.id_plan,
    plan.plan,
    plan.tipo,
    socio.fecha_nacimiento
FROM socio
JOIN plan ON socio.id_plan = plan.id_plan
WHERE MONTH(socio.fecha_nacimiento) = MONTH(CURDATE());

/*
18.
Crear dos variables de usuario. Una denominada @codigo_plan y la otra @mes_actual.
Asignar un valor a la variable @codigo_plan entre los planes que tiene el gimnasio.
Asignar el valor del mes en curso a la variable @mes_actual

*/

-- Asignar valor a la variable @codigo_plan con el plan 1
SET @codigo_plan := 2;

-- Asignar valor del mes actual a la variable @mes_actual
SET @mes_actual := MONTH(CURDATE());

-- Mostrar los valores de las variables
SELECT @codigo_plan AS codigo_plan, @mes_actual AS mes_actual;

/*
19.
Hacer una consulta basada en la vista cumpleanhos que utilice las variables de usuario para filtrar los cumpleañeros del mes que pertenezcan a un plan determinado.
*/

-- Consulta que filtra los cumpleañeros del mes y un plan específico
SELECT id_socio, nombre, apellido1, id_plan, plan, tipo, fecha_nacimiento
FROM cumpleanhos
WHERE MONTH(fecha_nacimiento) = @mes_actual -- Filtrar por el mes actual
AND id_plan = @codigo_plan; -- Filtrar por el plan específico











