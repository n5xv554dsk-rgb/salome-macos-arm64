      subroutine pcmaar ( elemen, nbele0,
     >                    somare, np2are, hetare,
     >                    famare, cfaare,
     >                    nnosca, narsca, narsho,
     >                    famele, noeele, typele,
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
c    aPres adaptation - Conversion - MAillage connectivite - ARetes
c     -                 -            --                      --
c ______________________________________________________________________
c
c remarque : voir vcorie pour la definition des orientations
c remarque : pcmaar et pcmaa0 sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . elemen . es  .   1    . numero du dernier element cree             .
c . nbele0 . e   .   1    . estimation du nombre d'elements            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero du noeud p2 milieu d'arete          .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . famare . e   . nbarto . famille des aretes                         .
c . cfaare . e   . nctfar*. codes des familles des aretes              .
c .        .     . nbfare .   1 : famille MED                          .
c .        .     .        .   2 : type de segment                      .
c .        .     .        .   3 : orientation                          .
c .        .     .        .   4 : famille d'orientation inverse        .
c .        .     .        .   5 : numero de ligne de frontiere         .
c .        .     .        .  > 0 si concernee par le suivi de frontiere.
c .        .     .        . <= 0 si non concernee                      .
c .        .     .        .   6 : famille frontiere active/inactive    .
c .        .     .        .   7 : numero de surface de frontiere       .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . nnosca . e   . rsnoto . numero des noeuds du code de calcul        .
c . narsca .  s  . rsarto . numero des aretes du calcul                .
c . narsho .  s  . nbele0 . numero des aretes dans HOMARD              .
c . famele . es  . nbele0 . famille med des elements                   .
c . noeele . es  . nbele0 . noeuds des elements                        .
c .        .     . *nbmane.                                            .
c . typele . es  . nbele0 . type des elements                          .
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
      parameter ( nompro = 'PCMAAR' )
c
#include "nblang.h"
#include "coftex.h"
#include "cofaar.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
#include "envca1.h"
c
#include "nbfami.h"
#include "nombar.h"
c
#include "nombsr.h"
c
#include "dicfen.h"
c
c 0.3. ==> arguments
c
      integer elemen
      integer nbele0
c
      integer somare(2,nbarto), np2are(nbarto)
      integer hetare(nbarto)
c
      integer cfaare(nctfar,nbfare), famare(nbarto)
c
      integer nnosca(rsnoto)
      integer narsca(rsarto), narsho(nbele0)
c
      integer famele(nbele0), noeele(nbele0,nbmane)
      integer typele(nbele0)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer larete
      integer etat
      integer iaux
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "impr03.h"
c
#include "impr06.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbarto', nbarto
      write (ulsort,90002) 'rsarto', rsarto
      write (ulsort,90002) 'nbele0', nbele0
#endif
c
c====
c 2. initialisations des renumerotations
c====
c
      do 21 , iaux = 1 , rsarto
        narsca(iaux) = 0
   21 continue
c
      do 22 , iaux = 1 , nbele0
        narsho(iaux) = 0
   22 continue
c
c====
c 3. Conversion en lineaire
c====
c
      if ( degre.eq.1 ) then
c
c                           a1
c                  n1*-------------*n2
c
        do 31 , larete = 1 , nbarto
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,11)) mess14(langue,2,1), larete
      write (ulsort,texte(langue,12))
     >                     cotyel, cfaare(cotyel,famare(larete))
#endif
c
          if ( cfaare(cotyel,famare(larete)).ne.0 ) then
c
            etat = mod( hetare(larete) , 10 )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,13)) hetare(larete), etat
#endif
c
            if ( etat.eq.0 .or. hierar.ne.0 ) then
c
              elemen = elemen + 1
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,14)) elemen
#endif
              narsho(elemen) = larete
              narsca(larete) = elemen
c
              if ( cfaare(coorfa,famare(larete)).eq.1 ) then
                noeele(elemen,1) = nnosca(somare(1,larete))
                noeele(elemen,2) = nnosca(somare(2,larete))
              else
                noeele(elemen,1) = nnosca(somare(2,larete))
                noeele(elemen,2) = nnosca(somare(1,larete))
              endif
c
              famele(elemen) = cfaare(cofamd,famare(larete))
              typele(elemen) = cfaare(cotyel,famare(larete))
c
#ifdef _DEBUG_HOMARD_
            if ( elemen.eq.-12 ) then
            write (ulsort,90002) 'famare', famare(larete)
            write (ulsort,texte(langue,14)) elemen
            write (ulsort,texte(langue,15))
     >             (noeele(elemen,iaux),iaux=1,2)
            write (ulsort,90002) 'Famille MED',famele(elemen)
            write (ulsort,90002) 'Type MED   ',typele(elemen)
            endif
#endif
            endif
c
          endif
c
   31   continue
c
c====
c 4. Conversion en quadratique
c====
c
      else
c                           a1
c                  n1*------*------*n4
c                          n2
c
        do 41 , larete = 1 , nbarto
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,11)) mess14(langue,2,1), larete
      write (ulsort,texte(langue,12))
     >                     cotyel, cfaare(cotyel,famare(larete))
#endif
c
          if ( cfaare(cotyel,famare(larete)).ne.0 ) then
c
            etat = mod( hetare(larete) , 10)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,13)) hetare(larete), etat
#endif
c
            if ( etat.eq.0 .or. hierar.ne.0 ) then
              elemen = elemen + 1
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,14)) elemen
#endif
              narsho(elemen) = larete
              narsca(larete) = elemen
c
              if ( cfaare(coorfa,famare(larete)).eq.1 ) then
                noeele(elemen,1) = nnosca(somare(1,larete))
                noeele(elemen,2) = nnosca(somare(2,larete))
              else
                noeele(elemen,1) = nnosca(somare(2,larete))
                noeele(elemen,2) = nnosca(somare(1,larete))
              endif
              noeele(elemen,3) = nnosca(np2are(larete))
c
              famele(elemen) = cfaare(cofamd,famare(larete))
              typele(elemen) = cfaare(cotyel,famare(larete))
            endif
c
          endif
c
   41   continue
c
      endif
c
c====
c 5. la fin
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
