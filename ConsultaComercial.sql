select distinct e.id_empresa,e.id_empresa_padre,e.razon_social
,((Case when a.ilimitadoDate > b.unidadesDate and a.id_tipo_prueba = 1 then 'Paquete de Selección'
        when a.ilimitadoDate > b.unidadesDate and a.id_tipo_prueba = 3 then 'Paquete de Organizacional'
        when b.unidadesDate > a.ilimitadoDate and b.id_tipo_prueba = 1 then 'Paquete de Selección'
        when b.unidadesDate > a.ilimitadoDate and b.id_tipo_prueba = 3 then  'Paquete de Organizacional'
        when a.ilimitadoDate is not null and a.id_tipo_prueba = 1 then 'Paquete de Selección'   
        when a.ilimitadoDate is not null and a.id_tipo_prueba = 3 then 'Paquete de Organizacional'
        when b.unidadesDate is not null and b.id_tipo_prueba = 1  then 'Paquete de Selección'    
        when b.unidadesDate is not null and b.id_tipo_prueba = 3  then 'Paquete de Organizacional'
                                                            else 'sin paquete asignado' end)) 'Tipo de prueba'
,(Case when a.ilimitadoDate > b.unidadesDate then 'Ilimitado ultimo adquirido '
                                                            when b.unidadesDate > a.ilimitadoDate then 'Unidades ultimo adquirido '
                                                            when a.ilimitadoDate is not null then 'Solo Ilimitado'
                                                            when b.unidadesDate is not null then 'Solo unidades'
                                                            else 'sin paquete asignado' end) as 'Tipo de paquete'
,(Case when a.ilimitadoDate > b.unidadesDate then 'Ilimitado'
                                                            when b.unidadesDate > a.ilimitadoDate then b.unidades
                                                            when a.ilimitadoDate is not null then 'Ilimitado'
                                                            when b.unidadesDate is not null then b.unidades
                                                            else 'sin paquete asignado' end) 'Unidades adquiridas en el último paquete'   
,(case when a.ilimitadoDate > b.unidadesDate then 'Ilimitado'
                                                            when b.unidadesDate > a.ilimitadoDate then unidades_padre.SUM_PADRE
                                                            when a.ilimitadoDate is not null then 'Ilimitado'
                                                            when b.unidadesDate is not null then unidades_padre.SUM_PADRE
                                                            else 'sin paquete asignado' End) as 'unidades disponibles'
,(Case when a.ilimitadoDate > b.unidadesDate then SUBSTRING(a.ilimitadoDate,1,10) 
       when b.unidadesDate > a.ilimitadoDate then 'No aplica'
       when a.ilimitadoDate is not null then SUBSTRING(a.ilimitadoDate,1,10) 
       when b.unidadesDate is not null then 'No aplica'
       else 'No aplica' End) as 'Fecha de compra último paquete ilimitado'                                                           
,(Case when a.ilimitadoDate > b.unidadesDate then a.fecha_vencimiento
       when b.unidadesDate > a.ilimitadoDate then 'No aplica'
       when a.ilimitadoDate is not null then SUBSTRING(a.fecha_vencimiento,1,10) 
       when b.unidadesDate is not null then 'No aplica'
  else 'No aplica' End) as 'Fecha de vencimiento Paquete ilimitado'
,(	 CASE
        WHEN a.ilimitadoDate > b.unidadesDate #and TIMESTAMPDIFF(MONTH, a.ilimitadoDate, a.fecha_vencimiento) > 0 
        THEN
            CONCAT(
                TIMESTAMPDIFF(MONTH, a.ilimitadoDate, a.fecha_vencimiento), ' mes(es) y ',
                DATEDIFF(
                    a.fecha_vencimiento,
                    DATE_ADD(a.ilimitadoDate, INTERVAL TIMESTAMPDIFF(MONTH, a.ilimitadoDate, a.fecha_vencimiento) MONTH)
                ), ' día(s)'
            ) 
       when b.unidadesDate > a.ilimitadoDate then 'No aplica'
       when a.ilimitadoDate is not null  THEN
            CONCAT(
                TIMESTAMPDIFF(MONTH, a.ilimitadoDate, a.fecha_vencimiento), ' mes(es) y ',
                DATEDIFF(
                    a.fecha_vencimiento,
                    DATE_ADD(a.ilimitadoDate, INTERVAL TIMESTAMPDIFF(MONTH, a.ilimitadoDate, a.fecha_vencimiento) MONTH)
                ), ' día(s)'
            ) 
       when b.unidadesDate is not null then 'No aplica'
            
   else 'No aplica' end) AS 'Días entre compra y vencimiento'
