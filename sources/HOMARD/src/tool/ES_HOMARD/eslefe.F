      subroutine eslefe ( idfmed, nomamd,
     >                    nhnoeu, nhmapo, nharet, nhtria, nhquad,
     >                    nhtetr, nhhexa, nhpyra, nhpent,
     >                    nhsups,
     >                    ltbsau, tbsaux,
     >                    ulsort, langue, codret)
c
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
c  Entree-Sortie : LEcture des Familles des Entites
c  -      -        --          -            -
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier MED              .
c . nomamd . e   . char64 . nom du maillage MED voulu                  .
c . nhsups . e   . char*8 . informations supplementaires caracteres 8  .
c . ltbsau . e   .    1   . longueur allouee a tbsaux                  .
c . tbsaux .     .    *   . tableau tampon caracteres                  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
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
      parameter ( nompro = 'ESLEFE' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmstri.h"
c
#include "dicfen.h"
#include "nbfami.h"
#include "envca2.h"
c
#include "enti01.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer ltbsau
c
      character*8 tbsaux(ltbsau)
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhsups
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*64 nomamd
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer nbgrox
      parameter (nbgrox = 10000 )
c
      integer iaux, jaux, kaux
      integer cptr, kdeb, kfin, reste
      integer typenh
      integer nbfmed, nrofam, numfam, natt, ngro
      integer adress, nbval
      integer codre0
      integer codre1, codre2
      integer adcono, adcomp, adcoar, adcotr, adcoqu
      integer adcote, adcopy, adcohe, adcope
      integer adcoen
      integer adnogr, lgnogr
      integer numtab, numgro
c
      character*8 nhenti
      character*8 ntnogr
      character*32 saux32
      character*80 nomgro
      character*64 nomfam
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "esimpr.h"
c
      texte(1,4) = '(''. Lecture des familles'')'
      texte(1,6) = '(''Allongement de nomgro.'')'
      texte(1,81) = '(''Longueur allouee pour tbsaux    : '',i10)'
      texte(1,82) = '(''Longueur necessaire pour tbsaux : '',i10)'
c
      texte(2,4) = '(''. Readings of families'')'
      texte(2,6) = '(''Extension of nomgro.'')'
      texte(2,81) = '(''Allocated length for tbsaux    : '',i10)'
      texte(2,82) = '(''Used length for tbsaux : '',i10)'
c
#include "impr03.h"
c
 1002 format(10(a8,'+'))
 1003 format(a80,'+')
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
#endif
c
      codret = 0
c
c====
c 2. Preparatifs
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. Preparatifs ; codret', codret
#endif
c
      do 21 , typenh = -1 , 7
c
        if ( codret.eq.0 ) then
c
        if ( typenh.eq.-1 ) then
          nhenti = nhnoeu
          iaux = nbfnoe
        elseif ( typenh.eq.0 ) then
          nhenti = nhmapo
          iaux = nbfmpo
       elseif ( typenh.eq.1 ) then
          nhenti = nharet
          iaux = nbfare
        elseif ( typenh.eq.2 ) then
          nhenti = nhtria
          iaux = nbftri
        elseif ( typenh.eq.3 ) then
          nhenti = nhtetr
          iaux = nbftet
        elseif ( typenh.eq.4 ) then
          nhenti = nhquad
          iaux = nbfqua
        elseif ( typenh.eq.5 ) then
          nhenti = nhpyra
          iaux = nbfpyr
        elseif ( typenh.eq.6 ) then
          nhenti = nhhexa
          iaux = nbfhex
        else
          nhenti = nhpent
          iaux = nbfpen
        endif
c
        if ( iaux.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,*) ' '
          write (ulsort,*) mess14(langue,4,typenh)
          write (ulsort,90002) 'nbfent', iaux
#endif
c
          call gmadoj ( nhenti//'.Famille.Codes', adcoen, iaux, codre1 )
c
          codret = max ( codret,
     >                   codre1 )
c
        endif
c
        endif
c
        if ( codret.eq.0 ) then
c
        if ( typenh.eq.-1 ) then
          adcono = adcoen
        elseif ( typenh.eq.0 ) then
          adcomp = adcoen
        elseif ( typenh.eq.1 ) then
          adcoar = adcoen
        elseif ( typenh.eq.2 ) then
          adcotr = adcoen
        elseif ( typenh.eq.3 ) then
          adcote = adcoen
        elseif ( typenh.eq.4 ) then
          adcoqu = adcoen
        elseif ( typenh.eq.5 ) then
          adcopy = adcoen
        elseif ( typenh.eq.6 ) then
          adcohe = adcoen
        else
          adcope = adcoen
        endif
c
        endif
c
   21 continue
c
ccc      write (ulsort,90002) 'adcono', adcono
ccc      write (ulsort,90002) 'adcomp', adcomp
ccc      write (ulsort,90002) 'adcoar', adcoar
ccc      write (ulsort,90002) 'adcotr', adcotr
ccc      write (ulsort,90002) 'adcote', adcote
ccc      write (ulsort,90002) 'adcoqu', adcoqu
ccc      write (ulsort,90002) 'adcopy', adcopy
ccc      write (ulsort,90002) 'adcohe', adcohe
ccc      write (ulsort,90002) 'adcope', adcope
c====
c 3. Nombre de familles dans le fichier
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Nombre de familles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFANFA', nompro
#endif
      call mfanfa ( idfmed, nomamd, nbfmed, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,29)) nbfmed
#endif
c
      endif
c
c====
c 4. Lecture des familles MED decrivant les familles HOMARD
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. Lecture des familles ; codret', codret
#endif
c
c 4.0. ==> Allocation d'un tableau tampon pour les noms des groupes
c
      if ( codret.eq.0 ) then
c
      lgnogr = nbgrox*10
      call gmalot ( ntnogr , 'chaine  ', lgnogr, adnogr, codret )
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'lgnogr', lgnogr
#endif
c
      endif
c
      do 40 , nrofam = 1 , nbfmed
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nrofam', nrofam
#endif
c
c 4.1. ==> Caracterisations de la famille en cours de lecture
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFANFG', nompro
#endif
        iaux = nrofam
        call mfanfg ( idfmed, nomamd, iaux, ngro, codret )
c
        endif
#ifdef _DEBUG_HOMARD_
        write(ulsort,90002) 'ngro  ', ngro
#endif
c
c 4.2. ==> Ici, on decode les familles HOMARD
c          ATTENTION : le test est severe mais il faudrait
c          avoir une fonction qui ne renvoie que le nom de la famille,
c          sans retourner nomgro
c
        if ( codret.eq.0 ) then
c
        if ( ngro.gt.nbgrox ) then
#ifdef _DEBUG_HOMARD_
          write(ulsort,90002) 'lgnogr', lgnogr
          write(ulsort,90002) 'ngro  ', ngro
          write (ulsort,texte(langue,6))
#endif
          iaux = ngro*10 + 100
          call gmmod ( ntnogr, adnogr, lgnogr, iaux, 1, 1, codret )
          lgnogr = iaux
#ifdef _DEBUG_HOMARD_
          write(ulsort,90002) 'lgnogr', lgnogr
#endif
c
        endif
c
        endif
c
c 4.3. ==> Lecture du contenu de la famille
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFAFAI', nompro
#endif
        iaux = nrofam
        call mfafai ( idfmed, nomamd, iaux, nomfam, numfam,
     >                smem(adnogr), codret )
c
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '... Famille ', nomfam
      write (ulsort,90002) 'numfam', numfam
      write (ulsort,*) (smem(adnogr+iaux),iaux=0,ngro-1)
      call gmprot(nompro, ntnogr, 1, 41 )
#endif
c
c 4.5. ==> Rangement
c
        if ( codret.eq.0 ) then
c
          do 45 , typenh = -1 , 7
c
            if ( nomfam(1:2).eq.suffix(3,typenh)(1:2) ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '... Famille ', nomfam
      write (ulsort,90002) 'numfam', numfam
#endif
c
c 4.5.1. ==> le numero de la famille HOMARD
c            Attention : le numero de la famille HOMARD associee est
c            le 1er attribut (cf. esecf0). Il faut gerer le decalage
c            des codes en consequence
c
              if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTS8CH', nompro
#endif
              iaux = 80
              call uts8ch ( smem(adnogr), iaux, nomgro,
     >                      ulsort, langue, codret )
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) '... nomgro : ', nomgro
#endif
c
              endif
c
              if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCHEN', nompro//"-4.5.1."
#endif
              call utchen ( nomgro(9:16), kaux,
     >                      ulsort, langue, codret )
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'Numero famille HOMARD', kaux
#endif
              kaux = kaux - 1
c
c 4.5.2. ==> les codes
c
              if ( typenh.eq.-1 ) then
                natt = nctfno
                adcoen = adcono + kaux*nctfno
              elseif ( typenh.eq.0 ) then
                natt = nctfmp
                adcoen = adcomp + kaux*nctfmp
              elseif ( typenh.eq.1 ) then
                natt = nctfar
                adcoen = adcoar + kaux*nctfar
              elseif ( typenh.eq.2 ) then
                natt = nctftr
                adcoen = adcotr + kaux*nctftr
              elseif ( typenh.eq.3 ) then
                natt = nctfte
                adcoen = adcote + kaux*nctfte
              elseif ( typenh.eq.4 ) then
                natt = nctfqu
                adcoen = adcoqu + kaux*nctfqu
              elseif ( typenh.eq.5 ) then
                natt = nctfpy
                adcoen = adcopy + kaux*nctfpy
              elseif ( typenh.eq.6 ) then
                natt = nctfhe
                adcoen = adcohe + kaux*nctfhe
              else
                natt = nctfpe
                adcoen = adcope + kaux*nctfpe
              endif
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'natt', natt
#endif
c
              reste = mod(natt+1,9)
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'reste', reste
#endif
c
              cptr = adcoen - 1
              kdeb = 2
              do 451 , jaux = 1, ngro
                if ( jaux.lt.ngro .or. reste.eq.0 ) then
                  kfin = 9
                else
                  kfin = reste
                endif
                iaux = 80
                call uts8ch ( smem(adnogr+10*(jaux-1)), iaux, nomgro,
     >                        ulsort, langue, codret )
                do 4511 , iaux = kdeb, kfin
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCHEN', nompro//"-do 4511"
#endif
                  call utchen ( nomgro(8*iaux+1:8*(iaux+1)), kaux,
     >                          ulsort, langue, codret )
                  cptr = cptr + 1
                  imem(cptr) = kaux
 4511           continue
                kdeb = 1
  451         continue
c
              endif
c
            endif
c
   45     continue
c
        endif
c
   40 continue
ccc          call gmprsx ( nompro, nhnoeu//'.Famille' )
ccc          call gmprsx ( nompro, nhnoeu//'.Famille.Codes' )
ccc          call gmprsx ( nompro, nhnoeu//'.Famille.Groupe' )
ccc          call gmprsx ( nompro, nharet//'.Famille' )
ccc          call gmprsx ( nompro, nharet//'.Famille.Codes' )
c
c====
c 5. Lecture des familles de sauvegarde
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. Lecture familles sauv. ; codret', codret
#endif
c
      do 50 , nrofam = 1 , nbfmed
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nrofam', nrofam
#endif
c
c 5.1. ==> Caracterisations de la famille en cours de lecture
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFANFG', nompro
#endif
        iaux = nrofam
        call mfanfg ( idfmed, nomamd, iaux, ngro, codret )
c
        endif
c
c 5.2. ==> Controles
c
        if ( codret.eq.0 ) then
c
        if ( 10*ngro.gt.ltbsau ) then
          write (ulsort,texte(langue,81)) ltbsau
          write (ulsort,texte(langue,82)) 10*ngro
          codret = 52
        endif
c
        endif
c
c 5.3. ==> Lecture du contenu de la famille
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFAFAI', nompro
#endif
        iaux = nrofam
        call mfafai ( idfmed, nomamd, iaux, nomfam, numfam,
     >                tbsaux, codret )
c
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '... Famille ', nomfam
      write (ulsort,90002) 'numfam', numfam
      do 5353 , jaux = 1 , ngro
      write (ulsort,1002) (tbsaux(kaux),kaux=10*(jaux-1)+1,10*jaux)
 5353 continue
#endif
c
c 5.3. ==> Rangement
c
        if ( codret.eq.0 ) then
c
c 5.3.1. ==> La date et le titre
c
          if ( nomfam(1:13).eq.'date_et_titre' ) then
c
            if ( codret.eq.0 ) then
c
            iaux = len(ladate)
            call  uts8ch ( tbsaux, iaux, ladate,
     >                     ulsort, langue, codret )
c
            endif
            if ( codret.eq.0 ) then
c
            iaux = 80
            call  uts8ch ( tbsaux(11), iaux, titre,
     >                     ulsort, langue, codret )
c
            endif
cgn           print *,ladate
cgn           print *,titre
c
c 5.3.2. ==> Les informations supplementaires (cf. esecfs)
c
          elseif ( nomfam(1:12).eq.'InfoSupS_Tab' ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '... Famille ', nomfam
      write (ulsort,90002) 'numfam', numfam
      write (ulsort,90002) 'ngro', ngro
      do 53299 , jaux = 1 , ngro
        write (ulsort,1002) (tbsaux(kaux),kaux=10*(jaux-1)+1,10*jaux)
53299 continue
#endif
c
c           La categorie
c
            if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCHEN', nompro//"-5.3.2.a"
#endif
            call utchen ( nomfam(13:64), numtab,
     >                    ulsort, langue, codret )
c
            endif
c
            if ( codret.eq.0 ) then
c
c           Le nombre de valeurs
c
            do 5321 , jaux = 1 , ngro
c
              kaux = 10*(jaux-1) + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'kaux', kaux
      write (ulsort,*) 'tbsaux(kaux)', tbsaux(kaux)
#endif
              if ( tbsaux(kaux).eq.'Nombre d' ) then
c
                numgro = jaux
c
                saux32 =
     > tbsaux(kaux+3)//tbsaux(kaux+4)//tbsaux(kaux+5)//tbsaux(kaux+6)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCHEN', nompro//"-5.3.2.b"
#endif
                call utchen ( saux32, nbval, ulsort, langue, codret )
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbval  ', nbval
      write (ulsort,90002) 'numgro', numgro
#endif
c
                goto 53210
c
              endif
c
 5321       continue
53210       continue
c
            endif
c
c           Gestion memoire
c
            if ( codret.eq.0 ) then
c
            call utlgut ( jaux, nomfam,
     >                    ulsort, langue, codret )
            call gmaloj ( nhsups//'.'//nomfam(10:jaux) , ' ',
     >                    nbval, adress, codre1 )
            call gmecat ( nhsups , numtab, nbval, codre2 )
c
            codre0 = min ( codre1, codre2 )
            codret = max ( abs(codre0), codret,
     >                     codre1, codre2 )
c
            endif
c
c           Les valeurs
c           il faut supprimer le pseudo-groupe du nombre de valeurs
c
            if ( codret.eq.0 ) then
c
            do 5322 , jaux = 1 , ngro
              if ( jaux.ne.numgro ) then
                kaux = 10*(jaux-1)
                do 53221 , iaux = 1, 10
                  smem(adress) = tbsaux(kaux+iaux)
                  adress = adress + 1
53221           continue
              endif
 5322       continue
c            do 5322 , jaux = 0 , nbval-1
c              smem(adress+jaux) = tbsaux(11+jaux)
c 5322       continue
c
            endif
c
          endif
c
        endif
c
   50 continue
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
      call gmlboj ( ntnogr , codret  )
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
      end
