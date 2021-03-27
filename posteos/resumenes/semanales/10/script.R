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
desde = '20210311'
hasta = '20210313'

# seteo carpeta de trabajo
dir = '~/repos/dlm/blog/posteos/resumenes/semanales/10'

diarios_ok = c('ambito', 'clarin', 'diariodeleuco', 'eldestape', 'paginadoce', 'perfil', 'popular', 'telam', 'todonoticias')
categorias_infobae = c('campo', 'cultura', 'deportes', 'economia', 'espectaculos', 'inhouse', 'opinion', 'politica', 'salud', 'sociedad', 'tecno', 'tendencias')
categorias_lanacion = c('autos', 'buenos-aires', 'ciencia', 'comunidad', 'cultura', 'deportes', 'economia', 'espectaculos',
                        'internacional', 'lifestyle', 'moda-y-belleza', 'opinion', 'politica', 'propiedades', 'salud', 'seguridad',
                        'tecnologia', 'turismo')

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
                                     diarios = diarios_ok,
                                     freq_min = 3,
                                     min_noticias = 5,
                                     top = 10000,
                                     top_por_tendencia = 1000,
                                     por_categoria = F)

dfoto_palabras_texto_infobae_por_cat = foto_palabras(que = c('terminos','personas'),
                                                     donde = 'textos',
                                                     desde = desde,
                                                     hasta = hasta,
                                                     diarios = c('infobae'),
                                                     categorias = categorias_infobae,
                                                     freq_min = 3,
                                                     min_noticias = 5,
                                                     top = 10000,
                                                     top_por_tendencia = 1000)
dfoto_palabras_texto_infobae = dfoto_palabras_texto_infobae_por_cat[,.(freq = sum(freq), diario = 'infobae', por_noticia = sum(por_noticia)), keyby = palabra]

dfoto_palabras_texto_lanacion_por_cat = foto_palabras(que = c('terminos','personas'),
                                                      donde = 'textos',
                                                      desde = desde,
                                                      hasta = hasta,
                                                      diarios = c('lanacion'),
                                                      categorias = categorias_lanacion,
                                                      freq_min = 3,
                                                      min_noticias = 5,
                                                      top = 10000,
                                                      top_por_tendencia = 1000,
                                                      por_categoria = T)
dfoto_palabras_texto_lanacion = dfoto_palabras_texto_lanacion_por_cat[,.(freq = sum(freq), diario = 'lanacion', por_noticia = sum(por_noticia)), keyby = palabra]

dfoto_palabras_texto = rbind(dfoto_palabras_texto, dfoto_palabras_texto_lanacion)
dfoto_palabras_texto = rbind(dfoto_palabras_texto, dfoto_palabras_texto_infobae)
dfoto_palabras_texto = dfoto_palabras_texto[order(-por_noticia)]

# guardo el dataset entero
fwrite(dfoto_palabras_texto, paste0(dir,'/palabras_texto.csv'))

# guardo el optimizado para subir al blog
dfoto_palabras_texto = formatear(dfoto_palabras_texto)
setcolorder(dfoto_palabras_texto, c('palabra', 'freq','por_noticia', 'diario'))
fwrite(dfoto_palabras_texto[!(diario %in% c('Casa Rosada','Popular'))][order(-freq)][1:200], paste0(dir,'/palabras_texto_blog.csv'))

# recupero la foto de las palabras en los titulos de noticias en las fechas seteadas
dfoto_palabras_titulo = foto_palabras(que = c('terminos','personas'),
                                      donde = 'titulos',
                                      desde = desde,
                                      hasta = hasta,
                                      diarios = diarios_ok,
                                      freq_min = 3,
                                      min_noticias = 5,
                                      top = 10000,
                                      top_por_tendencia = 1000,
                                      por_categoria = F)

dfoto_palabras_titulo_infobae_por_cat = foto_palabras(que = c('terminos','personas'),
                                                      donde = 'titulos',
                                                      desde = desde,
                                                      hasta = hasta,
                                                      diarios = c('infobae'),
                                                      categorias = categorias_infobae,
                                                      freq_min = 3,
                                                      min_noticias = 5,
                                                      top = 10000,
                                                      top_por_tendencia = 1000)
