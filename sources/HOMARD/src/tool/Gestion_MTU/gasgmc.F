      subroutine gasgmc ( nomemc, codret )
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
c     supprimer le graphe d'un objet en memoire centrale
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomemc . e   .char(*) . nom etendu en memoire centrale             .
c . codret .  s  . ent    . code retour de l'operation                 .
c .        .     .        .  0 : OK                                    .
c .        .     .        . -1 : nom d'objet invalide                  .
c .        .     .        . -2 : Probleme dans la liberation d'un objet.
c .        .     .        .      du chemin                             .
c .        .     .        . -3 : Probleme au detachement               .
c .        .     .        . -4 : L'objet n'est pas alloue.             .
c .        .     .        . -5 : L'objet est simple                    .
c .        .     .        . -6 : dimensionnement insuffisant           .
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
      parameter ( nompro = 'GASGMC' )
c
c
#include "genbla.h"
c
#include "gmmatc.h"
c
c 0.2. ==> communs
c
#include "gminds.h"
c
#include "gmcoer.h"
#include "envex1.h"
#include "gmimpr.h"
#include "gmlang.h"
c
c 0.3. ==> arguments
c
      integer codret
c
      character*(*) nomemc 
c
c 0.4. ==> variables locales
c
#include "gmixjx.h"
c
      character*8   chemin(ix,jx), objter
      character*8   objdet(nbjx), objlib(nbjx)
      character*8   obrepc, obterc, chterc
      character*40  mess
c
      integer iaux, jaux, kaux
      integer igrp, nj1, nbojdl, nbojdd, ityc, ioal
      integer impopt, nbchem, lgchem(ix)
c
      logical alloue, attach
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
c ... juste pour ne plus avoir de messages ftnchek :
c
      data objdet / nbjx * '        ' /
      data objlib / nbjx * '        ' /
c
#ifdef _DEBUG_HOMARD_
      impopt = 1
#else
      impopt = 0
