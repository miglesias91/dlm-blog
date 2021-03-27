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
desde = '20210324'
hasta = '20210324'

# seteo carpeta de trabajo
dir = '~/repos/dlm/blog/posteos/resumenes/semanales/12'

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

dMemoria_titulos = frecuencias(que = 'personas', donde = 'titulos', palabras = c('Memoria'),
                               desde = desde, hasta = hasta)
dMemoria_textos = frecuencias(que = 'personas', donde = 'textos', palabras = c('Memoria'),
                                              desde = desde, hasta = hasta)

dmemoria_titulos = frecuencias(que = 'terminos', donde = 'titulos', palabras = c('memoria'),
                                desde = desde, hasta = hasta)
dmemoria_textos = frecuencias(que = 'terminos', donde = 'textos', palabras = c('memoria'),
                               desde = desde, hasta = hasta)

# join por diario y cat de ursula y ursula_bahillo, en textos y titulos. sumar menciones.
dmemoria_textos = dmemoria_textos[,.('noticias' = sum(noticias), 'memoria' = sum(memoria)), keyby =.(diario)]
dmemoria_titulos = dmemoria_titulos[,.('noticias' = sum(noticias), 'memoria' = sum(memoria)), keyby =.(diario)]
dMemoria_textos = dMemoria_textos[,.('noticias' = sum(noticias), 'Memoria' = sum(Memoria)), keyby =.(diario)]
dMemoria_titulos = dMemoria_titulos[,.('noticias' = sum(noticias), 'Memoria' = sum(Memoria)), keyby =.(diario)]
# dmaia_beloso_textos = dmaia_beloso_textos[,.('noticias' = sum(noticias), 'maia' = sum(`Maia Beloso`)), keyby =.(diario, categoria)]

setkeyv(dmemoria_textos, c('diario'))
setkeyv(dmemoria_titulos, c('diario'))
setkeyv(dMemoria_textos, c('diario'))
setkeyv(dMemoria_titulos, c('diario'))

dmem_textos = merge(dmemoria_textos, dMemoria_textos, all = T)
dmem_textos[is.na(dmem_textos)] = 0
dmem_textos[, 'Memoria' := memoria + Memoria]
dmem_textos[, `:=`(memoria = NULL, noticias.x = NULL, noticias.y = NULL),]
dmem_textos[is.na(dmem_textos)] = 0

fwrite(dmem_textos[order(-Memoria)], paste0(dir,'/memoria_en_textos.csv'))

dmem_titulos = merge(dmemoria_titulos, dMemoria_titulos, all = T)
dmem_titulos[is.na(dmem_titulos)] = 0
dmem_titulos[, 'Memoria' := memoria + Memoria]
dmem_titulos[, `:=`(memoria = NULL, noticias.x = NULL, noticias.y = NULL),]
dmem_titulos[is.na(dmem_titulos)] = 0

fwrite(dmem_titulos[order(-Memoria)], paste0(dir,'/memoria_en_titulos.csv'))

dmem = merge(dmem_titulos, dmem_textos, all = T)
dmem[is.na(dmem)] = 0

setnames(dmem, c('Memoria.x', 'Memoria.y'), c('Memoria_titulos', 'Memoria_textos'))
setcolorder(dmem, c('diario','Memoria_textos', 'Memoria_titulos'))

dmem = formatear(dmem, cantidad_decimales = 0)

fwrite(dmem[order(-Memoria_textos)], paste0(dir,'/memoria.csv'))

a_dibujar = rbind(
  dmem[, .('valor' = Memoria_titulos, 'grupo' = 'titulo', 'grupo2' = 'Memoria'), keyby=.('clave' = diario)],
  dmem[, .('valor' = Memoria_textos, 'grupo' = 'texto', 'grupo2' = 'Memoria'), keyby=.('clave' = diario)]
)
gglollipop(a_dibujar[clave != 'Casa Rosada'], colores = c('#000000'))

eldestape = contar(desde = desde, hasta = hasta, diarios = c('eldestape'))
