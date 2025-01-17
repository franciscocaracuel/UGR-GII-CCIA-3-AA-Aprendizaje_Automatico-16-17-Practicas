###############################################################################
## Francisco Javier Caracuel Beltrán
##
## Curso 2016/2017 - Aprendizaje Automático - CCIA - ETSIIT
##
## Archivo .r asociado a la entrega 3.
##
###############################################################################

# Se establece el directorio de trabajo
setwd("/mnt/A0DADA47DADA18FC/Fran/Universidad/3º/2 Cuatrimestre/AA/Mis prácticas/Práctica 3/datos")

# Pintar 2 gráficas a la vez
#par(mfrow=c(1,2))

# Pintar 1 gráfica a la vez
par(mfrow=c(1,1))

# Se establece la semilla para la generación de datos aleatorios
set.seed(1822)

# Decimales en el porcentaje de los errores
perDec = 3

###############################################################################
# Ajuste de Modelos Lineales
###############################################################################

###############################################################################
# Problema de clasificación: South African Heart Disease
###################

###############################################################################
# 1. Comprender al problema a resolver.
#
# El problema a resolver consiste en predecir la posibilidad de padecer una 
# enfermedad cardíaca de alto riesgo siendo varón en la provincia Western Cape,
# en Sudáfrica.
# Para poder predecir esta enfermedad se tiene una muestra de datos de 463 
# varones.
# Hay muestras que se han recogido antes del tratamiento y otras que han sido
# recogidas después.
# 
# Las distintas características que se obtienen en cada muestra son:
# - sbp: (presión arterial sistólica).
# - tobacco: tabaco acumulado (kg).
# - ldl: (lipoproteína de baja densidad).
# - adiposity: grasa.
# - famhist: antecendentes familiares de riesgo cardiovascular 
#            (presente/ausente).
# - typea: (type-A behavior)
# - obesity: IMC (Índice de masa corporal).
# - alcohol: consumo actual de alcohol.
# - age: edad del varón de la muestra.
# - chd: respuesta obtenida (0: no presente, 1: presente).
# 

###############################################################################
# 2. Los conjuntos de training, validación y test usados en su caso.
#
# Para realizar la predicción solo se cuenta con un conjunto de datos con 463
# muestras.
# No se tienen conjuntos de datos de train, validación o test, por
# lo que se va a separar toda la muestra de datos en dos conjuntos. El
# conjunto de train contendrá el 70% de las muestras y el conjunto de test
# contendrá el 30%.
# Antes de hacer la separación de los datos en los dos conjuntos se va a 
# realizar su preprocesado.
#

###############################################################################
# 3. Preprocesado los datos: Falta de datos, categorización, normalización, 
# reducción de dimensionalidad, etc.
#
# Se pretende controlar la cantidad de datos que se tienen, el tipo de muestra
# (train o test), comprobar si existen datos cualitativos.
# Cuando se ajuste el modelo final se determinará la reducción de 
# dimensionalidad y demás procesamiento necesario.
# En este caso, no se normalizarán las características porque no se va a
# trabajar por similaridad, como en K-NN.
#

# Se pueden leer los datos desde la url
#read.table("https://www-stat.stanford.edu/~tibs/ElemStatLearn/datasets/SAheart.data",
#sep=",",head=T,row.names=1)

# En este caso, se han descargado los datos a un fichero del directorio de 
# trabajo. 
# Se indica que la separación entre datos de cada muestra viene identificada 
# por "," y que el fichero de datos tiene cabecera.
chd = read.table("SAHD.data", sep=",", head=T, row.names=1)

# Hay que comprobar si algún valor del conjunto de datos es de carácter 
# cualitativo, por lo que se muestran las primeras muestras con la función
# "head".
head(chd)

# De los datos obtenidos, la única columna que tiene etiquetas es la columna
# "famhist".
# Hay que eliminar las etiquetas y sustituirlas por números. Se pondrá 1 a
# los valores "Present" y 2 a los valores "Absent".
chd = within(chd, famhist <- as.numeric(factor(famhist, labels = c(1, 2))))

