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
desde = '20210228'
hasta = '20210306'

# seteo carpeta de trabajo
dir = '~/repos/dlm-blog/posteos/resumenes/semanales/9'

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
fwrite(dfoto_palabras_texto[diario != 'Casa Rosada'][1:200], paste0(dir,'/palabras_texto_blog.csv'))

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
fwrite(dfoto_palabras_titulo[diario != 'Casa Rosada'][1:200], paste0(dir,'/palabras_titulo_blog.csv'))

# vuelvo a leer los datasets enteros
dfoto_palabras_titulo = fread(paste0(dir,'/palabras_titulo.csv'))
dfoto_palabras_titulo = formatear(dfoto_palabras_titulo, cantidad_decimales = -1)
dfoto_palabras_texto = fread(paste0(dir,'/palabras_texto.csv'))
dfoto_palabras_texto = formatear(dfoto_palabras_texto, cantidad_decimales = -1)

# aca empiezo a desarrollar...
resto = c('Catamarca', 'Chaco', 'Chubut', 'Córdoba', 'Corrientes', 'Entre Ríos', 'Jujuy', 'La Pampa', 'La Rioja', 'Mendoza', 'Misiones', 'Neuquén', 'Río Negro', 'Salta', 'San Juan', 'San Luis', 'Santa Cruz', 'Santa Fe', 'Santiago del Estero', 'Tierra del Fuego', 'Tucumán')
insfran = c('Insfrán', 'Gildo', 'Gildo Insfrán')
formosa = c('Formosa')

a_dibujar = rbind(
  dfoto_palabras_titulo[palabra %in% formosa, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Formosa'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% formosa, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Formosa'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% insfran, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Insfrán'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% insfran, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Insfrán'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% resto, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Otras provincias'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% resto, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Otras provincias'), keyby=.('clave' = diario)]
)
gglollipop(a_dibujar[clave != 'Casa Rosada'])

cfk = c('CFK', 'Cristina Kirchner', 'Cristina', 'Cristina Fernández de Kirchner', 'Cristina Fernández')
caputo = c('Caputo', 'Nicolás Caputo', 'Nicky Caputo')
pratgay = c('Alfonso Prat Gay', 'Prat Gay', 'Alfonso Prat')
macri = c('Macri', 'Mauricio Macri')
petrone = c('Petrone', 'Daniel Petrone')
barroetaveña = c('Barroetaveña', 'Diego Barroetaveña')
dolarfuturo = c('Dólar futuro', 'futuro')

a_dibujar = rbind(
  dfoto_palabras_titulo[palabra %in% cfk, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'CFK'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% cfk, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'CFK'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% caputo, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Caputo'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% caputo, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Caputo'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% pratgay, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Prat Gay'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% pratgay, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Prat Gay'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% macri, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Macri'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% macri, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Macri'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% dolarfuturo, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Dólar Futuro'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% dolarfuturo, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Dólar Futuro'), keyby=.('clave' = diario)]
)
gglollipop(a_dibujar[clave != 'Casa Rosada'])

hornos = c('Hornos', 'Juez Hornos', 'Gustavo Hornos', 'Juez Gustavo Hornos')

a_dibujar = rbind(
  dfoto_palabras_titulo[palabra %in% hornos, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Juez Hornos'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% hornos, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Juez Hornos'), keyby=.('clave' = diario)]
)
gglollipop(a_dibujar[clave != 'Casa Rosada'])

represion = c('represión')

a_dibujar = rbind(
  dfoto_palabras_texto_202009[palabra %in% represion, .('valor' = sum(por_noticia), 'grupo' = 'Represión CABA enfermeros (Sep. 2020)', 'grupo2' = 'represión'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% represion, .('valor' = sum(por_noticia), 'grupo' = 'Represión Formosa movilización (Marzo 2021)', 'grupo2' = 'represión'), keyby=.('clave' = diario)]
)
gglollipop(a_dibujar[clave != 'Casa Rosada'])

desde = '20200920'
hasta = '20200926'

dfoto_palabras_texto_202009 = foto_palabras(que = c('terminos','personas'),
                                     donde = 'textos',
                                     desde = desde,
                                     hasta = hasta,
                                     diarios = diarios_ok,
                                     freq_min = 3,
                                     min_noticias = 5,
                                     top = 10000,
                                     top_por_tendencia = 1000,
                                     por_categoria = F)

dfoto_palabras_texto_infobae_por_cat_202009 = foto_palabras(que = c('terminos','personas'),
                                                     donde = 'textos',
                                                     desde = desde,
                                                     hasta = hasta,
                                                     diarios = c('infobae'),
                                                     categorias = categorias_infobae,
                                                     freq_min = 3,
                                                     min_noticias = 5,
                                                     top = 10000,
                                                     top_por_tendencia = 1000)
dfoto_palabras_texto_infobae_202009 = dfoto_palabras_texto_infobae_por_cat_202009[,.(freq = sum(freq), diario = 'infobae', por_noticia = sum(por_noticia)), keyby = palabra]

dfoto_palabras_texto_lanacion_por_cat_202009 = foto_palabras(que = c('terminos','personas'),
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
dfoto_palabras_texto_lanacion_202009 = dfoto_palabras_texto_lanacion_por_cat_202009[,.(freq = sum(freq), diario = 'lanacion', por_noticia = sum(por_noticia)), keyby = palabra]

dfoto_palabras_texto_202009 = rbind(dfoto_palabras_texto_202009, dfoto_palabras_texto_lanacion_202009)
dfoto_palabras_texto_202009 = rbind(dfoto_palabras_texto_202009, dfoto_palabras_texto_infobae_202009)
dfoto_palabras_texto_202009 = dfoto_palabras_texto_202009[order(-por_noticia)]

incidentes= c('incidentes', 'Incidentes', 'incidente', 'Incidente')

dfoto_palabras_texto_202009 = formatear(dfoto_palabras_texto_202009, cantidad_decimales = -1)

a_dibujar = rbind(
  dfoto_palabras_texto_202009[palabra %in% represion, .('valor' = sum(por_noticia), 'grupo' = 'CABA enfermeros (Sep. 2020)', 'grupo2' = 'represión'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% represion, .('valor' = sum(por_noticia), 'grupo' = 'Formosa marcha (Marzo 2021)', 'grupo2' = 'represión'), keyby=.('clave' = diario)],
  dfoto_palabras_texto_202009[palabra %in% incidentes, .('valor' = sum(por_noticia), 'grupo' = 'CABA enfermeros (Sep. 2020)', 'grupo2' = 'incidentes'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% incidentes, .('valor' = sum(por_noticia), 'grupo' = 'Formosa marcha (Marzo 2021)', 'grupo2' = 'incidentes'), keyby=.('clave' = diario)]
)
gglollipop(a_dibujar[clave != 'Casa Rosada'])


papa = c('Francisco', 'Papa')
irak = c('Irak')

a_dibujar = rbind(
  dfoto_palabras_titulo[palabra %in% papa, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Papa'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% papa, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Papa'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% irak, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Irak'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% irak, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Irak'), keyby=.('clave' = diario)]
)
gglollipop(a_dibujar[clave != 'Casa Rosada'])