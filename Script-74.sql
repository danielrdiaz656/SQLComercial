SELECT distinct e.id_empresa ,e.identificacion as NIT,e.razon_social,
(case when e1.id_empresa is not null then 'Paquete activo Ilimitado'
      
      when unidades_padre.id_empresa is not null then 'Paquete con unidades activas'
      when e2.id_empresa is not null then 'Paquete con ilimitado vencido '
      else 'Por definir' End ) 'Estado Paquete'
FROM empresa e
left join
    (
    
       /*Sub consulta para traer los paquetes Ilimitado Vigentes*/       
       select eevu.id_empresa,eevu.created_at,eevu.fecha_vencimiento,eevu.id_tipo_prueba,eevu.concepto,eevu.estado from es_empresa_vencimiento_unidades eevu
       where CURDATE() < eevu.fecha_vencimiento and eevu.estado = 1 and eevu.id_tipo_prueba in (1,3)
    
    ) e1 on e1.id_empresa = e.id_empresa
left join
   (
   /*Empresas Con ultimo pquete vencido*/
      select DISTINCT  eevu.id_empresa,eevu.created_at,eevu.fecha_vencimiento,eevu.id_tipo_prueba,eevu.concepto,eevu.estado  from es_empresa_vencimiento_unidades eevu
      where CURDATE() > eevu.fecha_vencimiento and eevu.created_at = (SELECT max(eevu1.created_at) from es_empresa_vencimiento_unidades eevu1
                                                                      where eevu.id_empresa =  eevu1.id_empresa) and eevu.id_tipo_prueba in (1,3)
   
   ) e2 on e2.id_empresa = e.id_empresa
  
left join
(
    SELECT SUM(A.unidades) AS SUM_PADRE, A.id_empresa, A.id_tipo_prueba
    FROM es_transacciones A
    #where A.id_empresa IN (6, 108, 41, 157, 176)
    GROUP BY A.id_empresa, A.id_tipo_prueba
) unidades_padre on unidades_padre.id_empresa = e.id_empresa
left JOIN (
    SELECT et.id_empresa, et.id_tipo_prueba, et.unidades, SUBSTRING(et.created_at, 1, 7) AS created_at
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
) ultimo_paquete ON e.id_empresa = ultimo_paquete.id_empresa AND ultimo_paquete.id_tipo_prueba = unidades_padre.id_tipo_prueba
left join es_tipo_prueba etp on unidades_padre.id_tipo_prueba = etp.id_tipo_prueba
where etp.id_tipo_prueba in (1,3)  and e.id_empresa_padre = 1  #in (1,3,4)
group by e.id_empresa
order by e.id_empresa desc





































select * from es_transacciones et
where et.unidades > 0
et.concepto IN ('Devolución de unidades para emparejamiento a 0.')