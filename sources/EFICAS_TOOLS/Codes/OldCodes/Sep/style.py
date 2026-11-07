# -*- coding: utf-8 -*-
"""
Pour modifier le style d'EFICAS  il faut ajouter un fichier style.py qui contiendra les
informations sur le style voulu dans son repertoire Eficas_install.

La methode la plus simple consiste à modifier directement les attributs de l'objet style dans le 
fichier style.py d'Eficas_install. Exemple::

    style.background='yellow'

pour modifier la couleur du background.

Il existe une autre méthode qui peut être utilisée quand on veut modifier plusieurs propriétés à la fois.

Le fichier style.py doit définir une nouvelle classe qui dérive de la classe de base STYLE avec des attributs
de classe qui définiront le nouveau style (par exemple, si on veut modifier le background)::

   class STYLE(STYLE):
       background='yellow'

Il faut ensuite instancier cette classe, dans ce meme fichier, en donnant le nom style à l'objet cree::

   style=STYLE()

Tous les attributs de classe possibles sont visibles dans le module Editeur/basestyle.py::

    background='gray90'
    foreground='black'
    entry_background='white'
    list_background='white'
    list_select_background='#00008b'
    list_select_foreground='grey'
    tooltip_background="yellow"

    standard = ("Helvetica",12)
    standard_italique = ("Helvetica",12,'italic')
    standard_gras = ("Helvetica",12,'bold')
    standard_gras_souligne = ("Helvetica",12,'bold','underline')

    canvas = ('Helvetica',10)
    canvas_italique = ('Helvetica',10,'italic')
    canvas_gras = ("Helvetica",10,'bold')
    canvas_gras_italique = ("Helvetica",12,'bold','italic')

    standard12 = ("Helvetica",14)
    standard12_gras = ("Helvetica",14,'bold')
    standard12_gras_italique = ( "Helvetica",14,'bold','italic')


Le fichier style.py contenu dans le répertoire Aster permet de spécifier des propriétés globales pour une installation.
Les modifications de style contenues dans ce fichier et dans le fichier style.py d'Eficas_install
sont prises en compte dans cet ordre.
"""

p1=10
p2=14
f1="Helvetica"

style.background='gray90'
style.foreground='black'
style.standard = (f1,p1)
style.standard_italique = (f1,p1,'italic')
style.standard_gras = (f1,p1,'bold')
style.canvas_italique = (f1,p1,'italic')
style.canvas_gras = (f1,p1,'bold')
style.statusfont = (f1,p2)
