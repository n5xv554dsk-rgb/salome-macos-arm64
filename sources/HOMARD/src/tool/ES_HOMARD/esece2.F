      subroutine esece2 ( typenh, nbencf, nbenca, nbrfma,
     >                    somare, codeen, infosu, codear,
     >                    tbiaux,
     >                    ulsort, langue, codret )
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
c  Entree-Sortie : ECriture d'une Entite - 2
c  -      -        --             -        -
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typenh . e   .   1    . code des entites                           .
c .        .     .        .  -1 : noeuds                               .
c .        .     .        .   0 : mailles-points                       .
c .        .     .        .   1 : aretes                               .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   3 : tetraedres                           .
c .        .     .        .   4 : quadrangles                          .
c .        .     .        .   5 : pyramides                            .
c .        .     .        .   6 : hexaedres                            .
c .        .     .        .   7 : pentaedres                           .
c . nbencf . e   .   1    . nombre d'entites decrites par faces        .
c . nbenca . e   .   1    . nombre d'entites decrites par aretes       .
c . nbrfma . e   .   1    . nbre faces par maille                      .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . codeen . e   .nbencf**. connectivite descendante des mailles       .
c . infosu . e   .nbencf**. code des faces dans les mailles 3D         .
c . codear . e   .nbenca**. connectivite des mailles par aretes        .
c . tbiaux .  s  .    *   . tableau tampon entier                      .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
      parameter ( nompro = 'ESECE2' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "fahmed.h"
#include "oriett.h"
#include "orieqh.h"
#include "oriefp.h"
#include "oriefy.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer typenh
      integer nbencf, nbenca, nbrfma
      integer somare(2,*)
      integer codeen(nbencf,*), infosu(nbencf,*), codear(nbenca,*)
      integer tbiaux(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux, jaux, kaux, laux
      integer orient(8)
      integer aret(4)
c
      integer nbmess
      parameter ( nbmess = 100 )
      character*80 texte(nblang,nbmess)
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
      texte(1,4) = '(''... Conversion des '',i10,1x,a)'
c
      texte(2,4) = '(''... Conversion of '',i10,1x,a)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbencf, mess14(langue,3,typenh)
      write (ulsort,90002) 'nbencf', nbencf
      write (ulsort,90002) 'nbenca', nbenca
#endif
c
c====
c 2. Mise en place de la connectivite descendante
c====
c
      if ( codret.eq.0 ) then
c
      kaux = 0
c
c 2.1. ==> Triangles
c
      if ( typenh.eq.2 ) then
c
        do 221 , iaux = 1, nbencf
          do 2211, jaux = 1, nbrfma
            aret(jaux) = codeen(iaux,jaux)
 2211     continue
cgn          write(ulsort,*)aret
          call utorat ( somare, aret(1), aret(2), aret(3),
     >                  orient(1), orient(2), orient(3) )
cgn          write(ulsort,*)(orient(jaux),jaux = 1, nbrfma)
          do 2212, jaux = 1, nbrfma
            kaux = kaux + 1
            tbiaux(kaux) = orient(jaux)*aret(jaux)
 2212     continue
  221   continue
c
c 2.3. ==> Tetraedres
c
      elseif ( typenh.eq.3 ) then
c
cgn            write(ulsort,*) typenh
        do 231 , iaux = 1, nbencf
          do 2311, jaux = 1, nbrfma
            laux = nofmed(typenh,jaux,1)
cgn          write(ulsort,*) jaux,laux
            orient(jaux) = orcott(laux,infosu(iaux,laux))
cgn          write(ulsort,*) laux, codeen(iaux,laux), orient(jaux)
            kaux = kaux + 1
            tbiaux(kaux) = orient(jaux)*codeen(iaux,laux)
 2311     continue
  231   continue
c
c 2.4. ==> Quadrangles
c
      elseif ( typenh.eq.4 ) then
c
        do 241 , iaux = 1, nbencf
          do 2411, jaux = 1, nbrfma
            aret(jaux) = codeen(iaux,jaux)
 2411     continue
cgn          write(ulsort,*)aret
          call utoraq ( somare, aret(1), aret(2), aret(3), aret(4),
     >                  orient(1), orient(2), orient(3), orient(4) )
cgn          write(ulsort,*)(orient(jaux),jaux = 1, nbrfma)
          do 2412, jaux = 1, nbrfma
            kaux = kaux + 1
            tbiaux(kaux) = orient(jaux)*aret(jaux)
 2412     continue
  241   continue
c
c 2.5. ==> Pyramides
c
      elseif ( typenh.eq.5 ) then
c
        do 251 , iaux = 1, nbencf
          do 2511, jaux = 1, nbrfma
            laux = nofmed(typenh,jaux,1)
            orient(jaux) = orcofy(laux,infosu(iaux,laux))
cgn          write(ulsort,*) laux, codeen(iaux,laux), orient(jaux)
            kaux = kaux + 1
            tbiaux(kaux) = orient(jaux)*codeen(iaux,laux)
 2511     continue
  251   continue
c
c 2.6. ==> Hexaedres
c
      elseif ( typenh.eq.6 ) then
c
        do 261 , iaux = 1, nbencf
          do 2611, jaux = 1, nbrfma
            laux = nofmed(typenh,jaux,1)
            orient(jaux) = orcoqh(laux,infosu(iaux,laux))
cgn          write(ulsort,*) laux, codeen(iaux,laux), orient(jaux)
            kaux = kaux + 1
            tbiaux(kaux) = orient(jaux)*codeen(iaux,laux)
 2611     continue
  261   continue
c
c 2.7. ==> Pentaedres
c
      elseif ( typenh.eq.7 ) then
c
        do 271 , iaux = 1, nbencf
          do 2711, jaux = 1, nbrfma
            laux = nofmed(typenh,jaux,1)
            orient(jaux) = orcofp(laux,infosu(iaux,laux))
cgn          write(ulsort,*) laux, codeen(iaux,laux), orient(jaux)
            kaux = kaux + 1
            tbiaux(kaux) = orient(jaux)*codeen(iaux,laux)
 2711     continue
  271   continue
c
c
      else
c
c 2.8. ==> Probleme
c
        codret = 28
c
      endif
c
      endif
c
c====
c 3. Quand il peut y avoir une description par arete, on complete
c    le tableau avec les premieres valeurs de la connectivite
c    pour optimiser le remplissage et utiliser le dimensionnement
c    habituel des entites, nbento
c    Une entite a nbrfac faces et nbrare aretes.
c    La connectivite descendante ecrite dans le fichier med
c    est dimensionnee a nbento*nbrfac.
c    Dans esece2, on remplit donc le tableau avec deux parties :
c    . La connectivite descendante proprement dite, soit
c      nbencf*nbrfac variables.
c    . La connectivite par aretes des nbenca entites decrites, en
c      se limitant aux nbrfac premieres, soit nbenca*nbrfac
c      variables.
c    Cela fait bien en tout nbento*nbrfac = (nbencf+nbenca)*nbrfac
c    On ecrit dans esecs5 la fin des descriptions par aretes,
c    donc au dela de la nbrfac-ieme.
c    Exemple : les pyramides sont decrites par 5 faces ou 8 aretes.
c    Pour toutes celles decrites par aretes, on met ici les numeros
c    de leurs 5 premieres aretes. Les autres seront geres avec les
c    profils dans esecs5
c    La lecture est faite dans eslee1.
c====
c
      if ( nbenca.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
        do 31 , iaux = 1, nbenca
c
          do 311, jaux = 1, nbrfma
            kaux = kaux + 1
            tbiaux(kaux) = codear(iaux,jaux)
  311     continue
c
   31   continue
c
        endif
c
      endif
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
