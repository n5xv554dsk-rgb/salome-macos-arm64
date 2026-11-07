      subroutine gagpmc ( objet,
     >                    ix, jx, chemin, lgchem, nbchem,
     >                    impopt, codret)
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
c     construction du graphe d'un objet structure
c     en memoire centrale
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . objet  . e   .  ch8   . nom de l'objet dont on doit construire le  .
c .        .     .        . graphe                                     .
c . ix,jx  . e   .   1    . dimension du tableau chemin(.,.)           .
c . chemin .  s  .(ix,jx) . tableau des chemins du graphe de l'objet   .
c . lgchem .  s  .  ix    . longueur des chemins                       .
c . nbchem .  s  .   1    . nombre de chemins                          .
c . impopt . e   .   1    . 1 : on imprime le graphe ; 0 : non         .
c . codret .  s  .   1    . code de retour :                           .
c .        .     .        .  0    : OK                                 .
c .        .     .        . -1    : dimensionnement insuffisant        .
c .        .     .        . -2    : objet non structure                .
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
      character*6 nompro
      parameter ( nompro = 'GAGPMC' )
c
c
#include "genbla.h"
c
#include "gmmaxt.h"
#include "gmmatc.h"
c
c 0.2. ==> communs
c
#include "gmtoai.h"
#include "gmtoas.h"
c
#include "gmtrrl.h"
#include "gmtren.h"
#include "gmtrst.h"
c
#include "gmalrl.h"
#include "gmalen.h"
#include "gmalst.h"
c
#include "gmimpr.h"
#include "gmlang.h"
c
c 0.3. ==> arguments
c
      integer ix,jx,nbchem, impopt, codret
      integer lgchem(ix)
c
      character*(*) objet
      character*8 chemin(ix,jx)
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.4. ==> variables locales
c
#ifdef _DEBUG_HOMARD_
      integer iaux
#endif
c
      integer nbrobj, nbrcha
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
      texte(1,10) =
     > '(/,''=======> graphe VTOC-MC de '',a8,'' <========'',/)'
c
      texte(2,10) =
     > '(/,''=======> graph VTOC-CM of '',a8,'' <========'',/)'
#ifdef _DEBUG_HOMARD_
      write (ulsort,90000)
        write (ulsort,texte(langue,1)) 'Sortie', nompro
90000 format (70('='))
#endif
c
c====
c 2. appel du programme generique
c====
c
      if (impopt.eq.1) then
        write (ulsort,texte(langue,10)) objet
      endif
c
      nbrobj = iptobj-1
      nbrcha = iptchp-1
      call gagpmf ( objet, chemin, lgchem, nbchem,
     >              ix, jx, nbrobj, nbrcha,
     >              nomobj, typobj, adrdso, nomobc,
     >              nballi, nomali,
     >              nballr, nomalr,
     >              nballs, nomals,
     >              impopt, codret)
c
      if (impopt.eq.1) then
        write (ulsort,texte(langue,10)) objet
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90000)
#endif
c
      end
