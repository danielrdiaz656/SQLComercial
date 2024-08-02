Select  a.id_empresa,
    #a.id_empresa_padre,
    a.razon_social,a.Tipo_de_prueba as 'Tipo de prueba' ,a.Tipo_de_paquete,a.Unidades_adquiridas_en_el_ultimo_paquete,
    a.unidades_disponibles,a.Fecha_de_compra_ultimo_paquete_ilimitado, a.Fecha_de_vencimiento_Paquete_ilimitado, a.Días_entre_compra_y_vencimiento,
    a.Concepto,a.Cosumo_del_paquete_Ilimitado
    ,
     (
        CASE
	        WHEN a.Tipo_de_paquete in ('Solo unidades','Unidades ultimo adquirido') AND a.unidades_disponibles < 1 THEN 'Sin unidades'
            WHEN a.Tipo_de_paquete in ('Solo unidades','Unidades ultimo adquirido') and a.unidades_disponibles <= IFNULL(CEIL(a.unidades_disponibles * 0.10), 1) THEN 'Menos del 10 por ciento de unidades'
            WHEN a.Tipo_de_paquete in ('Solo unidades','Unidades ultimo adquirido') and a.unidades_disponibles > 0 THEN 'unidades Disponibles'
            #--WHEN b.unidadesDate > a.ilimitadoDate AND unidades_padre.SUM_PADRE > 0 THEN 'unidades Disponibles'
	        
	        
            WHEN a.Tipo_de_paquete in ('Solo Ilimitado','Ilimitado ultimo adquirido') AND a.Fecha_de_vencimiento_Paquete_ilimitado < CURDATE() THEN 'Inactivo Ilimitado'
            WHEN a.Tipo_de_paquete in ('Solo Ilimitado','Ilimitado ultimo adquirido') 
                 AND DATEDIFF(a.Fecha_de_vencimiento_Paquete_ilimitado, CURRENT_DATE()) <= 7 
                 THEN CONCAT('Faltan ', DATEDIFF(a.Fecha_de_vencimiento_Paquete_ilimitado, CURRENT_DATE()) + 1, ' días o menos para vencer')
            #-- WHEN a.Tipo_de_paquete in ('Solo Ilimitado','Ilimitado ultimo adquirido')  AND a.fecha_vencimiento < CURDATE() THEN 'Inactivo Ilimitado'
            #--WHEN a.ilimitadoDate IS NOT NULL AND DATEDIFF(a.fecha_vencimiento, CURRENT_DATE()) <= 7 THEN CONCAT('Faltan ', DATEDIFF(a.fecha_vencimiento, CURRENT_DATE()) + 1, ' días o menos para vencer')
            
            WHEN a.Tipo_de_paquete in ('Solo Ilimitado','Ilimitado ultimo adquirido') AND a.Fecha_de_vencimiento_Paquete_ilimitado > CURDATE() THEN 'Activo Ilimitado'
            # --WHEN a.ilimitadoDate IS NOT NULL AND a.fecha_vencimiento > CURDATE() THEN 'Activo Ilimitado'
            When a.Tipo_de_paquete = 'sin paquete asignado' then 'sin paquete asignado'
            

        END
    ) AS 'Estado del paquete Ilimitado'
    
