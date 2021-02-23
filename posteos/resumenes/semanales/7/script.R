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
desde = '20210213'
hasta = '20210220'

# seteo carpeta de trabajo
dir = '~/repos/dlm-blog/posteos/resumenes/semanales/7'

# recupero la foto de los medios y categorias en las fechas seteadas
dfoto = foto(desde = desde, hasta = hasta)
dfoto$por_dia = sprintf('%.2f',dfoto$por_dia) # guardo con 2 decimales
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
dfoto_palabras_texto$por_noticia = sprintf('%.2f',dfoto_palabras_texto$por_noticia)
setcolorder(dfoto_palabras_texto, c('palabra', 'freq','por_noticia', 'diario'))
fwrite(dfoto_palabras_texto[diario != 'casarosada'][1:200], paste0(dir,'/palabras_texto_blog.csv'))

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
dfoto_palabras_titulo$por_noticia = sprintf('%.2f',dfoto_palabras_titulo$por_noticia)
setcolorder(dfoto_palabras_titulo, c('palabra', 'freq','por_noticia', 'diario'))
fwrite(dfoto_palabras_titulo[diario != 'casarosada'][1:200], paste0(dir,'/palabras_titulo_blog.csv'))

# vuelvo a leer los datasets enteros
dfoto_palabras_titulo = fread(paste0(dir,'/palabras_titulo.csv'))
dfoto_palabras_titulo = formatear(dfoto_palabras_titulo, cantidad_decimales = -1)
dfoto_palabras_texto = fread(paste0(dir,'/palabras_texto.csv'))
dfoto_palabras_texto = formatear(dfoto_palabras_texto, cantidad_decimales = -1)

# aca empiezo a desarrollar...

# Menem
menem = c('Menem', 'Carlos Menem', 'Carlos Saúl Menem', 'CSM')
riocuarto = c('Río Cuarto')
hiperinflacion = c('hiperinflación')
privatizacion = c('privatización')

a_dibujar = rbind(
  dfoto_palabras_titulo[palabra %in% menem, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Menem'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% menem, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Menem'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% riocuarto, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Río Cuarto'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% riocuarto, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Río Cuarto'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% hiperinflacion, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'hiperinflación'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% hiperinflacion, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'hiperinflación'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% privatizacion, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'privatización'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% privatizacion, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'privatización'), keyby=.('clave' = diario)]
)
gglollipop(a_dibujar[clave != 'casarosada'])

# Perseverance
perseverance = c('Perseverance', 'rover')
nasa = c('NASA')

a_dibujar = rbind(
  dfoto_palabras_titulo[palabra %in% perseverance, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Perseverance'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% perseverance, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Perseverance'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% nasa, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'NASA'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% nasa, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'NASA'), keyby=.('clave' = diario)]
)
gglollipop(a_dibujar[clave != 'casarosada'])

# vacunavip
vacunavip = c('vacunavip', 'VIP', 'vip')
vacunagate = c('vacunagate')
gines = c('Ginés','Ginés González', 'Ginés González García')
verbitsky = c('Verbitsky', 'Horacio Verbitsky')
aranda = c('Aranda', 'José Aranda', 'José Antonio Aranda')
vizzotti = c('Vizzotti', 'Carla Vizzotti')

a_dibujar = rbind(
  dfoto_palabras_titulo[palabra %in% vacunavip, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'vacunavip'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% vacunavip, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'vacunavip'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% vacunagate, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'vacunagate'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% vacunagate, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'vacunagate'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% gines, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Ginés'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% gines, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Ginés'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% verbitsky, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Verbitsky'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% verbitsky, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Verbitsky'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% aranda, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Aranda'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% aranda, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Aranda'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% vizzotti, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Vizzotti'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% vizzotti, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Vizzotti'), keyby=.('clave' = diario)]
)
gglollipop(a_dibujar[clave != 'casarosada'])

# AFI
afi = c('AFI', 'afi', 'Agencia Federal', 'Agencia Federal de Inteligencia')
espionaje = c('espionaje', 'Espionaje')
majdalani = c('Majdalani', 'Silvia Majdalani')
arribas = c('Arribas', 'Gustavo Arribas')

a_dibujar = rbind(
  dfoto_palabras_titulo[palabra %in% afi, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'AFI'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% afi, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'AFI'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% espionaje, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'espionaje'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% espionaje, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'espionaje'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% majdalani, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Majdalani'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% majdalani, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Majdalani'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% arribas, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Arribas'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% arribas, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Arribas'), keyby=.('clave' = diario)]
)
gglollipop(a_dibujar[clave != 'casarosada'])