,(Case when a.ilimitadoDate > b.unidadesDate then IFNULL(ilimitado_consumo.SUM_Ilimitado,0)
       when b.unidadesDate > a.ilimitadoDate then 'No aplica'
       when a.ilimitadoDate is not null then IFNULL(ilimitado_consumo.SUM_Ilimitado,0)
       when b.unidadesDate is not null then 'No aplica'
       else 'sin paquete asignado' end) as 'Cosumo del paquete Ilimitado'
,(case
	   when a.ilimitadoDate > b.unidadesDate and a.fecha_vencimiento < CURDATE() then 'Inactivo Ilimitado'
	   WHEN a.ilimitadoDate > b.unidadesDate and DATEDIFF(a.fecha_vencimiento, CURRENT_DATE()) <= 7 THEN CONCAT('Faltan ', DATEDIFF(a.fecha_vencimiento, CURRENT_DATE()) + 1 , ' días o menos para vencer')
	   when a.ilimitadoDate > b.unidadesDate and a.fecha_vencimiento > CURDATE() then 'Activo Ilimitado'
       
       
       when # b.unidadesDate > a.ilimitadoDate and
       unidades_padre.SUM_PADRE <= 0 and b.unidades is not null
       then 'Sin unidades'
       when unidades_padre.SUM_PADRE <= IFNULL(CEIL(unidades_padre.SUM_PADRE * 0.10), 1) and b.unidades is not null  THEN 'Menos del 10 por ciento de unidades'
       when
       # b.unidadesDate > a.ilimitadoDate and
       unidades_padre.SUM_PADRE > 0
       then 'unidades Disponibles'
       when a.ilimitadoDate is not null and a.fecha_vencimiento < CURDATE() then 'Inactivo Ilimitado'
       WHEN a.ilimitadoDate is not null and DATEDIFF(a.fecha_vencimiento, CURRENT_DATE()) <= 7 THEN CONCAT('Faltan ', DATEDIFF(a.fecha_vencimiento, CURRENT_DATE()) + 1 , ' días o menos para vencer')
       else 'sin paquete asignado' End) as 'Estado del paquete'
from empresa e
left join
(
/*Muestra la fecha mayor de creacion de un paquete Ilimitado*/
select eevu.id_empresa_vencimiento ,eevu.id_empresa,eevu.concepto,eevu.fecha_vencimiento, eevu.created_at as ilimitadoDate,eevu.id_tipo_prueba  from es_empresa_vencimiento_unidades eevu
where eevu.created_at = (select MAX(eevu1.created_at) from es_empresa_vencimiento_unidades eevu1 WHERE eevu.id_empresa = eevu1.id_empresa and eevu1.id_tipo_prueba in (1,3) )
order by eevu.id_empresa desc
) a on a.id_empresa = e.id_empresa
left join
(
/*Muestra la fecha mayor de creacion de unidades*/
SELECT et.id_empresa, et.concepto, et.unidades, et.id_tipo_prueba , et.created_at as unidadesDate
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
    SELECT SUM(A.unidades) AS SUM_PADRE, A.id_empresa, A.id_tipo_prueba, e.id_empresa_padre
    FROM es_transacciones A
    inner join empresa e on A.id_empresa = e.id_empresa
    #where A.id_empresa IN (6, 108, 41, 157, 176)
    GROUP BY A.id_empresa, A.id_tipo_prueba, e.id_empresa_padre
) unidades_padre on unidades_padre.id_empresa = e.id_empresa
/*Cosulta para el cosumo de unidades paquete ilimitado*/
left join (
    SELECT
        A.id_empresa,
        A.id_tipo_prueba,
        e.id_empresa_padre,
        IFNULL(ABS(SUM(A.unidades)),0) AS SUM_Ilimitado
    FROM
        es_transacciones A
    INNER JOIN
        empresa e ON A.id_empresa = e.id_empresa
    INNER JOIN (
        SELECT
            id_empresa,
            MAX(created_at) AS max_created_at
        FROM
            es_empresa_vencimiento_unidades
        WHERE
            id_tipo_prueba IN (1, 3)
        GROUP BY
            id_empresa
    ) AS mf2 ON A.id_empresa = mf2.id_empresa
    WHERE
        A.created_at >= mf2.max_created_at and unidades <0 # and A.id_empresa = 1039
    GROUP BY
        A.id_empresa, A.id_tipo_prueba, e.id_empresa_padre
 
) ilimitado_consumo on ilimitado_consumo.id_empresa = a.id_empresa and a.id_tipo_prueba = ilimitado_consumo.id_tipo_prueba
where e.id_empresa_padre = 1
order by e.id_empresa desc