# Se comprueba que se han cambiado los valores de la columna "famhist".
head(chd)

# Se comprueba si existe algún valor perdido. Para eso se utiliza la función
# which() y la función is.na(), que nos indican, respectivamente, la posición 
# en la que ocurre algún hecho y si alguna posición no es correcta.
which(is.na(chd))

# En este caso no se obtiene ninguna respuesta, por lo que no se encuentran
# valores perdidos en este conjunto de datos.

# Se simplifica el prefijo chd en las operaciones para evitar tener que
# escribir continuamente el conjunto de datos.
attach(chd)

# En este punto sí se pueden separar todos los datos en train y test.

# Se guarda el número de columnas para utilizarlo al sacar los datos y así
# no tener que repetir la misma operación en varias ocasiones.
numAttrChd = ncol(chd)

# Se va a utilizar como train una muestra del 70% de los datos del conjunto,
# por lo que se generan númeroDeMuestras*0.7 posiciones aleatoriamente.
posTrain = sample(nrow(chd), round(nrow(chd)*0.7))

# Se guardan los datos que forman parte del train.
#chd.train = chd[posTrain, c(1:numAttrChd-1)]
chd.train = chd[posTrain, c(1:numAttrChd)]

# Se crea un vector con las etiquetas de los datos de entrenamiento
#chd.train.label = chd[posTrain, c(numAttrChd-1, numAttrChd)]

# Se guardan los datos que forman parte del test. Serán todos aquellos que no
# sean del train.
#chd.test = chd[-posTrain, c(1:numAttrChd-1)]
chd.test = chd[-posTrain, c(1:numAttrChd)]

# Se crea un vector con las etiquetas de los datos de test
#chd.test.label = chd[-posTrain, c(numAttrChd-1, numAttrChd)]

# Se muestra un gráfico con la relación de los atributos entre ellos.
pairs(chd[1:9], pch=21, bg=c(4, 6)[factor(chd$chd)])

###############################################################################
# 4. Selección de clases de funciones a usar.
#
# Para predecidr datos se puede utilizar:
# - Regresión Lineal Simple: con la función lm().
# - Regresión Logística: con la función glm(). Cuenta a su vez con una serie
# de familias a utilizar. En esta práctica se utilizará binomial, gaussian y
# poisson.
# - Predicción: predict() permitirá predecir el resultado ajustado por la
# regresión realizada.
# - Disminución de atributos: se usa la función step() que devuelve un set de
# atributos con los que se puede representar la mayor parte del conjunto de
# datos.
# - Regularización: para realizar la regularización se utilizará la función
# potencial, exponencial y logarítmica.
#

###############################################################################
# 5. Discutir la necesidad de regularización y en su caso la función usada.
#
# Se debe comprobar primero qué tipo de muestras se tienen y en base a cómo
# respondan se realizará la regularización.
# Si los resultados que se obtienen no se pueden clasificar linealmente, se
# procederá a aplicar transformaciones para separar todo el conjunto como
# interese y comprobar si de este modo sí se encuentran las muestras 
# distintas diferenciadas entre ellas.
# Las transformaciones habituales suelen ser x^n, x^-n, log(x) y log(x+n).
#

###############################################################################
# 6. Definir los modelos a usar y estimar sus parámetros e hyperparámetros.
#
# El modelo a utilizar es regresión logística. Se podría utilizar regresión
# lineal, SVM, LDA, QDA, u otras técnicas no lineales más avanzadas, pero 
# escapan del interés de esta práctica, por lo que se va a realizar regresión
# logística.
# Los parámetros a utilizar se comprobarán durante la resolución del problema.
#

###############################################################################
# 7. Selección y ajuste modelo final.
#

# Se hace regresión logística de la muestra de entrenamiento teniendo en 
# cuenta todos los atributos. La intención es comprobar cuáles de ellos no 
# representan la mayor parte de la muestra y así tener una solución con el 
# menor número de atributos posibles, lo que hará que sea de mayor calidad.
chd.glm = glm(chd ~ ., family = gaussian, data = chd.train)

