      subroutine utb17d ( option,
     >                    hetare, somare, np2are,
     >                    posifa, facare,
     >                    hettri, aretri, voltri,
     >                    hetqua, arequa, volqua,
     >                    tabaux,
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
c    UTilitaire - Bilan sur le maillage - option 17 - phase d
c    --           -                              --         -
c ______________________________________________________________________
c
c Reperage des noeuds sur un bord de volume ou de face
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e       1    . 1 : noeuds sur un bord de face             .
c .        .     .        . 2 : noeuds sur un bord de volume           .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero des noeuds p2 milieux d'aretes      .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . volqua . e   .2*nbquto. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
c . tabaux .  s  . nbnoto . 0 : le noeud est interne                   .
c .        .     .        . 1 : le noeud est au bord d'un volume       .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c .____________________________________________________________________.
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
      parameter ( nompro = 'UTB17D' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envca1.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer option
c
      integer hetare(nbarto), somare(2,nbarto), np2are(nbarto)
      integer posifa(0:nbarto), facare(nbfaar)
c
      integer hettri(nbtrto), aretri(nbtrto,3)
      integer voltri(2,nbtrto)
      integer hetqua(nbquto), arequa(nbquto,4)
      integer volqua(2,nbquto)
c
      integer tabaux(nbnoto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer jdeb, jfin
      integer etat, etat00
      integer laface
c
      integer a1, a2, a3, a4
      integer sa1a2, sa2a3, sa3a1, sa3a4, sa4a1
c
      logical aubord
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisation
c====
c 1.1. messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Nombre de '',a,'' actifs : '',i10)'
      texte(1,5) = '(''. Examen du '',a,i10)'
      texte(1,6) = '(''... '',a,i10,'' au bord'')'
      texte(1,7) = '(''Nombre de '',a,''au bord : '',i10,'' sur'',i10)'
c
      texte(2,4) = '(''Number of active '',a,'' : '',i10)'
      texte(2,5) = '(''. Examination of '',a,''#'',i10)'
      texte(2,6) = '(''... '',a,''#'',i10,'' on the boundary'')'
      texte(2,7) =
     > '(''Number of '',a,''on boundaries : '',i10,'' over'',i10)'
c
 1000 format('... ',a,':',4i10)
c
#ifdef _DEBUG_HOMARD_
      if ( option.eq.1 ) then
        write (ulsort,texte(langue,4)) mess14(langue,3,1), nbarac
      else
        write (ulsort,texte(langue,4)) mess14(langue,3,2), nbtrac
        write (ulsort,texte(langue,4)) mess14(langue,3,4), nbquac
      endif
#endif
c
      codret = 0
c
c====
c 2. A priori, tous les noeuds sont internes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. noeuds internes, codret = ', codret
#endif
c
      do 2 , iaux = 1, nbnoto
        tabaux(iaux) = 0
    2 continue
c
c====
c 3. Les bords des faces
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. bords de faces, codret = ', codret
#endif
c
      if ( option.eq.1 ) then
c
      if ( nbarac.gt.0 ) then
c
        do 31 , iaux = 1, nbarto
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,1,1), iaux
#endif
c
          etat = mod( hetare(iaux),10 )
c
          if ( etat.eq.0 ) then
c
            aubord = .false.
            jdeb = posifa(iaux-1)+1
            jfin = posifa(iaux)
c
c 3.1. ==> L'arete a au plus une face voisine : elle est de bord
c
            if ( jfin.le.jdeb) then
cgn         write (ulsort,*) 'au plus une face voisine'
c
              aubord = .true.
c
c 3.2. ==> L'arete a au moins deux faces voisines : il faut compter le
c          nombre de faces actives car avec la conformite, une face et
c          sa fille sont declarees voisines de l'arete
c
            else
c
              kaux = 0
              do 312 , jaux = jdeb, jfin
                laface = facare(jaux)
cgn         write (ulsort,*) 'voisine de', laface
                if ( laface.gt.0 ) then
                  etat00 = mod(hettri(laface),10)
                else
                  etat00 = mod(hetqua(-laface),100)
                endif
                if ( etat00.eq.0 ) then
                  kaux = kaux + 1
                endif
  312         continue
c
              if ( kaux.le.1 ) then
                aubord = .true.
              endif
c
            endif
c
c 3.3. ==> Transfert de l'information sur les noeuds de l'arete
c
            if ( aubord ) then
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,6)) mess14(langue,1,1), iaux
#endif
c
              tabaux(somare(1,iaux)) = 1
              tabaux(somare(2,iaux)) = 1
