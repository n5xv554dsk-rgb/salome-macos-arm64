      subroutine vcsfas ( nbelem, nbf,
     >                    pointl, taigrl, nomgrl,
     >                    coexar, coextr, coexqu,
     >                    frofam, decala, typefr, nogrfr,
     >                    nuelex,
     >                    fameel, typele, numfam,
     >                    aretri, ntrsho,
     >                    arequa, nqusho,
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
c                     - Suivi de Frontiere - lien Arete Surface
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
c . coextr . es  . nbtrto*. codes de conditions aux limites portants   .
c .        .     . nctftr . sur les triangles                          .
c . coexqu . es  . nbquto*. codes de conditions aux limites portants   .
c .        .     . nctfqu . sur les quadrangles                        .
c . frofam . e   . nbfami . donne l'eventuel numero de surface         .
c .        .     .        . associee a chaque famille MED              .
c . decala . e   .   1    . decalage dans le stockage des numeros de fr.
c . typefr . es  .   nbf  . type de frontiere (1:ligne/-1:surface)     .
c . nogrfr . es  . 10*nbf . nom des groupes frontieres CAO             .
c . nuelex . e   . nbelem . numerotation des elements en exterieur     .
c . fameel . e   . nbelem . famille med des elements                   .
c . typele . e   . nbelem . type des elements pour le code de calcul   .
c . numfam . e   .   1    . numero MED des familles                    .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . ntrsho . e   . rstrac . numero des triangles dans HOMARD           .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . nqusho . e   . rsquac . numero des quadrangles dans HOMARD         .
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
      parameter ( nompro = 'VCSFAS' )
c
#include "nblang.h"
#include "cofaar.h"
#include "cofatq.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "dicfen.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "refert.h"
#include "rftmed.h"
c
c 0.3. ==> arguments
c
      integer nbelem, nbf
      integer pointl(0:*)
      integer taigrl(*)
      integer coexar(nbarto,nctfar)
      integer coextr(nbtrto,nctftr)
      integer coexqu(nbquto,nctfqu)
      integer frofam(nbf), decala
      integer typefr(nbf)
      integer nuelex(nbelem)
      integer fameel(nbelem), typele(nbelem)
      integer numfam(*)
      integer aretri(nbtrto,3), ntrsho(*)
      integer arequa(nbquto,4), nqusho(*)
c
      integer ulsort, langue, codret
c
      character*8 nomgrl(*)
      character*8 nogrfr(10*nbf)
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer el, nufro
      integer typhom
      integer larete
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
c 2. prise en compte de la correspondance entre les aretes
c    et les surfaces pour le suivi de frontiere.
c====
c     si une arete est attachee a une surface alors le premier code
c     contiendra le numero de la surface ; sinon 0
c     le numero de la surface est positif si le suivi de frontiere
c     est actif pour cette arete, negatif sinon
c     le deuxieme code contient le numero de la famille dont le
c     numero de surface est l'oppose
c
      do 21 , el = 1 , nbelem
c
        typhom = medtrf(typele(el))
c
        if ( typhom.eq.tyhtr1 .or. typhom.eq.tyhtr2 .or.
     >       typhom.eq.tyhqu1 .or. typhom.eq.tyhqu2 ) then
c
          if ( fameel(el).ne.0 ) then
c
            nufro = 0
            do 211 , iaux = 1 , nbf
              if ( numfam(iaux).eq.fameel(el) ) then
                nufro = frofam(iaux)
              endif
  211       continue
c
            if ( nufro.ne.0 ) then
c
c             complement dans le descriptif de la face
c
              if ( typhom.eq.tyhtr1 .or. typhom.eq.tyhtr2 ) then
                kaux = 3
              else
                kaux = 4
              endif
c
              do 212 , iaux = 1 , kaux
                if ( typhom.eq.tyhtr1 .or. typhom.eq.tyhtr2 ) then
                  larete = aretri(ntrsho(nuelex(el)),iaux)
                else
                  larete = arequa(nqusho(nuelex(el)),iaux)
                endif
                if ( coexar(larete,cosfsa).eq.nufro .or.
     >               coexar(larete,cosfsa).eq. 0 ) then
                  coexar(larete,cosfsa) = nufro
                else
                  coexar(larete,cosfsa) = -1968
                endif
  212         continue
c
c             memorisation pour le suivi
c
              if ( typefr(nufro).eq.0 ) then
c
                if ( codret.eq.0 ) then
c
c       adresse du debut du groupe associe a la frontiere nufro
                iaux = pointl(nufro-1 - decala) + 1
c
c       longueur utile du nom du groupe
                lgngro = 0
                do 31 , jaux = iaux , pointl(nufro - decala)
                  lgngro = lgngro + taigrl(jaux)
   31           continue
c
                endif
c
                if ( codret.eq.0 ) then
c
c       recuperation du nom du groupe associe a la frontiere nufro
                call uts8ch ( nomgrl(iaux), lgngro, nomgro,
     >                        ulsort, langue, codret )
c
                endif
c
                if ( codret.eq.0 ) then
c
                typefr(nufro) = -1
                call utchs8 ( nomgro, lgngro, nogrfr(10*(nufro-1)+1),
     >                        ulsort, langue, codret )
c
                endif
c
              endif
c
            endif
c
            if ( typhom.eq.tyhtr1 .or. typhom.eq.tyhtr2 ) then
              coextr(ntrsho(nuelex(el)),cosfsu) = nufro
            else
              coexqu(nqusho(nuelex(el)),cosfsu) = nufro
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
