--select files()
create or replace view view_dados_base as (
select
	nomedabase as base_mostra,
	'Está há '||cast(dias as varchar(10))||' dias sem operação' as msg_mostra,
	case when info_view_data.tamanho_gb > 0 then
		'Ocupando '||cast(info_view_data.tamanho_gb as varchar(10))||' GB de espaço em disco '
	else
		'Ocupando '||cast(info_view_data.tamanho_mb as varchar(10))||' MB  de espaço em disco '
	end  as tamanho_base_mostra,
	info_view_data.dtultimaoperacao as mostra_data_ultima_operacao
from(
	select 
		info_view.*,
		pg_database_size(info_view.nomedabase) / 1024 / 1024 / 1024 as tamanho_gb,
		pg_database_size(info_view.nomedabase) / 1024 / 1024  as tamanho_mb	
	from (

		select 
			so_info.data as dtultimaoperacao, 
			current_date as dt_atual,
			current_date - so_info.data  as dias,
			so_info.base as nomedoarquivo,
			so_info.datname as nomedabase
		from (

			select 
				cast(inf_so.data as date) as data, 
				cast(base as varchar(40)) as base, 
				pg_database.datname  
			from (
					select 
						substr(filename,35,10) as data, 
						substr(filename,46,20) as base 
					from 
						files order by filename
			     ) as inf_so 
			       join 
			       pg_database on(cast(oid as varchar(40)) = inf_so.base)
			       where 
			       cast(inf_so.data as varchar(10)) <> '' 
		     ) as so_info
		     order by nomedabase
	    ) as info_view
	    where
	    nomedabase not in('template0', 'template1', 'postgres')
	order by info_view.dias desc
) as info_view_data
)