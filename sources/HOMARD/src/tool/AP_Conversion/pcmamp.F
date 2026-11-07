      subroutine pcmamp ( elemen, nbele0,
     >                    noempo, hetmpo,
     >                    fammpo, cfampo,
     >                    nnosca, nmpsca, nmpsho,
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
c    aPres adaptation - Conversion - MAillage connectivite - MaillePoint
c     -                 -            --                      -     -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . elemen . es  .   1    . numero du dernier element cree             .
c . nbele0 . e   .   1    . estimation du nombre d'elements            .
c . noempo . e   . nbmpto . numeros des noeuds associes aux mailles    .
c . hetmpo . e   . nbmpto . historique de l'etat des mailles-points    .
c . fammpo . e   . nbmpto . famille des mailles-points                 .
c . cfampo . e   . nctfmp*. codes des familles des mailles-points      .
c .        .     . nbfmpo .   1 : famille MED                          .
c .        .     .        .   2 : type de maille-point                 .
c .        .     .        .   3 : famille des sommets                  .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . nnosca . e   . rsnoto . numero des noeuds du code de calcul        .
c . nmpsca .  s  . rsmpto . numero des mailles-points du calcul        .
c . nmpsho .  s  . rsmpac . numero des mailles-points dans HOMARD      .
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
      parameter ( nompro = 'PCMATE' )
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
#include "nombmp.h"
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
      integer noempo(nbmpto), hetmpo(nbmpto)
c
      integer cfampo(nctfmp,nbfmpo), fammpo(nbmpto)
c
      integer nnosca(rsnoto)
      integer nmpsca(rsmpto), nmpsho(nbele0)
c
      integer famele(nbele0), noeele(nbele0,nbmane)
      integer typele(nbele0)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
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
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "impr06.h"
c
c====
c 2. initialisations des renumerotations
c====
c
      if ( nbmpto.gt.0 ) then
c
        do 21 , iaux = 1 , nbmpto
          nmpsca(iaux) = 0
   21   continue
c
        do 22 , iaux = 1 , nbele0
          nmpsho(iaux) = 0
   22   continue
c
      endif
c
c====
c 3. Conversion
c====
c
      do 31 , iaux = 1 , nbmpto
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,11)) mess14(langue,2,0), iaux
      write (ulsort,texte(langue,12))
     >                     cotyel, cfampo(cotyel,fammpo(iaux))
#endif
c
        if ( cfampo(cotyel,fammpo(iaux)).ne.0 ) then
c
          etat = mod( hetmpo(iaux) , 10 )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,13)) hetmpo(iaux), etat
#endif
c
          if ( etat.eq.0 .or. hierar.ne.0 ) then
            elemen = elemen + 1
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,14)) elemen
#endif
            nmpsho(elemen) = iaux
            nmpsca(iaux) = elemen
            noeele(elemen,1) = nnosca(noempo(iaux))
            famele(elemen) = cfampo(cofamd,fammpo(iaux))
            typele(elemen) = cfampo(cotyel,fammpo(iaux))
          endif
c
        endif
c
   31 continue
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
