c
c  La liste qui suit decrit les mots-cles reconnus pour reperer
c  les objets et les fichiers dans le fichier de configuration.
c
c 1. La base
c===========
c
c 1.1. Les fichiers generaux
c===========================
c
c mcdico : dictionnaire des objets structures
c
      character*8 mcdico
      parameter ( mcdico = 'DicoOSGM' )
c
c mclist : liste de sortie standard
c
      character*8 mclist
      parameter ( mclist = 'ListeStd' )
c
c mcrept : repertoire de travail pour les fichiers temporaires
c
      character*8 mcrept
      parameter ( mcrept = 'RepeTrav' )
c
c 1.2. Les fichiers au format du code de calcul associe
c======================================================
c
c mccman : maillage a l'iteration n
c
      character*8 mccman
      parameter ( mccman = 'CCMaiN__' )
c
c mccmap : maillage a l'iteration n+1
c
      character*8 mccmap
      parameter ( mccmap = 'CCMaiNP1' )
c
c mccmaa : maillage annexe
c
      character*8 mccmaa
      parameter ( mccmaa = 'CCMaiAnn' )
c
c mccson : solution a l'iteration n
c
      character*8 mccson
      parameter ( mccson = 'CCSolN__' )
c
c mccsop : solution a l'iteration n+1
c
      character*8 mccsop
      parameter ( mccsop = 'CCSolNP1' )
c
c mccind : indicateur d'erreur
c
      character*8 mccind
      parameter ( mccind = 'CCIndica' )
c
c mccdfr : description de la frontiere discrete
c
      character*8 mccdfr
      parameter ( mccdfr = 'CCFronti' )
c
c 1.3. Les noms des maillages dans les fichiers du code de calcul
c================================================================
c
c mccnmn : maillage a l'iteration n
c
      character*8 mccnmn
      parameter ( mccnmn = 'CCNoMN__' )
c
c mccnmp : maillage a l'iteration n+1
c
      character*8 mccnmp
      parameter ( mccnmp = 'CCNoMNP1' )
c
c mccnma : maillage annexe
c
      character*8 mccnma
      parameter ( mccnma = 'CCNoMAnn' )
c
c mccnmf : maillage de la frontiere discrete
c
      character*8 mccnmf
      parameter ( mccnmf = 'CCNoMFro' )
c
c 1.4. L'indicateur d'erreur
c===========================
c
c mccnin : nom du champ de l'indicateur d'erreur
c
      character*8 mccnin
      parameter ( mccnin = 'CCNoChaI' )
c
c mccnin : nom de la composante de l'indicateur d'erreur
c
      character*8 mcccin
      parameter ( mcccin = 'CCCoChaI' )
c
c mcntin : numero du pas de temps de l'indicateur d'erreur
c
      character*8 mcntin
      parameter ( mcntin = 'CCNumPTI' )
c
c mcnoin : numero d'ordre de l'indicateur d'erreur
c
      character*8 mcnoin
      parameter ( mcnoin = 'CCNumOrI' )
c
c mcinin : instant de l'indicateur d'erreur
c
      character*8 mcinin
      parameter ( mcinin = 'CCInstaI' )
c
c mcmfi1 : mode de fonctionnement de l'indicateur d'erreur - 1
c
      character*8 mcmfi1
      parameter ( mcmfi1 = 'CCUsCmpI' )
c
c mcmfi2 : mode de fonctionnement de l'indicateur d'erreur - 2
c
      character*8 mcmfi2
      parameter ( mcmfi2 = 'CCModeFI' )
c
c 1.5. Les champs a mettre a jour
c================================
c
c mcchno : nom d'un champ de solution a mettre a jour
c
      character*8 mcchno
      parameter ( mcchno = 'CCChaNom' )
c
c mcchti : type d'interpolation
c
      character*8 mcchti
      parameter ( mcchti = 'CCChaTIn' )
c
c mcchpt : numero du pas de temps d'un champ de solution a mettre a jour
c
      character*8 mcchpt
      parameter ( mcchpt = 'CCChaPdT' )