dfoto_palabras_titulo_infobae = dfoto_palabras_titulo_infobae_por_cat[,.(freq = sum(freq), diario = 'infobae', por_noticia = sum(por_noticia)), keyby = palabra]

dfoto_palabras_titulo_lanacion_por_cat = foto_palabras(que = c('terminos','personas'),
                                                       donde = 'titulos',
                                                       desde = desde,
                                                       hasta = hasta,
                                                       diarios = c('lanacion'),
                                                       categorias = categorias_lanacion,
                                                       freq_min = 3,
                                                       min_noticias = 5,
                                                       top = 10000,
                                                       top_por_tendencia = 1000,
                                                       por_categoria = T)
dfoto_palabras_titulo_lanacion = dfoto_palabras_titulo_lanacion_por_cat[,.(freq = sum(freq), diario = 'lanacion', por_noticia = sum(por_noticia)), keyby = palabra]

dfoto_palabras_titulo = rbind(dfoto_palabras_titulo, dfoto_palabras_titulo_lanacion)
dfoto_palabras_titulo = rbind(dfoto_palabras_titulo, dfoto_palabras_titulo_infobae)
dfoto_palabras_titulo = dfoto_palabras_titulo[order(-por_noticia)]

# guardo el dataset entero
fwrite(dfoto_palabras_titulo, paste0(dir,'/palabras_titulo.csv'))

# guardo el optimizado para subir al blog
dfoto_palabras_titulo = formatear(dfoto_palabras_titulo)
setcolorder(dfoto_palabras_titulo, c('palabra', 'freq','por_noticia', 'diario'))
fwrite(dfoto_palabras_titulo[!(diario %in% c('Casa Rosada','Popular'))][order(-freq)][1:200], paste0(dir,'/palabras_titulo_blog.csv'))

# vuelvo a leer los datasets enteros
dfoto_palabras_titulo = fread(paste0(dir,'/palabras_titulo.csv'))
dfoto_palabras_titulo = formatear(dfoto_palabras_titulo, cantidad_decimales = -1)
dfoto_palabras_texto = fread(paste0(dir,'/palabras_texto.csv'))
dfoto_palabras_texto = formatear(dfoto_palabras_texto, cantidad_decimales = -1)

# aca empiezo a desarrollar...
lunapark = c('Luna Park','Luna','Park', 'Luna park')
larreta = c('Larreta','Horacio Rodríguez Larreta','Rodríguez Larreta', 'Horacio Larreta')

a_dibujar = rbind(
  dfoto_palabras_titulo[palabra %in% lunapark, .('valor' = sum(freq), 'grupo' = 'titulo', 'grupo2' = 'Luna Park'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% lunapark, .('valor' = sum(freq), 'grupo' = 'texto', 'grupo2' = 'Luna Park'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% larreta, .('valor' = sum(freq), 'grupo' = 'titulo', 'grupo2' = 'Larreta'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% larreta, .('valor' = sum(freq), 'grupo' = 'texto', 'grupo2' = 'Larreta'), keyby=.('clave' = diario)]
)
gglollipop(a_dibujar[clave != 'Casa Rosada'])

# aca empiezo a desarrollar...
lula = c('Lula','Da Silva', 'da Silva', 'Lula Da Silva', 'Lula da Silva', 'Luiz Inácio Lula da Silva')
moro = c('Moro','Sergio Moro')
lawfare = c('Lawfare','lawfare')

a_dibujar = rbind(
  dfoto_palabras_titulo[palabra %in% lula, .('valor' = sum(freq), 'grupo' = 'titulo', 'grupo2' = 'Lula'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% lula, .('valor' = sum(freq), 'grupo' = 'texto', 'grupo2' = 'Lula'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% moro, .('valor' = sum(freq), 'grupo' = 'titulo', 'grupo2' = 'Moro'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% moro, .('valor' = sum(freq), 'grupo' = 'texto', 'grupo2' = 'Moro'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% lawfare, .('valor' = sum(freq), 'grupo' = 'titulo', 'grupo2' = 'Lawfare'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% lawfare, .('valor' = sum(freq), 'grupo' = 'texto', 'grupo2' = 'Lawfare'), keyby=.('clave' = diario)]
)
gglollipop(a_dibujar[clave != 'Casa Rosada'])
