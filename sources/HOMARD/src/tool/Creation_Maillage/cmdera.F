      subroutine cmdera ( nomail,
     >                    indnoe, indnp2, indnim, indare,
     >                    indtri, indqua,
     >                    indtet, indhex, indpen,
     >                    lgopts, taopts, lgetco, taetco,
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
c    Creation du Maillage - DERAffinement
c    -           -          ----
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
c . indnoe .   s .   1    . nombre de noeuds restants apres deraff.    .
c . indnp2 .   s .   1    . nombre de noeuds p2 restants apres deraff. .
c . indnim .   s .   1    . nombre de noeuds internes restants ap deraf.
c . indare .   s .   1    . nombre d'aretes restantes apres deraff.    .
c . indtri .   s .   1    . nombre de triangles restants apres deraff. .
c . indqua .   s .   1    . nombre de quads restants apres deraff.     .
c . indtet .   s .   1    . nombre de tetraedres restants apres deraff..
c . indhex .   s .   1    . nombre de hexaedres restants apres deraff. .
c . indpen .   s .   1    . indice du dernier pentaedre cree           .
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
      parameter ( nompro = 'CMDERA' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmreel.h"
c
#include "envca1.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
      character*8 nomail
c
      integer indnoe, indnp2, indnim, indare, indtri, indqua
      integer indtet, indhex, indpen
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
      integer codava, nretap, nrsset
      integer iaux, jaux, ideb, ifin
      integer tbiaux(1)
c
      integer codre1, codre2, codre3, codre4, codre5
      integer codre6, codre7, codre8
      integer codre0
      integer pdecar, pdecfa
      integer phetno, pcoono, pareno
      integer phetar, psomar, pfilar, pmerar, pnp2ar
      integer phettr, paretr, pfiltr, ppertr, pnivtr, adnmtr
      integer phetqu, parequ, pfilqu, pperqu, pnivqu, adnmqu
      integer phette, ptrite, pcotrt, pfilte, pperte
      integer phethe, pquahe, pcoquh, pfilhe, pperhe, adnmhe
      integer phetpe, pfacpe, pcofap, pfilpe, pperpe
      integer pfamno, pcfano
      integer pfamar
      integer pfamtr
      integer pfamqu
      integer pfamte
      integer pfamhe
      integer pfampe
      integer pfacar, pposif
      integer nbpere, pdispe, pancpe, pnoupe
      integer nbhere, pdishe, panche, pnouhe
      integer nbtere, pdiste, pancte, pnoute
cgn      integer nbpyre, pdispy, pancpy, pnoupy
      integer         pdispy, pancpy, pnoupy
      integer nbqure, pdisqu, pancqu, pnouqu
      integer nbtrre, pdistr, panctr, pnoutr
      integer nbarre, pdisar, pancar, pnouar
      integer nbnore, pdisno, pancno, pnouno
      integer nbp2re, nbimre
      integer adhono, adhoar, adhotr, adhoqu
      integer ptrav3, ptrav4
      integer nbancn
c
      character*6 saux
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
      character*8 nnoupy, nnoupe, nnouhe, nnoute
      character*8 nnouqu, nnoutr, nnouar, nnouno
      character*8 ndispy, ndispe, ndishe, ndiste
      character*8 ndisqu, ndistr, ndisar, ndisno
      character*8 ntrav1, ntrav2, ntrav3, ntrav4
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
      nouvno = nbnoto
      nouvar = nbarto
      nouvtr = nbtrto
      nouvqu = nbquto
      nouvte = nbteto
      nouvtf = nouvte
      nouvhe = nbheto
      nouvhf = nouvhe
      nouvpe = nbpeto
      nouvpf = nouvpe
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
      texte(1,4) = '(/,a6,'' DERAFFINEMENT STANDARD DU MAILLAGE'')'
      texte(1,5) = '(41(''=''),/)'
c
      texte(2,4) = '(/,a6,'' STANDARD UNREFINEMENT OF MESH'')'
      texte(2,5) = '(36(''=''),/)'
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
c====
c 2. recuperation des pointeurs
c====
c
c 2.1. ==> structure generale
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.1. ==> structure generale'
#endif
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
c 2.2. ==> tableaux
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2. ==> tableaux'
#endif
c
      iaux = 210
      if ( homolo.ge.1 ) then
        iaux = iaux*11
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD01', nompro
#endif
      call utad01 ( iaux, nhnoeu,
     >              phetno,
     >              pfamno, pcfano,   jaux,
     >              pcoono, pareno, adhono,  jaux,
     >              ulsort, langue, codret )
c
      call gmnomc ( nomail//'.InfoSupE', nhsupe, codre0 )
c
      codret = max ( abs(codre0), codret )
c
      iaux = 210
      if ( degre.eq.2 ) then
        iaux = iaux*13
      endif
      if ( homolo.ge.2 ) then
        iaux = iaux*29
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_ar', nompro
#endif
      call utad02 ( iaux, nharet,
     >              phetar, psomar, pfilar, pmerar,
     >              pfamar,   jaux,   jaux,
     >                jaux, pnp2ar,   jaux,
     >                jaux, adhoar,   jaux,
     >              ulsort, langue, codret )
c
      if ( nbtrto.ne.0 ) then
c
        iaux = 2310
        if ( mod(mailet,2).eq.0 ) then
          iaux = iaux*19
        endif
        if ( homolo.ge.3 ) then
          iaux = iaux*29
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_tr', nompro
#endif
        call utad02 ( iaux, nhtria,
     >                phettr, paretr, pfiltr, ppertr,
     >                pfamtr,   jaux,   jaux,
     >                pnivtr,   jaux,   jaux,
     >                adnmtr, adhotr,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbquto.ne.0 ) then
c
        iaux = 2310
        if ( mod(mailet,3).eq.0 ) then
          iaux = iaux*19
        endif
        if ( homolo.ge.3 ) then
          iaux = iaux*29
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
        call utad02 ( iaux, nhquad,
     >                phetqu, parequ, pfilqu, pperqu,
     >                pfamqu,   jaux,   jaux,
     >                pnivqu,   jaux,   jaux,
     >                adnmqu, adhoqu,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbteto.ne.0 ) then
c
        iaux = 2730
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_te', nompro
#endif
        call utad02 ( iaux, nhtetr,
     >                phette, ptrite, pfilte, pperte,
     >                pfamte,   jaux,   jaux,
     >                  jaux, pcotrt,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbheto.ne.0 ) then
c
        iaux = 2730
        if ( mod(mailet,5).eq.0 ) then
          iaux = iaux*19
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_he', nompro
#endif
        call utad02 ( iaux, nhhexa,
     >                phethe, pquahe, pfilhe, pperhe,
     >                pfamhe,   jaux,   jaux,
     >                  jaux, pcoquh,   jaux,
     >                adnmhe,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbpeto.ne.0 ) then
c
        iaux = 2730
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_pe', nompro
#endif
        call utad02 ( iaux, nhpent,
     >                phetpe, pfacpe, pfilpe, pperpe,
     >                pfampe,   jaux,   jaux,
     >                  jaux, pcofap,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      iaux = 3
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD04', nompro
#endif
      call utad04 ( iaux, nhvois,
     >                jaux,   jaux, pposif, pfacar,
     >                jaux,   jaux,
     >                jaux,   jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      ntrav1 = taopts(11)
      call gmadoj ( ntrav1, pdecar, iaux, codre1 )
      ntrav2 = taopts(12)
      call gmadoj ( ntrav2, pdecfa, iaux, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
cgn      call gmprsx (nompro//'- DECARE', ntrav1)
cgn      call gmprot (nompro//'- DECARE', ntrav1, 1659, 1662)
cgn      if ( nbquto.eq.0 ) then
cgn        call gmprot (nompro//'- DECFAC', ntrav2, 2, nbtrto+1)
cgn      else
cgn        call gmprsx (nompro//'- DECFAC', ntrav2)
cgn      endif
c
      endif
c
c 2.3. ==> allocations supplementaires
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.3. alloc supplementaires ; codret', codret
#endif
c
c 2.3.1. ==> Renumerotation des noeuds
c
      if ( codret.eq.0 ) then
c
      call gmobal ( nhnoeu//'.Deraffin', codre0 )
      if ( codre0.eq.2 ) then
        call gmadoj ( nhnoeu//'.Deraffin', pancno, iaux, codret )
        nbancn = iaux
      elseif ( codre0.eq.0 ) then
        call gmaloj ( nhnoeu//'.Deraffin', ' ', nouvno, pancno, codret )
        nbancn = nouvno
        if ( codret.eq.0 ) then
          do 231 , iaux = 1, nouvno
            imem(pancno+iaux-1) = iaux
  231     continue
        endif
      else
        codret = codre0
      endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmaloj ( nharet//'.Deraffin', ' ', nouvar, pancar, codre1 )
      call gmaloj ( nhtria//'.Deraffin', ' ', nouvtr, panctr, codre2 )
      call gmaloj ( nhquad//'.Deraffin', ' ', nouvqu, pancqu, codre3 )
      call gmaloj ( nhtetr//'.Deraffin', ' ', nouvte, pancte, codre4 )
      call gmaloj ( nhhexa//'.Deraffin', ' ', nouvhe, panche, codre5 )
      call gmaloj ( nhpent//'.Deraffin', ' ', nouvpe, pancpe, codre6 )
      call gmaloj ( nhpyra//'.Deraffin', ' ', nouvpy, pancpy, codre7 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7 )
c
      iaux = nbnoto + 1
      call gmalot ( nnouno, 'entier  ', iaux, pnouno, codre1 )
      iaux = nbarto + 1
      call gmalot ( nnouar, 'entier  ', iaux, pnouar, codre2 )
      iaux = nbtrto + 1
      call gmalot ( nnoutr, 'entier  ', iaux, pnoutr, codre3 )
      iaux = nbquto + 1
      call gmalot ( nnouqu, 'entier  ', iaux, pnouqu, codre4 )
      iaux = nbteto+1
      call gmalot ( nnoute, 'entier  ', iaux, pnoute, codre5 )
      iaux = nbheto+1
      call gmalot ( nnouhe, 'entier  ', iaux, pnouhe, codre6 )
      iaux = nbpeto+1
      call gmalot ( nnoupe, 'entier  ', iaux, pnoupe, codre7 )
      iaux = nbpyto+1
      call gmalot ( nnoupy, 'entier  ', iaux, pnoupy, codre8 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8 )
c
      call gmalot ( ndisno, 'entier  ', nouvno, pdisno, codre1 )
      call gmalot ( ndisar, 'entier  ', nouvar, pdisar, codre2 )
      call gmalot ( ndistr, 'entier  ', nouvtr, pdistr, codre3 )
      call gmalot ( ndisqu, 'entier  ', nouvqu, pdisqu, codre4 )
      call gmalot ( ndiste, 'entier  ', nouvte, pdiste, codre5 )
      call gmalot ( ndishe, 'entier  ', nouvhe, pdishe, codre6 )
      call gmalot ( ndispe, 'entier  ', nouvpe, pdispe, codre7 )
      call gmalot ( ndispy, 'entier  ', nouvpy, pdispy, codre8 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8 )
c
      iaux = max ( nbarto, nbtrto, nbquto, nbteto, nbheto, nbpeto )
      call gmalot ( ntrav3, 'entier  ', iaux, ptrav3, codre1 )
      call gmalot ( ntrav4, 'entier  ', iaux, ptrav4, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c====
c 3. regroupement des entites
c====
c
c 3.1. ==> initialisation des tableaux de "disparition"
c     Par convention, une valeur 0 indique la conservation et
c     une autre valeur la disparition de l'entite concernee par la liste
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.1. Init tableaux disp ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      ideb = pdisno
      ifin = pdisno + nouvno - 1
      do 311 , iaux = ideb , ifin
        imem(iaux) = 0
  311 continue
c
      ideb = pdisar
      ifin = pdisar + nouvar - 1
      do 312 , iaux = ideb , ifin
        imem(iaux) = 0
  312 continue
c
      ideb = pdistr
      ifin = pdistr + nouvtr - 1
      do 313 , iaux = ideb , ifin
        imem(iaux) = 0
  313 continue
c
      ideb = pdisqu
      ifin = pdisqu + nouvqu - 1
      do 314 , iaux = ideb , ifin
        imem(iaux) = 0
  314 continue
c
      ideb = pdiste
      ifin = pdiste + nouvte - 1
      do 315 , iaux = ideb , ifin
        imem(iaux) = 0
  315 continue
c
      ideb = pdishe
      ifin = pdishe + nouvhe - 1
      do 316 , iaux = ideb , ifin
        imem(iaux) = 0
 316  continue
c
      ideb = pdispe
      ifin = pdispe + nouvpe - 1
      do 317 , iaux = ideb , ifin
        imem(iaux) = 0
 317  continue
c
      ideb = pdispy
      ifin = pdispy + nouvpy - 1
      do 318 , iaux = ideb , ifin
        imem(iaux) = 0
 318  continue
c
      endif
c
c 3.2. ==> regroupement des tetraedres
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.2 regroupement tetr ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbteto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMDRTE', nompro
#endif
c
      call cmdrte (
     >         imem(paretr), imem(pdecfa),
     >         imem(ptrite), imem(phette),
     >         imem(pfilte), imem(pdisar), imem(pdistr), imem(pdiste),
     >         imem(pareno), imem(psomar), imem(pcotrt), imem(pdisno),
     >         imem(pnp2ar), imem(ppertr), codret )
c
      endif
c
      endif
c
c 3.3. ==> regroupement des hexaedres
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.3 regroupement hexa ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbheto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMDRHE', nompro
#endif
c
      call cmdrhe (
     >         imem(parequ), imem(pdecfa),
     >         imem(pquahe), imem(phethe),
     >         imem(pfilhe), imem(pdisar), imem(pdisqu), imem(pdishe),
     >         imem(psomar), imem(pdisno),
     >         imem(pnp2ar), codret )
c
      endif
c
      endif
c
c 3.4. ==> regroupement des pentaedres
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.4 regroupement pent ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbpeto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMDRPE', nompro
#endif
c
      call cmdrpe (
     >         imem(paretr), imem(pdecfa),
     >         imem(pfacpe), imem(phetpe),
     >         imem(pfilpe),
     >         imem(pdisar), imem(pdistr), imem(pdisqu), imem(pdispe),
     >         imem(pdisno),
     >         imem(pnp2ar), codret )
c
      endif
c
      endif
c
c 3.5. ==> regroupement des triangles
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.5 regroupement tria ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbtrto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMDRTR', nompro
#endif
c
      call cmdrtr (
     >         imem(paretr), imem(pdecfa),
     >         imem(phettr), imem(pfiltr), imem(adnmtr),
     >         imem(pdisno), imem(pdisar), imem(pdistr), imem(pdisqu),
     >         imem(pdecar), imem(pfilar),
     >         imem(pnp2ar), imem(pposif), imem(pfacar), imem(psomar),
     >         imem(phetno), codret )
c
      endif
c
      endif
c
c 3.6. ==> regroupement des quadrangles
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.6 regroupement quad ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbquto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMDRQU', nompro
#endif
c
      call cmdrqu (
     >         imem(parequ), imem(pdecfa),
     >         imem(phetqu), imem(pfilqu), imem(adnmqu),
     >         imem(pdisno), imem(pdisar), imem(pdistr), imem(pdisqu),
     >         imem(pdecar), imem(pfilar),
     >         imem(pnp2ar), imem(pposif), imem(pfacar), imem(psomar),
     >         imem(phetno), codret )
c
      endif
c
      endif
c
c 3.7. ==> regroupement des aretes
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.7 regroupement aret ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMDRAR', nompro
#endif
c
      call cmdrar (
     >         imem(phetar), imem(pfilar), imem(pnp2ar), imem(psomar),
     >         imem(pdecar),
     >         imem(pdisar), imem(pdisno), imem(pdistr), imem(pdisqu),
     >         imem(phetno), imem(pposif), imem(pfacar), codret )
c
      endif
c
c====
c 4. suppression des entites
c====
c
c 4.1. ==> suppression des tetraedres
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.1. suppression tetr ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbteto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTSUTE', nompro
#endif
c
        call utsute ( imem(pdiste),
     >                imem(phette), imem(pperte), imem(pfilte),
     >                imem(ptrite), imem(pcotrt),
     >                imem(pareno), imem(psomar), imem(paretr),
     >                imem(pancte), imem(pnoute),
     >                nbtere,
     >                codret )
c
        indtet = nbtere
c
      else
c
        indtet = 0
c
      endif
c
      endif
c
c 4.2. ==> suppression des hexaedres
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.2. suppression hexa ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbheto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTSUHE', nompro
#endif
c
        call utsuhe ( imem(pdishe),
     >                imem(phethe), imem(pperhe), imem(pfilhe),
     >                imem(panche), imem(pnouhe),
     >                nbhere )
c
        indhex = nbhere
c
      else
c
        indhex = 0
c
      endif
c
      endif
c
c 4.3. ==> suppression des pentaedres
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.3. suppression pent ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbpeto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTSUPE', nompro
#endif
c
        call utsupe ( imem(pdispe),
     >                imem(phetpe), imem(pperpe), imem(pfilpe),
     >                imem(pancpe), imem(pnoupe),
     >                nbpere )
c
        indpen = nbpere
c
      else
c
        indpen = 0
c
      endif
c
      endif
c
c 4.4. ==> suppression des triangles
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.4. suppression tria ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbtrto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTSUTR', nompro
#endif
c
        call utsutr ( imem(pdistr),
     >                imem(phettr), imem(ppertr), imem(pfiltr),
     >                imem(panctr), imem(pnoutr),
     >                nbtrre )
c
        indtri = nbtrre
c
      else
c
        indtri = 0
c
      endif
c
      endif
c
c 4.5. ==> suppression des quadrangles
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.5. suppression quad ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbquto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTSUQU', nompro
#endif
c
        call utsuqu ( imem(pdisqu),
     >                imem(phetqu), imem(pperqu), imem(pfilqu),
     >                imem(pancqu), imem(pnouqu),
     >                nbqure )
c
        indqua = nbqure
c
      else
c
        indqua = 0
c
      endif
c
      endif
c
c 4.6. ==> suppression des aretes
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.6. suppression aret ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSUAR', nompro
#endif
c
      call utsuar ( imem(pdisar),
     >              imem(phetar), imem(pmerar), imem(pfilar),
     >              imem(pancar), imem(pnouar),
     >              nbarre )
c
      indare = nbarre
c
      endif
c
c 4.7. ==> suppression des noeuds
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.7. suppression noeuds ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSUNO', nompro
#endif
c
      call utsuno ( nbnoto, nouvno, imem(pdisno),
     >              imem(phetno), imem(pancno), imem(pnouno),
     >              nbnore, nbp2re, nbimre )
c
      indnoe = nbnore
      indnp2 = nbp2re
      indnim = nbimre
c
      endif
c
c====
c 5. compactage des numerotations
c====
c
c 5.1. ==> compactage des tetraedres
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.1. compactage tetr ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbteto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTCNTE', nompro
#endif
c
        call utcnte (
     >         imem(ptrite), imem(pcotrt), imem(phette), imem(pfamte),
     >         imem(pfilte), imem(pperte), imem(pancte), imem(pnoute),
     >         imem(pnoutr), nbtere,
     >         imem(ptrav3), imem(ptrav4) )
c
      endif
c
      endif

c
c 5.2. ==> compactage des hexaedres
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.2. compactage hexa ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbheto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTCNHE', nompro
#endif
        call utcnhe (
     >         imem(pquahe), imem(pcoquh), imem(phethe), imem(pfamhe),
     >         imem(pfilhe), imem(pperhe), imem(adnmqu),
     >         imem(panche), imem(pnouhe),
     >         imem(pnouqu), nbhere,
     >         imem(ptrav3), imem(ptrav4) )
c
      endif
c
      endif
c
c 5.3. ==> compactage des pentaedres
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.3. compactage pent ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbpeto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTCNPE', nompro
#endif
        call utcnpe (
     >         imem(pfacpe), imem(pcofap), imem(phetpe), imem(pfampe),
     >         imem(pfilpe), imem(pperpe), imem(pancpe), imem(pnoupe),
     >         imem(pnoutr), imem(pnouqu), nbpere,
     >         imem(ptrav3), imem(ptrav4) )
c
      endif
c
      endif
c
c 5.4. ==> compactage des triangles
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.4. compactage tria ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbtrto.ne.0 ) then
c
        iaux = 1
        if ( mod(mailet,2).eq.0 ) then
          iaux = iaux*2
        endif
        if ( homolo.ge.3 ) then
          iaux = iaux*5
        endif
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTCNTR', nompro
#endif
        call utcntr ( iaux,
     >         imem(phettr), imem(pfamtr), imem(pdecfa), imem(pnivtr),
     >         imem(pfiltr), imem(ppertr),
     >         tbiaux, imem(adnmtr), imem(adhotr),
     >         tbiaux, tbiaux,
     >         imem(panctr), imem(pnoutr), imem(pnouar), imem(paretr),
     >               nbtrre,
     >         imem(ptrav3), imem(ptrav4) )
c
      endif
c
      endif
c
c 5.5. ==> compactage des quadrangles
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.5. compactage quad ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbquto.ne.0 ) then
c
        iaux = 1
        if ( mod(mailet,3).eq.0 ) then
          iaux = iaux*3
        endif
        if ( homolo.ge.3 ) then
          iaux = iaux*5
        endif
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTCNQU', nompro
#endif
        call utcnqu ( iaux,
     >         imem(phetqu), imem(pfamqu), imem(pdecfa), imem(pnivqu),
     >         imem(pfilqu), imem(pperqu),
     >         tbiaux, imem(adnmqu),
     >         tbiaux, tbiaux,
     >         imem(pancqu), imem(pnouqu), imem(pnouar), imem(parequ),
     >               nbqure,
     >         imem(ptrav3), imem(ptrav4) )
c
      endif
c
      endif
c
c 5.6. ==> compactage des aretes
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.6. compactage aret ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCNAR', nompro
#endif
      call utcnar (
     >         imem(psomar), imem(phetar), imem(pfamar), imem(pdecar),
     >         imem(pfilar), imem(pmerar), imem(adhoar), imem(pnp2ar),
     >         imem(paretr), imem(parequ),
     >         imem(pposif), imem(pfacar),
     >         imem(pancar), imem(pnouar), imem(pnouno),
     >         nbtrre, nbqure, nbarre,
     >         imem(ptrav3), imem(ptrav4) )
c
      endif
c
c 5.7. ==> compactage des noeuds
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.7. compactage noeuds ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 1
      if ( mod(mailet,2).eq.0 ) then
        iaux = iaux*2
      endif
      if ( mod(mailet,3).eq.0 ) then
        iaux = iaux*3
      endif
      if ( homolo.ge.1 ) then
        iaux = iaux*5
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCNNO', nompro
#endif
      call utcnno ( iaux,
     >         rmem(pcoono),
     >         imem(phetno), imem(pfamno), imem(pareno), imem(adhono),
     >         tbiaux, tbiaux,
     >         imem(adnmtr),
     >         imem(adnmqu),
     >         imem(pnouar), imem(pnouno), nbnoto )
c
c
      endif
c
c====
c 6. Menage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. Menage ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( nnouno, codre1 )
      call gmlboj ( nnouar, codre2 )
      call gmlboj ( nnoutr, codre3 )
      call gmlboj ( nnouqu, codre4 )
      call gmlboj ( nnoute, codre5 )
      call gmlboj ( nnouhe, codre6 )
      call gmlboj ( nnoupe, codre7 )
      call gmlboj ( nnoupy, codre8 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8 )
c
      call gmlboj ( ndisno, codre1 )
      call gmlboj ( ndisar, codre2 )
      call gmlboj ( ndistr, codre3 )
      call gmlboj ( ndisqu, codre4 )
      call gmlboj ( ndiste, codre5 )
      call gmlboj ( ndishe, codre6 )
      call gmlboj ( ndispe, codre7 )
      call gmlboj ( ndispy, codre8 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8 )
c
      call gmlboj ( ntrav3, codre1 )
      call gmlboj ( ntrav4, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
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
c=======================================================================
      endif
c=======================================================================
c
      end