c
c mcchnu : numero d'ordre d'un champ de solution a mettre a jour
c
      character*8 mcchnu
      parameter ( mcchnu = 'CCChaNuO' )
c
c mcchin : instant d'un champ de solution a mettre a jour
c
      character*8 mcchin
      parameter ( mcchin = 'CCChaIns' )
c
c mcchcs : caracteristique du support d'un champ de solution a mettre
c          a jour
c
      character*8 mcchcs
      parameter ( mcchcs = 'CCChaCaS' )
c
c mcchnc : numero du champ aux noeuds par element associe
c
      character*8 mcchnc
      parameter ( mcchnc = 'CCChaNCN' )
c
c mcchto : mise a jour de tous les champs de solution
c
      character*8 mcchto
      parameter ( mcchto = 'CCChaTou' )
c
c 1.6. Les informations complementaires
c======================================
c
c mcicni : nom du champ MED qui contiendra le niveau
c
      character*8 mcicni
      parameter ( mcicni = 'NCNiveau' )
c
c mcicqu : nom du champ MED qui contiendra la qualite
c
      character*8 mcicqu
      parameter ( mcicqu = 'NCQualit' )
c
c mcicdi : nom du champ MED qui contiendra le diametre
c
      character*8 mcicdi
      parameter ( mcicdi = 'NCDiamet' )
c
c mcicpa : nom du champ MED qui contiendra la parente
c
      character*8 mcicpa
      parameter ( mcicpa = 'NCParent' )
c
c mcicvr : nom du champ MED qui contiendra les voisins des recollements
c
      character*8 mcicvr
      parameter ( mcicvr = 'NCVoisRc' )
c
c 2. Les objets HOMARD
c=====================
c
c 2.1. Les maillages au format HOMARD
c====================================
c
c mchman : maillage a l'iteration n
c
      character*8 mchman
      parameter ( mchman = 'HOMaiN__' )
c
c mchmap : maillage a l'iteration n+1
c
      character*8 mchmap
      parameter ( mchmap = 'HOMaiNP1' )
c
c 2.2. L'indicateur au format HOMARD
c===================================
c
c mchind : indicateur a l'iteration n
c
      character*8 mchind
      parameter ( mchind = 'HOIndica' )
c
c 2.3. Les utilitaires
c=====================
c
c mcauxi : mot-cle auxiliaire
c          il sert pour des operations de test
c
      character*8 mcauxi
      parameter ( mcauxi = 'MCAuxili' )
c
c  La liste qui suit decrit les mots-cles reconnus pour reperer
c  deux objets a comparer, par exemple
c
c mcobj1 : objet numero 1
c
      character*8 mcobj1
      parameter ( mcobj1 = 'Objet__1' )
c
c mcobj2 : objet numero 2
c
      character*8 mcobj2
      parameter ( mcobj2 = 'Objet__2' )
c
c 3. Les options de pilotage
c===========================
c
c 3.1. les options generales
c===========================
c
c mcmoho : mode de fonctionnement de HOMARD
c
      character*8 mcmoho
      parameter ( mcmoho = 'ModeHOMA' )
c
c mcecfh : ecriture des fichiers au format HOMARD
c
      character*8 mcecfh
      parameter ( mcecfh = 'EcriFiHO' )
c
c mctyel : type d'elements autorises
c
      character*8 mctyel
      parameter ( mctyel = 'TypeElem' )
c
c 3.2. les options de l'adaptation
c=================================
c 3.2.1. l'iteration
c-------------------
c
c mcnuit : numero d'iteration du maillage avant adaptation
c
      character*8 mcnuit
      parameter ( mcnuit = 'NumeIter' )
c
c 3.2.2. le raffinement
c----------------------
c
c mctyco : type de conformite
c
      character*8 mctyco
      parameter ( mctyco = 'TypeConf' )
c
c mctyra : type de raffinement
c
      character*8 mctyra
      parameter ( mctyra = 'TypeRaff' )
c
c mcnvma : niveau maximum pour le raffinement
c
      character*8 mcnvma
      parameter ( mcnvma = 'NiveauMa' )
c
c mcnbme : nombre maximum d'elements apres raffinement
c
      character*8 mcnbme
      parameter ( mcnbme = 'NbrMaxEl' )
