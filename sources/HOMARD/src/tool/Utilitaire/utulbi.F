      subroutine utulbi ( nuroul, nomflo, lnomfl,
     >                    typfic, motcle, numer1, numer2,
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
c    UTilitaire - Unite Logiques des BIlans
c    --           -     -            --
c ______________________________________________________________________
c
c  but : retourner le numero d'unite logique associe aux fichiers
c        d'ecriture des bilans.
c        . on ouvre le fichier et on renvoie le numero attribue.
c        . la premiere cause d'erreur donnant un code de retour non nul
c          est une mauvaise demande de type de fichier.
c          ensuite, en cas d'erreur dans la recherche du fichier, si le
c          type demande est positif, on renvoie le numero de la sortie
c          standard. si le type est negatif on renvoie un code 3.
c
c Selon qu'un mot-cle a ete fourni ou non, le fichier a pour nom :
c         "info".+[numer1.]+[numer2.]+suffixe(typfic)
c         prefixe.+[numer1.]+[numer2.]+suffixe(typfic)
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nuroul .  s  .    1   . numero d'unite logique lie au fichier      .
c . nomflo .  s  .  200   . nom local du fichier                       .
c . lnomfl .  s  .    1   . longueur du nom local du fichier           .
c . typfic . e   .    1   . type de fichier souhaite :                 .
c .        .     .        . 1 : bilan sur les entites                  .
c .        .     .        . 2 : pour xmgrace                           .
c .        .     .        . 3 : histogramme sur l'indicateur d'erreur  .
c .        .     .        . 4 : postscript                             .
c .        .     .        . 5 : champ en ascii                         .
c .        .     .        . 6 : xfig                                   .
c .        .     .        . 7 : texte                                  .
c .        .     .        . 8 : log                                    .
c .        .     .        . 9 : numero d'iteration                     .
c .        .     .        . 10 : valeurs brutes                        .
c .        .     .        . 100 : fortran des objets stockes           .
c . motcle . e   .    *   . si longueur > 0 : remplace le prefixe      .
c .        .     .        . si longueur = 0 : on garde le prefixe      .
c . numer1 . e   .    1   . si >= 0 : 1er numero a intercaler          .
c .        .     .        . si < 0 : on ne fait rien                   .
c . numer2 . e   .    1   . si >= 0 : 2nd numero a intercaler          .
c .        .     .        . si < 0 : on ne fait rien                   .
c . ulsort . e   .    1   . unite logique de la liste standard         .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour                             .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : mauvais type de fichier demande        .
c .        .     .        . 3 : probleme a l'ouverture                 .
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
      parameter ( nompro = 'UTULBI' )
c
#include "nblang.h"
#include "motcle.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nuroul, lnomfl
      integer typfic, numer1, numer2
c
      character*(*) nomflo
      character*(*) motcle
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer lnomfi, lgchai
c
      character*1 slash
      character*5 suffix
      character*8 typobs
      character*100 chaine
      character*200 nomfic
c
      integer nbmess
      parameter ( nbmess = 10 )
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
      texte(1,5) = '(''Mot-cle : '',a)'
      texte(1,6) = '(''Numero '',i8,'' : '',i4)'
      texte(1,4) = '(''Type de fichier demande : '',i4)'
      texte(1,7) = '(''            --> suffixe : '',a5)'
      texte(1,8) = '(''Repertoire racine : '',a)'
      texte(1,9) = '(''Unite logique :'',i3)'
      texte(1,10) = '(''Nom du fichier : '',a)'
c
      texte(2,5) = '(''Keyword: '',a)'
      texte(2,6) = '(''Number '',i8,'': '',i4)'
      texte(2,4) = '(''File type: '',i4)'
      texte(2,7) = '(''      --> : '',a5)'
      texte(2,8) = '(''Root directory: '',a)'
      texte(2,9) = '(''Logical unit:'',i3)'
      texte(2,10) = '(''File name: '',a)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) typfic
      write (ulsort,texte(langue,5)) motcle
      write (ulsort,texte(langue,6)) 1, numer1
      write (ulsort,texte(langue,6)) 2, numer2
#endif
c
c====
c 2. type de fichier
c====
c
      if ( abs(typfic).eq.1 ) then
        suffix = 'bilan'
      elseif ( abs(typfic).eq.2 ) then
        suffix = 'dat  '
      elseif ( abs(typfic).eq.3 ) then
        suffix = 'hist '
      elseif ( abs(typfic).eq.4 ) then
        suffix = 'ps   '
      elseif ( abs(typfic).eq.5 ) then
        suffix = 'data '
      elseif ( abs(typfic).eq.6 ) then
        suffix = 'fig  '
      elseif ( abs(typfic).eq.7 ) then
        suffix = 'txt  '
      elseif ( abs(typfic).eq.8 ) then
        suffix = 'log  '
      elseif ( abs(typfic).eq.9 ) then
        suffix = 'iter '
      elseif ( abs(typfic).eq.10 ) then
        suffix = 'dat  '
      elseif ( abs(typfic).eq.100 ) then
        suffix = 'F    '
      else
        codret = 1
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) suffix
#endif
c
      nomfic(  1: 80) = blan80
      nomfic( 81:160) = blan80
      nomfic(161:200) = blan80(1:40)