# Para obtener el menor número de atributos posibles se podría haber utilizado
# regsubsets(), step() o PCA con el paquete caret.
# En este caso se ha utilizado la función step() que, directamente devuelve
# los atributos mas representativos del conjunto de muestras. Además, indica
# qué peso tiene cada uno de ellos, por lo que se puede hacer una valoración
# más exhaustiva del resultado.
# Se ha inspeccionado la función step() para comprobar su funcionamiento y
# se puede determinar que el pseudocódigo relacionado es:
#
# initial_setting
# for i in steps
# start
#   set_type_scan
#   get_attributes
#   evaluate_attributes
#   result += list_evaluation
# end
# return result
#
# El algoritmo de la función step() comienza ajustando los parámetros iniciales
# por defecto que tiene definidos o los que el usuario quiera utilizar.
# De manera iterativa, en una serie de pasos previamente establecidos, obtiene
# los atributos con los que va a realizar la prueba. En cada iteración 
# selecciona una serie de ellos y evalúa el resultado de la regresión logística
# (en este caso). Finalmente, para cada evaluación realizada, devuelve su 
# resultado, mostrando la desviación de cada atributo y el criterio de
# información de Akaike, así como los atributos con los que se han obtenido
# estos resultados.
# 

# Para obtener más información de la que se obtiene solo con la función step(),
# se utiliza summary() para ver un informe más completo.
summary(step(chd.glm))

# Los atributos que se deben tener en cuenta según los resultados obtenidos son:
# - sbp.
# - tobacco.
# - ldl.
# - famhist.
# - typea.
# - obesity.
# - age.
#
# Si se analizan los coeficientes que han obtenido cada uno de ellos, se puede
# no tener en cuenta el atributo "sbp", "typea" y "age". Se realizarán dos
# pruebas, con estos atributos y sin ellos. Si se obtiene el mismo resultado
# interesa utilizar el menor número de atributos posibles.

# Prueba 1

# Los coeficientes que se deben tener en cuenta son: sbp, tobacco, ldl, 
# famhist, typea, obesity y age. 

# Se van a utilizar tres familias de funciones para realizar la regresión
# logística: binomial, gaussian y poisson. Con cada una de ellas se comprobará 
# su resultado y se elegirá la mejor.

# Se hace de nuevo regresión lineal con estos coeficientes.

# binomial
chd.glm = glm(chd ~ sbp + tobacco + ldl + famhist + typea + obesity + age,
              family = binomial, 
              data = chd.train)

# Se predicen los resultados de entrenamiento con la regresión logística
predictTrain = predict(chd.glm, chd.train)

# Se calcula la media de error de los datos de entrenamiento
meanTrain.glm = mean((predictTrain > 0.5) != (chd.train[, 'chd'] > 0.5))

# Se predicen los resultados de test con la regresión logística
predictTest = predict(chd.glm, chd.test)

# Se calcula la media de error de los datos de test
meanTest.glm = mean((predictTest > 0.5) != (chd.test[, 'chd'] > 0.5))

print(paste("Ein calculado con Regresión Logística: ", 
            round(meanTrain.glm*100, digits = perDec), "%"))
print(paste("Etest calculado con Regresión Logística: ", 
            round(meanTest.glm*100, digits = perDec), "%"))

# gaussian
chd.glm = glm(chd ~ sbp + tobacco + ldl + famhist + typea + obesity + age,
              family = gaussian, 
              data = chd.train)

# Se predicen los resultados de entrenamiento con la regresión logística
predictTrain = predict(chd.glm, chd.train)

# Se calcula la media de error de los datos de entrenamiento
meanTrain.glm = mean((predictTrain > 0.5) != (chd.train[, 'chd'] > 0.5))

# Se predicen los resultados de test con la regresión logística
predictTest = predict(chd.glm, chd.test)