c
c mccora : contraintes de raffinement
c
      character*8 mccora
      parameter ( mccora = 'ContRaff' )
c
c mcseuh : seuil haut absolu pour le raffinement
c
      character*8 mcseuh
      parameter ( mcseuh = 'SeuilHau' )
c
c mcserh : seuil haut relatif pour le raffinement
c
      character*8 mcserh
      parameter ( mcserh = 'SeuilHRe' )
c
c mcseph : seuil haut en pourcentage pour le raffinement
c
      character*8 mcseph
      parameter ( mcseph = 'SeuilHPE' )
c
c mcsesh : seuil haut en mu+n.sigma pour le raffinement
c
      character*8 mcsesh
      parameter ( mcsesh = 'SeuilHMS' )
c
c mcdimi : diametre minimum pour le raffinement
c
      character*8 mcdimi
      parameter ( mcdimi = 'DiametMi' )
c
c 3.2.3. le deraffinement
c----------------------
c
c mctyde : type de deraffinement
c
      character*8 mctyde
      parameter ( mctyde = 'TypeDera' )
c
c mcnvmi : niveau minimum pour le deraffinement
c
      character*8 mcnvmi
      parameter ( mcnvmi = 'NiveauMi' )
c
c mcseub : seuil bas absolu pour le deraffinement
c
      character*8 mcseub
      parameter ( mcseub = 'SeuilBas' )
c
c mcserb : seuil bas relatif pour le deraffinement
c
      character*8 mcserb
      parameter ( mcserb = 'SeuilBRe' )
c
c mcsepb : seuil bas en pourcentage pour le deraffinement
c
      character*8 mcsepb
      parameter ( mcsepb = 'SeuilBPE' )
c
c mcsesb : seuil bas en mu-n.sigma pour le deraffinement
c
      character*8 mcsesb
      parameter ( mcsesb = 'SeuilBMS' )
c
c 3.2.4. les zones de raffinement
c--------------------------------
c
c mczrty : type de la zone de raffinement
c
      character*8 mczrty
      parameter ( mczrty = 'ZoRaType' )
c
c mcrxmi : zone a raffiner : x mini
c
      character*8 mcrxmi
      parameter ( mcrxmi = 'ZoRaXmin' )
c
c mcrxma : zone a raffiner : x maxi
c
      character*8 mcrxma
      parameter ( mcrxma = 'ZoRaXmax' )
c
c mcrymi : zone a raffiner : y mini
c
      character*8 mcrymi
      parameter ( mcrymi = 'ZoRaYmin' )
c
c mcryma : zone a raffiner : y maxi
c
      character*8 mcryma
      parameter ( mcryma = 'ZoRaYmax' )
c
c mcrzmi : zone a raffiner : z mini
c
      character*8 mcrzmi
      parameter ( mcrzmi = 'ZoRaZmin' )
c
c mcrzma : zone a raffiner : y maxi
c
      character*8 mcrzma
      parameter ( mcrzma = 'ZoRaZmax' )
c
c mcrxce : zone a raffiner : x du centre
c
      character*8 mcrxce
      parameter ( mcrxce = 'ZoRaXCen' )
c
c mcryce : zone a raffiner : y du centre
c
      character*8 mcryce
      parameter ( mcryce = 'ZoRaYCen' )
c
c mcrzce : zone a raffiner : z du centre
c
      character*8 mcrzce
      parameter ( mcrzce = 'ZoRaZCen' )
c
c mcrxba : zone a raffiner : x de la base
c
      character*8 mcrxba
      parameter ( mcrxba = 'ZoRaXBas' )
c
c mcryba : zone a raffiner : y de la base
c
      character*8 mcryba
      parameter ( mcryba = 'ZoRaYBas' )
c
c mcrzba : zone a raffiner : z de la base
c
      character*8 mcrzba
      parameter ( mcrzba = 'ZoRaZBas' )
c
c mcrhau : zone a raffiner : hauteur
c
      character*8 mcrhau
      parameter ( mcrhau = 'ZoRaHaut' )
