library(dlmr)
library(data.table)
library(jsonlite)

login = fromJSON('~/keys/dlm-login.json')

usuario = login$usuario
password = login$password
servidor = login$servidor
conectar(usuario = usuario, password = password, servidor = servidor)

desde = '20210201'
hasta = '20210207'

dfoto = foto(desde = desde, hasta = hasta)
fwrite(dfoto, '~/repos/dicenlosmedios.com.ar/resumen-semanal-5/medios_categoria.csv')

dfoto_palabras_texto = foto_palabras(que = c('terminos','personas'),
                               donde = 'textos',
                               desde = desde,
                               hasta = hasta,
                               freq_min = 3,
                               min_noticias = 5,
                               top = 10000,
                               top_por_tendencia = 1000,
                               por_categoria = F)
setcolorder(dfoto_palabras_texto, c('palabra', 'freq','por_noticia', 'diario'))
fwrite(dfoto_palabras_texto[diario != 'casarosada'][1:200], '~/repos/dicenlosmedios.com.ar/resumen-semanal-5/palabras_texto.csv')

dfoto_palabras_titulo = foto_palabras(que = c('terminos','personas'),
                                     donde = 'titulos',
                                     desde = desde,
                                     hasta = hasta,
                                     freq_min = 2,
                                     min_noticias = 5,
                                     top = 10000,
                                     top_por_tendencia = 1000,
                                     por_categoria = F)

setcolorder(dfoto_palabras_titulo, c('palabra', 'freq','por_noticia', 'diario'))
fwrite(dfoto_palabras_titulo[diario != 'casarosada'][1:200], '~/repos/dicenlosmedios.com.ar/resumen-semanal-5/palabras_titulo.csv')

dfoto_palabras_titulo = fread('~/repos/dicenlosmedios.com.ar/resumen-semanal-5/palabras_titulo.csv')
dfoto_palabras_texto = fread('~/repos/dicenlosmedios.com.ar/resumen-semanal-5/palabras_texto.csv')
