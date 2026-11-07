      subroutine sfcofa ( bilan, nbbasc, libasc,
     >                    lenoeu, larete,
     >                    nufade, nufafi, nbvoto,
     >                    coonoe,
     >                    somare, filare, np2are,
     >                    facare,
     >                    hettri, aretri,
     >                    voltri,
     >                    hetqua, arequa, filqua,
     >                    volqua,
     >                    ulsort, langue, codret)
c ______________________________________________________________________
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
c   Suivi de Frontiere - COntroles des FAces
c   -        -           --            --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . bilan  .   s .   1    . bilan du controle de l'arete               .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c . nbbasc .   s .   1    . nombre de bascule a faire                  .
c . libasc .   s .   *    . liste des aretes a basculer                .
c . lenoeu . e   .   1    . noeud qui bouge                            .
c . larete . e   .   1    . arete a controler                          .
c . nufade . e   .   1    . numero face depart des voisines de larete  .
c . nufafi . e   .   1    . numero face fin des voisines de larete     .
c . nbvoto . e   .   1    . nombre de volumes total                    .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . *sdim  .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . filare . e   . nbarto . premiere fille des aretes                  .
c . np2are . e   . nbarto . noeud milieux des aretes                   .
c . facare . es  . nbfaar . liste des faces contenant une arete        .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . volqua . e   .2*nbquto. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . x : probleme                               .
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
      parameter ( nompro = 'SFCOFA' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "nombno.h"
#include "nombar.h"
#include "nombqu.h"
#include "nombtr.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer bilan, nbbasc, libasc(*)
      integer lenoeu, larete
      integer nufade, nufafi, nbvoto
c
      integer somare(2,nbarto), filare(nbarto), np2are(nbarto)
      integer facare(nbfaar)
      integer hettri(nbtrto), aretri(nbtrto,3)
      integer voltri(2,nbtrto)
      integer hetqua(nbquto), arequa(nbquto,4), filqua(nbquto)
      integer volqua(2,nbquto)
c
      double precision coonoe(nbnoto,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer laface
c
      logical bascul
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
      texte(1,4) = '(/,''.. Examen du '',a,i10)'
      texte(1,5) = '(''.. Probleme.'')'
      texte(1,6) = '(''.. Bascule a faire.'')'
c
      texte(2,4) = '(/,''.. Examination of '',a,'' # '',i10)'
      texte(2,5) = '(''. Problem.'')'
      texte(2,6) = '(''.. Swapping.'')'
c
#ifdef _DEBUG_HOMARD_
       write (ulsort,texte(langue,4)) mess14(langue,1,1), larete
       write (ulsort,texte(langue,4)) mess14(langue,1,-1), lenoeu
#endif
c
      codret = 0
c
      bilan = 0
      nbbasc = 0
c
c====
c 2. boucle sur les faces s'appuyant sur l'arete
c    On ne s'interesse qu'aux aretes qui viennent d'etre decoupees et
c    qui font partie d'une frontiere reconnue
c    On ne s'interesse qu'aux faces qui ne bordent aucun volume
c====
c
      do 21 , iaux = nufade, nufafi
c
        if ( codret.eq.0 ) then
c
        bascul = .false.
c
        laface = facare(iaux)
c
c 2.1. ==> si la face voisine est un triangle
c
        if ( laface.gt.0 ) then
cgn        write (ulsort,*)'.. Face voisine : triangle ', laface
c
          if ( nbvoto.eq.0 .or. voltri(1,laface).eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFTQTR', nompro
#endif
            call sftqtr ( bilan, bascul,
     >                    lenoeu, larete, laface,
     >                    coonoe,
     >                    somare, filare, np2are,
     >                    hettri, aretri,
     >                    ulsort, langue, codret)
c
          endif
c
c 2.2. ==> si la face voisine est un quadrangle
c
        else
cgn      write(ulsort,*)'.. Face voisine : quadrangle ',-laface
c
          if ( nbvoto.eq.0 .or. volqua(1,-laface).eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFTQQU', nompro
#endif
            call sftqqu ( bilan,
     >                    lenoeu, larete, -laface,
     >                    coonoe,
     >                    somare, filare, np2are,
     >                    hetqua, arequa, filqua,
     >                    ulsort, langue, codret)
c
          endif
c
        endif
c
c 2.3. ==> Memorisations
c
        if ( codret.eq.0 ) then
c
          if ( bilan.ne.0 ) then
            goto 30
          endif
c
          if ( bascul ) then
            nbbasc = nbbasc + 1
            libasc(nbbasc) = laface
          endif
c
        endif
c
        endif
c
   21 continue
c
c====
c 3. Bilan
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. Bilan ; codret = ', codret
#endif
c
   30 continue
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      if ( bilan.ne.0 ) then
        write (ulsort,texte(langue,4)) mess14(langue,1,1), larete
        write (ulsort,texte(langue,5))
      endif
      if ( bascul ) then
        write (ulsort,texte(langue,4)) mess14(langue,1,1), larete
        write (ulsort,texte(langue,6))
      endif
      endif
#endif
c
c====
c 4. La fin
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
