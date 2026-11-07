      subroutine gmprot ( chaine, nom, ideb, ifin )
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
c but : imprime le contenu de l'objet terminal de nom "nom"
c       entre les indices locaux ideb et ifin compris
c       si les deux indices sont nuls, on imprime tout
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . chaine . e   . char*  . chaine de commentaire a imprimer           .
c .  nom   . e   . char*  . nom de la structure a imprimer             .
c .  ideb  . e   .   1    . indice local de debut d'impression         .
c .  ifin  . e   .   1    . indice local de fin d'impression           .
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
      parameter ( nompro = 'GMPROT' )
c
#include "genbla.h"
c
#include "gmmatc.h"
c
c 0.2. ==> communs
c
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
c
#include "gmtail.h"
c
#include "gmcoer.h"
#include "gmimpr.h"
#include "gmlang.h"
c
c 0.3. ==> arguments
c
      character*(*) chaine
      character*(*) nom
c
      integer ideb, ifin
c
c 0.4. ==> variables locales
c
      character*2 saux02
      character*8 typtab
      character*8 nomter
      character*45 fmtstr
      character*45 fmtent
      character*45 fmt131, fmt132
      character*45 fmt141, fmt142
      character*45 fmt151, fmt152
      character*80 saux80
c
      integer iaux, jaux
      integer lgent
      integer iadr, codret, lgtabl, entmax, entmin
      integer ledebu, lafin, nrotab
c
      logical partie
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1.  messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Cet objet est de longueur '',i10,/)'
      texte(1,5) = '(''Objet '',a8,'' :'',/,16(''=''))'
      texte(1,8) = '(''Impression demandee entre'',i10,'' et'',i10)'
      texte(1,9) =
     >'(''=== Structure '',a8,'', type '',a8,'' ==='')'
      texte(1,10) =
     >'(''=== Structure '',a8,'' / '',a,'', type '',a8,'' ==='')'
      texte(1,15) =
     > '(''Impression partielle entre les indices '',i10,'' et '',i10)'
      texte(1,16) = '(''Cet objet est introuvable.'',/)'
      texte(1,17) = '(''Mauvais nom d''''objet.'',/)'
      texte(1,18) =
     > '(''Cet objet est structure ? ou n''''existe pas ?'')'
      texte(1,19) = '(''Cet objet est defini plusieurs fois.'')'
      texte(1,20) = '(''Impression impossible entre'',i10,'' et'',i10)'
c
      texte(2,4) = '(''The length of this object is '',i10,/)'
      texte(2,5) = '(''Object '',a8,'' :'',/,17(''=''))'
      texte(2,8) = '(''Output is requested between'',i10,'' et'',i10)'
      texte(2,9)  = texte(1,9)
      texte(2,10) = texte(1,10)
      texte(2,15) =
     > '(''Partial impression between indices '',i10,'' et '',i10)'
      texte(2,16) = '(''This object is not available.'',/)'
      texte(2,17) = '(''Bad object name.'',/)'
      texte(2,18) =
     > '(''This object is structured ? or is not available ?'')'
      texte(2,19) = '(''This object is defined several times.'')'
      texte(2,20) =
     > '(''Output cannot be done between'',i10,'' et'',i10)'
c
 1000 format(a)
 1100 format(a,/)
c
c               12345678901234567890123456789012345678901234567890
      fmtstr = '( y(ixx,'' : '',a8))                           '
      fmtent = '( y(ixx,'' : '',iz ))                          '
      fmt131 = '(2(i6 ,'' : ( '', g14.7,'' ; '', g14.7,'' )''))    '
      fmt132 = '(2(i6 ,'' : ( '',g23.16,'' ; '',g23.16,'' )''))    '
      fmt141 = '(3(i6 ,'' : '', g14.7))                        '
      fmt142 = '(3(i6 ,'' : '',g23.16))                        '
      fmt151 = '(3(i6 ,'' : '',g23.16))                        '
      fmt152 = '(2(i6 ,'' : '',g39.32))                        '
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) ideb, ifin
#endif
c
c====
c 2. caracteristiques du tableau
c====
c
c 2.1. ==> recherche du nom terminal de l'objet
c
      call gmnomc ( nom, nomter, codret )
c
      if ( codret.eq.-3 ) then
        codret = -2
      elseif ( codret.eq.-1 ) then
        codret = -1
      else
        codret = 0
      endif
c
c 2.3. ==> reperage du pointeur
c          le code de retour est non nul si le tableau n'est pas
c          un objet simple alloue
c
      if ( codret.eq.0 ) then
c
         call gbcara ( nomter, nrotab, iadr, lgtabl, typtab )
c
         if ( coergm.eq.0 ) then
c
           if ( lgtabl.gt.0 ) then
c
              if ( ideb.le.1 .and.
     >            ( ifin.eq.0 .or. ifin.ge.lgtabl ) ) then
                 ledebu = 1
                 lafin = lgtabl
                 partie = .false.
c
              elseif ( ifin.lt.ideb ) then
                 codret = -5