From (

SELECT DISTINCT 
    e.id_empresa,
    e.id_empresa_padre,
    e.razon_social,
    (
        CASE 
            WHEN a.ilimitadoDate > b.unidadesDate AND a.id_tipo_prueba = 1 THEN 'Paquete de Selección'
            WHEN a.ilimitadoDate > b.unidadesDate AND a.id_tipo_prueba = 3 THEN 'Paquete de Organizacional'
            WHEN b.unidadesDate > a.ilimitadoDate AND b.id_tipo_prueba = 1 THEN 'Paquete de Selección'
            WHEN b.unidadesDate > a.ilimitadoDate AND b.id_tipo_prueba = 3 THEN 'Paquete de Organizacional'
            WHEN a.ilimitadoDate IS NOT NULL AND a.id_tipo_prueba = 1 THEN 'Paquete de Selección'
            WHEN a.ilimitadoDate IS NOT NULL AND a.id_tipo_prueba = 3 THEN 'Paquete de Organizacional'
            WHEN b.unidadesDate IS NOT NULL AND b.id_tipo_prueba = 1 THEN 'Paquete de Selección'
            WHEN b.unidadesDate IS NOT NULL AND b.id_tipo_prueba = 3 THEN 'Paquete de Organizacional'
            ELSE 'sin paquete asignado' 
        END
    ) AS Tipo_de_prueba ,
    (
        CASE 
            WHEN a.ilimitadoDate > b.unidadesDate THEN 'Ilimitado ultimo adquirido'
            WHEN b.unidadesDate > a.ilimitadoDate THEN 'Unidades ultimo adquirido'
            WHEN a.ilimitadoDate IS NOT NULL THEN 'Solo Ilimitado'
            WHEN b.unidadesDate IS NOT NULL THEN 'Solo unidades'
            ELSE 'sin paquete asignado' 
        END
    ) AS Tipo_de_paquete,
    (
        CASE 
            WHEN a.ilimitadoDate > b.unidadesDate THEN 'Ilimitado'
            WHEN b.unidadesDate > a.ilimitadoDate THEN b.unidades
            WHEN a.ilimitadoDate IS NOT NULL THEN 'Ilimitado'
            WHEN b.unidadesDate IS NOT NULL THEN b.unidades
            ELSE 'sin paquete asignado' 
        END
    ) AS Unidades_adquiridas_en_el_ultimo_paquete,
    (
        CASE 
            WHEN a.ilimitadoDate > b.unidadesDate THEN 'Ilimitado'
            WHEN b.unidadesDate > a.ilimitadoDate THEN unidades_padre.SUM_PADRE
            WHEN a.ilimitadoDate IS NOT NULL THEN 'Ilimitado'
            WHEN b.unidadesDate IS NOT NULL THEN unidades_padre.SUM_PADRE
            ELSE 'sin paquete asignado' 
        END
    ) AS unidades_disponibles,
    (
        CASE 
            WHEN a.ilimitadoDate > b.unidadesDate THEN SUBSTRING(a.ilimitadoDate, 1, 10)
            WHEN b.unidadesDate > a.ilimitadoDate THEN 'No aplica'
            WHEN a.ilimitadoDate IS NOT NULL THEN SUBSTRING(a.ilimitadoDate, 1, 10)
            WHEN b.unidadesDate IS NOT NULL THEN 'No aplica'
            ELSE 'No aplica' 
        END
    ) AS Fecha_de_compra_ultimo_paquete_ilimitado,
    (
        CASE 
            WHEN a.ilimitadoDate > b.unidadesDate THEN a.fecha_vencimiento
            WHEN b.unidadesDate > a.ilimitadoDate THEN 'No aplica'
            WHEN a.ilimitadoDate IS NOT NULL THEN SUBSTRING(a.fecha_vencimiento, 1, 10)
            WHEN b.unidadesDate IS NOT NULL THEN 'No aplica'
            ELSE 'No aplica' 
        END
    ) AS Fecha_de_vencimiento_Paquete_ilimitado,
    (
        CASE 
            WHEN a.ilimitadoDate > b.unidadesDate THEN
                CONCAT(
                    TIMESTAMPDIFF(MONTH, a.ilimitadoDate, a.fecha_vencimiento), ' mes(es) y ',
                    DATEDIFF(
                        a.fecha_vencimiento,
                        DATE_ADD(a.ilimitadoDate, INTERVAL TIMESTAMPDIFF(MONTH, a.ilimitadoDate, a.fecha_vencimiento) MONTH)
                    ), ' día(s)'
                )
            WHEN b.unidadesDate > a.ilimitadoDate THEN 'No aplica'
            WHEN a.ilimitadoDate IS NOT NULL THEN
                CONCAT(
                    TIMESTAMPDIFF(MONTH, a.ilimitadoDate, a.fecha_vencimiento), ' mes(es) y ',
                    DATEDIFF(
                        a.fecha_vencimiento,
                        DATE_ADD(a.ilimitadoDate, INTERVAL TIMESTAMPDIFF(MONTH, a.ilimitadoDate, a.fecha_vencimiento) MONTH)
                    ), ' día(s)'
                )
            WHEN b.unidadesDate IS NOT NULL THEN 'No aplica'
            ELSE 'No aplica' 
        END
    ) AS Días_entre_compra_y_vencimiento,
    (
        CASE 
            WHEN a.ilimitadoDate > b.unidadesDate THEN a.concepto
            WHEN b.unidadesDate > a.ilimitadoDate THEN 'No aplica'
            WHEN a.ilimitadoDate IS NOT NULL THEN a.concepto
            WHEN b.unidadesDate IS NOT NULL THEN 'No aplica'
            ELSE 'sin paquete asignado' 
        END
    ) AS Concepto,
    (
        CASE 
            WHEN a.ilimitadoDate > b.unidadesDate THEN IFNULL(ilimitado_consumo.SUM_Ilimitado, 0)
            WHEN b.unidadesDate > a.ilimitadoDate THEN 'No aplica'
            WHEN a.ilimitadoDate IS NOT NULL THEN IFNULL(ilimitado_consumo.SUM_Ilimitado, 0)
            WHEN b.unidadesDate IS NOT NULL THEN 'No aplica'
            ELSE 'sin paquete asignado' 
        END
    ) AS Cosumo_del_paquete_Ilimitado

FROM empresa e
LEFT JOIN (
/*Maxima Fecha de ilimitado*/
    SELECT 
        eevu.id_empresa_vencimiento,
        eevu.id_empresa,
        eevu.concepto,
        eevu.fecha_vencimiento,
        eevu.created_at AS ilimitadoDate,
        eevu.id_tipo_prueba
    FROM es_empresa_vencimiento_unidades eevu
    WHERE eevu.created_at in (
        SELECT MAX(eevu1.created_at)
        FROM es_empresa_vencimiento_unidades eevu1
        WHERE eevu.id_empresa = eevu1.id_empresa
        AND eevu1.id_tipo_prueba IN (1, 3)
        GROUP BY eevu1.id_tipo_prueba
    )
    ORDER BY eevu.id_empresa DESC
) a ON a.id_empresa = e.id_empresa
LEFT JOIN (
/*Maxima del ultimo paquete de unidades y cuantas unidades compro para ese paquete*/
    SELECT 
        et.id_empresa,
        et.concepto,
        et.unidades,
        et.id_tipo_prueba,
        et.created_at AS unidadesDate
    FROM es_transacciones et
    WHERE et.unidades > 1
    AND et.created_at in (
        SELECT MAX(et2.created_at)
        FROM es_transacciones et2
        WHERE et2.id_empresa = et.id_empresa
        AND et2.unidades > 1
        AND et2.id_tipo_prueba IN (1, 3)
        group by et2.id_tipo_prueba
    )
    AND et.id_tipo_prueba IN (1, 3) and et.id_empresa = 984
) b ON b.id_empresa = e.id_empresa AND a.id_tipo_prueba = b.id_tipo_prueba
LEFT JOIN (
    SELECT 
 /*Suma de Unidades cosumidas */
    
        SUM(A.unidades) AS SUM_PADRE,
        A.id_empresa,
        A.id_tipo_prueba,
        e.id_empresa_padre
    FROM es_transacciones A
    INNER JOIN empresa e ON A.id_empresa = e.id_empresa
    WHERE A.id_tipo_prueba IN (1, 3) #and e.id_empresa = 984
    GROUP BY A.id_empresa, A.id_tipo_prueba, e.id_empresa_padre
) unidades_padre ON unidades_padre.id_empresa = b.id_empresa 
                 AND b.id_tipo_prueba = unidades_padre.id_tipo_prueba
         
LEFT JOIN (
    SELECT 
 /*consumo  de ilimitado */    
        A.id_empresa,
        A.id_tipo_prueba,
        e.id_empresa_padre,
        IFNULL(ABS(SUM(A.unidades)), 0) AS SUM_Ilimitado
    FROM es_transacciones A
    INNER JOIN empresa e ON A.id_empresa = e.id_empresa
    INNER JOIN (
        SELECT 
            id_empresa,
            MAX(created_at) AS max_created_at
        FROM es_empresa_vencimiento_unidades
        WHERE id_tipo_prueba IN (1, 3)
        GROUP BY id_empresa
    ) AS mf2 ON A.id_empresa = mf2.id_empresa
    WHERE A.created_at >= mf2.max_created_at
    AND unidades < 0
    GROUP BY A.id_empresa, A.id_tipo_prueba, e.id_empresa_padre
) ilimitado_consumo ON ilimitado_consumo.id_empresa = a.id_empresa 
                    AND a.id_tipo_prueba = ilimitado_consumo.id_tipo_prueba 
                    
WHERE e.id_empresa_padre = 1
ORDER BY e.id_empresa DESC
) a
where a.id_empresa = 984