      subroutine decr02 ( decfac, decare,
     >                    somare,
     >                    filare, merare, hetare,
     >                    posifa, facare,
     >                    hettri, aretri, nivtri,
     >                    voltri,
     >                    hetqua, arequa, nivqua,
     >                    list1f, bornoe, borare, list2f,
     >                    afaire,
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
c traitement des DEcisions - Contraintes de Raffinement - 02
c                --          -              -             --
c    Decalage de deux mailles avant un changement de niveau
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . decfac . es  . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . decare . es  . nbarto . decisions des aretes                       .
c . somare . e   .nbarto*2. numeros des extremites d'arete             .
c . filare . e   . nbarto . fille ainee de chaque arete                .
c . merare . e   . nbarto . mere de chaque arete                       .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . nivtri . e   . nbtrto . niveau des triangles                       .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . nivqua . e   . nbquto . niveau des quadrangles                     .
c . list1f . aux . nbquto/. auxiliaire sur les faces (quad. + tri.)    .
c .        .     . nbtrto .                                            .
c . bornoe . aux . nbnoto . auxiliaire sur les noeuds                  .
c . borare . aux . nbarto . auxiliaire sur les aretes                  .
c . afaire . es  .    1   . que faire a la sortie                      .
c .        .     .        . 0 : aucune action                          .
c .        .     .        . 1 : refaire une iteration de l'algorithme  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . sinon : probleme                           .
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
      parameter ( nompro = 'DECR02' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "impr02.h"
#include "ope1a4.h"
c
c 0.3. ==> arguments
c
      integer decfac(-nbquto:nbtrto), decare(0:nbarto)
      integer somare(2,nbarto)
      integer hetare(nbarto), filare(nbarto), merare(nbarto)
      integer posifa(0:nbarto), facare(nbfaar)
      integer hettri(nbtrto), aretri(nbtrto,3), nivtri(nbtrto)
      integer voltri(2,nbtrto)
      integer hetqua(nbquto), arequa(nbquto,4), nivqua(nbquto)
      integer list1f(2,*), bornoe(*), borare(*), list2f(*)
      integer afaire
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer ipos
      integer iaux, ideb, ifin
      integer laface, faced, etatfa
      integer larelo, lardeb, larfin, larete, iface
      integer option, nbento, nbaret
      integer nbfac1, nbfac2
      integer nbnobo, nbar2d, nbar3d
c
      integer nbmess
      parameter ( nbmess = 30 )
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
      texte(1,4) = '(5x,''Au moins 2 mailles entre 2 niveaux.'')'
      texte(1,5) = '(7x,''Nombre de faces a reconsiderer :'',i6,/)'
c
      texte(2,4) = '(5x,''A least 2 meshes between 2 levels.'')'
      texte(2,5) = '(7x,''Number of faces to deal with :'',i6,/)'
c
#include "impr03.h"
c
#include "derco1.h"
c
      codret = 0
c
      write (ulsort,texte(langue,4))
c
c====
c 2. recherche des noeuds a la limite entre deux zones de raffinement de
c    niveau different, sans tenir compte du bord exterieur
c====
c
      if ( codret.eq.0 ) then
c
      iaux = 3
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTBONO', nompro
#endif
      call utbono ( iaux,
     >              nbnoto, nbarto, nbtrto, nbquto, nbteto, nbfaar,
     >              somare,
     >              filare, hetare,
     >              posifa, facare,
     >              hettri, aretri, voltri,
     >              hetqua, arequa,
     >              nbnobo, bornoe,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 3. recherche des aretes a la limite entre deux zones de raffinement de
c    niveau different, sans tenir compte du bord exterieur
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. recherche aretes ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 3
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTBOAR', nompro
#endif
      call utboar ( iaux,
     >              nbarto, nbtrto, nbquto, nbteto, nbfaar,
     >              hetare, filare,
     >              posifa, facare,
     >              aretri, hettri, voltri,
     >              arequa, hetqua,
     >              nbar2d, nbar3d, borare,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 4. recherche des faces :
c    . dont une des aretes est a la limite entre deux zones de
c      raffinement de niveau different, sans tenir compte du bord
c      exterieur
c    . qui sont actives
c    . qui sont a garder dans l'adaptation
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. recherche faces ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      nbfac1 = 0
c
      do 4 , option = 2, 4, 2
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) mess14(langue,2,option)
#endif
c
        if ( option.eq.2 ) then
          nbento = nbtrto
          nbaret = 3
        else
          nbento = nbquto
          nbaret = 4
       endif
c
        do 40 , laface = 1 , nbento
c
          if ( option.eq.2 ) then
            etatfa = mod( hettri(laface) , 10 )
            faced = laface
          else
            etatfa = mod( hetqua(laface) , 100 )
            faced = -laface
          endif
c
          if ( etatfa.eq.0 .and. decfac(faced).eq.0 ) then
c
            do 41 , larelo = 1 , nbaret
c
              if ( option.eq.2 ) then
                larete = aretri(laface,larelo)
              else
                larete = arequa(laface,larelo)
              endif
              if ( borare(larete).eq.1 ) then
                nbfac1 = nbfac1 + 1
                list1f(1,nbfac1) = faced
                list1f(2,nbfac1) = larelo
                goto 40
              endif
c
   41       continue
c
          endif
c
   40   continue
c
    4 continue
c
      endif
cgn      write (ulsort,1789)(list1f(1,iaux),list1f(2,iaux),
cgn     >iaux=1,nbfac1)
cgn 1789 format(10(i8,i2))
c
c====
c 5. pour chacune des faces trouvees a l'etape 4 :
c    . on cherche leur voisine par l'arete parallele au bord
c    . si cette voisine est a couper en 4, on coupera la face
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. voisines ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      nbfac2 = 0
c
      do 5 , iaux = 1 , nbfac1
c
        faced = list1f(1,iaux)
        if ( faced.gt.0 ) then
          lardeb = 1
          larfin = 3
        else
          lardeb = per1a4(2,list1f(2,iaux))
          larfin = lardeb
        endif
c
        do 51 , larelo = lardeb , larfin
c
          if ( faced.gt.0 ) then
            larete = aretri(faced,larelo)
          else
            larete = arequa(-faced,larelo)
          endif
c
          if ( decare(larete).eq.2 ) then
c
            ideb = posifa(larete-1)+1
            ifin = posifa(larete)
c
            do 511 , ipos = ideb , ifin
              iface = facare(ipos)
              if ( iface.ne.faced) then
                if ( decfac(iface).eq.4 ) then
                  nbfac2 = nbfac2 + 1
                  list2f(nbfac2) = faced
                endif
              endif
  511       continue
c
          endif
c
   51   continue
c
    5 continue
c
      endif
c
c====
c 6. modifications des decisions des faces
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. modifications decfac ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbfac2.gt.0 ) then
        write (ulsort,texte(langue,5)) nbfac2
        afaire = 1
      endif
c
      do 61 , iaux = 1 , nbfac2
c
        laface = list2f(iaux)
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,30)) 'decfac',laface,4,' '
#endif
        decfac(laface) = 4
c
        if ( laface.gt.0 ) then
          nbaret = 3
        else
          nbaret = 4
        endif
c
        do 611 , larelo = 1 , nbaret
c
          if ( laface.gt.0 ) then
            larete = aretri(laface,larelo)
          else
            larete = arequa(-laface,larelo)
          endif
c
          if ( decare(larete).eq.0 ) then
            if ( mod(hetare(larete),10).eq.0 ) then
              decare(larete) = 2
            endif
          elseif ( decare(larete).eq.-1 ) then
            decare(larete) = 0
          endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))'decare', larete,decare(larete),' '
#endif
c
  611   continue
c
   61 continue
c
      endif
c
c====
c 7. la fin
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