c
c====
c 3. Definition du repertoire des fichiers
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Repertoire ; codret', codret
#endif
c 3.1. ==> Recherche de la donnee eventuelle
c
      if ( codret.eq.0 ) then
c
      typobs = mcrepi
c
      call utosde ( typobs, ulsort, langue, codret )
c
      if ( codret.ne.0 ) then
c
        codret = 0
        lnomfi = 1
        nomfic(1:lnomfi) = '.'
c
      else
c
        iaux = 0
        jaux = 1
        call utfino ( typobs, iaux, nomfic, lnomfi,
     >                jaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 3.2. ==> Mise en forme du nom du repertoire
c
      if ( codret.eq.0 ) then
c
      call dmsepf ( slash )
      lnomfi = lnomfi + 1
      nomfic(lnomfi:lnomfi) = slash
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      if ( lnomfi.gt.0 ) then
      write (ulsort,90002) 'lnomfi', lnomfi
      write (ulsort,texte(langue,8)) nomfic(1:lnomfi)
      endif
      endif
#endif
c
c====
c 4. nom complet du fichier
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. nom du fichier ; codret', codret
#endif
c
      if ( lnomfi.gt.0 ) then
c
c 4.1. ==> mot-cle a intercaler
c
        if ( codret.eq.0 ) then
c
        call utlgut ( lgchai, motcle,
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        nomflo(  1: 80) = blan80
        nomflo( 81:160) = blan80
        nomflo(161:200) = blan80(1:40)
c
        if ( lgchai.eq.0 ) then
c
          lnomfl = 4
          nomflo(1:lnomfl) = 'info'
c
        else
c
          lnomfl = lgchai
          nomflo(1:lnomfl) = motcle(1:lgchai)
cc          nomflo(1:lgchai) = motcle(1:lgchai)
cc          lnomfl = lgchai
c
        endif
c
        endif
c
c 4.2. ==> 1ere chaine a intercaler
c          En general, on impose un retour sur au moins 2 caracteres
c          Pour les valeurs brutes, au moins 3 caracteres
c
        if ( numer1.ge.0 ) then
c
          if ( codret.eq.0 ) then
c
          if ( numer1.lt.100 .and. abs(typfic).ne.10 ) then
            iaux = 2
          elseif ( numer1.lt.1000 ) then
            iaux = 3
          elseif ( numer1.lt.10000 ) then
            iaux = 4
          else
            iaux = len(chaine)
          endif
          call utench ( numer1, '0', lgchai, chaine(1:iaux),
     >                  ulsort, langue, codret )
c
          endif
cgn          print *,'lgchai = ',lgchai
cgn          print *,'chaine = ',chaine
c
          if ( codret.eq.0 ) then
c
          iaux = lnomfl + 1 + lgchai
          nomflo(lnomfl+1:iaux) = '.'//chaine(1:lgchai)
          lnomfl = iaux
c
          endif
c
        endif
c
c 4.3. ==> 2ere chaine a intercaler
c          Remarque : on impose un retour sur 3 caracteres
c
        if ( numer2.ge.0 ) then
c
          if ( codret.eq.0 ) then
c
          call utench ( numer2, '0', lgchai, chaine(1:3),
     >                  ulsort, langue, codret )
c
          endif
cgn          print *,'lgchai = ',lgchai
cgn          print *,'chaine = ',chaine
c
          if ( codret.eq.0 ) then
c
          iaux = lnomfl + 1 + lgchai
          nomflo(lnomfl+1:iaux) = '.'//chaine(1:lgchai)
          lnomfl = iaux
c
          endif
c
        endif
c
c 4.4. ==> suffixe retenu
c
        if ( codret.eq.0 ) then
c
        call utlgut ( lgchai, suffix,
     >                ulsort, langue, codret )
c
        iaux = lnomfl + 1 + lgchai
        nomflo(lnomfl+1:iaux) = '.'//suffix(1:lgchai)
        lnomfl = iaux
c
        endif
c
c 4.5. ==> nom complet
c
        if ( codret.eq.0 ) then
c
        nomfic(lnomfi+1:lnomfi+1+lnomfl) = nomflo(1:lnomfl)
        lnomfi = lnomfi+lnomfl
c
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,10)) nomflo(1:lnomfl)
        write (ulsort,texte(langue,10)) nomfic(1:lnomfi)
#endif
c
      endif
c
c====
c 5. recherche de l'unite logique associee
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. unite logique ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
c 5.1. ==> rien n'a ete precise, on le met dans la sortie standard
c
      if ( lnomfi.le.0 ) then
c
        nuroul = ulsort
c
c 5.2. ==> recherche du numero d'unite logique associee au fichier
c          soit il existe deja, soit on le cree.
c
      else
c
cgn        call guinfo
        call gucara ( nomfic, lnomfi, nuroul, codret)
c
        if ( codret.eq.0 ) then
c
        if ( nuroul.eq.0 ) then
          call guoufs ( nomfic, lnomfi, nuroul, codret )
          if ( codret.eq.0 ) then
            call gurbbu ( nuroul, codret)
          else
            codret = 0
            nuroul = ulsort
          endif
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,9)) nuroul
#endif
c
        endif
c
      endif
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
      write (ulsort,texte(langue,4)) typfic
      write (ulsort,texte(langue,5)) motcle
      write (ulsort,texte(langue,6)) 1, numer1
      write (ulsort,texte(langue,6)) 2, numer2
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
