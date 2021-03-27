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
desde = '20210227'
hasta = '20210227'

# seteo carpeta de trabajo
dir = '~/repos/dlm-blog/posteos/resumenes/semanales/8'

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
fwrite(dfoto_palabras_texto[diario != 'Casa Rosada'][1:200], paste0(dir,'/palabras_texto_blog.csv'))

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
fwrite(dfoto_palabras_titulo[diario != 'Casa Rosada'][1:200], paste0(dir,'/palabras_titulo_blog.csv'))

# vuelvo a leer los datasets enteros
dfoto_palabras_titulo = fread(paste0(dir,'/palabras_titulo.csv'))
dfoto_palabras_titulo = formatear(dfoto_palabras_titulo, cantidad_decimales = -1)
dfoto_palabras_texto = fread(paste0(dir,'/palabras_texto.csv'))
dfoto_palabras_texto = formatear(dfoto_palabras_texto, cantidad_decimales = -1)

# aca empiezo a desarrollar...

# EJEMPLO: gráficar como se trata el tema 'dólar' en los medios, filtrando por algunas palabras, buscando en textos y titulos.
covax = c('covax', 'COVAX', 'C.O.V.A.X.')

a_dibujar = rbind(
  dfoto_palabras_titulo[palabra %in% covax, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'COVAX'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% covax, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'COVAX'), keyby=.('clave' = diario)])
gglollipop(a_dibujar[clave != 'Casa Rosada'])

pfizer = c('Pfizer', 'pfizer')
sinopharm = c('Sinopharm', 'sinopharm')
china = c('china')

a_dibujar = rbind(
  dfoto_palabras_titulo[palabra %in% pfizer, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Pfizer'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% pfizer, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Pfizer'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% sinopharm, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Sinopharm'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% sinopharm, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Sinopharm'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% china, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'china'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% china, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'china'), keyby=.('clave' = diario)]
)
gglollipop(a_dibujar[clave != 'Casa Rosada'])

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
  dfoto_palabras_titulo[palabra %in% gines, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Ginés'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% gines, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Ginés'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% verbitsky, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Verbitsky'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% verbitsky, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Verbitsky'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% aranda, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Aranda'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% aranda, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Aranda'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% vizzotti, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Vizzotti'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% vizzotti, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Vizzotti'), keyby=.('clave' = diario)]
)
gglollipop(a_dibujar[clave != 'Casa Rosada'])

#27F
marcha = c('27F', '27f', '#27F', '#27f')

a_dibujar = rbind(
  dfoto_palabras_titulo[palabra %in% marcha, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = '27F'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% marcha, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = '27F'), keyby=.('clave' = diario)])
gglollipop(a_dibujar[clave != 'Casa Rosada'])

dfoto_palabras_titulo[palabra == '27F']
