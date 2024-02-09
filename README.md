# BBDD-AdvancedQueries-II-Functions-SQL
Diseño y Programación de una BBDD (MySQL)

ACTIVIDAD:

Mostrar aquellos socios que cumplen años en el mes en curso.
El listado deberá mostrar los siguientes campos: idSocio, Nombre, Apellido1, Email, FechaNacimiento, Cumpleaños (sí/no) Ordenado por Día de nacimiento.
Contar cuántos socios mujeres y hombres han recomendado a otros socios, agrupados por PLAN.
El plan debe ser tipo 'P' (socios principales) La salida de la consulta deberá ser la siguiente.
Utilizar la función IF y agrupar.

Plan	Mujeres	Hombres
BASICO AM		
BASICO PM		
PREMIUM		
24h VIP		
24h		
ROSA		
Mostrar una lista de monitores donde se especifique si imparten una o más de una actividad.
La salida de la consulta deberá ser la siguiente. Utilizar la función CASE y agrupar.

id_monitor	nombre	apellidos	actividades
1	Lorena	Lanau	Más de una actividad
2	Mila	Kumari	Más de una actividad
3...	Eric	Taylor	Una actividad
Inventar una consulta que haga uso de una de las siguientes funciones: COALESCE, IFNULL, NULLIF.
Explicar su objetivo en los comentarios de la plantilla .sql

Funciones UDF
Crear una función UDF llamada Nombre Resumido que reciba como parámetros un nombre y un apellido y retorne un nombre en formato (Inicial de Nombre + "." + Apellido en mayúsculas. Ejemplo: L. LANAU).
Probar la función en dos consultas, una contra la tabla de monitores y otra contra la tabla de socios. Ambas consultas deberán mostrar el id del Socio o Monitor (según sea el caso), el Nombre Resumido además de sus nombres y apellidos y estar ordenadas por este campo.

Crear una función UDF llamada Pases cortesía. Se regalarán 3 pases de cortesía a aquellas empresas que tengan más de 10 empleados afiliados al gimnasio.
Hacer la consulta pertinente para probar la función.

Crear una función UDF llamada Kit Cortesía. Se regalarán un kit de cortesía a aquellos socios que cumplan años durante el mes (que recibirá la función por parámetro) según los siguientes criterios:

Planes premium: (3 y 4) Una entrada para dos personas para Parque acuático (de abril a noviembre) o Pista de Esquí (de diciembre a marzo)
Resto de planes: Botella de agua + toalla.
Hacer la consulta pertinente para probar la función.

Crear una función UDF llamada Grasa Corporal que recibirá un parámetro de entrada en referencia al porcentaje de grasa corporal y lo traducirá de la siguiente manera:

HOMBRES: Baja (0.04 a 0.09), Saludable (0.1 a 0.19), Sobrepeso (0.2 a 0.24), Obesidad (>0.24)
MUJERES: Baja (0.09 a 0.16), Saludable (0.17 a 0.29), Sobrepeso (0.3 a 0.34), Obesidad (>0.34)

Probar la función con una consulta contra la tabla de seguimiento, donde se encuentra un campo llamado 'porcentaje_grasa_corporal'. La salida de la consulta deberá tener el id del Socio, su nombre y apellido, el porcentaje de grasa corporal, el resultado de la función Grasa Corporal y estar ordenada por id_socio, año y semana.

Variables de @usuario
Hacer una vista llamada cumpleanhos con la lista de cumpleañeros del mes. La consulta de la vista, deberá tener los siguientes campos: id_socio, nombre, apellido1, id_plan, plan, tipo, fecha_nacimiento
Crear dos variables de usuario. Una denominada @codigo_plan y la otra @mes_actual.
Asignar un valor a la variable @codigo_plan entre los planes que tiene el gimnasio.
Asignar el valor del mes en curso a la variable @mes_actual
Hacer una consulta basada en la vista cumpleanhos que utilice las variables de usuario para filtrar los cumpleañeros del mes que pertenezcan a un plan determinado.
