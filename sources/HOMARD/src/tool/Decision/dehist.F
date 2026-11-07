      subroutine dehist ( nomail,
     >                    lgopti, taopti, lgetco, taetco,
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
c traitement des DEcisions - mise a jour des HISToriques
c                --                          ----
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
c . lgopti . e   .   1    . longueur du tableau des options            .
c . taopti . e   . lgopti . tableau des options                        .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
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
      parameter ( nompro = 'DEHIST' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "envca1.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpe.h"
#include "nombpy.h"
c
c 0.3. ==> arguments
c
      character*8 nomail
c
      integer lgopti
      integer taopti(lgopti)
c
      integer lgetco
      integer taetco(lgetco)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codava
      integer nrosec
      integer nretap, nrsset
      integer iaux
c
      integer phetno, phetar, phettr, phetqu
      integer phette, phethe, phetpe, phetpy
      integer codre1, codre2, codre3, codre4, codre5
      integer codre6, codre7, codre8
      integer codre0
c
      character*6 saux
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
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
c 1.1. ==> le debut des mesures de temps
c
      nrosec = taetco(4)
      call gtdems (nrosec)
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
      texte(1,4) = '(/,a6,'' MISE A JOUR DES HISTORIQUES'')'
      texte(1,5) = '(34(''=''),/)'
c
      texte(2,4) = '(/,a6,'' UPDATING OF HISTORY'')'
      texte(2,5) = '(26(''=''),/)'
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
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
c
c====
c 2. recuperation des pointeurs, initialisations
c====
c
c 2.1. ==> structure generale
c
      if ( codret.eq.0 ) then
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
c 2.2. ==> tableaux
c
      if ( codret.eq.0 ) then
c
      call gmadoj ( nhnoeu//'.HistEtat', phetno, iaux, codre1 )
      call gmadoj ( nharet//'.HistEtat', phetar, iaux, codre2 )
      if ( nbtrto.ne.0 ) then
        call gmadoj ( nhtria//'.HistEtat', phettr, iaux, codre3 )
      else
        codre3 = 0
      endif
      if ( nbquto.ne.0 ) then
        call gmadoj ( nhquad//'.HistEtat', phetqu, iaux, codre4 )
      else
        codre4 = 0
      endif
      if ( nbteto.ne.0 ) then
        call gmadoj ( nhtetr//'.HistEtat', phette, iaux, codre5 )
      else
        codre5 = 0
      endif
      if ( nbheto.ne.0 ) then
        call gmadoj ( nhhexa//'.HistEtat', phethe, iaux, codre6 )
      else
        codre6 = 0
      endif
      if ( nbpeto.ne.0 ) then
        call gmadoj ( nhpent//'.HistEtat', phetpe, iaux, codre7 )
      else
        codre7 = 0
      endif
      if ( nbpyto.ne.0 ) then
        call gmadoj ( nhpyra//'.HistEtat', phetpy, iaux, codre8 )
      else
        codre8 = 0
      endif
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8 )
c
      endif
c
c====
c 3. mise a jour effective
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. mise a jour effective ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( taopti(31).ne.0 .or. taopti(32).ne.0 ) then
        iaux = 0
      else
        iaux = 1
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEHMAJ', nompro
#endif
      call dehmaj ( iaux,
     >              imem(phetno), imem(phetar),
     >              imem(phettr), imem(phetqu),
     >              imem(phette), imem(phethe),
     >              imem(phetpe), imem(phetpy),
     >              ulsort, langue, codret )
c
      endif
c
c====
c 4. la fin
c====
c
c 4.1. ==> message si erreur
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
c 4.2. ==> fin des mesures de temps de la section
c
      call gtfims (nrosec)
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
