      subroutine gmmod ( nomet, point,
     >                   d1old, d1new, d2old, d2new, codret )
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
c     modification des tailles d'un objet terminal connu
c     par son nom etendu
c
c . si les tailles sont les memes : on se contente de retourner le
c                                   pointeur associe
c . si les tailles sont toutes positives :
c          on passe de tab(d1old,d2old) a tab(d1new,d2new)
c . si les tailles d1x sont negatives et les tailles d2x positives :
c          on passe de tab(d1old:d2old) a tab(d1new:d2new)
c . sinon : probleme ...
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomet  . e   . char(*). nom etendu en memoire centrale             .
c . point  . es  . ent    . pointeur associe                           .
c . d1old  . e   . ent    . premiere dimension avant                   .
c . d1new  . e   . ent    . premiere dimension apres                   .
c . d2old  . e   . ent    . seconde dimension avant                    .
c . d2new  . e   . ent    . seconde dimension apres                    .
c . codret .  s  . ent    . code retour de l'operation                 .
c .        .     .        .  0 : OK                                    .
c .        .     .        . -1 : objet-terminal pas simple             .
c .        .     .        . -2 : objet-terminal non defini ou non alloue
c .        .     .        . -3 : nom etendu invalide                   .
c .        .     .        .  x : cas non prevu                         .
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
      parameter ( nompro = 'GMMOD' )
c
#include "genbla.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "gmcoer.h"
#include "gmimpr.h"
#include "gmlang.h"
c
c 0.3. ==> arguments
c
      character*(*) nomet
c
      integer point, d1old, d1new, d2old, d2new
      integer codret
c
c 0.4. ==> variables locales
c
      character*8 objrep, objter, chater
      character*8 type8
c
      integer idec, letype, codre0, ilong
      integer iaux
      integer typmod, lgold, lgnew
c
      integer nbmess
      parameter ( nbmess = 20 )
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
      texte(1,4) = '(''Objet a modifier : '',a)'
      texte(1,5) =
     > '(''Passage de ( d1old = '',i10,'' , d2old = '',i10,'')'')'
      texte(1,6) =
     > '(''         a ( d1new = '',i10,'' , d2new = '',i10,'')'')'
      texte(1,11) = '(''L''''objet n''''est pas simple.'')'
      texte(1,12) = '(''Objet non defini ou non alloue.'')'
      texte(1,13) = '(''Nom etendu invalide.'')'
      texte(1,14) = '(''Mauvaises dimensions'')'
      texte(1,15) = '(''Cas imprevu.'')'
      texte(1,16) = '(''Nom incorrect.'')'
      texte(1,17) = '(''Tableau introuvable.'')'
c
      texte(2,4) = '(''Object to modidy: '',a)'
      texte(2,5) =
     > '(''Passage from ( d1old = '',i10,'' , d2old = '',i10,'')'')'
      texte(2,6) =
     > '(''          to ( d1new = '',i10,'' , d2new = '',i10,'')'')'
      texte(2,11) = '(''The object is not simple.'')'
      texte(2,12) = '(''Object not defined or not allocated.'')'
      texte(2,13) = '(''Not valid name.'')'
      texte(2,14) = '(''Bad array sizes.'')'
      texte(2,15) = '(''Impossible case.'')'
      texte(2,16) = '(''Uncorrect name.'')'
      texte(2,17) = '(''Array cannot be found.'')'
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
cgn      if ( nomet.eq.'MaEn002f' ) then
      write (ulsort,texte(langue,4)) nomet
      write (ulsort,texte(langue,5)) d1old, d2old
      write (ulsort,texte(langue,6)) d1new, d2new
cgn      endif
#endif
c
c====
c 2.  controle des dimensions
c====
c
      lgold = d1old*d2old
      lgnew = d1new*d2new
c
c 2.1. ==> pas de changement
c
      if ( d1old.eq.d1new .and. d2old.eq.d2new ) then
c
cgn        write (ulsort,*) '2.1. ==> pas de changement'
        typmod = 0