c
c mcrxax : zone a raffiner : x de l'axe
c
      character*8 mcrxax
      parameter ( mcrxax = 'ZoRaXAxe' )
c
c mcryax : zone a raffiner : y de l'axe
c
      character*8 mcryax
      parameter ( mcryax = 'ZoRaYAxe' )
c
c mcrzax : zone a raffiner : z de l'axe
c
      character*8 mcrzax
      parameter ( mcrzax = 'ZoRaZAxe' )
c
c mcrray : zone a raffiner : rayon
c
      character*8 mcrray
      parameter ( mcrray = 'ZoRaRayo' )
c
c mcrrai : zone a raffiner : rayon interieur
c
      character*8 mcrrai
      parameter ( mcrrai = 'ZoRaRayI' )
c
c mcrrae : zone a raffiner : rayon exterieur
c
      character*8 mcrrae
      parameter ( mcrrae = 'ZoRaRayE' )
c
c 3.2.5. les groupes pour l'adaptation
c-------------------------------------
c
c mcgrad : groupes ou a lieu l'adaptation
c
      character*8 mcgrad
      parameter ( mcgrad = 'CCGroAda' )
c
c 3.2.6. l'initialisation
c-------------------------------------
c
c mcinad : initialisation de l'adaptation
c
      character*8 mcinad
      parameter ( mcinad = 'AdapInit' )
c
c 3.2.7. la cible en nombre de sommets
c------------------------------------
c
c mcpacm : nombre de passages maximum pour atteindre la cible
c
      character*8 mcpacm
      parameter ( mcpacm = 'CiblePaM' )
c
c mcnbsc : nombre de sommets cible
c
      character*8 mcnbsc
      parameter ( mcnbsc = 'CibleNbS' )
c
c 3.3. liens avec le code de calcul
c==================================
c
c mcccas : code de calcul associe
c
      character*8 mcccas
      parameter ( mcccas = 'CCAssoci' )
c
c mcvman : conversion de maillage a l'iteration n
c
      character*8 mcvman
      parameter ( mcvman = 'CVMaiN__' )
c
c mcvmap : conversion de maillage a l'iteration n+1
c
      character*8 mcvmap
      parameter ( mcvmap = 'CVMaiNP1' )
c
c mcvind : conversion de l'indicateur
c
      character*8 mcvind
      parameter ( mcvind = 'CVIndN__' )
c
c mcvsol : conversion de la solution
c
      character*8 mcvsol
      parameter ( mcvsol = 'CVSolNP1' )
c
c mcsufr : suivi de la frontiere
c
      character*8 mcsufr
      parameter ( mcsufr = 'SuivFron' )
c
c mcgrfr : groupes de la frontiere CAO
c
      character*8 mcgrfr
      parameter ( mcgrfr = 'GrFroCAO' )
c
c mcgrfd : groupes de la frontiere discrete
c
      character*8 mcgrfd
      parameter ( mcgrfd = 'CCGroFro' )
c
c mcfanm : nom de la frontiere analytique
c
      character*8 mcfanm
      parameter ( mcfanm = 'FANom  ' )
c
c mcfaty : type de la frontiere analytique
c
      character*8 mcfaty
      parameter ( mcfaty = 'FAType ' )
c
c mcfaxc : frontiere analytique : x du centre
c
      character*8 mcfaxc
      parameter ( mcfaxc = 'FAXCen  ' )
c
c mcfayc : frontiere analytique : y du centre
c
      character*8 mcfayc
      parameter ( mcfayc = 'FAYCen  ' )
c
c mcfazc : frontiere analytique : z du centre
c
      character*8 mcfazc
      parameter ( mcfazc = 'FAZCen  ' )
c
c mcfaxa : frontiere analytique : x de l'axe
c
      character*8 mcfaxa
      parameter ( mcfaxa = 'FAXAxe  ' )
c
c mcfaya : frontiere analytique : y de l'axe
c
      character*8 mcfaya
      parameter ( mcfaya = 'FAYAxe  ' )
c
c mcfaza : frontiere analytique : z de l'axe
c
      character*8 mcfaza
      parameter ( mcfaza = 'FAZAxe  ' )
