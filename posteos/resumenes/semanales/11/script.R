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
desde = '20210314'
hasta = '20210320'

# seteo carpeta de trabajo
dir = '~/repos/dlm/blog/posteos/resumenes/semanales/11'

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
dfoto_palabras_texto = formatear(dfoto_palabras_texto, cantidad_decimales = 0)
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
dfoto_palabras_titulo = formatear(dfoto_palabras_titulo, cantidad_decimales = 0)
setcolorder(dfoto_palabras_titulo, c('palabra', 'freq','por_noticia', 'diario'))
fwrite(dfoto_palabras_titulo[!(diario %in% c('Casa Rosada','Popular'))][order(-freq)][1:200], paste0(dir,'/palabras_titulo_blog.csv'))

# vuelvo a leer los datasets enteros
dfoto_palabras_titulo = fread(paste0(dir,'/palabras_titulo.csv'))
dfoto_palabras_titulo = formatear(dfoto_palabras_titulo, cantidad_decimales = -1)
dfoto_palabras_texto = fread(paste0(dir,'/palabras_texto.csv'))
dfoto_palabras_texto = formatear(dfoto_palabras_texto, cantidad_decimales = -1)

# aca empiezo a desarrollar...
soria = c('Soria','Martín Soria','Martín Ignacio Soria', 'Ministro de Justicia', 'ministro de Justicia')
kirchnerismo = c('kirchnerismo', 'CFK','Kirchner', 'Cristina', 'Cristina Kirchner', 'kirchnerista', 'Cristina Fernández de Kirchner')
lawfare = c('Lawfare','lawfare')

a_dibujar = rbind(
  dfoto_palabras_titulo[palabra %in% soria, .('valor' = sum(freq), 'grupo' = 'titulo', 'grupo2' = 'Martín Soria'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% soria, .('valor' = sum(freq), 'grupo' = 'texto', 'grupo2' = 'Martín Soria'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% lawfare, .('valor' = sum(freq), 'grupo' = 'titulo', 'grupo2' = 'Lawfare'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% lawfare, .('valor' = sum(freq), 'grupo' = 'texto', 'grupo2' = 'Lawfare'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% kirchnerismo, .('valor' = sum(freq), 'grupo' = 'titulo', 'grupo2' = 'kirchnerismo'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% kirchnerismo, .('valor' = sum(freq), 'grupo' = 'texto', 'grupo2' = 'kirchnerismo'), keyby=.('clave' = diario)]
)
gglollipop(a_dibujar[clave != 'Casa Rosada'])

# aca empiezo a desarrollar...
maia = c('Maia','Maia Beloso', 'Beloso')
gcba = c('GCBA','Gobierno de la Ciudad', 'Gobierno de la Ciudad de Buenos Aires', 'Ciudad de Buenos Aires')
larreta = c('Larreta','Horacio Larreta', 'Horacio Rodríguez Larreta', 'Horacio Rodríguez')

a_dibujar = rbind(
  dfoto_palabras_titulo[palabra %in% maia, .('valor' = sum(freq), 'grupo' = 'titulo', 'grupo2' = 'Maia'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% maia, .('valor' = sum(freq), 'grupo' = 'texto', 'grupo2' = 'Maia'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% gcba, .('valor' = sum(freq), 'grupo' = 'titulo', 'grupo2' = 'GCBA'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% gcba, .('valor' = sum(freq), 'grupo' = 'texto', 'grupo2' = 'GCBA'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% larreta, .('valor' = sum(freq), 'grupo' = 'titulo', 'grupo2' = 'Larreta'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% larreta, .('valor' = sum(freq), 'grupo' = 'texto', 'grupo2' = 'Larreta'), keyby=.('clave' = diario)]
)
gglollipop(a_dibujar[clave != 'Casa Rosada'])

dmaia_titulos = frecuencias(que = 'personas', donde = 'titulos', palabras = c('Maia'),
                              desde = desde, hasta = hasta)
dmaia_beloso_titulos = frecuencias(que = 'personas', donde = 'titulos', palabras = c('Maia Beloso'),
                                      desde = desde, hasta = hasta)

dmaia_textos = frecuencias(que = 'personas', donde = 'textos', palabras = c('Maia'),
                            desde = desde, hasta = hasta)
dmaia_beloso_textos = frecuencias(que = 'personas', donde = 'textos', palabras = c('Maia Beloso'),
                                   desde = desde, hasta = hasta)

# join por diario y cat de ursula y ursula_bahillo, en textos y titulos. sumar menciones.
dmaia_textos = dmaia_textos[,.('noticias' = sum(noticias), 'maia' = sum(Maia)), keyby =.(diario, categoria)]
# dmaia_beloso_textos = dmaia_beloso_textos[,.('noticias' = sum(noticias), 'maia' = sum(`Maia Beloso`)), keyby =.(diario, categoria)]

setkeyv(dmaia_textos, c('diario', 'categoria'))
# setkeyv(dmaia_beloso_textos, c('diario', 'categoria'))

dmaia_titulos = dmaia_titulos[,.('noticias' = sum(noticias), 'maia' = sum(Maia)), keyby =.(diario, categoria)]
dmaia_beloso_titulos = dmaia_beloso_titulos[,.('noticias' = sum(noticias), 'maia' = sum(`Maia Beloso`)), keyby =.(diario, categoria)]

setkeyv(dmaia_titulos, c('diario', 'categoria'))
setkeyv(dmaia_beloso_titulos, c('diario', 'categoria'))

# dmaia_textos = merge(dmaia_textos, dmaia_beloso_textos, all = T)
# dmaia_textos[is.na(maia_textos)] = 0
# dmaia_textos[, 'noticias' := noticias.x + noticias.y]
# dmaia_textos[, 'maia' := maia.x + maia.y]
# dmaia_textos[, `:=`(noticias.x = NULL, noticias.y = NULL),]
# dmaia_textos[, `:=`(maia.x = NULL, maia.y = NULL),]
# dmaia_textos[, noticias := NULL,]
# dmaia_textos[is.na(dmaia_textos)] = 0

fwrite(dmaia_textos[order(-maia)], paste0(dir,'/maia_en_textos_por_categorias.csv'))

dmaia_titulos = merge(dmaia_titulos, dmaia_beloso_titulos, all = T)
dmaia_titulos[is.na(dmaia_titulos)] = 0
dmaia_titulos[, 'noticias' := noticias.x + noticias.y]
dmaia_titulos[, 'maia' := maia.x + maia.y]
dmaia_titulos[, `:=`(noticias.x = NULL, noticias.y = NULL),]
dmaia_titulos[, `:=`(maia.x = NULL, maia.y = NULL),]
dmaia_titulos[, noticias := NULL,]
dmaia_titulos[is.na(dmaia_titulos)] = 0

fwrite(dmaia_titulos[order(-maia)], paste0(dir,'/maia_en_titulos_por_categorias.csv'))

dfinal = merge(dmaia_titulos, dmaia_textos, all = T)
dfinal[is.na(dfinal)] = 0

setnames(dfinal, c('maia.x', 'maia.y'), c('maia_titulos', 'maia_textos'))
setcolorder(dfinal, c('diario','categoria','maia_textos', 'maia_titulos'))

dfinal = formatear(dfinal, cantidad_decimales = 0)

fwrite(dfinal[order(-maia_textos)], paste0(dir,'/maia_por_categorias.csv'))