c
              elseif ( ideb.gt.lgtabl .or. ifin.lt.1 ) then
                 codret = -6
c
              else
                 ledebu = max(ideb,1)
                 lafin = min(ifin,lgtabl)
                 partie = .true.
c
              endif
c
           endif
c
         elseif ( coergm.eq.1  ) then
            codret = -3
c
         else
            codret = -4
c
         endif
c
      endif
c
c====
c 3. impression
c    pour les entiers, on optimise la longueur de l'impression
c    . on cherche la plus grande valeur, entmax.
c     on a l'encadrement 10**(n-1) <= entmax < 10**n, donc on utilisera
c     n chiffres significatifs.
c    . si l'une des valeurs du tableau est negative, il faut ajouter
c    une case pour le signe "-".
c====
c
c 3.1. ==> format des indices
c
      if ( codret.eq.0 ) then
c
      if ( lgtabl.gt.0 ) then
c
        saux02 = '3'
        do 31 , iaux = 11 , 0 , -1
          if ( lafin.gt.10**iaux ) then
            if ( iaux.le.6 ) then
              write(saux02(1:1),'(i1)') iaux+3
            else
              write(saux02(1:2),'(i2)') iaux+3
            endif
            lgent = iaux+3
            goto 311
          endif
   31   continue
c
  311   continue
cgn      print *,lafin ,' = ',saux02
c
      endif
c
      endif
c
c 3.2. ==> format des valeurs et impressions
c
      if ( codret.eq.0 ) then
c
        if ( nomter.eq.nom ) then
          write (ulsort,texte(langue,9)) nomter, typtab
        else
          write (ulsort,texte(langue,10)) nomter, nom, typtab
        endif
        if ( len(chaine).gt.0 ) then
          write (ulsort,1000) chaine
        endif
c
        if ( lgtabl.eq.0 ) then
          write (ulsort,texte(langue,4)) lgtabl
c
        else
c
          if ( partie ) then
            write (ulsort,texte(langue,15)) ledebu , lafin
          endif
c
          iadr = iadr - 1
c
          if ( typtab.eq.'entier  ' ) then
            entmax = 0
            entmin = 0
            do 312 , iaux = ledebu , lafin
              entmax = max (entmax,abs(imem(iadr+iaux)))
              entmin = min (entmin,imem(iadr+iaux))
  312       continue
            jaux = 10
            do 322 , iaux = 9 , 1 , -1
              if ( entmax.lt.10**iaux ) then
                jaux = iaux
              endif
  322       continue
            if ( entmin.ne.0 ) then
              jaux = min(jaux+1,15)
            endif
            iaux = lgent + 3 + jaux
            iaux = (120-mod(120,iaux))/iaux
            if ( iaux.le.9 ) then
              write(fmtent(3:3),'(i1)') iaux
            else
              write(fmtent(2:3),'(i2)') iaux
            endif
            fmtent(6:7) = saux02
            if ( jaux.le.9 ) then
              write(fmtent(16:16),'(i1)') jaux
            else
              write(fmtent(16:17),'(i2)') jaux
            endif
            write (ulsort,fmtent)
     >             (iaux,imem(iadr+iaux),iaux=ledebu,lafin)
c
          elseif ( typtab.eq.'chaine  ' ) then
            iaux = lgent + 3 + 8
            iaux = max(10,(120-mod(120,iaux))/iaux)
            write(fmtstr(2:3),'(i2)') iaux
            fmtstr(6:7) = saux02
            write (ulsort,fmtstr)
     >               (iaux,smem(iadr+iaux),iaux=ledebu,lafin)
c
          elseif ( typtab.eq.'reel    ' ) then
            if (treel.eq.4) then
              fmt141(5:6) = saux02
              write (ulsort,fmt141)
     >               (iaux,rmem(iadr+iaux),iaux=ledebu,lafin)
            else
              fmt142(5:6) = saux02
              write (ulsort,fmt142)
     >               (iaux,rmem(iadr+iaux),iaux=ledebu,lafin)
            endif
c
          endif
c
c                          1234567890123456789012345678901234567890
          saux80( 1:40) = '===   ===   ===   ===   ===   ===   === '
          saux80(41:80) = '  ===   ===   ===   ===   ===   ===   =='
          iaux = 16 + len(nom) + 3 + len(nomter) + 19
          write (ulsort,1100) saux80(1:min(80,iaux))
c
        endif
c
      endif
c
c====
c 4. gestion des erreurs
c====
c
      if ( codret.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90000)
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,texte(langue,2)) codret
#endif
        write (ulsort,texte(langue,5)) nomter
        write (ulsort,*) nom
        if ( codret.eq.-6 ) then
          write (ulsort,texte(langue,4)) lgtabl
        endif
        if ( codret.eq.-5 .or. codret.eq.-6 ) then
          write (ulsort,texte(langue,20)) ideb, ifin
        else
          iaux = 15+abs(codret)
          write (ulsort,texte(langue,iaux))
        endif
#ifdef _DEBUG_HOMARD_
        write (ulsort,90000)
90000 format (70('='))
#endif
c
      endif
c
      end