# Se calcula la media de error de los datos de test
meanTest.glm = mean((predictTest > 0.5) != (chd.test[, 'chd'] > 0.5))

print(paste("Ein calculado con Regresión Logística: ", 
            round(meanTrain.glm*100, digits = perDec), "%"))
print(paste("Etest calculado con Regresión Logística: ", 
            round(meanTest.glm*100, digits = perDec), "%"))

# poisson
chd.glm = glm(chd ~ sbp + tobacco + ldl + famhist + typea + obesity + age,
              family = poisson, 
              data = chd.train)

# Se predicen los resultados de entrenamiento con la regresión logística
predictTrain = predict(chd.glm, chd.train)

# Se calcula la media de error de los datos de entrenamiento
meanTrain.glm = mean((predictTrain > 0.5) != (chd.train[, 'chd'] > 0.5))

# Se predicen los resultados de test con la regresión logística
predictTest = predict(chd.glm, chd.test)

# Se calcula la media de error de los datos de test
meanTest.glm = mean((predictTest > 0.5) != (chd.test[, 'chd'] > 0.5))

print(paste("Ein calculado con Regresión Logística: ", 
            round(meanTrain.glm*100, digits = perDec), "%"))
print(paste("Etest calculado con Regresión Logística: ", 
            round(meanTest.glm*100, digits = perDec), "%"))

# Prueba 2

# Los coeficientes que se deben tener en cuenta son: tobacco, ldl, famhist y 
# obesity. 

# Se van a utilizar tres familias de funciones para realizar la regresión
# logística: binomial, gaussian y poisson. Con cada una de ellas se comprobará 
# su resultado y se elegirá la mejor.

# Se hace de nuevo regresión lineal con estos coeficientes.

# binomial
chd.glm = glm(chd ~ tobacco + ldl + famhist + obesity,
              family = binomial, 
              data = chd.train)

# Se predicen los resultados de entrenamiento con la regresión logística
predictTrain = predict(chd.glm, chd.train)

# Se calcula la media de error de los datos de entrenamiento
meanTrain.glm = mean((predictTrain > 0.5) != (chd.train[, 'chd'] > 0.5))

# Se predicen los resultados de test con la regresión logística
predictTest = predict(chd.glm, chd.test)

# Se calcula la media de error de los datos de test
meanTest.glm = mean((predictTest > 0.5) != (chd.test[, 'chd'] > 0.5))

print(paste("Ein calculado con Regresión Logística: ", 
            round(meanTrain.glm*100, digits = perDec), "%"))
print(paste("Etest calculado con Regresión Logística: ", 
            round(meanTest.glm*100, digits = perDec), "%"))

# gaussian
chd.glm = glm(chd ~ tobacco + ldl + famhist + obesity,
              family = gaussian, 
              data = chd.train)

# Se predicen los resultados de entrenamiento con la regresión logística
predictTrain = predict(chd.glm, chd.train)

# Se calcula la media de error de los datos de entrenamiento
meanTrain.glm = mean((predictTrain > 0.5) != (chd.train[, 'chd'] > 0.5))

# Se predicen los resultados de test con la regresión logística
predictTest = predict(chd.glm, chd.test)

# Se calcula la media de error de los datos de test
meanTest.glm = mean((predictTest > 0.5) != (chd.test[, 'chd'] > 0.5))

print(paste("Ein calculado con Regresión Logística: ", 
            round(meanTrain.glm*100, digits = perDec), "%"))
print(paste("Etest calculado con Regresión Logística: ", 
            round(meanTest.glm*100, digits = perDec), "%"))

# poisson
chd.glm = glm(chd ~ tobacco + ldl + famhist + obesity,
              family = poisson, 
              data = chd.train)

# Se predicen los resultados de entrenamiento con la regresión logística
predictTrain = predict(chd.glm, chd.train)

# Se calcula la media de error de los datos de entrenamiento
meanTrain.glm = mean((predictTrain > 0.5) != (chd.train[, 'chd'] > 0.5))

