      subroutine pcmatr ( elemen, nbele0,
     >                    somare, np2are,
     >                    aretri, hettri, nintri,
     >                    famtri, cfatri,
     >                    nnosca, ntrsca, ntrsho,
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
c    aPres adaptation - Conversion - MAillage connectivite - TRiangles
c     -                 -            --                      --
c ______________________________________________________________________
c
c remarque : pcmatr et pcmat0 sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . elemen . es  .   1    . numero du dernier element cree             .
c . nbele0 . e   .   1    . estimation du nombre d'elements            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero du noeud p2 milieu d'arete          .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . nintri . e   . nbtrto . noeud interne au triangle                  .
c . famtri . e   . nbtrto . famille des triangles                      .
c . cfatri . e   . nctftr*. codes des familles des triangles           .
c .        .     . nbftri .   1 : famille MED                          .
c .        .     .        .   2 : type de triangle                     .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c . nnosca . e   . rsnoto . numero des noeuds du code de calcul        .
c . ntrsca .  s  . rstrto . numero des triangles du calcul             .
c . ntrsho .  s  . nbele0 . numero des triangles dans HOMARD           .
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
      parameter ( nompro = 'PCMATR' )
c
#include "nblang.h"
#include "coftex.h"
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
#include "nombtr.h"
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
      integer aretri(nbtrto,3), hettri(nbtrto), nintri(nbtrto)
c
      integer cfatri(nctftr,nbftri), famtri(nbtrto)
c
      integer nnosca(rsnoto)
      integer ntrsca(rstrto), ntrsho(nbele0)
c
      integer famele(nbele0), noeele(nbele0,nbmane)
      integer typele(nbele0)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer letria
      integer etat
      integer a1, a2, a3
      integer sa3a1, sa1a2, sa2a3
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
c====
c 2. initialisations des renumerotations
c====
c
      do 21 , iaux = 1 , rstrto
        ntrsca(iaux) = 0
   21 continue
c
      do 22 , iaux = 1 , nbele0
        ntrsho(iaux) = 0
   22 continue
c
c====
c 3. Conversion en lineaire
c====
c
      if ( degre.eq.1 ) then
c
c                          sa2a3
c                            *
c                           . .
c                          .   .
c     HOMARD              .     .
c                     a3 .       .  a2
c                       .         .
c                      .           .
c                     .             .
c               sa3a1*---------------*sa1a2
c                           a1
c
c                            s3
c                            *
c                           / \
c                          /   \
c     code de calcul :    /     \
c                        /       \
c                       /_________\
c                      s1          s2
c
c
        do 31 , letria = 1 , nbtrto
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,11)) mess14(langue,2,2), letria
      write (ulsort,*) '. Famille : ', famtri(letria)
      write (ulsort,texte(langue,12))
     >                     cotyel, cfatri(cotyel,famtri(letria))
#endif
c
          if ( cfatri(cotyel,famtri(letria)).ne.0 ) then
c
            etat = mod( hettri(letria) , 10 )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,13)) hettri(letria), etat
#endif
c
            if ( etat.eq.0 .or. hierar.ne.0 ) then
c
c 3.1. ==> generalites
c
              elemen = elemen + 1
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,14)) elemen
#endif
              ntrsho(elemen) = letria
              ntrsca(letria) = elemen
c
              a1 = aretri(letria,1)
              a2 = aretri(letria,2)
              a3 = aretri(letria,3)
c
c 3.2. ==> recherche des numeros des sommets
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSOTR', nompro
#endif
              call utsotr ( somare, a1, a2, a3,
     >                      sa1a2, sa2a3, sa3a1 )
c
c 3.3. ==> archivage
c
              noeele(elemen,1) = nnosca(sa2a3)
              noeele(elemen,2) = nnosca(sa3a1)
              noeele(elemen,3) = nnosca(sa1a2)
c
              famele(elemen) = cfatri(cofamd,famtri(letria))
              typele(elemen) = cfatri(cotyel,famtri(letria))
c
#ifdef _DEBUG_HOMARD_
            if ( elemen.eq.-12 ) then
            write (ulsort,90002) 'famtri', famtri(letria)
            write (ulsort,texte(langue,14)) elemen
            write (ulsort,texte(langue,15))
     >             (noeele(elemen,iaux),iaux=1,3)
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
      elseif ( mod(mailet,2).ne.0 ) then
