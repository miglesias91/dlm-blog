library(dlmr)
library(data.table)
library(jsonlite)

login = fromJSON('~/keys/dlm-login.json')

usuario = login$usuario
password = login$password
servidor = login$servidor

conectar(usuario = usuario, password = password, servidor = servidor)

desde = '20210125'
hasta = '20210131'

# seteo carpeta de trabajo
dir = '~/repos/dlm-blog/posteos/resumenes/semanales/4'

dfoto = foto()
fwrite(dfoto, '~/repos/dicenlosmedios.com.ar/resumen-semanal-4/medios_categoria.csv')

dfoto_palabras_texto = foto_palabras(que = c('terminos','personas'),
                                     donde = 'textos',
                                     desde = desde,
                                     hasta = hasta,
                                     freq_min = 3,
                                     min_noticias = 5,
                                     top = 10000,
                                     top_por_tendencia = 1000,
                                     por_categoria = F)
# guardo el dataset entero
fwrite(dfoto_palabras_texto, paste0(dir,'/palabras_texto.csv'))

# guardo el optimizado para subir al blog
# dfoto_palabras_texto$por_noticia = sprintf('%.2f',dfoto_palabras_texto$por_noticia)
dfoto_palabras_texto = formatear(dfoto_palabras_texto)
setcolorder(dfoto_palabras_texto, c('palabra', 'freq','por_noticia', 'diario'))
fwrite(dfoto_palabras_texto[diario != 'Casa Rosada'][1:200], paste0(dir,'/palabras_texto_blog.csv'))

dfoto_palabras_titulo = foto_palabras(que = c('terminos','personas'),
                                      donde = 'titulos',
                                      desde = desde,
                                      hasta = hasta,
                                      freq_min = 2,
                                      min_noticias = 5,
                                      top = 10000,
                                      top_por_tendencia = 1000,
                                      por_categoria = F)
# guardo el dataset entero
fwrite(dfoto_palabras_titulo, paste0(dir,'/palabras_titulo.csv'))

# guardo el optimizado para subir al blog
# dfoto_palabras_titulo$por_noticia = sprintf('%.2f',dfoto_palabras_titulo$por_noticia)
dfoto_palabras_titulo = formatear(dfoto_palabras_titulo)
setcolorder(dfoto_palabras_titulo, c('palabra', 'freq','por_noticia', 'diario'))
fwrite(dfoto_palabras_titulo[diario != 'Casa Rosada'][1:200], paste0(dir,'/palabras_titulo_blog.csv'))

# vuelvo a leer los datasets enteros
dfoto_palabras_titulo = fread(paste0(dir,'/palabras_titulo.csv'))
dfoto_palabras_titulo = formatear(dfoto_palabras_titulo, cantidad_decimales = -1)
dfoto_palabras_texto = fread(paste0(dir,'/palabras_texto.csv'))
dfoto_palabras_texto = formatear(dfoto_palabras_texto, cantidad_decimales = -1)

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
gglollipop(a_dibujar[clave != 'Casa Rosada'])

a_dibujar = rbind(
  dfoto_palabras_titulo[palabra %in% c('Boca', 'Boca Juniors', 'Riquelme'), .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Boca'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% c('Boca', 'Boca Juniors', 'Riquelme'), .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Boca'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% c('River', 'River Plate', 'Gallardo'), .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'River'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% c('River', 'River Plate', 'Gallardo'), .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'River'), keyby=.('clave' = diario)]
  )
gglollipop(a_dibujar[clave != 'Casa Rosada'], colores = c('darkblue', 'red'))

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
gglollipop(a_dibujar[clave != 'Casa Rosada'])

resto = c('Catamarca', 'Chaco', 'Chubut', 'Córdoba', 'Corrientes', 'Entre Ríos', 'Jujuy', 'La Pampa', 'La Rioja', 'Mendoza', 'Misiones', 'Neuquén', 'Río Negro', 'Salta', 'San Juan', 'San Luis', 'Santa Cruz', 'Santa Fe', 'Santiago del Estero', 'Tierra del Fuego', 'Tucumán')
formosa = c('Formosa')

a_dibujar = rbind(
  dfoto_palabras_titulo[palabra %in% formosa, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Formosa'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% formosa, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Formosa'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% resto, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Otras provincias'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% resto, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Otras provincias'), keyby=.('clave' = diario)]
)
gglollipop(a_dibujar[clave != 'Casa Rosada'])
