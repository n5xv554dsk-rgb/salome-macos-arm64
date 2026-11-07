      subroutine utsuex ( disnoe, ancnoe, nbnore, nbp2re, nbimre,
     >                    hetnoe,
     >                    famnoe, arenoe, homnoe,
     >                    nnoeca, nnoeho,
     >                    coonoe,
     >                    disare, ancare, nbarre,
     >                    hetare, somare, merare, filare,
     >                    famare, np2are, homare,
     >                    posifa, facare,
     >                    distri, anctri, nbtrre,
     >                    hettri, aretri, pertri, filtri,
     >                    famtri, nivtri, pentri, nintri, homtri,
     >                    ntreca, ntreho,
     >                    disqua, ancqua, nbqure,
     >                    hetqua, arequa, perqua, filqua,
     >                    famqua, nivqua, hexqua, ninqua,
     >                    nqueca, nqueho,
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
c    UTilitaire - SUppression des entites EXtrudees
c    --           --                      --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . disnoe . e   . nbnoto . indicateurs de disparition des noeuds      .
c . disare . e   . nbarto . indicateurs de disparition des aretes      .
c . distri . e   . nbtrto . indicateurs de disparition des triangles   .
c . disqua . e   . nbquto . indicateurs de disparition des quadrangles .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 5 : mauvais type de code de calcul associe .
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
      parameter ( nompro = 'UTSUEX' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "gmenti.h"
c
#include "envex1.h"
#include "envca1.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nouvnb.h"
#include "nomber.h"
c
c 0.3. ==> arguments
c
      integer disnoe(nbnoto), ancnoe(nbnoto), nbnore
      integer nbp2re, nbimre
      integer hetnoe(nbnoto)
      integer famnoe(nouvno), arenoe(nouvno), homnoe(nouvno)
      integer nnoeca(nouvno), nnoeho(renoac)
      integer disare(nbarto), ancare(nbarto), nbarre
      integer hetare(nbarto), somare(2,nouvar)
      integer famare(nouvar), merare(nouvar), filare(nouvar)
      integer homare(nouvar)
      integer np2are(nouvar)
      integer posifa(0:nbarto), facare(nbfaar)
      integer distri(nbtrto), anctri(nbtrto), nbtrre
      integer hettri(nouvtr), aretri(nouvtr,3)
      integer famtri(nouvtr), pertri(nouvtr), filtri(nouvtr)
      integer nivtri(nouvtr), pentri(nouvtr), nintri(nouvtr)
      integer homtri(nouvtr)
      integer ntreca(nouvtr), ntreho(retrac)
      integer disqua(nbquto), ancqua(nbquto), nbqure
      integer hetqua(nouvqu), arequa(nouvqu,4)
      integer famqua(nouvqu), perqua(nouvqu), filqua(nouvqu)
      integer nivqua(nouvqu), hexqua(nouvqu), ninqua(nouvqu)
      integer nqueca(nouvqu), nqueho(requac)
c
      double precision coonoe(nouvno,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codre1, codre2, codre3, codre4
      integer codre0
      integer ptrav1, ptrav2, ptrav3
      integer pnouqu
      integer pnoutr
      integer pnouar
      integer pnouno
c
      character*8 nnouqu, nnoutr, nnouar, nnouno
      character*8 ntrav1, ntrav2, ntrav3
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
      codret = 0
c
#include "impr03.h"
c====
c 2. Tableaux utilitaires
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. Tableaux utilitaires ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = nbnoto + 1
      call gmalot ( nnouno, 'entier  ', iaux, pnouno, codre1 )
      iaux = nbarto + 1
      call gmalot ( nnouar, 'entier  ', iaux, pnouar, codre2 )
      iaux = nbtrto + 1
      call gmalot ( nnoutr, 'entier  ', iaux, pnoutr, codre3 )
      iaux = nbquto + 1
      call gmalot ( nnouqu, 'entier  ', iaux, pnouqu, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      iaux = max(nbarto, nbtrto+nbquto) + 1
      call gmalot ( ntrav1, 'entier  ', iaux, ptrav1, codre1 )
      iaux = max ( nbarto, nbtrto, nbquto )
      call gmalot ( ntrav2, 'entier  ', iaux, ptrav2, codre2 )
      call gmalot ( ntrav3, 'entier  ', iaux, ptrav3, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
c
      endif
c
c====
c 3. Suppression
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. destruction ; codret', codret
#endif
c 3.1. ==> Suppression des quadrangles inutiles
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.1. quadrangles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSUQU', nompro
#endif
      call utsuqu ( disqua,
     >              hetqua, perqua, filqua,
     >              ancqua, imem(pnouqu),
     >              nbqure )
cgn      write (ulsort,90002) 'nbqure', nbqure
c
      endif
c
c 3.2. ==> Suppression des triangles inutiles
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.2. triangles ; codret', codret
#endif
c
      if ( nbtrto.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTSUTR', nompro
#endif
        call utsutr ( distri,
     >                hettri, pertri, filtri,
     >                anctri, imem(pnoutr),
     >                nbtrre )
cgn        write (ulsort,90002) 'nbtrre', nbtrre
c
      endif
c
      endif
c
c 3.3. ==> Suppression des aretes inutiles
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.3. aretes ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSUAR', nompro
#endif
      call utsuar ( disare,
     >              hetare, merare, filare,
     >              ancare, imem(pnouar),
     >              nbarre )
cgn      write (ulsort,90002) 'nbarre', nbarre
c
      endif
c
c 3.4. ==> Suppression des noeuds inutiles
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.4. noeuds ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSUNO', nompro
#endif
      call utsuno ( nbnoto, nbnoto, disnoe,
     >              hetnoe, ancnoe, imem(pnouno),
     >              nbnore, nbp2re, nbimre )
cgn      write (ulsort,90002) 'nbnore', nbnore
cgn      write (ulsort,90002) 'nbp2re', nbp2re
cgn      write (ulsort,90002) 'nbimre', nbimre
c
      endif
c
c====
c 4. Compactage des numerotation des entites detruites
c====
c 4.1. ==> compactage des triangles
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.1. compactage tria ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbtrto.ne.0 ) then
c
        iaux = 77
        if ( mod(mailet,2).eq.0 ) then
          iaux = iaux*2
        endif
        if ( homolo.ge.3 ) then
          iaux = iaux*5
        endif
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTCNTR', nompro
#endif
        call utcntr (   iaux,
     >                hettri, famtri, imem(ptrav1), nivtri,
     >                filtri, pertri, pentri, nintri, homtri,
     >                ntreca, ntreho,
     >                anctri, imem(pnoutr), imem(pnouar), aretri,
     >                nbtrre,
     >                imem(ptrav2), imem(ptrav3) )
c
      endif
c
      endif
c
c 4.2. ==> compactage des quadrangles
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.2. compactage quad ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 77
      if ( mod(mailet,3).eq.0 ) then
        iaux = iaux*3
      endif
      if ( homolo.ge.3 ) then
        iaux = iaux*5
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCNQU', nompro
#endif
      call utcnqu (   iaux,
     >              hetqua, famqua, imem(ptrav1), nivqua,
     >              filqua, perqua, hexqua, ninqua,
     >              nqueca, nqueho,
     >              ancqua, imem(pnouqu), imem(pnouar), arequa,
     >              nbqure,
     >              imem(ptrav2), imem(ptrav3) )
c
      endif
c
c 4.3. ==> compactage des aretes
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.3. compactage aret ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCNAR', nompro
#endif
      call utcnar ( somare, hetare, famare, imem(ptrav1),
     >              filare, merare, homare, np2are,
     >              aretri, arequa,
     >              posifa, facare,
     >              ancare, imem(pnouar), imem(pnouno),
     >              nbtrre, nbqure, nbarre,
     >              imem(ptrav2), imem(ptrav3) )
c
      endif
c
c 4.4. ==> compactage des noeuds
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.4. compactage noeuds ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 7
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
     >              coonoe,
     >              hetnoe, famnoe, arenoe, homnoe,
     >              nnoeca, nnoeho,
     >              nintri,
     >              ninqua,
     >              imem(pnouar), imem(pnouno), nbnoto )
c
      endif
c
c====
c 5. Menage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. menage ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav1 , codre1  )
      call gmlboj ( ntrav2 , codre2  )
      call gmlboj ( ntrav3 , codre3  )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      call gmlboj ( nnouno , codre1  )
      call gmlboj ( nnouar , codre2  )
      call gmlboj ( nnoutr , codre3  )
      call gmlboj ( nnouqu , codre4  )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
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
