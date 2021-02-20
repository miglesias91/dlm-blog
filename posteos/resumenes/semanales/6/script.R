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
desde = '20210207'
hasta = '20210213'

# seteo carpeta de trabajo
dir = '~/repos/dlm-blog/posteos/resumenes/semanales/6'

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
dfoto_palabras_texto = fread(paste0(dir,'/palabras_texto.csv'))

# aca empiezo a desarrollar...

# EJEMPLO: gráficar como se trata el tema 'dólar' en los medios, filtrando por algunas palabras, buscando en textos y titulos.
carne = c('carne', 'Carne', 'carnicería', 'Carnicería', 'asado', 'chorizo', 'entraña', 'bife')
grasa = c('grasa', 'Grasa')

a_dibujar = rbind(
  
  dfoto_palabras_titulo[palabra %in% carne, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'carne'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% carne, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'carne'), keyby=.('clave' = diario)],
  
  dfoto_palabras_titulo[palabra %in% grasa, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'grasa'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% grasa, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'grasa'), keyby=.('clave' = diario)]

)
gglollipop(a_dibujar[clave != 'casarosada'])

ypf = c('YPF')
nafta = c('nafta', 'combustible', 'combustibles')
canje = c('canje', 'refinanciación', 'reestructuración')
ajuste = c('ajuste', 'aumento', 'aumentos')

a_dibujar = rbind(
  
  dfoto_palabras_titulo[palabra %in% ypf, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'YPF'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% ypf, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'YPF'), keyby=.('clave' = diario)],
  
  dfoto_palabras_titulo[palabra %in% nafta, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'nafta'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% nafta, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'nafta'), keyby=.('clave' = diario)],
  
  dfoto_palabras_titulo[palabra %in% canje, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'canje'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% canje, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'canje'), keyby=.('clave' = diario)],
  
  dfoto_palabras_titulo[palabra %in% ajuste, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'ajuste'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% ajuste, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'ajuste'), keyby=.('clave' = diario)]
  
)
gglollipop(a_dibujar[clave != 'casarosada'])

ursula = c('Úrsula', 'Úrsula Bahillo')
femicidio = c('femicidio')
asesinato = c('asesinato')
violencia = c('violencia')

dfoto_palabras_textos_por_cat = foto_palabras(que = c('terminos','personas'),
                                      donde = 'textos',
                                      desde = desde,
                                      hasta = hasta,
                                      freq_min = 2,
                                      min_noticias = 1,
                                      top = 10000,
                                      top_por_tendencia = 1000,
                                      por_categoria = T)

dfoto_palabras_titulo_por_cat = foto_palabras(que = c('terminos','personas'),
                                      donde = 'titulos',
                                      desde = desde,
                                      hasta = hasta,
                                      freq_min = 2,
                                      min_noticias = 1,
                                      top = 10000,
                                      top_por_tendencia = 1000,
                                      por_categoria = T)

a_dibujar = rbind(
  dfoto_palabras_titulo[palabra %in% ursula, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Úrsula'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% ursula, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Úrsula'), keyby=.('clave' = diario)],
  
  dfoto_palabras_titulo[palabra %in% femicidio, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'femicidio'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% femicidio, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'femicidio'), keyby=.('clave' = diario)]
)
gglollipop(a_dibujar[clave != 'casarosada'])

dursula_textos = frecuencias(que = 'personas', donde = 'textos', palabras = c('Úrsula'),
                      desde = desde, hasta = hasta)
dursula_bahillo_textos = frecuencias(que = 'personas', donde = 'textos', palabras = c('Úrsula Bahillo'),
                      desde = desde, hasta = hasta)
dfemicidio_textos = frecuencias(que = 'terminos', donde = 'textos', palabras = c('femicidio'),
                      desde = desde, hasta = hasta)

dursula_titulos = frecuencias(que = 'personas', donde = 'titulos', palabras = c('Úrsula'),
                             desde = desde, hasta = hasta)
dursula_bahillo_titulos = frecuencias(que = 'personas', donde = 'titulos', palabras = c('Úrsula Bahillo'),
                                     desde = desde, hasta = hasta)
