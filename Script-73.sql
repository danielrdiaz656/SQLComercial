select b.id_transaccion,a.id_empresa_vencimiento,e.id_empresa,e.id_empresa_padre,e.razon_social
,(Case when a.ilimitadoDate > b.unidadesDate then 'Ilimitado'
                                                            when b.unidadesDate > a.ilimitadoDate then b.unidades
                                                            when a.ilimitadoDate is not null then 'Ilimitado'
                                                            when b.unidadesDate is not null then b.unidades
                                                            else 'sin paquete asignado' end) unidades
,(Case when a.ilimitadoDate > b.unidadesDate then 'Ilimitado ultimo adquirido '
                                                            when b.unidadesDate > a.ilimitadoDate then 'Unidades ultimo adquirido '
                                                            when a.ilimitadoDate is not null then 'Solo Ilimitado'
                                                            when b.unidadesDate is not null then 'Solo unidades'
                                                            else 'sin paquete asignado' end) as 'Estado del paquete'
,(Case when a.ilimitadoDate > b.unidadesDate then a.fecha_vencimiento else 'No aplica' End) as fecha_vencimiento                                                           
,a.ilimitadoDate,b.unidadesDate,e1.created_at as 'Creado vigente',e1.fecha_vencimiento 'Vencido vigente',e2.created_at as 'Creado Vencido',e2.fecha_vencimiento 'Vencido Vencido'
,unidades_padre.SUM_PADRE,ultimo_paquete.unidades,ultimo_paquete.created_at
from empresa e
left join
(
/*Muestra la fecha mayor de creacion de un paquete*/
select eevu.id_empresa_vencimiento ,eevu.id_empresa,eevu.concepto,eevu.fecha_vencimiento, eevu.created_at as ilimitadoDate,eevu.id_tipo_prueba  from es_empresa_vencimiento_unidades eevu
where eevu.created_at = (select MAX(eevu1.created_at) from es_empresa_vencimiento_unidades eevu1 WHERE eevu.id_empresa = eevu1.id_empresa and eevu1.id_tipo_prueba in (1,3) )
order by eevu.id_empresa desc
) a on a.id_empresa = e.id_empresa
left join
(
/*Muestra la fecha mayor de creacion de unidades*/
SELECT et.id_transaccion ,et.id_empresa, et.concepto, et.unidades, et.created_at as unidadesDate
FROM es_transacciones et
WHERE et.unidades > 1
AND et.created_at = (
    SELECT MAX(et2.created_at)
    FROM es_transacciones et2
    WHERE et2.id_empresa = et.id_empresa AND et2.unidades > 1 and et2.id_tipo_prueba in (1,3)
)
) b on b.id_empresa = e.id_empresa
left join
    (
    
       /*Sub consulta para traer los paquetes Ilimitado Vigentes*/       
       select eevu.id_empresa_vencimiento,eevu.id_empresa,eevu.created_at,eevu.fecha_vencimiento,eevu.id_tipo_prueba,eevu.concepto,eevu.estado from es_empresa_vencimiento_unidades eevu
       where CURDATE() < eevu.fecha_vencimiento and eevu.estado = 1 and eevu.id_tipo_prueba in (1,3)
    
    ) e1 on e1.id_empresa = e.id_empresa and a.id_empresa_vencimiento = e1.id_empresa_vencimiento
left join
   (
   /*Empresas Con ultimo pquete vencido*/
      select DISTINCT  eevu.id_empresa_vencimiento,eevu.id_empresa,eevu.created_at,eevu.fecha_vencimiento,eevu.id_tipo_prueba,eevu.concepto,eevu.estado  from es_empresa_vencimiento_unidades eevu
      where CURDATE() > eevu.fecha_vencimiento and eevu.created_at = (SELECT max(eevu1.created_at) from es_empresa_vencimiento_unidades eevu1
                                                                      where eevu.id_empresa =  eevu1.id_empresa) and eevu.id_tipo_prueba in (1,3)
   
   ) e2 on e2.id_empresa = e.id_empresa and a.id_empresa_vencimiento = e1.id_empresa_vencimiento
left join
(
    SELECT A.id_transaccion,SUM(A.unidades) AS SUM_PADRE, A.id_empresa, A.id_tipo_prueba
    FROM es_transacciones A
    #where A.id_empresa IN (6, 108, 41, 157, 176)
    GROUP BY A.id_empresa, A.id_tipo_prueba
) unidades_padre on unidades_padre.id_empresa = e.id_empresa and unidades_padre.id_transaccion = b.id_transaccion
left JOIN (
    SELECT et.id_transaccion,et.id_empresa, et.id_tipo_prueba, et.unidades, SUBSTRING(et.created_at, 1, 7) AS created_at
    FROM es_transacciones et
    INNER JOIN (
        SELECT tra.id_empresa, tra.id_tipo_prueba, MAX(tra.created_at) AS Ultima_compra
        FROM es_transacciones tra
        WHERE  tra.id_agenda IS NULL AND tra.unidades > 0
              #AND tra.id_empresa IN (6, 108, 41, 157, 176)
        GROUP BY
        tra.id_empresa, tra.id_tipo_prueba
    ) et1 ON et.id_empresa = et1.id_empresa AND et.id_tipo_prueba = et1.id_tipo_prueba AND et.created_at = et1.Ultima_compra 
    WHERE et.concepto NOT IN ('Devolución de unidades para emparejamiento a 0.')
) ultimo_paquete ON e.id_empresa = ultimo_paquete.id_empresa AND ultimo_paquete.id_tipo_prueba = unidades_padre.id_tipo_prueba and unidades_padre.id_transaccion = b.id_transaccion
where e.id_empresa_padre = 1