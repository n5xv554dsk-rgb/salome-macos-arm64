
def view_med(params,appli) :
    mcSimp=params[0].object.get_child('cracked_name')
    fileName=mcSimp.valeur
    import os
    if not os.path.isfile(fileName) : 
           from PyQt4.QtGui import QMessageBox
           QMessageBox.warning( None, "Erreur","Le fichier n'existe pas")
           return
    result,message=appli.importMedFile(fileName)
    if result==1 : return 
    from PyQt4.QtGui import QMessageBox
    QMessageBox.warning( None, "Erreur a l import",message)
    return


# le dictionnaire des commandes a la structure suivante :
# la clef est la commande qui va proposer l action
# puis un tuple qui contient
#	- la fonction a appeler
#       - le label dans le menu du clic droit
#	- un tuple contenant les parametres attendus par la fonction
#	- appelable depuis Salome uniquement -)
#	- appelable depuis un item valide uniquement 
#	- toolTip
dict_commandes={
	'MAILLAGE_RESULTAT':((view_med,"View Result",('item','editor'),False,False,"affiche dans Smesh le fichier med resultat"),),
               }
