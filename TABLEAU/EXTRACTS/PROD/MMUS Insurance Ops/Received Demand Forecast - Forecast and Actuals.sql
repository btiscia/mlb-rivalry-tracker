select lpi.*
from dma_analytics.lpi_forecast_and_actuals_vw as lpi
union all
select lc.*
from dma_analytics.lc_forecast_and_actuals_vw as lc
union all
select anc.*
from dma_analytics.anc_forecast_and_actuals_vw as anc
union all
select psc.*
from dma_analytics.psc_forecast_and_actuals_vw as psc