c
c 2.2. ==> De longeur non nulle devenant de longueur nulle
c
      elseif ( lgold.gt.0 .and. lgnew.eq.0 ) then
c
cgn        write (ulsort,*) '2.2. ==> devenant de longueur nulle'
        typmod = 61
c
c 2.3. ==> la 1ere dimension est toujours nulle, la 2nde est positive :
c          tab(0:d2)
c
      elseif ( d1old.eq.0 .and. d1new.eq.0 .and.
     >         d2old.ge.0 .and. d2new.ge.0 ) then
c
cgn        write (ulsort,*) '2.2. ==> la 1ere dim est =0, la 2nde >=0'
c
        lgold = d2old + 1
        lgnew = d2new + 1
c
c 2.3.1. ==> 2nde dimension : allongement
c
        if ( d2old.lt.d2new ) then
          typmod = 31
c
c 2.3.2. ==> 2nde dimension : raccourcissemement
c
        elseif ( d2old.gt.d2new ) then
          typmod = 32
c
c 2.3.3. ==> autres cas impossibles
c
        else
c
          codret = 4
c
        endif
c
c 2.4. ==> la 1ere dimension est positive ou nulle, la 2nde vaut 1 :
c          tab(d1,1)
C
      elseif ( d1old.ge.0 .and. d1new.ge.0 .and.
     >         d2old.eq.1 .and. d2new.eq.1 ) then
c
cgn        write (ulsort,*) '2.3. ==> la 1ere dim est >=0, la 2nde =1'
c
        lgold = d1old
        lgnew = d1new
c
c 2.4.1. ==> 1ere dimension : allongement
c
        if ( d1old.lt.d1new ) then
          typmod = 11
c
c 2.4.2. ==> 1ere dimension : raccourcissemement
c
        elseif ( d1old.gt.d1new ) then
          typmod = 12
c
c 2.4.3. ==> autres cas impossibles
c
        else
c
          codret = 4
c
        endif
c
c 2.5. ==> la 1ere vaut 1, la 2nde dimension est positive ou nulle :
c          tab(1,d2)
C
      elseif ( d1old.eq.1 .and. d1new.eq.1 .and.
     >         d2old.ge.0 .and. d2new.ge.0 ) then
c
cgn        write (ulsort,*) '2.5. ==> la 1ere dim est =1, la 2nde >=0'
c
        lgold = d2old
        lgnew = d2new
c
c 2.5.1. ==> 2nde dimension : allongement
c
        if ( d2old.lt.d2new ) then
          typmod = 21
c
c 2.5.2. ==> 2nde dimension : raccourcissemement
c
        elseif ( d2old.gt.d2new ) then
          typmod = 22
c
c 2.5.3. ==> autres cas impossibles
c
        else
          codret = 4
c
        endif
c
c 2.6. ==> la premiere dimension est strictement positive : tab(d1,d2)
c          et la seconde etait ou devient nulle
c
      elseif ( d1old.gt.0 .and. d1new.gt.0 .and.
     >         d2old.ge.0 .and. d2new.ge.0 ) then
c
cgn        write (ulsort,*) '2.6. ==> la 1ere dimension est >0'
        lgold = d1old*d2old
        lgnew = d1new*d2new
c
c 2.6.1. ==> 2nde dimension : creation
c
        if ( d2old.eq.0 ) then
          typmod = 1
c
c 2.6.2. ==> 2nde dimension : destruction
c
        elseif ( d2new.eq.0 ) then
          typmod = 2
c
c 2.6.3. ==> pas de particularites
c
        else
          typmod = 5
        endif
c
c 2.7. ==> la seconde dimension est strictement positive : tab(d1,d2)
c          et la premiere etait ou devient nulle
c
      elseif ( d1old.ge.0 .and. d1new.ge.0 .and.
     >         d2old.gt.0 .and. d2new.gt.0 ) then
c
cgn        write (ulsort,*) '2.7. ==> la 2nde dimension est >0'
        lgold = d1old*d2old
        lgnew = d1new*d2new