dfemicidio_titulos = frecuencias(que = 'terminos', donde = 'titulos', palabras = c('femicidio'),
                                desde = desde, hasta = hasta)

# join por diario y cat de ursula y ursula_bahillo, en textos y titulos. sumar menciones.
dursula_textos = dursula_textos[,.('noticias' = sum(noticias), 'ursula' = sum(Úrsula)), keyby =.(diario, categoria)]
dursula_bahillo_textos = dursula_bahillo_textos[,.('noticias' = sum(noticias), 'ursula' = sum(`Úrsula Bahillo`)), keyby =.(diario, categoria)]
dfemicidio_textos = dfemicidio_textos[,.('noticias' = sum(noticias), 'femicidio' = sum(femicidio)), keyby =.(diario, categoria)]

setkeyv(dursula_textos, c('diario', 'categoria'))
setkeyv(dursula_bahillo_textos, c('diario', 'categoria'))
setkeyv(dfemicidio_textos, c('diario', 'categoria'))

dursula_titulos = dursula_titulos[,.('noticias' = sum(noticias), 'ursula' = sum(Úrsula)), keyby =.(diario, categoria)]
dursula_bahillo_titulos = dursula_bahillo_titulos[,.('noticias' = sum(noticias), 'ursula' = sum(`Úrsula Bahillo`)), keyby =.(diario, categoria)]
dfemicidio_titulos = dfemicidio_titulos[,.('noticias' = sum(noticias), 'femicidio' = sum(femicidio)), keyby =.(diario, categoria)]

setkeyv(dursula_titulos, c('diario', 'categoria'))
setkeyv(dursula_bahillo_titulos, c('diario', 'categoria'))
setkeyv(dfemicidio_titulos, c('diario', 'categoria'))

dursula_textos = merge(dursula_textos, dursula_bahillo_textos, all = T)
dursula_textos[is.na(dursula_textos)] = 0
dursula_textos[, 'noticias' := noticias.x + noticias.y]
dursula_textos[, 'ursula' := ursula.x + ursula.y]
dursula_textos[, `:=`(noticias.x = NULL, noticias.y = NULL),]
dursula_textos[, `:=`(ursula.x = NULL, ursula.y = NULL),]
dursula_textos[, noticias := NULL,]

dfemicidio_textos[, noticias := NULL]
dtextos = merge(dursula_textos, dfemicidio_textos, all = T)
dtextos[is.na(dtextos)] = 0

fwrite(dtextos[order(-ursula)], paste0(dir,'/ursula_femicidio_en_textos_por_categorias.csv'))

dursula_titulos = merge(dursula_titulos, dursula_bahillo_titulos, all = T)
dursula_titulos[is.na(dursula_titulos)] = 0
dursula_titulos[, 'noticias' := noticias.x + noticias.y]
dursula_titulos[, 'ursula' := ursula.x + ursula.y]
dursula_titulos[, `:=`(noticias.x = NULL, noticias.y = NULL),]
dursula_titulos[, `:=`(ursula.x = NULL, ursula.y = NULL),]
dursula_titulos[, noticias := NULL,]

dfemicidio_titulos[, noticias := NULL]
dtitulos = merge(dursula_titulos, dfemicidio_titulos, all = T)
dtitulos[is.na(dtitulos)] = 0

fwrite(dtitulos[order(-ursula)], paste0(dir,'/ursula_femicidio_en_titulos_por_categorias.csv'))

dfinal = merge(dtitulos, dtextos, all = T)
dfinal[is.na(dfinal)] = 0

setnames(dfinal, c('ursula.x', 'femicidio.x', 'ursula.y', 'femicidio.y'), c('ursula_titulos', 'femicidio_titulos', 'ursula_textos', 'femicidio_textos'))
setcolorder(dfinal, c('diario','categoria','ursula_textos', 'femicidio_textos', 'ursula_titulos', 'femicidio_titulos'))

fwrite(dfinal[order(-ursula_textos)], paste0(dir,'/ursula_femicidio_por_categorias.csv'))
