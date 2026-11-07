c
c nndoad : nom de la structure qui contient les donnees de l'adaptation
c          elle est de type DonnAdap
c          elle est allouee dans utindh
c=======================================================================
c
c  Attributs :
c   1 : longueur du tableau d'entiers associe au champ OptEnt
c   2 : longueur du tableau de reels associe au champ OptRee
c   3 : longueur du tableau de caracteres associe au champ OptCar
c   4 : longueur du tableau d'entiers associe au champ EtatCour
c   5 : type de programme : 1 : homard complet
c                           2 : interface avant adaptation
c                           3 : adaptation
c                           4 : suivi de frontiere
c                           5 : interface apres adaptation
c                           6 : information
c
c=======================================================================
c
c 1. Champ OptEnt : liste des options entieres
c c'est un tableau d'entiers ou l'on trouve dans l'ordre :
c
c   1 : langue des messages
c   2 : libre
c   3 : type de bilan sur le maillage
c       c'est le produit des options suivantes :
c       2 : nombre d'entites HOMARD  3 : interpenetration des mailles
c       5 : qualite des mailles      7 : nombre d'entites du calcul
c      11 : connexite               13 : tailles des sous-domaines
c      17 : proprietes des elements du calcul
c      19 : diametre des mailles
c       Par defaut : 7, sauf pour le module d'adaptation pure : 2
c       Si 0, on ne fait rien.
c       Pour l'adaptation, on ne fait le bilan avant adaptation que si
c       le type de bilan est negatif
c   4 : mode de fonctionnement de HOMARD
c       1 : adaptation complete (defaut) 2 : information
c       3 : modification de maillage     4 : interpolation de solution
c       5 : mise a jour des coordonnees
c   5 : ecriture des fichiers au format HOMARD
c       c'est le produit des options suivantes :
c       2 : pour le maillage n  3 : pour le maillage n+1 (defaut)
c       >0 : avec la frontiere discrete, <0 : sans la frontiere discrete
c   6 : type de donnees des seuils d'erreur haut :
c      -1 : probleme                  0 : pas de donnees (defaut)
c       1 : en absolu                 2 : en relatif
c       3 : en pourcentage d'entites  4 : en mu+n.sigma
c       5 : cible en nombre de noeuds
c   7 : type de donnees des seuils d'erreur bas :
c      -1 : probleme                  0 : pas de donnees (defaut)
c       1 : en absolu                 2 : en relatif
c       3 : en pourcentage d'entites  4 : en mu-n.sigma
c   8 : usage des composantes multiples de l'indicateur
c       0 : norme L2 (defaut)
c       1 : norme infinie (max des valeurs absolues)
c       2 : valeur relative (si 1 seule composante)
c   9 : ecriture de messages complementaires : c'est le produit de :
c       1 : rien
c       2 : les temps de chaque section
c       3 : les caracteristiques MED des fichiers et de HOMARD
c       5 : les bilans sur la memoire
c
c  10 : numero d'iteration du maillage avant adaptation (-1 par defaut)
c  11 : type de code de calcul associe (-1 par defaut)
c           1 : HOMARD
c           6 : MED
c          16 : ATHENA (format MED)
c          26 : SATURNE_2D (format MED)
c          36 : SATURNE (format MED)
c          46 : NEPTUNE_2D (format MED)
c          56 : NEPTUNE (format MED)
c          66 : CARMEL_2D (format MED)
c          76 : CARMEL (format MED)
c         106 : NON-CONFORME (format MED)
c  12 : type d'informations ecrites sur le fichier med de sortie
c       c'est le produit des options suivantes :
c        2 : niveau des mailles       3 : qualite des mailles
c        5 : diametre des mailles     7 : parente
c       11 : voisin des recollements
c       Par defaut : 1
c       Si 0 ou 1, on ne fait rien.
c  13 : numero de pas de temps (eventuel) lie a l'indicateur d'erreur
c  14 : numero d'ordre (eventuel) lie a l'indicateur d'erreur
c  15 : -2, aucun numero de pas de temps n'a ete fourni pour
c          l'indicateur
c       1, un numero de pas de temps est fourni
c       2, on prend le dernier pas de temps
c  16 : -2, aucun numero d'ordre n'a ete fourni pour l'indicateur
c       1, un numero est fourni
c  17 : -2, aucune valeur d'instant n'a ete fournie pour
c          l'indicateur
c       1, une valeur d'instant est fournie
c       2, on prend le dernier instant
c  18 : 0, l'indicateur est utilise pour sa valeur dans chaque
c          maille (defaut)
c       1, l'indicateur est utilise pour le saut entre 2 mailles
c  19 : nombre de groupes de filtrage de l'adaption
c  20 : nombre de tableaux a lire pour mise a jour
c      -1 : tous
c       0 : aucun (defaut)
c      >0 : certains
c
c  Pour les options de 21 a 28 : 1=oui, 0=non
c  21 : conversion du maillage a l'iteration n
c  22 : conversion du maillage a l'iteration n+1
c  27 : conversion de l'indicateur l'iteration n
c  28 : conversion de la solution a l'iteration n+1
c  29 : suivi de frontiere : c'est le produit de :
c       1 : rien
c       2 : presence de frontieres discretes par groupe
c       3 : presence de frontieres analytiques
c       5 : frontieres par la CAO
c       remarque : (2/3) et 5 sont incompatibles
c
c  30 : mode de conformite
c       0 : conforme (defaut)
c       1 : non-conforme avec au minimum 2 aretes non decoupees en 2
c           par face (triangle ou quadrangle)
c       2 : non-conforme avec 1 seul noeud pendant par arete
c       3 : non-conforme fidele a l'indicateur
c      -1 : conforme, avec des boites pour les quadrangles, hexaedres
c           et pentaedres
c      -2 : non-conforme avec au maximum 1 arete decoupee en 2 et des
c           boites pour les quadrangles, hexaedres et pentaedres
c  31 : raffinement
c      -1 : raffinement uniforme
c       0 : pas de raffinement
c       1 : raffinement libre (defaut)
c       2 : raffinement libre homogene en type de maille
c  32 : deraffinement
c      -1 : deraffinement uniforme
c       0 : pas de deraffinement
c       1 : deraffinement libre (defaut)
c  33 : niveau maximum
c  34 : niveau minimum
c  35 : nombre maximum de mailles (0 par defaut, c'est-a-dire libre)
c  36 : contraintes de raffinement : c'est le produit de :
c       1 : pas de contraintes (defaut)
c       2 : decalage de deux mailles avant un changement de niveau
c       3 : bande de raffinement interdite
c       5 : pas de mailles decoupees sans leurs voisines de
c           dimension superieure
c  37 : nombre de zones a raffiner
c       si negatif, les zones sont 2D (en x et y)
c  38 : initialisation de l'adaptation
c       0 : on garde tout (defaut)
c       1 : reactivation des mailles ou aucun indicateur n'est defini
c  39 : maillage extrude
c       0 : non (defaut)
c       1 : selon X
c       2 : selon Y
c       3 : selon Z (cas de Saturne ou Neptune)
c  40 : calcul des coordonnees pour les maillages extrudes :
c       1 : coordonnees initiales (defaut)
c       2 : valeur imposee
c       3 : moyenne arithmetique des mini/maxi en (x,y) des mailles
c       4 : moyenne geometrique des mini/maxi en (x,y) des mailles
c       5 : ecart initial, divise par 2**nivsup
c
c  Pour les modifications de maillage :
c  41 : changement de degre : 1=oui, 0=non (defaut)
c  42 : creation de joints  : 1=oui, 0=non (defaut)
c
c  Pour la cible en nombre de noeuds :
c  43 : nombre de passages maximum : 50 par defaut
c  44 : cible en nombre de noeuds : -1 si non concerne (defaut)
c  45 : cible en nombre de mailles : -1 si non concerne (defaut)
c
c  49 : types de mailles acceptes
c       s'il existe des mailles incompatibles avec l'usage de HOMARD
c       0 : on bloque (defaut)
c       1 : on les reproduit telles quelles
c  50 : type de maillage a ecrire
c       1 : maillage apres adaptation
c       2 : maillage annexe apres adaptation
c
c=======================================================================
c
c 2. Champ OptRee : liste des options reelles
c c'est un tableau de reels ou l'on trouve dans l'ordre :
c
c   1 : seuil haut (absolu, relatif ou pourcentage selon le cas)
c   2 : seuil bas (absolu, relatif ou pourcentage selon le cas)
c   3 : diametre minimal de maille pour le raffinement
c   4 : valeur imposee pour le deltaZ de Saturne ou Neptune 2D
c  10 : instant (eventuel) lie a l'indicateur d'erreur
c
c  Pour les options de 11 a 16 : les limites de la zone a raffiner
c  11 : xmin
c  12 : xmax
c  13 : ymin
c  14 : ymax
c  15 : zmin
c  16 : zmax
c
c=======================================================================
c
c 3. Champ OptCar : liste des noms d'objets intermediaires
c c'est un tableau de caracteres*8 ou l'on trouve dans l'ordre :
c
c   1 : nom du maillage externe a l'iteration n
c   2 : nom du maillage externe a l'iteration n+1
c   3 : nom du maillage HOMARD a l'iteration n
c   4 : nom du maillage HOMARD a l'iteration n+1
c   5 : nom du maillage annexe a l'iteration n+1
c   7 : nom de l'indicateur externe a l'iteration n
c   8 : nom de l'indicateur au format homard
c   9 : nom de la solution externe a l'iteration n
c  10 : nom de la solution externe a l'iteration n+1
c  11 : nom du tableau des decisions sur les aretes
c  12 : nom du tableau des decisions sur les triangles
c  14 : nom des sauvegardes du maillage homard a l'iteration n
c  15 : nom des groupes de filtrage sur l'adaptation
c  16 : nom du maillage de la frontiere au format MED
c  17 : definition des frontieres discretes/CAO : nom des groupes
c  18 : nom des champs a mettre a jour
c  19 : definition des zones a raffiner par un critere geometrique
c  20 : specificites aux maillages externes
c  23 : definition des liens groupes/frontieres : nom des frontieres
c  24 : definition des liens groupes/frontieres : nom des groupes
c  25 : definition des frontieres analytiques : nom des frontieres
c  26 : definition des frontieres analytiques : valeurs reelles
c  27 : unites logiques frontieres/groupes
c  28 : structure permettant le filtrage par le diametre minimal
c  29 : structure permettant le filtrage par les groupes
c  30 : action en cours : 'adap', 'info_av', 'info_ap', 'sufr', 'modi'
c  31 : nom de la solution complementaire
c
c=======================================================================
c
c 4. Champ EtatCour : decrit l'etat courant
c c'est un tableau d'entiers ou l'on trouve dans l'ordre :
c
c   1 : numero de l'etape en cours (pour impression)
c   2 : numero de la sous-etape en cours (pour impression)
c   3 : numero de la grande section de mesure de temps en cours
c   4 : numero de la petite section de mesure de temps en cours
c
c=======================================================================
c
      character*8     nndoad
      common /cndoad/ nndoad
