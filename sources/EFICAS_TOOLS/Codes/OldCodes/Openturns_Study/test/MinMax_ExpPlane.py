#! /usr/bin/env python

# Chargement du module systeme
import sys
sys.path.append( '/local00/home/dutka/OpenTURNS/trunk/build/install/lib/python2.4/site-packages/openturns' )

# Chargement du module Open TURNS
from openturns import *

# Definit le niveau d'affichage de la log
flags = Log.NONE
flags = flags + Log.WARN
flags = flags + Log.ERROR
flags = flags - Log.WRAPPER
flags = flags + Log.INFO
flags = flags - Log.USER
flags = flags - Log.DBG
Log.Show( flags )

# Etude 'Min/Max'
# Charge le modele physique
model = NumericalMathFunction( 'poutre' )
n = model.getInputNumericalPointDimension()

# Etude par plan d'experience
# Definit les niveaux de la structure de grille
levels = NumericalPoint( 3 )
levels[0] = 1
levels[1] = 2
levels[2] = 5

# Cree le plan d'experience centre reduit
myCenteredReductedGrid = Axial(n, levels)
myExperimentPlane = myCenteredReductedGrid.generate()

# Definit les facteurs d'echelle dans chaque direction
scaledVector = NumericalPoint( n )
scaledVector[0] = 100
scaledVector[1] = 5
scaledVector[2] = 0.5
scaledVector[3] = 1e-07
myExperimentPlane.scale( scaledVector )

# Definit le vecteur de translation
translationVector = NumericalPoint( n )
translationVector[0] = 3e+09
translationVector[1] = 300
translationVector[2] = 2.5
translationVector[3] = 4e-06
myExperimentPlane.translate( translationVector )


inputSample = myExperimentPlane

# Calcul
outputSample = model( inputSample )

# Resultats
minValue = outputSample.getMin()
maxValue = outputSample.getMax()

print 'minValue = ', minValue
print 'maxValue = ', maxValue



# Terminaison du fichier
sys.exit( 0 )
