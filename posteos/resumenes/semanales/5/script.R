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

dfoto_palabras_titulo22 = fread('~/repos/dicenlosmedios.com.ar/resumen-semanal-5/palabras_titulo.csv')
dfoto_palabras_texto = fread('~/repos/dicenlosmedios.com.ar/resumen-semanal-5/palabras_texto.csv')

a_dibujar = rbind(
  dfoto_palabras_titulo[palabra %in% c('Alberto', 'Alberto Fernández'), .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Alberto Fernández'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% c('Alberto', 'Alberto Fernández'), .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Alberto Fernández'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% c('Larreta', 'Horacio Larreta', 'Horacio Rodríguez Larreta'), .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Larreta'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% c('Larreta', 'Horacio Larreta', 'Horacio Rodríguez Larreta'), .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Larreta'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% c('Gildo Insfrán', 'Insfrán'), .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Insfrán'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% c('Gildo Insfrán', 'Insfrán'), .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Insfrán'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% c('Kicillof', 'Axel Kicillof'), .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Kicillof'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% c('Kicillof', 'Axel Kicillof'), .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Kicillof'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% c('Macri', 'Mauricio Macri'), .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Macri'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% c('Macri', 'Mauricio Macri'), .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Macri'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% c('CFK', 'Cristina', 'Cristina Fernández de Kirchner'), .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'CFK'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% c('CFK', 'Cristina', 'Cristina Fernández de Kirchner'), .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'CFK'), keyby=.('clave' = diario)]
)
gglollipop(a_dibujar[clave != 'casarosada'])

a_dibujar = rbind(
  dfoto_palabras_titulo[palabra %in% c('Boca', 'Boca Juniors', 'Riquelme'), .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Boca'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% c('Boca', 'Boca Juniors', 'Riquelme'), .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Boca'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% c('River', 'River Plate', 'Gallardo'), .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'River'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% c('River', 'River Plate', 'Gallardo'), .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'River'), keyby=.('clave' = diario)]
  )
gglollipop(a_dibujar[clave != 'casarosada'], colores = c('darkblue', 'red'))

a_dibujar = rbind(
  dfoto_palabras_titulo[palabra %in% c('vacunación'), .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'vacunación'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% c('vacunación'), .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'vacunación'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% c('Sputnik', 'Sputnik V'), .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Sputnik V'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% c('Sputnik', 'Sputnik V'), .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Sputnik V'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% c('AstraZeneca'), .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'AstraZeneca'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% c('AstraZeneca'), .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'AstraZeneca'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% c('Pfizer'), .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Pfizer'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% c('Pfizer'), .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Pfizer'), keyby=.('clave' = diario)]
)
gglollipop(a_dibujar[clave != 'casarosada'])
