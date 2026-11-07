      subroutine gmcmpr ( codret )
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
c  - interet:
c    . Aucun en mode dynamique de gestion de la memoire !!!!!
c    . En mode statique, on elimine les trous laisses entre les
c      differents tableaux entiers, reels et character*8
c      de maniere a offrir le maximum de place disponible en un seul
c      trou situe en fin des tableaux de travail.
c      attention la reallocation se fait sans reinitialiser la memoire
c      en mettant lindef a 1. lindef est remis a 0 en fin de programme.
c
c      La technique est la suivante :
c      Tant qu'il reste au moins deux trous (en effet, s'il n'en reste
c      qu'un, il est forcement a la fin, donc c'est gagne !) :
c      a. recherche du premier tableau qui suit le premier trou.
c      b. memorisation de son nom, son adresse utile, sa longueur
c      c. retrait de ses references des tables de GM
c      d. allocation d'un tableau de meme nom et de meme longueur : GM
c         va forcement le placer au debut du premier trou et creer
c         un trou a sa suite
c      e. si le tableau n'est pas de longueur nulle, decalage du contenu
c
c    - restriction d'utilisation
c      apres cet appel, il faut prendre soin de rechercher
c      les nouveaux pointeurs des tableaux toujours en usage par appel
c      a gmadoj
c
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . codret .  s  . ent    . code retour de l'operation                 .
c .        .     .        .  0 : OK                                    .
c .        .     .        .  2 : probleme                              .
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
#include "gmmaxt.h"
c
c 0.2. ==> communs
c
#include "gmtyge.h"
c
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
c
#include "gmtrrl.h"
#include "gmtren.h"
#include "gmtrst.h"
c
#include "gmalrl.h"
#include "gmalen.h"
#include "gmalst.h"
c
#include "gmadui.h"
#include "gmadur.h"
#include "gmadus.h"
c
#include "gmimpr.h"
c
#include "gmindf.h"
c
c 0.3. ==> arguments
c
      integer codret
c
c 0.4. ==> variables locales
c
      character*8 nomtab
      character*16 blabla
c
      integer aduold, ilongr, adunew, iptfin
      integer iaux, ideb, nrotab
c
      logical detlg0
c
c 0.5. ==> initialisations
c
      detlg0 = .true.
c ______________________________________________________________________
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) 'Compression de la memoire'
#endif
c
#include "impr03.h"
c
c====
c 1. Pas de compression en mode dynamique
c====
c
      if ( modgm.eq.2) then
c
        codret = 0
#ifdef _DEBUG_HOMARD_
        write(ulsort,*) 'impossible en mode dynamique'
#endif
c
      else
c
      lindef = 1
c
10000 format (//2x,' =======  spg gmcmpr  ==========',/2x,
     >       'Zone en ',a16,/2x,
     >       'le trou debutant en ',i4,' et de longueur ',i4,/2x,
     > 'n''est pas contigu a un tableau entier alloue --> probleme')
c
c====
c 2. traitement du tableau reel
c====
c
#ifdef _DEBUG_HOMARD_
      call gmdmpr ( iaux )
#endif
c
      nrotab = 0
c
    2 continue
c
      if ( ntrour.gt.1 ) then
c
        blabla = 'reel            '
c
c 2.1. ==> on cherche le premier tableau alloue qui suit le trou "1"
c          il suffit d'explorer a partir du dernier trouve
c
        iptfin = ptrour(1) + ltrour(1)
c
        ideb = nrotab + 1
        do 21 , iaux = ideb , nballr
           if ( ptallr(iaux).eq.iptfin ) then
            nrotab = iaux
            goto 22
          endif
   21   continue
c
c --> pb de consistance entre les trous et les variables allouees
c
        write(ulsort,10000) blabla, ptrour(1), ltrour(1)
        iaux = 3
        call gmdmpr ( iaux )
        call ugstop ( 'gmcmpr-reel', ulsort, 0, 1, 1 )
c
c 2.2. ==> on libere ce tableau (apres avoir memorise ses
c          caracteristiques)
c
   22   continue
c
        aduold = adur(nrotab)
        ilongr = lgallr(nrotab)
        nomtab = nomalr(nrotab)
c
        call gmdesr ( nomtab , ilongr , detlg0)
c
c 2.3. ==> on le realloue (--> on detruit ainsi le trou precedant
c          qui se propage vers la droite )
c          attention, l'adresse renvoyee est l'adresse utile
c
        call gmalor ( nomtab , adunew , ilongr )
c
c 2.4. ==> on translate son contenu de l'ancienne position a la nouvelle
c          si le tableau n'est pas de longueur nulle
c
        if ( ilongr.ne.0 ) then
          call gmshfr ( rmem , adunew , aduold , ilongr )
        endif
c
c 2.5. ==> on recommence jusqu'a epuisement
c
        goto 2
c
      endif
c
#ifdef _DEBUG_HOMARD_
      call gmdmpr ( iaux )