c
c mcfara : frontiere analytique : rayon
c
      character*8 mcfara
      parameter ( mcfara = 'FARayon ' )
c
c mcfaxc : frontiere analytique : x du centre numero 2
c
      character*8 mcfax2
      parameter ( mcfax2 = 'FAXCen2 ' )
c
c mcfayc : frontiere analytique : y du centre numero 2
c
      character*8 mcfay2
      parameter ( mcfay2 = 'FAYCen2 ' )
c
c mcfazc : frontiere analytique : z du centre numero 2
c
      character*8 mcfaz2
      parameter ( mcfaz2 = 'FAZCen2 ' )
c
c mcfara : frontiere analytique : rayon numero 2
c
      character*8 mcfar2
      parameter ( mcfar2 = 'FARayon2' )
c
c mcfara : frontiere analytique : angle
c
      character*8 mcfaan
      parameter ( mcfaan = 'FAAngle ' )
c
c mcfgfr : nom de la frontiere liee a un groupe
c
      character*8 mcfgfr
      parameter ( mcfgfr = 'FGNomFro' )
c
c mcfggr : nom du groupe lie a une frontiere
c
      character*8 mcfggr
      parameter ( mcfggr = 'FGNomGro' )
c
c mctybi : type de bilan sur le maillage
c
      character*8 mctybi
      parameter ( mctybi = 'TypeBila' )
c
c mcmext : le maillage est un maillage extrude
c
      character*8 mcmext
      parameter ( mcmext = 'M_Extrud' )
c
c mccex1 : choix de la gestion de la coordonnee constante pour
c          les maillages extrudes
c
      character*8 mccex1
      parameter ( mccex1 = 'Coo_Extr' )
c
c mccex2 : valeur du delta de coordonnee si impose
c
      character*8 mccex2
      parameter ( mccex2 = 'DC_impos' )
c
c 3.4. les options de la modification de maillage
c================================================
c
c mcmdeg : modification du degre du maillage (1<->2)
c
      character*8 mcmdeg
      parameter ( mcmdeg = 'ModDegre' )
c
c mcjoin : creation de joint entre des groupes de volumes
c
      character*8 mcjoin
      parameter ( mcjoin = 'CreJoint' )
c
c 4. la memoire
c==============
c
c mcmogm : mode de gestion de la memoire
c
      character*8 mcmogm
      parameter ( mcmogm = 'ModeGM  ' )
c
c mcgmen : nombre d'entiers en statique
c
      character*8 mcgmen
      parameter ( mcgmen = 'ModeGMEN' )
c
c mcgmre : nombre de reels en statique
c
      character*8 mcgmre
      parameter ( mcgmre = 'ModeGMRE' )
c
c mcgmc8 : nombre de caracteres8 en statique
c
      character*8 mcgmc8
      parameter ( mcgmc8 = 'ModeGMC8' )
c
c mcgmco : nombre de complexes en statique
c
      character*8 mcgmco
      parameter ( mcgmco = 'ModeGMCO' )
c
c mcgmsi : nombre de reels simple precision en statique
c
      character*8 mcgmsi
      parameter ( mcgmsi = 'ModeGMSI' )
c
c mcgmta : type d'arret de la gestion de la memoire
c
      character*8 mcgmta
      parameter ( mcgmta = 'ModeGMTA' )
c
c 5. Autres options de pilotage
c==============================
c
c mcguta : type d'arret de la gestion des unites logiques
c
      character*8 mcguta
      parameter ( mcguta = 'ModeGUTA' )
c
c mclang : la langue des messages
c
      character*8 mclang
      parameter ( mclang = 'Langue  ' )
c
c mcppty : type de post-processeur
c
      character*8 mcppty
      parameter ( mcppty = 'PPType  ' )
c
c mcrepi : repertoire de travail pour les fichiers d'information
c
      character*8 mcrepi
      parameter ( mcrepi = 'RepeInfo' )
c
c mcacti : l'action en cours
c
      character*8 mcacti
      parameter ( mcacti = 'Action  ' )
c
c mcinfo : les informations a ecrire
c
      character*8 mcinfo
      parameter ( mcinfo = 'MessInfo' )
