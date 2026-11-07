# -*- coding: utf-8 -*-
# Copyright (C) 2007-2026   EDF R&D
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
#
# See http://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
#
# Modules Python
# Modules Eficas

from desWidgetBar import Ui_BarVP

from PyQt5.QtWidgets import QDialog
from PyQt5.QtChart   import QBarSet, QChart, QChartView, QBarSeries, QBarCategoryAxis, QValueAxis
from PyQt5.QtCore    import Qt
from PyQt5.QtGui     import QPainter



# Import des panels

class MonWidgetBar(Ui_BarVP, QDialog):
    """
    """
    def __init__(self, widgetProfile):
        self.widgetProfile=widgetProfile
        QDialog.__init__(self,self.widgetProfile.editor)
        self.setModal(False)
        self.setupUi(self)
        self.monChart =  QChart()
        self.mesLabels=[]
        self.creeSerie()


    def creeSerie(self):
       debug = 0
       setId=set()
       if debug : print ('liste des Id ', self.widgetProfile.listeId)
       for serie in self.widgetProfile.dictSerie.values() :
           if debug : print ('---- traitement de la serie' , serie, serie.label)
           for point in serie.listeClicked :
               if debug : print ('point clicke nunero', point)
               # attention les numeros des points sont de 1 a n et des sha1 de 0 a n-1
               setId.add(self.widgetProfile.listeId[point - 1])
           if debug : print ('--------- fin  traitement de la serie' , serie, serie.label)

       debug = 0
       if debug : print ('set des Id', setId)
       if debug : print (self.widgetProfile.dictLabelIdValue)
       self.mesSeries = QBarSeries()
       max=0
       for id in setId :
           barSet=QBarSet(str(id))
           for serie in self.widgetProfile.dictSerie.values() :
               if self.widgetProfile.dictLabelIdValue[serie.label][id] > 0 :
                  barSet.append(self.widgetProfile.dictLabelIdValue[serie.label][id])
               else :
                  barSet.append(-1)
               self.mesLabels.append(serie.label)
               if self.widgetProfile.dictLabelIdValue[serie.label][id] > max :
                  max = self.widgetProfile.dictLabelIdValue[serie.label][id]
           self.mesSeries.append(barSet)

       self.monChart.addSeries(self.mesSeries)
       self.monChart.setTitle("Comparaison")
       self.monChart.setAnimationOptions(QChart.SeriesAnimations);

       axisX=QBarCategoryAxis()
       axisX.append(self.mesLabels)
       self.mesSeries.attachAxis(axisX)
       self.monChart.addAxis(axisX, Qt.AlignBottom);
       
       axisY=QValueAxis()
       axisY.setRange(0,max);
       self.mesSeries.attachAxis(axisY)
       self.monChart.addAxis(axisY, Qt.AlignLeft);

       self.monChart.legend().setVisible(True)
       self.monChart.legend().setAlignment(Qt.AlignBottom)
       self.chartView = QChartView(self.monChart);
       self.chartView.setRenderHint(QPainter.Antialiasing)
       self.GraphLayout.addWidget(self.chartView)
       self.resize(420,300)

       
