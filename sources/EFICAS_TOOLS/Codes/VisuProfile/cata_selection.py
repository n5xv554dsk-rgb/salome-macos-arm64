# -*- coding: utf-8 -*-
# 
# Ce catalogue permet de decrire la partie Selection du GUI
# il doit etre en coherence avec les meta données de la database
#
import time

# Eficas
from Accas import SIMP, JDC_CATA, PROC, JDC_CATA_SINGLETON
from Accas import AU_MOINS_UN, PRESENT_PRESENT
from Accas import infFrereMC, supFrereMC
from interrogeDB import cherche_code_name
from interrogeDB import cherche_max_timestamp
from interrogeDB import cherche_sha1_from_date
from interrogeDB import cherche_in_profile
#from interrogeDB import cherche_min_sha1, cherche_max_sha1

# PN Attention, Eficas réappelle la fonction si elle est directement dans le into
# ici l 'appel n 'est fait qu 'une fois
into_code_name = cherche_code_name()

#PN a regler dans le XSD genere
from datetime import datetime, timedelta
lastTimeStamp = cherche_max_timestamp()[0][0]
#aWeekBeforeDT = datetime.fromtimestamp(lastTimeStamp) - timedelta(days=7)
#aWeekBefore = aWeekBeforeDT.timestamp()
#listSha1Min = cherche_sha1_from_date( aWeekBefore)
#if listSha1Min != [] : sha1Min = listSha1Min[0]
#else : sha1Min = 0
#listSha1Max = cherche_sha1_from_date( lastTimeStamp)
#if listSha1Max != [] : sha1Max = listSha1Max[0]
#else : sha1Max = 9

print ('Attention, il faut decommenter les timestamps pour creer le XSD du chapeau')
sha1Min=None
listSha1Min=None
sha1Max=None
listSha1Max=None
aWeekBefore=None

JdC = JDC_CATA_SINGLETON(code="ProfileSelection")
Selection = PROC( nom = "Selection",
    fenetreIhm='InterfaceGUI.VisuProfile.monWidgetSelection',
    code_name  =  SIMP(statut='o', typ='TXM', into = into_code_name,
                  fenetreIhm='InterfaceGUI.VisuProfile.monWidgetCBSelectionVP',
                  affichage=('selection',0,0),
                  ),
    test_name  =  SIMP(statut='o', typ='TXM', 
                  fenetreIhm='InterfaceGUI.VisuProfile.monWidgetCBSelectionVP',
                  affichage=('selection',0,1),
                  ),
    host = SIMP (statut='o', typ = 'TXM',
                  fenetreIhm='InterfaceGUI.VisuProfile.monWidgetCBSelectionVP',
                  affichage=('selection',1,0),
                  into = ('All',),
                  defaut = 'All',
                  ),
    procs = SIMP(statut='o', typ='I', val_min=0,
                  fenetreIhm='InterfaceGUI.VisuProfile.monWidgetCBSelectionVP',
                  affichage=('selection', 1, 1),
                  ),
    OS = SIMP(statut='o', typ='TXM',
                 fenetreIhm='InterfaceGUI.VisuProfile.monWidgetCBSelectionVP',
                 affichage=('selection',1,2),
                 into = (),
                 #defaut = 'All',
                  ),
    build_type = SIMP(statut='o', typ='TXM', into=('Release','Debug','RelWithDebInfo','All'),
                 fenetreIhm='InterfaceGUI.VisuProfile.monWidgetCBSelectionVP',
                 affichage=('selection', 2, 0),
                 defaut = 'All',
                 ),
    version = SIMP(statut='o', typ='TXM',
                 fenetreIhm='InterfaceGUI.VisuProfile.monWidgetCBSelectionVP',
                 affichage=('selection', 2, 1),
                 ),
    execution = SIMP(statut='o', typ='TXM', into=('par','seq','All'),
                 fenetreIhm='InterfaceGUI.VisuProfile.monWidgetCBSelectionVP',
                 affichage=('selection', 2, 2),
                 defaut = 'All',
                 ),
    timestamp_debut =  SIMP(statut='o', typ='I', typeXSD='xs:int',
                  fenetreIhm='InterfaceGUI.VisuProfile.monWidgetDateVP',
                  affichage=('selection',3,0),
                  validators=[infFrereMC(frere='timestamp_fin'),],
                  #defaut = aWeekBefore,
                  ),
    timestamp_fin   =  SIMP(statut='o', typ='I', typeXSD='xs:int',
                  fenetreIhm='InterfaceGUI.VisuProfile.monWidgetDateVP',
                  affichage=('selection',3,1),
                  validators=[supFrereMC(frere='timestamp_debut'),],
                  defaut = lastTimeStamp,
                  ),
    sha1_debut =  SIMP(statut='o', typ='TXM',
                  fenetreIhm='InterfaceGUI.VisuProfile.monWidgetCBSelectionVP',
                  affichage=('selection',4,0),
                  into = listSha1Min,
                  defaut = sha1Min,
                  ),
    sha1_fin   =  SIMP(statut='o', typ='TXM',
                  fenetreIhm='InterfaceGUI.VisuProfile.monWidgetCBSelectionVP',
                  affichage=('selection',4,1),
                  into = listSha1Max,
                  defaut = sha1Max,
                  ),
    performance = SIMP(statut='o', typ='TXM',
                  fenetreIhm='InterfaceGUI.VisuProfile.monWidgetCBSelectionVP',
                  affichage=('selection',5,0),
                  into = ('CPU', 'Memory'),
                  defaut = 'CPU',
                  ),
)
PresentationLabels = PROC ( nom = 'PresentationLabels',
     fenetreIhm='InterfaceGUI.VisuProfile.monWidgetLabels',
     labels = SIMP(statut='o', typ='TXM', into = [], max='**', homo='SansOrdreNiDoublon',),
) 