#endif
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
      texte(1,6) = '(1x,''Suppression du graphe de l''''objet '',a8)'
      texte(1,4) = '(1x,''en memoire centrale.'')'
      texte(1,11) = '(1x,''Le nom d''''objet est invalide.'')'
      texte(1,12) =
     >  '(1x,''Probleme a la liberation d''''un objet du chemin.'')'
      texte(1,13) = '(1x,''Probleme lors d''''un detachement.'')'
      texte(1,14) = '(1x,''L''''objet n''''est pas alloue.'')'
      texte(1,15) = '(1x,''L''''objet est simple.'')'
      texte(1,16) = '(1x,''Dimensionnement du chemin insuffisant.'')'
c
      texte(2,6) = '(1x,''Suppression of the graph of the object '',a8)'
      texte(2,4) = '(1x,''in central memory.'')'
      texte(2,11) = '(1x,''The name of the object is not valid.'')'
      texte(2,12) = '(1x,''Problem in freeing an object of the path.'')'
      texte(2,13) = '(1x,''Problem in untighting.'')'
      texte(2,14) = '(1x,''The object is not allocated.'')'
      texte(2,15) = '(1x,''The object is simple.'')'
      texte(2,16) = '(1x,''Unsufficient path dimension.'')'
c
      mess = '                                        '
c
c====
c 2. on recherche le type d'allocation
c====
c
c 2.1. ==> decodage du nom
c
      call gbdnoe(nomemc,obrepc,obterc,chterc,codret)
cgn      write(1,*) nompro, codret
c
      if ( codret.lt.0 .or. codret.eq.1 .or. codret.eq.2 ) then
         codret = -1
      else
         codret = 0
      endif
cgn      write(1,*) nompro, codret, coergm
c
c 2.2. ==> l'objet "obterc" est-il alloue ?
c        ioal = 0    : objet non alloue
c        ioal = 1    : objet structure alloue
c        ioal = 2    : objet simple    alloue
c
      if ( codret.eq.0 ) then
c
         call gbobal ( obterc, ityc, ioal )
c
cgn       write(1,*) nompro, ioal, coergm
      endif
c
c====
c 3. si l'objet est structure
c====
c
      if ( codret.eq.0 ) then
c
       if ( ioal.eq.1 ) then
c
c 3.1. ==> nbojdl : nombre d'objets deja liberes
c          nbojdd : nombre d'objets deja detaches
c
         nbojdl = 0
         nbojdd = 0
c
c 3.2. ==> construction du graphe de 'nomemc'
c                          * pour simple alloue
c                          > pour structure alloue
c                          = pour simple non alloue
c                          + pour structure non alloue
c                          - pour simple non defini
c                          < pour structure non defini
c
         iaux = ix
         jaux = jx
         call gagpmc(obterc,iaux,jaux,chemin,lgchem,nbchem,impopt,igrp)
c
         if (igrp.lt.0) then
            mess = ' gasgmc -> gagpmc -> codret : '
            write(mess(29:30),'(i2)') igrp
            codret = -6
            goto 91
         endif
cgn       write(1,*) nompro, codret, coergm
c
c 3.3. ==> liberation de tous les objets du chemin
c
         do 33 , iaux = nbchem , 1 , -1
c
c 3.3.1. ==> recherche de la profondeur du chemin
c
            do 331 , jaux = 3 , jx , 2
               if ((chemin(iaux,jaux)(1:1).eq.'*').or.
     >          (chemin(iaux,jaux)(1:1).eq.'=').or.
     >          (chemin(iaux,jaux)(1:1).eq.'+').or.
     >          (chemin(iaux,jaux)(1:1).eq.'-').or.
     >          (chemin(iaux,jaux)(1:1).eq.'<')) then
                  nj1 = jaux-1
                  goto 332
               endif
  331       continue
            codret = -6
            goto 91
c
  332       continue
c
c 3.3.2. ==> exploration des branches de ce chemin, a l'envers
c            on s'interesse a tous ceux que le graphe declare comme
c            etant alloues. neanmoins, il faut verifier a chaque
c            fois que l'objet est encore alloue car il a pu etre 
c            desalloue dans un chemin precedent.
c            quand on arrive au bout du chemin, il faut detacher
c            le dernier objet de la racine
c
            do 333 , jaux = nj1 , 2 ,-2
c
               objter = chemin(iaux,jaux)
c
               alloue = .true.
               if (objter.eq.sindef) then
                  alloue = .false.
               endif
               if ((chemin(iaux,jaux+1)(1:1).eq.'=').or.
     >          (chemin(iaux,jaux+1)(1:1).eq.'+').or.
     >          (chemin(iaux,jaux+1)(1:1).eq.'-').or.
     >          (chemin(iaux,jaux+1)(1:1).eq.'<')) then
                  alloue = .false.
               endif
               do 334 , kaux = 1,nbojdl
                  if (objlib(kaux).eq.objter) then
                     alloue = .false.
                  endif
  334          continue
c
               if ( alloue ) then
c
                  call gblboj (objter)
cgn       write(1,*) nompro, 'call gblboj (objter)', coergm
                  if ( coergm.ne.0 ) then
                     mess(1:8) = objter
                     codret = -2
                     goto 91
                  endif
c
                  nbojdl = nbojdl+1
                  objlib(nbojdl) = objter
c
               endif
c
               if ( jaux.eq.2 .and. chemin(iaux,2).ne.sindef ) then
c
                  attach = .true.
                  do 335 , kaux = 1,nbojdd
                     if (objdet(kaux).eq.chemin(iaux,1)) then
                        attach = .false.
                     endif
  335             continue
c
                  if ( attach ) then
c
                     call gmdtoj ( obterc//'.'//chemin(iaux,1) , kaux )
cgn      write (ulsort,*) obterc//'.'//chemin(iaux,1) , kaux, coergm
                     if ( kaux.ne.0 ) then
                        mess(1:17) = obterc//'.'//chemin(iaux,1)
                        codret = -3
                        goto 91
                     endif
c
                     nbojdd = nbojdd+1
                     objdet(nbojdd) = chemin(iaux,1)
c
                  endif
c
               endif
c
  333       continue
c
   33    continue
c
c====
c 4. si l'objet est simple : pas de chemin
c====
c
       elseif ( ioal.eq.2 ) then
c
         codret = -5
c
c====
c 5. l'objet n'est pas alloue
c====
c
       else
c
         codret = -4
c
       endif
c
      endif
c
c====
c 9. gestion des erreurs
c====
c
   91 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '9. Gestions des erreurs ; codret = ', codret
      write (ulsort,*) '9. Gestions des erreurs ; coergm = ', coergm
#endif
c
      if ( codret.ne.0 ) then
c
        write (ulsort,90000)
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,texte(langue,6))
        write (ulsort,*) nomemc
        write (ulsort,texte(langue,4))
        if ( abs(codret).le.6 .and. coergm.eq.0 ) then
          iaux = 10+abs(codret)
          write (ulsort,texte(langue,iaux))
        endif
        write (ulsort,*) mess
        write (ulsort,90000)
c
#include "envex2.h"
c
      endif
c
90000 format (1x,70('='))
c
      end
