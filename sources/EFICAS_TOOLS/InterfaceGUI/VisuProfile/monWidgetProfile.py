# Copyright (C) 2007 - 2026   EDF R&D
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

#from InterfaceQT.groupe import Groupe
from UiQT5.desWidgetProfile  import Ui_ProfileVP
from Accas.extensions.eficas_translation import tr
# Import des panels

from PyQt5.QtWidgets import QCheckBox, QWidget, QGraphicsView, QGraphicsEllipseItem
from PyQt5.QtWidgets import QGraphicsItem, QGraphicsScene, QGraphicsTextItem, QGraphicsPathItem
from PyQt5.QtCore    import Qt, QSignalMapper, QPoint, QRectF, QTimer
from PyQt5.QtChart   import QLineSeries, QChart, QChartView, QValueAxis, QCategoryAxis, QScatterSeries
from PyQt5.QtGui     import QColor, QBrush, QPen, QPainter, QPainterPath


tabCouleur={ 0 : (41,128,185),   1 : (46,64,83),    2 : (255,87,51),    3 : (199,00,57),
             4 : (144,12,63),    5 : (125,60,152),  6 : (249,231,159),  7 : (127,140,141),
             8 : (255,195,0),    9 : (127,179,213), 10: (204,255,0),   11 : (204, 255, 204),
            12 : (204,255,255), 13 : (204,204,255), 14: (255,204,255), 15 : (255, 204, 51),
            16 : (255,153,51),  17 : (102,0,102),   18: (255, 0, 51),  19 : (102,153,204)
           }

class ClickablePoint(QGraphicsEllipseItem):
#------------------------------------------
    #def __init__(self, X, Y, id, label, serie, couleur):
    def __init__(self, X, Y, id,  label):
    #-------------------------------------
        debug = 0
        if debug : print ('initialisation de ClickablePoint avec', X, Y, serie)
        super().__init__(X, Y, 10, 10)
        self.X=X
        self.Y=Y
        self.selectionne = False
        self.couleur = Qt.blue
        self.label = label
        self.id = id
        self.setBrush(QBrush(self.couleur))
        self.setPen(QPen(Qt.black))
        self.setFlag(QGraphicsItem.ItemIsSelectable)
        self.setFlag(QGraphicsItem.ItemIsMovable)
        #self.serie=serie
        #if self.serie.maxY < Y :  self.serie.maxY = Y

    def mousePressEvent(self, event):
    #--------------------------------
        print(f'Clicked on ID: {self.id}, Label: {self.label}')
        super().mousePressEvent(event)


class ClickableText(QGraphicsTextItem):
#--------------------------------------
    def __init__(self, text, x, y, label, graph_widget):
        super().__init__(text)
        self.setPos(x, y)
        self.label = label
        self.graph_widget = graph_widget
        self.setDefaultTextColor(Qt.black)
        self.setFlag(QGraphicsItem.ItemIsSelectable)
        self.setFlag(QGraphicsItem.ItemIsMovable)

    def mousePressEvent(self, event):
        self.graph_widget.toggle_column(self.label)
        super().mousePressEvent(event)


         
