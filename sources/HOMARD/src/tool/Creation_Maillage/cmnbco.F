      subroutine cmnbco ( nomail,
     >                    lgopti, taopti, lgopts, taopts,
     >                    lgetco, taetco,
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
c    Creation du Maillage - NomBre de mise en COnformite
c    -           -          -  -              --
c ______________________________________________________________________
c
c but : decompte les entites a creer lors du decoupage de mise en
c       conformite des faces et des volumes.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
c . lgopti . e   .   1    . longueur du tableau des options entieres   .
c . taopti . e   . lgopti . tableau des options                        .
c . lgopts . e   .   1    . longueur du tableau des options caracteres .
c . taopts . e   . lgopts . tableau des options caracteres             .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .   1    . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . e/s .   1    . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c ______________________________________________________________________
c    Rappel des codes de pilotage du raffinement et deraffinement :
c  30 : mode de conformite
c       0 : conforme (defaut)
c       1 : non-conforme avec 1 seule arete decoupee (en 2)
c           par face (triangle ou quadrangle)
c       2 : non-conforme avec 1 seul noeud pendant par arete
c       3 : non-conforme fidele a l'indicateur
c      -1 : conforme, avec des boites pour les quadrangles, hexaedres
c           et pentaedres
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
      parameter ( nompro = 'CMNBCO' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "gmenti.h"
c
#include "envca1.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      character*8 nomail
c
      integer lgopti
      integer taopti(lgopti)
c
      integer lgopts
      character*8 taopts(lgopts)
c
      integer lgetco
      integer taetco(lgetco)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codava
      integer nretap, nrsset
      integer iaux, jaux, kaux
c
      integer codre0
      integer codre1, codre2
c
      integer pdecar, pdecfa
      integer phetar
      integer paretr, phettr, pnivtr
      integer parequ, phetqu, pnivqu
      integer phette, ptrite
      integer phethe, pquahe, pcoquh
      integer phetpe, pfacpe
c
      character*6 saux
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
      character*8 ntrav1
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
      codava = codret
c
c=======================================================================
      if ( codava.eq.0 ) then
c=======================================================================
c
c 1.3. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     > '(/,a6,'' NOMBRE DE MISES EN CONFORMITE'')'
      texte(1,5) = '(36(''=''),/)'
      texte(1,6) = '(''Modification de taille des tableaux des '',a)'
      texte(1,7) = '(5x,''==> code de retour :'',i8)'
c
      texte(2,4) =
     > '(/,a6,'' NUMBER OF REQUESTED CONFORMITY OPERATIONS'')'
      texte(2,5) = '(48(''=''),/)'
      texte(2,6) = '(''Size modification of arrays for '',a)'
      texte(2,7) = '(5x,''==> error code :'',i8)'
c
#include "impr03.h"
c
c 1.4. ==> le numero de sous-etape
c
      nretap = taetco(1)
      nrsset = taetco(2) + 1
      taetco(2) = nrsset
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
c 1.5. ==> le titre
c
      write ( ulsort,texte(langue,4)) saux
      write ( ulsort,texte(langue,5))
c
c====
c 2. recuperation des pointeurs
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMH', nompro
#endif
c
      call utnomh ( nomail,
     >                sdim,   mdim,
     >               degre, maconf, homolo, hierar,
     >              rafdef, nbmane, typcca, typsfr, maextr,
     >              mailet,
     >              norenu,
     >              nhnoeu, nhmapo, nharet,
     >              nhtria, nhquad,
     >              nhtetr, nhhexa, nhpyra, nhpent,
     >              nhelig,
     >              nhvois, nhsupe, nhsups,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
      ntrav1 = taopts(11)
      call gmadoj ( ntrav1, pdecar, iaux, codre1 )
      ntrav1 = taopts(12)
      call gmadoj ( ntrav1, pdecfa, iaux, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_ar', nompro
#endif
      iaux = 2
      call utad02 ( iaux, nharet,
     >              phetar, kaux  , jaux  , jaux  ,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      if ( nbtrto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_tr', nompro
#endif
        iaux = 2
        call utad02 ( iaux, nhtria,
     >                phettr, paretr, jaux  , jaux  ,
     >                  jaux,   jaux,   jaux,
     >                pnivtr,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbquto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
        iaux = 2
        call utad02 ( iaux, nhquad,
     >                phetqu, parequ, jaux  , jaux  ,
     >                  jaux,   jaux,   jaux,
     >                pnivqu,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbteto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_te', nompro
#endif
        iaux = 2
        call utad02 ( iaux, nhtetr,
     >                phette, ptrite, jaux  , jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
      if ( nbheto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_he', nompro
#endif
        iaux = 2
        if ( taopti(30).ge.0 ) then
          iaux = iaux*13
        endif
        call utad02 ( iaux, nhhexa,
     >                phethe, pquahe, jaux  , jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux, pcoquh,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbpeto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_pe', nompro
#endif
        iaux = 2
        call utad02 ( iaux, nhpent,
     >                phetpe, pfacpe, jaux  , jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
c====
c 3. decompte des nouvelles entites a creer
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. decompte ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTPLCO', nompro
#endif
c
      call utplco ( taopti(30),
     >              imem(pdecar), imem(pdecfa),
     >              imem(phetar),
     >              imem(phettr), imem(paretr),
     >              imem(phetqu), imem(parequ),
     >              imem(phette), imem(ptrite),
     >              imem(phethe), imem(pquahe), imem(pcoquh),
     >              imem(phetpe), imem(pfacpe),
     >              ulsort, langue, codret )
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
c=======================================================================
      endif
c=======================================================================
c
      end