# Se predicen los resultados de test con la regresión logística
predictTest = predict(chd.glm, chd.test)

# Se calcula la media de error de los datos de test
meanTest.glm = mean((predictTest > 0.5) != (chd.test[, 'chd'] > 0.5))

print(paste("Ein calculado con Regresión Logística: ", 
            round(meanTrain.glm*100, digits = perDec), "%"))
print(paste("Etest calculado con Regresión Logística: ", 
            round(meanTest.glm*100, digits = perDec), "%"))

# De los resultados obtenidos, se descarta la familia "poisson" por ser la peor
# de las tres en ambas pruebas.
# En la prueba 1, la familia "binomial" y "gaussian" han obtenido el mismo
# resultado, pero la familia "gaussian" se ha ajustado mejor a la reducción de
# atributos.
# Teniendo en cuenta que el error de test obtenido en la prueba 1 y la prueba 2
# que se ha obtenido ha sido igual, se confirma la utilización de los
# atributos tobacco, ldl, famhist y obesity, obteniendo así una reducción de
# la dimensionalidad del 44%.
#

###############################################################################
# 8. Estimacion del error E out del modelo lo más ajustada posible.
#
# El error de test/out obtenido ha sido demasiado alto. Este hecho hace pensar
# que la muestra de datos no es separable linealmente, por lo que habría que
# intentar buscar transformaciones que permitan separar los datos en dos
# grupos bien definidos, como ya se hizo en la entrega 2.
#
# Las funciones utilizadas para realizar las transformaciones han sido:
# - x^n
# - x^-n
# - log(x)
# - log(x+n)
# - exp(x)
# - poly()
# 
# Para aplicar estas transformaciones se han implementado cinco bucles for
# en el que se han probado iterativamente las distintas funciones potenciales
# que se iban generando. 
# No se ha conseguido mejora ninguna con este método, empeorando en muchos
# casos el error obtenido.
# De manera Greedy se ha utilizado una combinación de las funciones anteriores
# entre todos los atributos, obteniendo solo en un caso una leve mejora.
# La mejora obtenida viene dada por la transformación de la función logarítmica
# en el atributo "obesity" de la muestra, que se muestra a continuación:
# 

# Se utiliza la familia "gaussian" al ser la que mejor resultado ha ofrecido y
# se aplica la transformación de la función log() al atributo "obesity".
chd.glm = glm(chd ~ tobacco + ldl + famhist + log(obesity),
              family = gaussian, 
              data = chd.train)

# Se predicen los resultados de entrenamiento con la regresión logística
predictTrain = predict(chd.glm, chd.train)

# Se calcula la media de error de los datos de entrenamiento
meanTrain.glm = mean((predictTrain > 0.5) != (chd.train[, 'chd'] > 0.5))

# Se predicen los resultados de test con la regresión logística
predictTest = predict(chd.glm, chd.test)

# Se calcula la media de error de los datos de test
meanTest.glm = mean((predictTest > 0.5) != (chd.test[, 'chd'] > 0.5))

print(paste("Ein calculado con Regresión Logística: ", 
            round(meanTrain.glm*100, digits = perDec), "%"))
print(paste("Etest calculado con Regresión Logística: ", 
            round(meanTest.glm*100, digits = perDec), "%"))

# Se ha podido disminuir el error de test/out del 25.18% al 24.46%, lo que
# sigue siendo un resultado alejado de uno de calidad.

###############################################################################
# 9. Discutir y justificar la calidad del modelo encontrado y las razones por 
# las que considera que dicho modelo es un buen ajuste que representa 
# adecuadamente los datos muestrales.
#
# El conjunto de datos que se tiene no es separable linealmente. Se ha
# intentado un ajuste no lineal para poder transformar la muestra y así
# clasificarla, pero no se han conseguido grandes mejoras.
# Considero que el modelo encontrado no es bueno por la muestra en concreto de
# la que se dispone. Son necesarias técnicas no lineales más avanzadas que sean
# capaz de ajustar mejor los datos.
#