c
c                          sa2a3
c                            *
c                           . .
c                          .   .
c     HOMARD              .     .
c                     a3 *n3   n2. a2
c                       .         .
c                      .           .
c                     .     n1      .
c               sa3a1*-------*-------*sa1a2
c                           a1
c
c                            s3
c                            *
c                           / \
c                          /   \
c                MED : s6 *     *s5
c                        /       \
c                       /____*____\
c                      s1    s4    s2
c
        do 41 , letria = 1 , nbtrto
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,11)) mess14(langue,2,2), letria
      write (ulsort,texte(langue,12))
     >                     cotyel, cfatri(cotyel,famtri(letria))
#endif
c
          if ( cfatri(cotyel,famtri(letria)).ge.1 ) then
c
            etat = mod( hettri(letria) , 10 )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,13)) hettri(letria), etat
#endif
c
            if ( etat.eq.0 .or. hierar.ne.0 ) then
c
c 4.1. ==> generalites
c
              elemen = elemen + 1
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,14)) elemen
#endif
              ntrsho(elemen) = letria
              ntrsca(letria) = elemen
c
              a1 = aretri(letria,1)
              a2 = aretri(letria,2)
              a3 = aretri(letria,3)
c
c 4.2. ==> recherche des numeros des sommets
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSOTR', nompro
#endif
              call utsotr ( somare, a1, a2, a3,
     >                      sa1a2, sa2a3, sa3a1 )
c
c 4.3. ==> archivage
c
              noeele(elemen,1) = nnosca(sa2a3)
              noeele(elemen,2) = nnosca(sa3a1)
              noeele(elemen,3) = nnosca(sa1a2)
              noeele(elemen,4) = nnosca(np2are(a3))
              noeele(elemen,5) = nnosca(np2are(a1))
              noeele(elemen,6) = nnosca(np2are(a2))
c
              famele(elemen) = cfatri(cofamd,famtri(letria))
              typele(elemen) = cfatri(cotyel,famtri(letria))
c
            endif
c
          endif
c
   41   continue
c
c====
c 5. Conversion en quadratique etendu
c    Similaire au quadratique a part le 7-eme noeud
c====
c
      else
c
c                          sa2a3
c                            *
c                           . .
c                          .   .
c     HOMARD              .     .
c                     a3 *n3   n2. a2
c                       .   nin   .
c                      .           .
c                     .     n1      .
c               sa3a1*-------*-------*sa1a2
c                           a1
c
c                            s3
c                            *
c                           / \
c                          /   \
c                MED : s6 .     .s5
c                        /   s7  \
c                       /____.____\
c                      s1    s4    s2
c
        do 51 , letria = 1 , nbtrto
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,11)) mess14(langue,2,2), letria
      write (ulsort,texte(langue,12))
     >                     cotyel, cfatri(cotyel,famtri(letria))
#endif
c
          if ( cfatri(cotyel,famtri(letria)).ge.1 ) then
c
            etat = mod( hettri(letria) , 10 )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,13)) hettri(letria), etat
#endif
c
            if ( etat.eq.0 .or. hierar.ne.0 ) then
c
c 5.1. ==> generalites
c
              elemen = elemen + 1
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,14)) elemen
#endif
              ntrsho(elemen) = letria
              ntrsca(letria) = elemen
c
              a1 = aretri(letria,1)
              a2 = aretri(letria,2)
              a3 = aretri(letria,3)
c
c 5.2. ==> recherche des numeros des sommets
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSOTR', nompro
#endif
              call utsotr ( somare, a1, a2, a3,
     >                      sa1a2, sa2a3, sa3a1 )
c
c 5.3. ==> archivage
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'noeud interne', nintri(letria)
#endif
              noeele(elemen,1) = nnosca(sa2a3)
              noeele(elemen,2) = nnosca(sa3a1)
              noeele(elemen,3) = nnosca(sa1a2)
              noeele(elemen,4) = nnosca(np2are(a3))
              noeele(elemen,5) = nnosca(np2are(a1))
              noeele(elemen,6) = nnosca(np2are(a2))
              noeele(elemen,7) = nnosca(nintri(letria))
c
              famele(elemen) = cfatri(cofamd,famtri(letria))
              typele(elemen) = cfatri(cotyel,famtri(letria))
c
            endif
c
          endif
c
   51   continue
c
      endif
c
c====
c 6. la fin
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
