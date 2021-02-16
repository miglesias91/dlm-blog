library(dlmr)
library(data.table)
library(jsonlite)

# setear la path donde esté 'dlm-login.json', que tiene que ser:
# {
#   "usuario" : "mi_usuario"
#   "password" : "mi_password"
#   "servidor" : "ip_del_servidor"
# }
login = fromJSON('./dlm-login.json')

usuario = login$usuario
password = login$password
servidor = login$servidor
conectar(usuario = usuario, password = password, servidor = servidor)

# setear fechas 'desde' y 'hasta', en formato aaaammdd
desde = ''
hasta = ''

# recupero la foto de los medios y categorias en las fechas seteadas
dfoto = foto(desde = desde, hasta = hasta)
dfoto$por_dia = sprintf('%.2f',dfoto$por_dia) # guardo con 2 decimales
fwrite(dfoto, './medios_categoria.csv')

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
fwrite(dfoto_palabras_texto, './palabras_texto.csv')

# guardo el optimizado para subir al blog
dfoto_palabras_texto$por_noticia = sprintf('%.2f',dfoto_palabras_texto$por_noticia)
setcolorder(dfoto_palabras_texto, c('palabra', 'freq','por_noticia', 'diario'))
fwrite(dfoto_palabras_texto[diario != 'casarosada'][1:200], './palabras_texto_blog.csv')

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
fwrite(dfoto_palabras_titulo, './palabras_titulo.csv')

# guardo el optimizado para subir al blog
dfoto_palabras_titulo$por_noticia = sprintf('%.2f',dfoto_palabras_titulo$por_noticia)
setcolorder(dfoto_palabras_titulo, c('palabra', 'freq','por_noticia', 'diario'))
fwrite(dfoto_palabras_titulo[diario != 'casarosada'][1:200], './palabras_titulo_blog.csv')

# vuelvo a leer los datasets enteros
dfoto_palabras_titulo = fread('./palabras_titulo.csv')
dfoto_palabras_texto = fread('./palabras_texto.csv')

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
