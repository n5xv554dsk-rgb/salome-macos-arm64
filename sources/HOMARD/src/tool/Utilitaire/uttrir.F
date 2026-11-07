      subroutine uttrir ( classt, vmin, vmax,
     >                    nbval, valeur,
     >                    ulsort, langue, codret)
c ______________________________________________________________________
c
c                             H O M A R D
c
c Outil de Maillage Adaptatif par Raffinement et Deraffinement d'EDF R&D
c
c Version originale enregistree le 18 juin 1996 sous le numero 96036
c aupres des huissiers de justice Simart et Lavoir a Clamart
c Version 11.2 enregistree le 13 fevrier 2015 sous le numero 2015/014
c aupres des huissiers de justice
c Lavoir, Silinski & Cherqui-Abrahmi a Clamart
c
c    HOMARD est une marque deposee d'Electricite de France
c
c Copyright EDF 1996
c Copyright EDF 1998
c Copyright EDF 2002
c Copyright EDF 2020
c ______________________________________________________________________
c
c    UTilitaire - TRI d'un tableau Reel
c    --           ---              -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . classt .  s  . nbval  . classement des numeros associes aux valeurs.
c .        .     .        . 1 : le numero de la plus petite valeur     .
c .        .     .        . nbval : le numero de la plus grande valeur .
c . vmin   .  s  .   1    . valeur minimale atteinte                   .
c . vmax   .  s  .   1    . valeur maximale atteinte                   .
c . nbval  . e   .   1    . nombre de valeurs a traiter                .
c . valeur . e   . nbval  . liste des valeurs a ranger                 .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c ______________________________________________________________________
c
c====
c 0. declarations et dimensionnement
c====
c
c 0.1. ==> generalites
c
      implicit none
      save
c
      character*6 nompro
      parameter ( nompro = 'UTTRIR' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nbval
      integer classt(nbval)
c
      double precision valeur(nbval), vmin, vmax
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer numero, nbvtri
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Tri d''''un tableau reel.'')'
      texte(1,5) = '(''Nombre de valeurs a trier :'',i13)'
      texte(1,6) = '(''Valeur minimale :'',g13.7)'
      texte(1,7) = '(''Valeur maximale :'',g13.7)'
c
      texte(2,4) = '(''Sort of a real array.'')'
      texte(2,5) = '(''Number of valeurs to sort :'',i13)'
      texte(2,6) = '(''Minimum value :'',g13.7)'
      texte(2,7) = '(''Maximum value :'',g13.7)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
      write (ulsort,texte(langue,5)) nbval
 1000 format (a,'(',i13,') = ',g13.8)
 1001 format (a,'(',g13.8,') = ',g13.8)
#endif
c
c====
c 2. Tri
c====
c
      nbvtri = 0
c
      do 21 , iaux = 1 , nbval
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,1000) 'valeur',iaux, valeur(iaux)
#endif
c
c 2.1. ==> recherche de la valeur superieure a la courante parmi
c          les valeurs deja classees
c
        do 211 , jaux = 1 , nbvtri
#ifdef _DEBUG_HOMARD_
      write (ulsort,1000) '   classt',jaux, classt(jaux)
#endif
          if ( valeur(classt(jaux)).gt.valeur(iaux) ) then
            numero = jaux
            goto 212
          endif
  211   continue
c
        numero = nbvtri + 1
c
c 2.2. ==> insertion de l'element courant a la bonne place dans la liste
c
  212   continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,1001) '   ==> numero',valeur(iaux), numero
#endif
c
        do 213 , jaux = nbvtri, numero, -1
          classt(jaux+1) = classt(jaux)
  213   continue
c
        classt(numero) = iaux
c
        nbvtri = nbvtri + 1
c
   21 continue
c
      vmin = valeur(classt(1))
      vmax = valeur(classt(nbval))
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) vmin
      write (ulsort,texte(langue,7)) vmax
#endif
c
c====
c 4. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
