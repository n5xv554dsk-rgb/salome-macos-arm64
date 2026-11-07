      subroutine decora ( nomail,
     >                    lgopti, taopti, lgopts, taopts,
     >                    lgetco, taetco,
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
c traitement des DEcisions - COntraintes de RAffinement
c                --          --             --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
c . lgopti . e   .   1    . longueur du tableau des options            .
c . taopti . e   . lgopti . tableau des options                        .
c . lgopts . e   .   1    . longueur du tableau des options caracteres .
c . taopts . e   . lgopts . tableau des options caracteres             .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
c . afaire .   s .    1   . que faire a la sortie                      .
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
      parameter ( nompro = 'DECORA' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
#include "nombno.h"
#include "nombar.h"
#include "nombqu.h"
#include "nombtr.h"
#include "nombte.h"
#include "nombhe.h"
#include "envca1.h"
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
      integer afaire
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nretap, nrsset
      integer iaux, jaux
c
      integer psomar, phetar, pfilar, pmerar, pposif, pfacar
      integer phettr, paretr, pnivtr, advotr
      integer phetqu, parequ, pnivqu, advoqu
      integer phette, ptrite
      integer phethe, pquahe, pcoquh
c
      integer pdecar, pdecfa
      integer adhoar
      integer adtra3, adtra4, adtra5, adtra6
c
      integer codre0, codre1, codre2, codre3, codre4
c
      character*6 saux
      character*8 ntrav1, ntrav2, ntrav3, ntrav4, ntrav5, ntrav6
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
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
c 1.3. ==> les messages
c
      texte(1,4) = '(/,a6,'' CONTRAINTES POUR LE RAFFINEMENT'')'
      texte(1,5) = '(38(''=''),/)'
      texte(1,6) = '(5x,''Toutes les contraintes sont respectees.'')'
      texte(1,7) = '(''Option choisie :'',i4)'
      texte(1,9) = '(''Cette option est impossible en dimension'',i2,/)'
      texte(1,10) = '(''Decision en retour de '',a6,'' ='',i2,/)'
c
      texte(2,4) = '(/,a6,'' REFINEMENT CONDITIONS'')'
      texte(2,5) = '(28(''=''),/)'
      texte(2,6) = '(5x,''No more unfilled conditions.'')'
      texte(2,7) = '(''Selected option :'',i4)'
      texte(2,9) =
     > '(''This option is not available with dimension'',i4,/)'
      texte(2,10) = '(''Decision code from '',a6,'' ='',i4,/)'
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
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) taopti(36)
#endif
c
c====
c 2. recuperation des pointeurs, initialisations
c====
c
c 2.1. ==> structure generale
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMH', nompro
#endif
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
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2. tableaux ; codret', codret
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'taopti(36)', taopti(36)
#endif
c
      if ( codret.eq.0 ) then
c
      if ( mod(taopti(36),2).eq.0 ) then
        iaux = 10
      elseif ( mod(taopti(36),3).eq.0 ) then
        iaux = 2
      elseif ( mod(taopti(36),5).eq.0 ) then
        iaux = 6
      else
        codret = 2
      endif
      if ( homolo.ge.2 ) then
        iaux = iaux*29
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'iaux, codret', iaux, codret
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_ar', nompro
#endif
      call utad02 ( iaux, nharet,
     >              phetar, psomar, pfilar, pmerar,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux, adhoar,   jaux,
     >              ulsort, langue, codret )
c
      if ( nbtrto.ne.0 ) then
c
        if ( mod(taopti(36),2).eq.0 ) then
          iaux = 22
        else
          iaux = 2
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_tr', nompro
#endif
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
        if ( mod(taopti(36),2).eq.0 ) then
          iaux = 22
        else
          iaux = 2
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
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
        if ( mod(taopti(36),5).eq.0 ) then
          iaux = 2
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_te', nompro
#endif
          call utad02 ( iaux, nhtetr,
     >                  phette, ptrite, jaux  , jaux  ,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  ulsort, langue, codret )
        endif
c
      endif
c
      if ( nbheto.ne.0 ) then
c
        if ( mod(taopti(36),5).eq.0 ) then
          iaux = 26
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_he', nompro
#endif
          call utad02 ( iaux, nhhexa,
     >                  phethe, pquahe, jaux  , jaux  ,
     >                    jaux,   jaux,   jaux,
     >                    jaux, pcoquh,   jaux,
     >                    jaux,   jaux,   jaux,
     >                  ulsort, langue, codret )
        endif
c
      endif
c
c 2.3. ==> voisinages
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.3. voisinages ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 3
      if ( mod(taopti(36),2).eq.0 .or.
     >     mod(taopti(36),5).eq.0 ) then
        if ( nbteto.ne.0 ) then
          iaux = iaux*5
        endif
        if ( nbheto.ne.0 ) then
          iaux = iaux*7
        endif
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD04', nompro
#endif
      call utad04 ( iaux, nhvois,
     >                jaux,   jaux, pposif, pfacar,
     >              advotr, advoqu,
     >                jaux,   jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      endif
c
c 2.4. ==> decisions
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.4. decisions ; codret', codret
#endif
c
      ntrav1 = taopts(11)
      call gmadoj ( ntrav1, pdecar, iaux, codre1 )
      ntrav2 = taopts(12)
      call gmadoj ( ntrav2, pdecfa, iaux, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
c 2.5. ==> auxiliaires
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.5. auxiliaires ; codret', codret
#endif
c
      iaux = 2 * ( nbtrto + nbquto )
      call gmalot ( ntrav3, 'entier', iaux, adtra3, codre1 )
      iaux = nbnoto
      call gmalot ( ntrav4, 'entier', iaux, adtra4, codre2 )
      iaux = nbarto
      call gmalot ( ntrav5, 'entier', iaux, adtra5, codre3 )
      iaux = nbtrto + nbquto
      call gmalot ( ntrav6, 'entier', iaux, adtra6, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
c
c====
c 3. Application des contraintes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Application contraintes ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
        afaire = 0
c
c 3.1. ==> Decalage de deux elements avant un changement de niveau
c          operationnel en 2D uniquement aujourd'hui
c
        if ( mod(taopti(36),2).eq.0 ) then
c
          if ( sdim.ne.2 ) then
c
            write (ulsort,texte(langue,7)) taopti(36)
            write (ulsort,texte(langue,9)) sdim
            codret = 3
c
          else
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'DECR02', nompro
#endif
          call decr02 ( imem(pdecfa), imem(pdecar),
     >                  imem(psomar),
     >                  imem(pfilar), imem(pmerar), imem(phetar),
     >                  imem(pposif), imem(pfacar),
     >                  imem(phettr), imem(paretr), imem(pnivtr),
     >                  imem(advotr),
     >                  imem(phetqu), imem(parequ), imem(pnivqu),
     >                  imem(adtra3), imem(adtra4),
     >                  imem(adtra5), imem(adtra6),
     >                  afaire,
     >                  ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,10)) 'DECR02', afaire
#endif
          endif
c
        endif
c
c 3.2. ==> Bande de raffinement interdite
c          operationnel en 2D uniquement aujourd'hui
c
        if ( mod(taopti(36),3).eq.0 ) then
c
          if ( sdim.ne.2 ) then
c
            write (ulsort,texte(langue,7)) taopti(36)
            write (ulsort,texte(langue,9)) sdim
            codret = 3
c
          else
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'DECR03', nompro
#endif
          call decr03 ( imem(pdecfa), imem(pdecar),
     >                  imem(phetar), imem(pposif), imem(pfacar),
     >                  imem(phettr), imem(paretr),
     >                  imem(phetqu), imem(parequ),
     >                  imem(adtra3),
     >                  afaire,
     >                  ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,10)) 'DECR03', afaire
#endif
          endif
c
        endif
c
c 3.3. ==> Pas d'elements decoupes seul :
c          . Pas de segments sans la ou les faces auxquelles
c            il appartient
c          . Pas de face sans le ou les volumes auxquels il appartient
c
        if ( mod(taopti(36),5).eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'DECR05', nompro
#endif
          call decr05 ( taopti(31), homolo,
     >                  imem(pdecfa), imem(pdecar),
     >                  imem(phetar), imem(pfilar),
     >                  imem(pposif), imem(pfacar),
     >                  imem(phettr), imem(paretr), imem(advotr),
     >                  imem(phetqu), imem(parequ), imem(advoqu),
     >                  imem(ptrite),
     >                  imem(pquahe), imem(pcoquh),
     >                  imem(adhoar),
     >                  afaire,
     >                  ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,10)) 'DECR05', afaire
#endif
c
        endif
c
      endif
c
c====
c 4. menage
c====
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav3, codre1 )
      call gmlboj ( ntrav4, codre2 )
      call gmlboj ( ntrav5, codre3 )
      call gmlboj ( ntrav6, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
c
c====
c 5. la fin
c====
c
      if ( codret.eq.0 ) then
      if ( afaire.eq.0 ) then
        write (ulsort,texte(langue,6))
      endif
      endif
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