###############################################################################
# Problema de regresión: Prostate Data Info
###################

###############################################################################
# 1. Comprender al problema a resolver.
#
# El problema a resolver consiste en predecir un antigen específico de la 
# próstata en el diagnóstico y tratamiento del adenocarcinoma de próstata.
#
# Para ello se cuenta con 8 atributos:
# - lcavol: volumen de cancer.
# - lWeight: anchura de la próstata.
# - age: edad del paciente.
# - lbph: cantidad benigna de hiperplasia prostática.
# - svi: invasión de vesículas seminales.
# - lcp: penetración capsular.
# - gleason: puntuación Gleason.
# - pgg45: porcentaje Gleason.
#
# La salida que se tiene es lpsam, que es el antígeno específico de la 
# próstata.
#
# 

###############################################################################
# 2. Los conjuntos de training, validación y test usados en su caso.
#
# Para realizar la predicción solo se cuenta con un conjunto de datos con 97
# muestras.
# Ya se tiene en el conjunto de datos una columna que indica si la muestra
# es de tipo train o test, por lo que solo se dispondrá a leer a qué tipo de
# conjunto pertenece cada muestra para agruparlas.
#

###############################################################################
# 3. Preprocesado los datos: Falta de datos, categorización, normalización, 
# reducción de dimensionalidad, etc.
#
# Se pretende controlar la cantidad de datos que se tienen, el tipo de muestra
# (train o test), comprobar si existen datos cualitativos.
# Cuando se ajuste el modelo final se determinará la reducción de 
# dimensionalidad y demás procesamiento necesario.
# En este caso, se normalizarán los datos de la columna pgg45 que viene dado
# en %.
#

# Se han descargado los datos a un fichero del directorio de trabajo.
# Se indica que la separación entre datos de cada muestra viene identificada 
# por una tabulación y que el fichero de datos tiene cabecera.
prost = read.table("prostate.data", sep="\t", head=T, row.names=1)

# En caso de querer cargar los datos sin utilizar este fichero, se pueden
# utilizar las tres instrucciones siguientes, pero no se asegura que funcione
# todo el proceso correctamente.
# data("prostate", package = "ElemStatLearn")
# str(prostate)
# prostate

# Hay que comprobar si algún valor del conjunto de datos es de carácter 
# cualitativo, por lo que se muestran las primeras muestras con la función
# "head".
head(prost)

# De los datos obtenidos, la única columna con una etiqueta es la última,
# "train", que indica si la muestra pertenece a train o test, por lo que 
# cuando se separen los datos y se trabajen con los correspondientes 
# subgrupos, ya no se tendrá en cuenta.

# Se comprueba si existe algún valor perdido. Para eso se utiliza la función
# which() y la función is.na(), que nos indican, respectivamente, la posición 
# en la que ocurre algún hecho y si alguna posición no es correcta.
which(is.na(prost))

# En este caso no se obtiene ninguna respuesta, por lo que no se encuentran
# valores perdidos en este conjunto de datos.

# Se van a normalizar los datos de la columna pgg45, que se encuentran
# en %. Realmente solo se cambia el valor a su probabilidad correspondiente.
prost[, 'pgg45'] = prost[, 'pgg45']/100

# Se simplifica el prefijo prost en las operaciones para evitar tener que
# escribir continuamente el conjunto de datos.
attach(prost)

# En este punto sí se pueden separar todos los datos en train y test.

# Se guardan los datos que forman parte del train.
prost.train = prost[which(prost[, 'train']) , 1:9]

# Se guardan los datos que forman parte del test. Serán todos aquellos que no
# sean del train.
prost.test = prost[which(!prost[, 'train']) , 1:9]

# Se comprueba que coincida el número de train y test
print(paste("Número de muestras de train: ", nrow(prost.train)))
print(paste("Número de muestras de test: ", nrow(prost.test)))

