      subroutine vcsfal ( nbelem, nbf,
     >                    pointl, taigrl, nomgrl,
     >                    coexar,
     >                    frofam, typefr, nogrfr,
     >                    nuelex, narsho,
     >                    fameel, typele, numfam,
     >                    ulsort, langue, codret)
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
c    aVant adaptation - Conversion
c     -                 -
c                     - Suivi de Frontiere - lien Arete Ligne
c                       -        -                -     -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbelem . e   .   1    . nombre d'elements dans le maillage         .
c . nbf    . e   .   1    . nombre de familles du maillage de calcul   .
c . pointl . e   .0:nbfron. pointeur sur le tableau nomgrl             .
c . taigrl . e   .   *    . taille des noms des groupes des frontieres .
c . nomgrl . e   .   *    . noms des groupes des frontieres            .
c . coexar . es  . nbarto*. codes de conditions aux limites portants   .
c .        .     . nctfar . sur les aretes                             .
c . frofam . e   . nbfami . donne l'eventuel numero de ligne           .
c .        .     .        . associee a chaque famille MED              .
c . typefr . es  .   nbf  . type de frontiere (1:ligne/-1:surface)     .
c . nogrfr . es  . 10*nbf . nom des groupes frontieres CAO             .
c . nuelex . e   . nbelem . numerotation des elements en exterieur     .
c . narsho . e   . rsarac . numero des aretes dans HOMARD              .
c . fameel . e   . nbelem . famille med des elements                   .
c . typele . e   . nbelem . type des elements pour le code de calcul   .
c . numfam . e   .   1    . numero MED des familles                    .
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
      parameter ( nompro = 'VCSFAL' )
c
#include "nblang.h"
#include "cofaar.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "dicfen.h"
#include "nombar.h"
#include "refert.h"
#include "rftmed.h"
c
c 0.3. ==> arguments
c
      integer nbelem, nbf
      integer pointl(0:*)
      integer taigrl(*)
      integer coexar(nbarto,nctfar)
      integer frofam(nbf), typefr(nbf)
      integer nuelex(nbelem)
      integer narsho(*), fameel(nbelem), typele(nbelem)
      integer numfam(*)
c
      integer ulsort, langue, codret
c
      character*8 nomgrl(*)
      character*8 nogrfr(10*nbf)
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer el, nufro
      integer typhom
      integer lgngro
c
      character*80 nomgro
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
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
#include "impr03.h"
c
      codret = 0
c
c====
c 2. prise en compte du suivi de frontiere
c    prise en compte de la correspondance entre les aretes de bord
c    et des lignes du format c pour le suivi de frontiere.
c====
c
c     si une arete est attachee a une frontiere alors le premier code
c     contient le numero de la frontiere ; sinon 0
c     le numero de la frontiere est positif si le suivi de frontiere
c     est actif pour cette arete, negatif sinon
c     le deuxieme code contient le numero de la famille dont le
c     numero de frontiere est l'oppose
c
      do 21 , el = 1 , nbelem
c
        typhom = medtrf(typele(el))
c
        if ( typhom.eq.tyhse1 .or. typhom.eq.tyhse2 ) then
c
          nufro = 0
          if ( fameel(el).ne.0 ) then
            do 211 , iaux = 1 , nbf
              if ( numfam(iaux).eq.fameel(el) ) then
                nufro = frofam(iaux)
              endif
  211       continue
          endif
c
          coexar(narsho(nuelex(el)),cosfli) = nufro
c
c     Si on a trouve une frontiere, on doit supprimer
c     l'eventuelle surface
c
          if ( nufro.ne.0 ) then
c
            coexar(narsho(nuelex(el)),cosfsa) = 0
c
c             memorisation pour le suivi
c
            if ( typefr(nufro).eq.0 ) then
c
              if ( codret.eq.0 ) then
c
c       adresse du debut du groupe associe a la frontiere nufro
              iaux = pointl(nufro-1) + 1
c
c       longueur utile du nom du groupe
              lgngro = 0
              do 31 , jaux = iaux , pointl(nufro)
                lgngro = lgngro + taigrl(jaux)
   31         continue
c
              endif
c
              if ( codret.eq.0 ) then
c
c       recuperation du nom du groupe associe a la frontiere nufro
              call uts8ch ( nomgrl(iaux), lgngro, nomgro,
     >                      ulsort, langue, codret )
c
              endif
c
              if ( codret.eq.0 ) then
c
              typefr(nufro) = 1
              call utchs8 ( nomgro, lgngro, nogrfr(10*(nufro-1)+1),
     >                      ulsort, langue, codret )
c
              endif
c
            endif
c
          endif
c
        endif
c
   21 continue
c
c====
c 3. bilan
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