c
c 2.7.1. ==> 1ere dimension : creation
c
        if ( d1old.eq.0 ) then
          typmod = 3
c
c 2.7.2. ==> 1ere dimension : destruction
c
        elseif ( d1new.eq.0 ) then
          typmod = 4
c
c 2.7.3. ==> pas de particularites
c
        else
          typmod = 5
        endif
c
c 2.8. ==> la 1ere dimension est negative, la 2nde positive : tab(d1:d2)
C
      elseif ( d1old.le.0 .and. d1new.le.0 .and.
     >         d2old.ge.0 .and. d2new.ge.0 ) then
c
cgn        write (ulsort,*) '2.8. ==> la 1ere dim est <=0, la 2nde >=0'
c
        lgold = d2old + 1 - d1old
        lgnew = d2new + 1 - d1new
c
c 2.8.1. ==> 1ere dimension : allongement
c            2nde dimension : constante
c
        if ( d1old.gt.d1new .and. d2old.eq.d2new ) then
          typmod = -1
c
c 2.8.2. ==> 1ere dimension : raccourcissemement
c            2nde dimension : constante
c
        elseif ( d1old.lt.d1new .and. d2old.eq.d2new ) then
          typmod = -3
c
c 2.8.3. ==> 1ere dimension : constante < 0
c            2nde dimension : allongement
c
        elseif ( d1old.eq.d1new .and. d2old.lt.d2new ) then
          typmod = -2
c
c 2.8.4. ==> 1ere dimension : constante < 0
c            2nde dimension : raccourcissemement
c
        elseif ( d1old.eq.d1new .and. d2old.gt.d2new ) then
          typmod = -4
c
c 2.8.5. ==> pas de particularites
c
        else
          typmod = -5
        endif
cgn        write (ulsort,*) '==> typmod = ', typmod
c
c 2.9. ==> le tableau de depart est de longueur nulle
c          la 1ere dimension devient strcitement positive, la 2nde
c          vaut 1, ou l'inverse : tab(d1,1) ou tab(1,d2)
c
      elseif ( d1old.eq.0 .and. d1new.gt.0 .and.
     >         d2old.eq.0 .and. d2new.gt.0 ) then
c
cgn      write (ulsort,*) '2.9. le tableau initial est de longueur 0'
c
        lgold = 0
c
c 2.9.1. ==> 1ere dimension valant 1
c
        if ( d1new.eq.1 ) then
          lgnew = d2new
          typmod = 41
c
c 2.9.2. ==> 2nde dimension valant 1
c
        elseif ( d2new.eq.1 ) then
          lgnew = d1new
          typmod = 51
c
c 2.9.3. ==> autres cas impossibles
c
        else
c
          codret = 4
c
        endif
c
c 2.10. ==> autres cas impossibles
c
      else
c
        write (ulsort,*) 'Ce cas est imprevu ???? '
c
        codret = 5
c
      endif
c
c====
c 3.  decodage du nom etendu
c     determination du type du champ terminal
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. Decodage ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gbdnoe(nomet,objrep,objter,chater,idec)
c
      if (idec.lt.0) then
c
c      nom etendu invalide
c
        codret = -3
c
      else if (idec.eq.1.or.idec.eq.2) then
c
c      objet-terminal indefini ou non aloue
c
        codret = -2
c
      else
c
        call gbobal(objter,letype,codre0)
        if ( codre0.ne.2) then
c
c        objet-terminal non simple
c
          codret = -1
        endif
c
      endif
c
      endif
c
c====
c 4.  appel aux fonctions de plus bas niveau, mais
c     seulement si au moins une des dimensions a bouge.
c     sinon, on ne fait rien !
c
c   letype   -1  'entier'
c   letype   -2  'reel'
c   letype   -3  'chaine'
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. Appel fonctions ; codret = ', codret
#endif
c
cgn       if ( objter.eq.'MaCo002n')then
cgn           print *,'typmod = ',typmod
cgn           print *,'d1old, d1new, d2old, d2new = ',
cgn     > d1old, d1new, d2old, d2new
cgn           print *,'lgold, lgnew = ',lgold, lgnew
cgn       endif
      if ( codret.eq.0 ) then