# Se muestra un gráfico con la relación de los atributos entre ellos.
pairs(prost, col = c(4, 6)[prost$train + 1])

###############################################################################
# 4. Selección de clases de funciones a usar.
#
# Para predecidr datos se puede utilizar:
# - Regresión Lineal Simple: con la función lm().
# - Regresión Logística: con la función glm(). Cuenta a su vez con una serie
# de familias a utilizar.
# - Predicción: predict() permitirá predecir el resultado ajustado por la
# regresión realizada.
# - Disminución de atributos: se usa la función step() que devuelve un set de
# atributos con los que se puede representar la mayor parte del conjunto de
# datos.
# - Regularización: para hacer la regresión con regularización se va a
# utilizar el paquete glmnet, que ya la aplica a una regresión logística.
#
#

###############################################################################
# 5. Discutir la necesidad de regularización y en su caso la función usada.
#
# Directamente se van a hacer dos pruebas para comprobar la evolución de las
# muestras.
# La primera prueba se hará con regresión lineal.
# En la segunda prueba, que será donde se haga la regularización, se usará
# la función cv.glmnet(), que realiza una regresión logística aplicando
# generalización y haciendo cross-validation.
# La segunda prueba a su vez, se divide en dos, en las que en una se hará
# la regularización Ridge y en otra la regularización Lasso.
#

###############################################################################
# 6. Definir los modelos a usar y estimar sus parámetros e hyperparámetros.
#
# El modelo a utilizar es regresión lineal. Se ajustarán los atributos que se
# van a aplicar en la regresión lineal final con la función step().
# Para hacer la segunda prueba se utiliza regresión logística y directamente
# la función cv.glmnet() ajusta los parámetros que mejor resultado ofrecen.
# Sí se cambiará el tipo de generalización que va a realizar con el parámetro
# alpha de la función.
#

###############################################################################
# 7. Selección y ajuste modelo final.
#

###################
# Función que devuelve el error en las etiquetas de una muestra
#
# La función comprueba la diferencia entre el valor que se ha predecido y el 
# que realmente le corresponde, hace la suma de todas las diferencias y las
# divide por por la máxima diferencia que se puede encontrar. Finalmente se
# hace la media y es el valor que se devuelve.
#
getErrorReg = function(y, yHat){
  
  (sum(abs(y - yHat))/(max(y)-min(y)))*(1/length(y))
  
}

# Se hace regresión lineal de la muestra de entrenamiento teniendo en 
# cuenta todos los atributos. La intención es comprobar cuáles de ellos no 
# representan la mayor parte de la muestra y así tener una solución con el 
# menor número de atributos posibles, lo que hará que sea de mayor calidad.
prost.lm = lm(lpsa ~ ., data = prost.train)

# Para obtener el menor número de atributos posibles se podría haber utilizado
# regsubsets(), step() o PCA con el paquete caret.
# En este caso se ha utilizado la función step() que, directamente devuelve
# los atributos mas representativos del conjunto de muestras. Además, indica
# qué peso tiene cada uno de ellos, por lo que se puede hacer una valoración
# más exhaustiva del resultado.
# Se ha inspeccionado la función step() para comprobar su funcionamiento y
# se puede determinar que el pseudocódigo relacionado es:
#
# initial_setting
# for i in steps
# start
#   set_type_scan
#   get_attributes
#   evaluate_attributes
#   result += list_evaluation
# end
# return result
#
# El algoritmo de la función step() comienza ajustando los parámetros iniciales
# por defecto que tiene definidos o los que el usuario quiera utilizar.
# De manera iterativa, en una serie de pasos previamente establecidos, obtiene
# los atributos con los que va a realizar la prueba. En cada iteración 
# selecciona una serie de ellos y evalúa el resultado de la regresión logística
# (en este caso). Finalmente, para cada evaluación realizada, devuelve su 
# resultado, mostrando la desviación de cada atributo y el criterio de
# información de Akaike, así como los atributos con los que se han obtenido
# estos resultados.
# 

