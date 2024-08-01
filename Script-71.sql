select p.nombre, f.nombre, d.nombre,COUNT(*)  from pruebas p 
inner join factores_pruebas fp on p.id = fp.prueba_id 
inner join factores f on f.id = fp.factor_id 
inner join dimensiones_factores df on df.factor_id = f.id 
inner join dimensiones d on d.id = df.dimension_id 
inner join dimensiones_reactivos dr on dr.dimension_id = d.id 
inner join reactivos r on r.id = dr.reactivo_id 
group by  p.nombre, f.nombre, d.nombre 
order by p.id desc