c
c 4.1. ==> taille identique : recuperation du pointeur
c
      if ( typmod.eq.0 ) then
c
        call gbcara ( objter, iaux, point, ilong, type8 )
c
        codret = coergm
c
c 4.2. ==> changement de taille
c
      else
c
        if ( letype.eq.-1) then
          call gmmodi ( objter, typmod, lgold, lgnew,
     >                  point, d1old, d1new, d2old, d2new )
c
        elseif ( letype.eq.-2) then
          call gmmodr ( objter, typmod, lgold, lgnew,
     >                  point, d1old, d1new, d2old, d2new )
c
        elseif ( letype.eq.-3) then
          call gmmods ( objter, typmod, lgold, lgnew,
     >                  point, d1old, d1new, d2old, d2new )
c
        endif
c
        codret = coergm
c
      endif
c
      else
c
      objter = "        "
c
      endif
c
c====
c 5. gestion des erreurs
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5. Gestions des erreurs ; codret = ', codret
#endif
c
      if ( codret.ne.0 ) then
c
        write (ulsort,90000)
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,texte(langue,4)) nomet//' ('//objter//')'
        write (ulsort,texte(langue,5)) d1old, d2old
        write (ulsort,texte(langue,6)) d1new, d2new
        if ( abs(codret).le.7 .and. coergm.eq.0 ) then
          iaux = 10+abs(codret)
          write (ulsort,texte(langue,iaux))
        endif
        write (ulsort,90000)
c
#include "envex2.h"
c
      endif
c
90000 format (70('='))
c
      end