class Graphique(QGraphicsView):
#-------------------------------
    def __init__(self, donnees):
        super().__init__()
        self.scene = QGraphicsScene(self)
        self.donnees = donnees
        self.setScene(self.scene)
        self.setRenderHint(QPainter.Antialiasing)
        self.columns = {}
        self.plot(self.donnees)


    def plot(self, donnees, x_step = 100, y_step = 10, x_offset = 50, y_offset = 300) :  
        # Ajout des axes avec des lignes plus épaisses
        self.scene.addLine(x_offset, y_offset, x_offset + len(donnees) * x_step, y_offset, QPen(Qt.black, 2))  # Axe des X en bas
        self.scene.addLine(x_offset, y_offset, x_offset, y_offset - 300, QPen(Qt.black, 2))  # Axe des Y à gauche

        self.paths = {}
        self.colors = {}
        colorId = 0 
        indice = 0

        for (label, timeValues) in donnees.items():
            x = x_offset + indice * x_step
            indice += 1
            # Ajout des labels sur l'axe des X
            text = ClickableText(label, x - 10, y_offset + 10, label, self)
            self.scene.addItem(text)
            # Ajout des lignes verticales pour les labels
            line = self.scene.addLine(x, y_offset, x, y_offset - 300, QPen(Qt.lightGray, 1, Qt.DashLine))
            self.columns[label] = [line]

            for runId, value in timeValues.items():
                y = y_offset - value * y_step  # Ajustement pour que les valeurs soient correctes par rapport à l'axe des X
                ellipse = ClickablePoint(x, y,  runId, label)
                self.scene.addItem(ellipse)
                self.columns[label].append(ellipse)

                if runId not in self.paths:
                    self.paths[runId] = QPainterPath()
                    self.paths[runId].moveTo(x, y)
                else:
                    self.paths[runId].lineTo(x, y)
                if runId not in self.colors:
                    self.colors[runId]=QColor(tabCouleur[colorId][0], tabCouleur[colorId][1],tabCouleur[colorId][2])
                    if colorId == len(tabCouleur) :
                       colorId = len(tabCouleur) -1
                       self.editor.afficheMessage('Pas assez de couleurs definies',
                          'Prevenez la maintenance',critique=False)
                    else : colorId += 1

        print (self.colors)
        # Ajout des lignes pour chaque ID
        self.line_items = {}
        for id, path in self.paths.items():
            line_item = QGraphicsPathItem(path)
            line_item.setPen(QPen(self.colors[id], 2))
            self.scene.addItem(line_item)
            self.line_items[id] = line_item

        self.update_y_axis()

    def toggle_column(self, label):
        for item in self.columns[label]:
            item.setVisible(not item.isVisible())
        self.update_lines()
        self.update_y_axis()

    def update_lines(self):
        for id, path in self.paths.items():
            new_path = QPainterPath()
            for i, (label, values) in enumerate(self.donnees.items()):
                if self.columns[label][0].isVisible():
                    x = 50 + i * 100
                    y = 300 - values[id] * 10
                    if new_path.elementCount() == 0:
                        new_path.moveTo(x, y)
                    else:
                        new_path.lineTo(x, y)
            self.line_items[id].setPath(new_path)

    def update_y_axis(self):
        # Supprimer les anciennes graduations
        for item in self.scene.items():
            if isinstance(item, QGraphicsTextItem) and item.toPlainText().isdigit():
                self.scene.removeItem(item)

        # Trouver les valeurs min et max visibles
        min_value = float('inf')
        max_value = float('-inf')
        for label, values in self.donnees.items():
            if self.columns[label][0].isVisible():
                for value in values.values():
                    if value < min_value:
                        min_value = value
                    if value > max_value:
                        max_value = value

        # Ajuster l'échelle de l'axe des Y
        y_step = 10
        y_offset = 300
        x_offset = 50
        if min_value != float('inf') : min_value = int(min_value // 10 * 10)
        else : min_value = 0
        if max_value != float('-inf') : max_value = int(max_value // 10 * 10 + 10)
        else : max_value = 0

        for i in range(min_value, max_value + 1, 10):
            y = y_offset - (i - min_value) * y_step
            self.scene.addLine(x_offset - 5, y, x_offset + 5, y, QPen(Qt.black, 2))
            text = QGraphicsTextItem(str(i))
            text.setPos(x_offset - 30, y - 10)
            self.scene.addItem(text)


#    def plot(self):
#        x_step = 100
#        y_step = 10
#        x_offset = 50
#        y_offset = 300  # Ajustement pour que l'axe des X soit en bas
#
#        # Ajout des axes avec des lignes plus épaisses
#        self.scene.addLine(x_offset, y_offset, x_offset + len(self.donnees) * x_step, y_offset, QPen(Qt.black, 2))  # Axe des X en bas
#        self.scene.addLine(x_offset, y_offset, x_offset, y_offset - 300, QPen(Qt.black, 2))  # Axe des Y à gauche
#
#        # Ajout des graduations sur l'axe des Y
#        for i in range(0, 31, 10):
#            y = y_offset - i * y_step
#            self.scene.addLine(x_offset - 5, y, x_offset + 5, y, QPen(Qt.black, 2))
#            text = QGraphicsTextItem(str(i))
#            text.setPos(x_offset - 30, y - 10)
#            self.scene.addItem(text)
#
#        # Création des chemins pour chaque ID
#        paths = {}
#        colors = {'ID1': Qt.red, 'ID2': Qt.green}
#
#        for i, (label, values) in enumerate(self.donnees.items()):
#            x = x_offset + i * x_step
#            # Ajout des labels sur l'axe des X
#            text = QGraphicsTextItem(label)
#            text.setPos(x - 10, y_offset + 10)
#            self.scene.addItem(text)
#            # Ajout des lignes verticales pour les labels
#            self.scene.addLine(x, y_offset, x, y_offset - 300, QPen(Qt.lightGray, 1, Qt.DashLine))
#            for id, value in values.items():
#                y = y_offset - value * y_step  # Ajustement pour que les valeurs soient correctes par rapport à l'axe des X
#                ellipse = ClickablePoint(x, y, id, label)
#                self.scene.addItem(ellipse)
#
#                if id not in paths:
#                    paths[id] = QPainterPath()
#                    paths[id].moveTo(x, y)
#                else:
#                    paths[id].lineTo(x, y)
#
#        # Ajout des lignes pour chaque ID
#        for id, path in paths.items():
#            line_item = QGraphicsPathItem(path)
#            line_item.setPen(QPen(colors[id], 2))
#            self.scene.addItem(line_item)

         
class MonWidgetProfile(QWidget,Ui_ProfileVP):
#--------------------------------------------

    def __init__(self, editor,  listeId, listeLabels, donnees, debug = 0):
    #---------------------------------------------------------------------
        QWidget.__init__(self,None)
        self.setupUi(self)
        self.editor=editor
        self.couleurUtilisee=-1
        self.maxY=-1
        self.widgetBar=None
        self.listeLabels=listeLabels
        self.dictLabelIdValue = {}
        self.listeId=listeId
        donnees = {
          'Label1': {'ID1': 10, 'ID2': 20},
          'Label2': {'ID1': 15, 'ID2': 25},
          'Label3': {'ID1': 20, 'ID2': 30}
        }
        self.donnees=donnees
        self.graphique = Graphique(donnees)
        self.GraphLayout.addWidget(self.graphique)


    def markerClicked(self,index):
    #-----------------------------
    # cache ou affiche la QLSerie selon le click sur la legende
        debug = 0
        if debug : print ('in markerClicked')
        marker=self.dictMarkers[index]
        if debug : print ('index', index)

        if debug : print ('Visible : ',marker.series().isVisible())
        if marker.series().isVisible() : marker.series().setVisible(False)
        else :  marker.series().setVisible(True)
        marker.setVisible(True)
        if not (marker.series().isVisible()): alpha = 0.5
        else : alpha = 1.0

        brush = marker.labelBrush()
        color = brush.color()
        color.setAlphaF(alpha)
        brush.setColor(color)
        marker.setLabelBrush(brush);

        brush = marker.brush();
        color = brush.color();
        color.setAlphaF(alpha);
        brush.setColor(color);
        marker.setBrush(brush);

        pen = marker.pen();
        color = pen.color();
        color.setAlphaF(alpha);
        pen.setColor(color);
        marker.setPen(pen);
                                                         

    def afficheInfosForId(self,index):
    #---------------------------------
        id=self.listeId[index]
        self.editor.afficheInfosForId(id)

    def displaySelectedInBar(self):
    #------------------------------
       
       if self.widgetBar == None :
          from InterfaceGUI.VisuProfile.monWidgetBar import MonWidgetBar
          self.widgetBar=MonWidgetBar(self)
          self.widgetBar.adjustSize()
          self.widgetBar.show()
          self.widgetBar = None
       else :
          print ('on ajoute une serie')