#endif
c
c====
c 3. traitement du tableau entier
c    on n'effectue un passage que s'il existe plusieurs trous dans
c    le tableau, car quand il n'y en a qu'un, il est au bout.
c====
c
#ifdef _DEBUG_HOMARD_
      call gmdmpi ( iaux )
#endif
c
      nrotab = 0
c
  3   continue
c
      if ( ntroui.gt.1 ) then
c
        blabla = 'entier          '
c
c 3.1. ==> on cherche le premier tableau alloue qui suit le trou "1"
c          il suffit d'explorer a partir du dernier trouve
c
        iptfin = ptroui(1) + ltroui(1)
c
        ideb = nrotab + 1
        do 31 , iaux = ideb , nballi
          if ( ptalli(iaux).eq.iptfin ) then
            nrotab = iaux
            goto 32
          endif
   31   continue
c
c --> pb de consistance entre les trous et les variables allouees
c
        write(ulsort,10000) blabla, ptroui(1), ltroui(1)
        iaux = 3
        call gmdmpi ( iaux )
        call ugstop ( 'gmcmpr_entier', ulsort, 0, 1, 1 )
c
c 3.2. ==> on libere ce tableau (apres avoir memorise ses
c          caracteristiques)
c
   32   continue
c
        aduold = adui(nrotab)
        ilongr = lgalli(nrotab)
        nomtab = nomali(nrotab)
c
        call gmdesi ( nomtab , ilongr , detlg0)
c
c 3.3. ==> on le realloue (--> on detruit ainsi le trou precedant
c          qui se propage vers la droite )
c          attention, l'adresse renvoyee est l'adresse utile
c
        call gmaloi ( nomtab , adunew , ilongr )
c
c 3.4. ==> on translate son contenu de l'ancienne position a la nouvelle
c          si le tableau n'est pas de longueur nulle
c
        if ( ilongr.ne.0 ) then
          call gmshfi ( imem , adunew , aduold , ilongr )
        endif
c
c 3.5. ==> on recommence jusqu'a epuisement
c
        goto 3
c
      endif
c
#ifdef _DEBUG_HOMARD_
      call gmdmpi ( iaux )
#endif
c
c====
c 4. traitement du tableau character*8
c====
c
#ifdef _DEBUG_HOMARD_
      call gmdmps ( iaux )
#endif
c
      nrotab = 0
c
  4   continue
c
      if ( ntrous.gt.1 ) then
c
        blabla = 'caractere       '
c
c 4.1. ==> on cherche le premier tableau alloue qui suit le trou "1"
c          il suffit d'explorer a partir du dernier trouve
c
        iptfin = ptrous(1) + ltrous(1)
c
        ideb = nrotab + 1
        do 41 , iaux = ideb , nballs
           if ( ptalls(iaux).eq.iptfin ) then
            nrotab = iaux
            goto 42
          endif
   41   continue
c
c --> pb de consistance entre les trous et les variables allouees
c
        write(ulsort,10000) blabla, ptrous(1), ltrous(1)
        iaux = 3
        call gmdmps ( iaux )
        call ugstop ( 'gmcmpr-caractere', ulsort, 0, 1, 1 )
c
c 4.2. ==> on libere ce tableau (apres avoir memorise ses
c          caracteristiques)
c
   42   continue
c
        aduold = adus(nrotab)
        ilongr = lgalls(nrotab)
        nomtab = nomals(nrotab)
c
        call gmdess ( nomtab , ilongr , detlg0)
c
c 4.3. ==> on le realloue (--> on detruit ainsi le trou precedant
c          qui se propage vers la droite )
c          attention, l'adresse renvoyee est l'adresse utile
c
        call gmalos ( nomtab , adunew , ilongr )
c
c 4.4. ==> on translate son contenu de l'ancienne position a la nouvelle
c          si le tableau n'est pas de longueur nulle
c
        if ( ilongr.ne.0 ) then
          call gmshfs ( smem , adunew , aduold , ilongr )
        endif
c
c 4.5. ==> on recommence jusqu'a epuisement
c
        goto 4
c
      endif
c
#ifdef _DEBUG_HOMARD_
      call gmdmps ( iaux )
#endif
c
c====
c 5. fin du travail
c====
c
      minler = min(minler,minmer)
      if ( ntrour.ne.0 ) then
        minmer = ltrour(1)
        if ( nballr.ne.0 ) then
          nommxr = nomalr(nballr)
        endif
      endif
c
      minlei = min(minlei,minmei)
      if ( ntroui.ne.0 ) then
        minmei = ltroui(1)
        if ( nballi.ne.0 ) then
          nommxi = nomali(nballi)
        endif
      endif
c
      minles = min(minles,minmes)
      if ( ntrous.ne.0 ) then
        minmes = ltrous(1)
        if ( nballs.ne.0 ) then
          nommxs = nomals(nballs)
        endif
      endif
c
c lindef est remis a 0 pour permettre de nouveau l'initialisation
c
      lindef = 0
c
      codret = 0
c
      endif
c
      end