c
ctest      integer ul, ptr, d1old, d1new, d2old, d2new
ctest      character*8 obj
ctest      ul = 6
ctest      ul = ulsort
ctest      call gmmess(ul)
ctest      write(ul,*)'init'
ctest      d1old=-6
ctest      d2old=8
ctest      codre1 = -d1old+d2old+1
ctest      call gmalot ( obj, 'entier  ', codre1, ptr, codret )
ctest      call zzz(d1old,d2old,imem(ptr),0,ul)
ctest      call zzz(d1old,d2old,imem(ptr),1,ul)
c
ctest      write(ul,*)'idem'
ctest      d1new = -6
ctest      d2new = 8
ctest      call gmmod(obj,ptr, d1old, d1new, d2old, d2new, codret)
ctest      d1old=d1new
ctest      d2old=d2new
ctest      call zzz(d1old,d2old,imem(ptr),1,ul)
c
ctest      write(ul,*)'d2 monte'
ctest      d1new = -6
ctest      d2new = 10
ctest      call gmmod(obj,ptr, d1old, d1new, d2old, d2new, codret)
ctest      d1old=d1new
ctest      d2old=d2new
ctest      call zzz(d1old,d2old,imem(ptr),1,ul)
c
ctest      write(ul,*)'d2 baisse'
ctest      d1new = -6
ctest      d2new = 6
ctest      call gmmod(obj,ptr, d1old, d1new, d2old, d2new, codret)
ctest      d1old=d1new
ctest      d2old=d2new
ctest      call zzz(d1old,d2old,imem(ptr),1,ul)
ctest      write(ul,*)'d1 bouge'
c
ctest      write(ul,*)'re init'
ctest      d1old=-6
ctest      d2old=8
ctest      codre1 = -d1old+d2old+1
ctest      call gmalot ( obj, 'entier  ', codre1, ptr, codret )
ctest      call zzz(d1old,d2old,imem(ptr),0,ul)
ctest      call zzz(d1old,d2old,imem(ptr),1,ul)
c
ctest      write(ul,*)'d1 monte'
ctest      d1new = -8
ctest      d2new = 8
ctest      call gmmod(obj,ptr, d1old, d1new, d2old, d2new, codret)
ctest      d1old=d1new
ctest      d2old=d2new
ctest      call zzz(d1old,d2old,imem(ptr),1,ul)
c
ctest      write(ul,*)'d1 baisse'
ctest      d1new = -4
ctest      d2new = 8
ctest      call gmmod(obj,ptr, d1old, d1new, d2old, d2new, codret)
ctest      d1old=d1new
ctest      d2old=d2new
ctest      call zzz(d1old,d2old,imem(ptr),1,ul)
c
ctest      write(ul,*)'re init'
ctest      d1old=-6
ctest      d2old=8
ctest      codre1 = -d1old+d2old+1
ctest      call gmalot ( obj, 'entier  ', codre1, ptr, codret )
ctest      call zzz(d1old,d2old,imem(ptr),0,ul)
ctest      call zzz(d1old,d2old,imem(ptr),1,ul)
c
ctest      write(ul,*)'d1 monte & d2 monte'
ctest      d1new = -8
ctest      d2new = 10
ctest      call gmmod(obj,ptr, d1old, d1new, d2old, d2new, codret)
ctest      d1old=d1new
ctest      d2old=d2new
ctest      call zzz(d1old,d2old,imem(ptr),1,ul)
c
ctest      write(ul,*)'re init'
ctest      d1old=-6
ctest      d2old=8
ctest      codre1 = -d1old+d2old+1
ctest      call gmalot ( obj, 'entier  ', codre1, ptr, codret )
ctest      call zzz(d1old,d2old,imem(ptr),0,ul)
ctest      call zzz(d1old,d2old,imem(ptr),1,ul)
c
ctest      write(ul,*)'d1 baisse & d2 baisse'
ctest      d1new = -4
ctest      d2new = 6
ctest      call gmmod(obj,ptr, d1old, d1new, d2old, d2new, codret)
ctest      d1old=d1new
ctest      d2old=d2new
ctest      call zzz(d1old,d2old,imem(ptr),1,ul)
c
ctest      write(ul,*)'re init'
ctest      d1old=-6
ctest      d2old=8
ctest      codre1 = -d1old+d2old+1
ctest      call gmalot ( obj, 'entier  ', codre1, ptr, codret )
ctest      call zzz(d1old,d2old,imem(ptr),0,ul)
ctest      call zzz(d1old,d2old,imem(ptr),1,ul)
c
ctest      write(ul,*)'d1 monte & d2 baisse'
ctest      d1new = -8
ctest      d2new = 6
ctest      call gmmod(obj,ptr, d1old, d1new, d2old, d2new, codret)
ctest      d1old=d1new
ctest      d2old=d2new
ctest      call zzz(d1old,d2old,imem(ptr),1,ul)
c
ctest      write(ul,*)'re init'
ctest      d1old=-6
ctest      d2old=8
ctest      codre1 = -d1old+d2old+1
ctest      call gmalot ( obj, 'entier  ', codre1, ptr, codret )
ctest      call zzz(d1old,d2old,imem(ptr),0,ul)
ctest      call zzz(d1old,d2old,imem(ptr),1,ul)
c
ctest      write(ul,*)'d1 baisse & d2 monte'
ctest      d1new = -4
ctest      d2new = 10
ctest      call gmmod(obj,ptr, d1old, d1new, d2old, d2new, codret)
ctest      d1old=d1new
ctest      d2old=d2new
ctest      call zzz(d1old,d2old,imem(ptr),1,ul)
ctest      subroutine zzz(d1,d2,tab,opt,ulsort)
ctest      integer d1, d2, opt,ulsort
ctest      integer tab(d1:d2)
ctest      if ( opt.eq.0 ) then
ctest       do 1 , iaux = d1 , d2
ctest         tab(iaux) = iaux
ctest    1  continue
ctest      else
ctest       do 2 , iaux = d1 , d2
ctest         write(ulsort,20) iaux, tab(iaux)
ctest    2  continue
ctest      endif
ctest  20  format(i4,' : ',i12)
ctest      end
