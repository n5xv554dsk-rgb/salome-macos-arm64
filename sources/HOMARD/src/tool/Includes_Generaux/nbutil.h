c
c=======================================================================
c nombres utiles au maillage de calcul
c cela correspond a peu pres a la branche Nombres de l'objet
c Maillage de calcul
c-----------------------------------------------------------------------
c sdimca : dimension de l'espace (2 ou 3)
c mdimca : dimension du maillage (1, 2 ou 3)
c nbelem : nombre d'elements dans le maillage
c nbmaae : nombre maximum d'aretes par element
c nbmafe : nombre maximum de faces par element
c nbmnei : nombre maximum de noeuds par element elimine
c nbmapo : nombre de mailles-points dans le maillage
c nbsegm : nombre de segments dans le maillage
c nbtria : nombre de triangles dans le maillage
c nbtetr : nombre de tetraedres dans le maillage
c nbquad : nombre de quadrangles dans le maillage
c nbhexa : nombre d'hexaedres dans le maillage
c nbpent : nombre de pentaedres dans le maillage
c nbpyra : nombre de pyramides dans le maillage
c nbelig : nombre d'elements a eliminer de l'adaptation
c numael : numero maximum d'element dans le maillage
c numano : numero maximum de noeud dans le maillage
c nbma2d : nombre total de mailles 2D
c nbma3d : nombre total de mailles 3D
c nvoare : nombre cumule d'elements voisins d'aretes du maillage
c nvosom : nombre cumule d'elements voisins des sommets du maillage
c nbfmed : nombre total de familles MED pour toutes les entites
c nbfmen : nombre de familles MED pour les noeuds
c ngrouc : nombre de groupes cumules dans les familles
c nbequi : nombre total d'equivalences
c nbeqno : nombre total de paires equivalentes de noeuds
c nbeqmp : nombre total de paires equivalentes de mailles-points
c nbeqar : nombre total de paires equivalentes d'aretes
c nbeqtr : nombre total de paires equivalentes de triangles
c nbeqqu : nombre total de paires equivalentes de quadrangles
c nbeqte : nombre total de paires equivalentes de tetraedres
c nbeqhe : nombre total de paires equivalentes d'hexaedres
c-----------------------------------------------------------------------
      integer         sdimca, mdimca,
     >                nbelem, nbmaae, nbmafe,  nbmnei,
     >                nbmapo, nbsegm, nbtria, nbtetr,
     >                nbquad, nbhexa, nbpent, nbpyra, nbelig,
     >                nbma2d, nbma3d,
     >                numael, numano, nvoare, nvosom,
     >                nbfmed, nbfmen, ngrouc,
     >                nbequi, nbeqno, nbeqmp, nbeqar, nbeqtr, nbeqqu,
     >                nbeqte, nbeqhe
      common /nbutil/ sdimca, mdimca,
     >                nbelem, nbmaae, nbmafe, nbmnei,
     >                nbmapo, nbsegm, nbtria, nbtetr,
     >                nbquad, nbhexa, nbpent, nbpyra, nbelig,
     >                nbma2d, nbma3d,
     >                numael, numano, nvoare, nvosom,
     >                nbfmed, nbfmen, ngrouc,
     >                nbequi, nbeqno, nbeqmp, nbeqar, nbeqtr, nbeqqu,
     >                nbeqte, nbeqhe