# Para obtener más información de la que se obtiene solo con la función step(),
# se utiliza summary() para ver un informe más completo.
summary(step(prost.lm))

# Los atributos que se deben tener en cuenta según los resultados obtenidos son:
# - lcavol.
# - lweight.
# - age.
# - lbph.
# - svi.
# - lcp.
# - pgg45.
#

# Se predice los valores que va a obtener cada elemento del conjunto de test.
prost.yHat <- predict(prost.lm, prost.test)

# Se calcula el error que tiene esta predicción
meanTest.lm = getErrorReg(prost.test$lpsa, prost.yHat)

print(paste("Etest calculado con Regresión Lineal: ", 
            round(meanTest.lm*100, digits = perDec), "%"))

# Para calcular el error haciendo generalización se usa el paquete glmnet
library(glmnet)

# La función cv.glmnet() recibe como parámetros los datos sin etiqueta y sus
# etiquetas correspondientes.

# Se separan los datos, cogiendo todos menos la columna que contiene el 
# resultado
prost.train.x <- as.matrix(subset(prost.train, select = -lpsa))

# Se obtiene solo el resultado de cada muestra
prost.train.y <- prost.train[, "lpsa"]

# Se realiza la regresión logísitca con regularización Ridge
prost.glmnet <- cv.glmnet(prost.train.x, prost.train.y, alpha = 0)

# Se vuelven a separar los datos como anteriormente pero con test
prost.test.x <- as.matrix(subset(prost.test, select = -lpsa))
prost.test.y <- prost.test[, "lpsa"]

# Se predice el resultado que obtendrá cada muestra
prost.yHat <- predict(prost.glmnet, prost.test.x)

# Se calcula el error obtenido
meanTest.lm.ridge = getErrorReg(prost.test.y, prost.yHat)

print(paste("Etest calculado con Regresión Logística con regularización Ridge: ", 
            round(meanTest.lm.ridge*100, digits = perDec), "%"))

# Se repite la misma operación realizada con glmnet(), pero se hace con
# generalización Lasso.
# Como los datos ya están separados, no se repite.

# Se realiza la regresión logísitca con regularización Lasso.
prost.glmnet <- cv.glmnet(prost.train.x, prost.train.y, alpha = 1)

# Se predice el resultado que obtendrá cada muestra
prost.yHat <- predict(prost.glmnet, prost.test.x)

# Se calcula el error obtenido
meanTest.lm.lasso = getErrorReg(prost.test.y, prost.yHat)

print(paste("Etest calculado con Regresión Logística con regularización Lasso: ", 
            round(meanTest.lm.lasso*100, digits = perDec), "%"))

###############################################################################
# 8. Estimacion del error E out del modelo lo más ajustada posible.
#
# Se ha realizado una primera aproximación con regresión lineal, reduciendo
# la dimensionalidad y se ha obtenido un error del 10.864%.
# En un segundo intento, con regresión logística con regularización Ridge,
# el error ha aumentado al 11.173%.
# El tercer intento, con regresión logística con regularización Lasso, ha 
# obtenido el mejor porcentaje, con 10.702%, por lo que el error más ajustado
# posible ha sido el obtenido con el último método mencionado.
# 

###############################################################################
# 9. Discutir y justificar la calidad del modelo encontrado y las razones por 
# las que considera que dicho modelo es un buen ajuste que representa 
# adecuadamente los datos muestrales.
#
# Al contrario de lo que ha ocurrido con el problema de clasificación, el error
# obtenido ha sido bueno.
# Pese a que se ha utilizado una técnica más avanzada a la regresión lineal,
# apenas se ha conseguido aumentar la calidad del ajuste, probablemente
# gracias a los datos que se tienen. Estos datos son fáciles de aprender y 
# cuentan con unas características que representan la muestra en su totalidad.
# El modelo ha ajustado bien, posiblemente, por la mínima cantidad de muestras
# que se tienen en el conjunto de datos, pero se puede determinar que es
# correcto al obtener un error de test/out del 10.702%.
#
