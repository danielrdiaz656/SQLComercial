
select ep.prueba_nombre
,ef.factor_nombre
,ed.dimension_nombre 
,er.id_reactivo,count(*) from es_pruebas ep 
inner join es_pruebas_factores epf on ep.id_prueba = epf.id_prueba 
inner join es_factores ef on ef.id_factor = epf.id_factor 
inner join es_factores_dimensiones efd on efd.id_factor =ef.id_factor 
inner join es_dimensiones_reactivos edr on efd.id_dimension = edr.id_dimension
inner join es_dimensiones ed ON edr.id_dimension = ed.id_dimension 
inner join es_reactivos er on edr.id_reactivo = er.id_reactivo 
group by ep.prueba_nombre
,ef.factor_nombre
,ed.dimension_nombre
order by ep.prueba_nombre desc, 5 desc



