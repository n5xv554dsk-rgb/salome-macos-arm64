c
c=======================================================================
c environnement de calcul (premiere partie)
c cela correspond aux attributs de l'objet maillage HOMARD
c-----------------------------------------------------------------------
c sdim   : dimension de l'espace (2 ou 3)
c mdim   : dimension du maillage (1, 2 ou 3)
c degre  : degre maximum d'interpolation des variables.
c maconf : conformite du maillage
c          0 : oui
c          1 : non-conforme avec 1 seule arete decoupee (en 2)
c          2 : non-conforme avec 1 seul noeud pendant par arete
c          3 : non-conforme sans contrainte
c         10 : non-conforme sans autre connaissance
c homolo : type de relations par homologues
c          0 : pas d'homologues
c          1 : relations sur les noeuds
c          2 : relations sur les noeuds et les aretes
c          3 : relations sur les noeuds, les aretes et les faces
c hierar : maillage hierarchique
c          0 : non
c          1 : oui
c rafdef : mode de raffinement/deraffinement avant le maillage
c          0 : macro-maillage
c          1 : le maillage est inchange
c          2 : le maillage est issu du raffinement pur
c              d'un autre maillage
c          3 : le maillage est issu du deraffinement
c              pur d'un autre maillage
c          4 : le maillage est issu de raffinement et
c              de deraffinement d'un autre maillage
c         12 : le maillage est un maillage passe de degre 1 a 2
c         21 : le maillage est un maillage passe de degre 2 a 1
c nbmane : nombre maximum de noeuds par element
c typcca : type du code de calcul associe
c           6 : MED
c          16 : ATHENA (format MED)
c          26 : SATURNE_2D (format MED)
c          36 : SATURNE (format MED)
c          46 : NEPTUNE_2D (format MED)
c          56 : NEPTUNE (format MED)
c          66 : CARMEL_2D (format MED)
c          76 : CARMEL (format MED)
c         106 : NON-CONFORME (format MED)
c typsfr : type du suivi de frontiere
c          0 : aucun
c          1 : maillage de degre 1, avec projection des nouveaux sommets
c          2 : maillage de degre 2, seuls les noeuds P1 sont sur la
c              frontiere ; les noeuds P2 restent au milieu des P1
c          3 : maillage de degre 2, les noeuds P2 sont sur la frontiere
c maextr : maillage extrude
c          0 : non
c          1 : selon X
c          2 : selon Y
c          3 : selon Z
c mailet : presence de mailles etendues :
c          1 : aucune
c         2x : TRIA7
c         3x : QUAD9
c         5x : HEXA27
c-----------------------------------------------------------------------
      integer           sdim,   mdim, degre, maconf, homolo, hierar,
     >                rafdef, nbmane, typcca, typsfr, maextr,
     >                mailet
      common /envca1/   sdim,   mdim, degre, maconf, homolo, hierar,
     >                rafdef, nbmane, typcca, typsfr, maextr,
     >                mailet
