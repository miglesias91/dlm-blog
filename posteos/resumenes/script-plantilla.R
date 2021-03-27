library(dlmr)
library(data.table)
library(jsonlite)

# setear la path donde esté 'dlm-login.json', que tiene que ser:
# {
#   "usuario" : "mi_usuario"
#   "password" : "mi_password"
#   "servidor" : "ip_del_servidor"
# }
login = fromJSON('~/keys/dlm-login.json')

usuario = login$usuario
password = login$password
servidor = login$servidor
conectar(usuario = usuario, password = password, servidor = servidor)

# setear fechas 'desde' y 'hasta', en formato aaaammdd
desde = ''
hasta = ''

# seteo carpeta de trabajo
dir = ''

# recupero la foto de los medios y categorias en las fechas seteadas
dfoto = foto(desde = desde, hasta = hasta)
# dfoto$por_dia = sprintf('%.2f',dfoto$por_dia) # guardo con 2 decimales
dfoto = formatear(dfoto)
fwrite(dfoto, paste0(dir,'/medios_categoria.csv'))

# recupero la foto de las palabras en los textos de noticias en las fechas seteadas
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
fwrite(dfoto_palabras_texto[!(diario %in% c('Casa Rosada','Popular'))][order(-freq)][1:200], paste0(dir,'/palabras_texto_blog.csv'))

# recupero la foto de las palabras en los titulos de noticias en las fechas seteadas
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
fwrite(dfoto_palabras_titulo[!(diario %in% c('Casa Rosada','Popular'))][order(-freq)][1:200], paste0(dir,'/palabras_titulo_blog.csv'))

# vuelvo a leer los datasets enteros
dfoto_palabras_titulo = fread(paste0(dir,'/palabras_titulo.csv'))
dfoto_palabras_titulo = formatear(dfoto_palabras_titulo, cantidad_decimales = -1)
dfoto_palabras_texto = fread(paste0(dir,'/palabras_texto.csv'))
dfoto_palabras_texto = formatear(dfoto_palabras_texto, cantidad_decimales = -1)

# aca empiezo a desarrollar...

# EJEMPLO: gráficar como se trata el tema 'dólar' en los medios, filtrando por algunas palabras, buscando en textos y titulos.
dolar = c('dólar', 'dólares', 'Dóĺar', 'Dólares')
blue = c('blue', 'Blue')
mep = c('MEP', 'mep')
solidario = c('solidario','Solidario', '35', '%35')

a_dibujar = rbind(
  dfoto_palabras_titulo[palabra %in% dolar, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'dólar'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% dolar, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'dólar'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% mep, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'mep'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% mep, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'mep'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% blue, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'blue'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% blue, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'blue'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% solidario, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'solidario'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% solidario, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'solidario'), keyby=.('clave' = diario)]
)
gglollipop(a_dibujar[clave != 'casarosada'], colores = c('#0040ff', '#2db300', 'red'))
