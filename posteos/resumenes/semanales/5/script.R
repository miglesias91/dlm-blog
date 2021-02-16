library(dlmr)
library(data.table)
library(jsonlite)

login = fromJSON('~/keys/dlm-login.json')

usuario = login$usuario
password = login$password
servidor = login$servidor
conectar(usuario = usuario, password = password, servidor = servidor)

desde = '20210201'
hasta = '20210207'

dfoto = foto(desde = desde, hasta = hasta)
dfoto$por_dia = sprintf('%.2f',dfoto$por_dia)
fwrite(dfoto, '~/repos/dlm-blog/posteos/resumenes/semanales/5/medios_categoria.csv')

dfoto_palabras_texto = foto_palabras(que = c('terminos','personas'),
                               donde = 'textos',
                               desde = desde,
                               hasta = hasta,
                               freq_min = 3,
                               min_noticias = 5,
                               top = 10000,
                               top_por_tendencia = 1000,
                               por_categoria = F)
fwrite(dfoto_palabras_texto, '~/repos/dlm-blog/posteos/resumenes/semanales/5/palabras_texto.csv')

dfoto_palabras_texto$por_noticia = sprintf('%.2f',dfoto_palabras_texto$por_noticia)
setcolorder(dfoto_palabras_texto, c('palabra', 'freq','por_noticia', 'diario'))
fwrite(dfoto_palabras_texto[diario != 'casarosada'][1:200], '~/repos/dlm-blog/posteos/resumenes/semanales/5/palabras_texto_light.csv')

dfoto_palabras_titulo = foto_palabras(que = c('terminos','personas'),
                                     donde = 'titulos',
                                     desde = desde,
                                     hasta = hasta,
                                     freq_min = 2,
                                     min_noticias = 5,
                                     top = 10000,
                                     top_por_tendencia = 1000,
                                     por_categoria = F)
fwrite(dfoto_palabras_titulo, '~/repos/dlm-blog/posteos/resumenes/semanales/5/palabras_titulo.csv')

dfoto_palabras_titulo$por_noticia = sprintf('%.2f',dfoto_palabras_titulo$por_noticia)
setcolorder(dfoto_palabras_titulo, c('palabra', 'freq','por_noticia', 'diario'))
fwrite(dfoto_palabras_titulo[diario != 'casarosada'][1:200], '~/repos/dlm-blog/posteos/resumenes/semanales/5/palabras_titulo_light.csv')

dfoto_palabras_titulo = fread('~/repos/dlm-blog/posteos/resumenes/semanales/5/palabras_titulo.csv')
dfoto_palabras_texto = fread('~/repos/dlm-blog/posteos/resumenes/semanales/5/palabras_texto.csv')

ecuador = c('Ecuador')
elecciones = c('Elecciones', 'elecciones', 'elección', 'Elección')
correa = c('Correa', 'Rafael Correa')
arauz = c('Arauz','Andrés Arauz')
perez = c('Yaku', 'Yaku Pérez')
lasso = c('Lasso', 'Guillermo Lasso')

venezuela = c('Venezuela', 'Maduro', 'Nicolás Maduro')
eeuu = c('Estados Unidos', 'EEUU', 'USA', 'EE.UU.', 'U.S.A.')

dfoto_palabras_texto[diario == 'infobae' && categoria == 'internacionales']

a_dibujar = rbind(
  dfoto_palabras_titulo[palabra %in% ecuador, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Ecuador'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% ecuador, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Ecuador'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% correa, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Correa'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% correa, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Correa'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% arauz, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Arauz'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% arauz, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Arauz'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% perez, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Yaku Pérez'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% perez, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Yaku Pérez'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% lasso, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Lasso'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% lasso, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Lasso'), keyby=.('clave' = diario)]
)
gglollipop(a_dibujar[clave != 'casarosada'])

infobae_internacional = tendencias(que = c('terminos', 'personas'),
                                   donde = 'textos',
                                   desde = desde,
                                   hasta = hasta,
                                   diarios = c('infobae'),
                                   categorias = c('internacional'),
                                   top = 1000)
infobae_internacional[1:100]

acunia = c('Acuña', 'Soledad Acuña')
escuelas = c('Clases', 'clases', 'aulas', 'escuelas', 'aula', 'escuela')
trotta = c('Trotta', 'Nicolás Trotta')
mineducacion = c('Ministerio de Educación','Educación')

a_dibujar = rbind(
  dfoto_palabras_titulo[palabra %in% acunia, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Acuña'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% acunia, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Acuña'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% escuelas, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Escuelas'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% escuelas, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Escuelas'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% trotta, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Trotta'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% trotta, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Trotta'), keyby=.('clave' = diario)],
  dfoto_palabras_titulo[palabra %in% mineducacion, .('valor' = sum(por_noticia), 'grupo' = 'titulo', 'grupo2' = 'Ministerio Educación'), keyby=.('clave' = diario)],
  dfoto_palabras_texto[palabra %in% mineducacion, .('valor' = sum(por_noticia), 'grupo' = 'texto', 'grupo2' = 'Ministerio Educación'), keyby=.('clave' = diario)]
)
gglollipop(a_dibujar[clave != 'casarosada'])

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