#ifdef _DEBUG_HOMARD_
              write (ulsort,1000) mess14(langue,3,-1),
     >                            somare(1,iaux), somare(2,iaux)
#endif
c
              if ( degre.eq.2 ) then
c
                tabaux(np2are(iaux)) = 1
#ifdef _DEBUG_HOMARD_
                write (ulsort,1000) mess14(langue,3,-1), np2are(iaux)
#endif
c
              endif
c
            endif
c
          endif
c
   31   continue
c
      endif
c
c====
c 4. Les bords des volumes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. bords de volume, codret = ', codret
#endif
c
      else
c
c 4.1. ==> Exploration des triangles
c
      if ( nbtrac.gt.0 ) then
c
        do 41 , iaux = 1, nbtrto
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,1,2), iaux
#endif
c
          etat = mod( hettri(iaux),10 )
c
          if ( etat.eq.0 ) then
c
            if ( voltri(2,iaux).eq.0 ) then
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,6)) mess14(langue,1,2), iaux
#endif
c
              a1 = aretri(iaux,1)
              a2 = aretri(iaux,2)
              a3 = aretri(iaux,3)
              call utsotr ( somare, a1, a2, a3,
     >                      sa1a2, sa2a3, sa3a1 )
c
              tabaux(sa1a2) = 1
              tabaux(sa2a3) = 1
              tabaux(sa3a1) = 1
#ifdef _DEBUG_HOMARD_
              write (ulsort,1000) mess14(langue,3,-1),
     >                            sa1a2, sa2a3, sa3a1
#endif
c
              if ( degre.eq.2 ) then
c
                tabaux(np2are(a1)) = 1
                tabaux(np2are(a2)) = 1
                tabaux(np2are(a3)) = 1
#ifdef _DEBUG_HOMARD_
                write (ulsort,1000) mess14(langue,3,-1),
     >          np2are(a1), np2are(a2), np2are(a3)
#endif
c
              endif
c
            endif
c
          endif
c
   41   continue
c
      endif
c
c 4.2. ==> Exploration des quadrangles
c
      if ( nbquac.gt.0 ) then
c
        do 42 , iaux = 1, nbquto
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,1,4), iaux
#endif
c
          etat = mod( hetqua(iaux),100 )
c
          if ( etat.eq.0 ) then
c
            if ( volqua(2,iaux).eq.0 ) then
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,6)) mess14(langue,1,4), iaux
#endif
c
              a1 = arequa(iaux,1)
              a2 = arequa(iaux,2)
              a3 = arequa(iaux,3)
              a4 = arequa(iaux,4)
              call utsoqu ( somare, a1, a2, a3, a4,
     >                      sa1a2, sa2a3, sa3a4, sa4a1 )
#ifdef _DEBUG_HOMARD_
              write (ulsort,1000) mess14(langue,3,-1),
     >                            sa1a2, sa2a3, sa3a4, sa4a1
#endif
c
              tabaux(sa1a2) = 1
              tabaux(sa2a3) = 1
              tabaux(sa3a4) = 1
              tabaux(sa4a1) = 1
c
              if ( degre.eq.2 ) then
c
                tabaux(np2are(a1)) = 1
                tabaux(np2are(a2)) = 1
                tabaux(np2are(a3)) = 1
                tabaux(np2are(a4)) = 1
#ifdef _DEBUG_HOMARD_
                write (ulsort,1000) mess14(langue,3,-1),
     >          np2are(a1), np2are(a2), np2are(a3), np2are(a4)
#endif
c
              endif
c
            endif
c
          endif
c
   42   continue
c
      endif
c
      endif
c
c====
c 5. Bilan
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5. Bilan, codret = ', codret
#endif
#ifdef _DEBUG_HOMARD_
c
      iaux = 0
      do 5 , sa1a2 = 1, nbnoto
        if ( tabaux(sa1a2).ne.0 ) then
          iaux = iaux + 1
cgn        else
cgn          write (ulsort,1000) mess14(langue,1,-1), sa1a2
        endif
    5 continue
      write (ulsort,texte(langue,7)) mess14(langue,3,-1), iaux, nbnoto
#endif
c
      end
