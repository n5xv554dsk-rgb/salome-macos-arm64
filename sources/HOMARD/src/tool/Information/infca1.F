      subroutine infca1 ( numfic, option,
     >                    nbcham, nocham,
     >                    nrocha, nrocmp, nrotab,
     >                    ulfido, ulenst, ulsost,
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
c   INformation : Fichiers Champs ASCII - 1ere partie
c   --            -        -      -       -
c ______________________________________________________________________
c
c but : determination des choix pour les fichiers
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . numfic . e   .   1    . numero du fichier a ecrire                 .
c . option .   s .   1    . 0 : on ne sort aucun fichier               .
c .        .     .        . 1 : un champ et toutes ses composantes     .
c .        .     .        . 2 : un champ et 1 seule composante         .
c .        .     .        . negatif : la valeur absolue du champ       .
c .        .     .        . positif : la valeur du champ               .
c . nbcham . e   .   1    . nombre de champs definis                   .
c . nocham . e   . nbcham . nom des objets qui contiennent la          .
c .        .     .        . description de chaque champ                .
c . nrocha .   s .   1    . numero du champ retenu pour le coloriage   .
c .        .     .        . -1 si coloriage selon la qualite           .
c . nrocmp .   s .   1    . numero de la composante retenue            .
c . nrotab .   s .   1    . numero du tableau associe au pas de temps  .
c . ulfido . e   .   1    . unite logique du fichier de donnees correct.
c . ulenst . e   .   1    . unite logique de l'entree standard         .
c . ulsost . e   .   1    . unite logique de la sortie standard        .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme dans les memoires             .
c .        .     .        . 3 : probleme dans les fichiers             .
c .        .     .        . 5 : probleme autre                         .
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
      parameter ( nompro = 'INFCA1' )
c
#include "nblang.h"
#include "esutil.h"
c
c 0.2. ==> communs
c
#include "gmenti.h"
#include "gmstri.h"
c
c 0.3. ==> arguments
c
      integer numfic, option
      integer ulfido, ulenst, ulsost
      integer nbcham
      integer nrocha, nrocmp, nrotab
c
      character*8 nocham(nbcham)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nbsign
      integer typsig(3), valent(3)
c
      character*2 valcha(3)
      character*80 chaine
c
      integer iaux
      integer iaux1, iaux2, iaux3
c
      integer nbcomp, nbtvch, typcha
      integer adnocp, adcaen, adcare, adcaca
c
      integer adtrav, lgtrav
c
      character*2 saux02
      character*8 saux08
      character*16 nomcmp
      character*16 saux16
      character*64 saux64
      character*64 nomcha
c
      integer nbmess
      parameter ( nbmess = 100 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisation
c_______________________________________________________________________
c
c====
c 1. initialisation
c====
c
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4)  = '(''0 : aucun fichier'')'
      texte(1,5)  =
     > '(''1 : fichier ascii avec un champ et toutes ses composantes'')'
      texte(1,6)  =
     > '(''2 : fichier ascii avec un champ et 1 seule composante'')'
      texte(1,14) = '(''Option non disponible'',/)'
      texte(1,40) = '(''Quel choix de champ ?'')'
      texte(1,41) = '(''Quelle composante ?'')'
      texte(1,42) = '(''Quel numero de pas de temps ?'')'
      texte(1,48) = '(''Le champ ou sa valeur absolue ? (ch/va)'')'
      texte(1,49) =
     > '(''Repondre ch pour le champ, va pour sa valeur absolue.'')'
      texte(1,100) = '(/,''Creation du fichier ascii numero'',i4)'
c
      texte(2,4) = '(''0 : no file'')'
      texte(2,5)  =
     > '(''1 : ascii file with a field and all its components'')'
      texte(2,6)  =
     > '(''2 : ascii file with a field and a single component'')'
      texte(2,14) = '(''Option still not available'',/)'
      texte(2,40) = '(''What is your choice for the field ?'')'
      texte(2,41) = '(''What is your choice for the component ?'')'
      texte(2,42) = '(''What is your choice for the time step ?'')'
      texte(2,48) = '(''Field or absolute value ? (ch/va)'')'
      texte(2,49) =
     > '(''Answer ch for the field, va for its abslute value.'')'
      texte(2,100) = '(/,''Creation of ascii file #'',i4)'
c
10000 format(a)
10080 format(a80)
11000 format(i10)
c
      write (ulsort,texte(langue,100)) numfic+1
      write (ulsost,texte(langue,100)) numfic+1
c
c====
c 2. questions - reponses pour l'option
c====
c
   20 continue
c
c 2.1. ==> interactivite
c
      write (ulsost,texte(langue,4))
cgn      write (ulsost,texte(langue,5))
      write (ulsost,texte(langue,6))
c
      call dmflsh ( iaux )
      read (ulenst,10080,err=20,end=20) chaine
c
c 2.2. ==> decoupage de la chaine
c
      call utqure ( chaine,
     >              nbsign, typsig, valcha, valent,
     >              ulsort, langue, codret )
cgn      write(ulsort,*) typsig
cgn      write(ulsort,*) valcha
cgn      write(ulsort,*) valent
c
      if ( nbsign.eq.0 ) then
        goto 20
      elseif ( typsig(1).ne.0 ) then
        goto 20
      endif
c
c 2.4. ==> decodage et validation du choix
c
      option = valent(1)
c
      if ( option.le.-1 .or. option.ge.3 .or. option.eq.1 ) then
        write (ulsost,texte(langue,14))
        goto 20
      endif
c
      write(ulfido,1000) chaine
c
c====
c 7. questions - reponses pour le champ
c====
c
      if ( option.ne.0 ) then
c
c 7.1. ==> choix du champ a representer
c
   71 continue
c
      write (ulsost,texte(langue,40))
c
      do 711 , iaux1 = 1 , nbcham
c
        if ( codret.eq.0 ) then
c
        saux08 = nocham(iaux1)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCACH', nompro
#endif
        call utcach ( saux08,
     >                saux64,
     >                nbcomp, nbtvch, typcha,
     >                adnocp, adcaen, adcare, adcaca,
     >                ulsort, langue, codret )
c
        write (ulsost,10000) saux64
c
        endif
c
  711 continue
c
      call dmflsh ( iaux )
      read (ulenst,*,err=71,end=71) nomcha
c
      call utlgut ( iaux2, nomcha,
     >              ulsort, langue, codret )
c
      do 712 , iaux1 = 1 , nbcham
c
        if ( codret.eq.0 ) then
c
        saux08 = nocham(iaux1)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCACH', nompro
#endif
        call utcach ( saux08,
     >                saux64,
     >                nbcomp, nbtvch, typcha,
     >                adnocp, adcaen, adcare, adcaca,
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        call utlgut ( iaux3, saux64,
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        if ( iaux2.eq.iaux3 ) then
          if ( nomcha(1:iaux2).eq.saux64(1:iaux2) ) then
            nrocha = iaux1
            write(ulfido,1000) nomcha
            goto 72
          endif
        endif
c
        endif
c
  712 continue
c
      goto 71
c
c 7.2. ==> choix de la composante a representer
c
   72 continue
c
      if ( option.eq.2 ) then
c
      if ( nbcomp.eq.1 ) then
c
        nrocmp = 1
        nomcmp = smem(adnocp+4)//smem(adnocp+5)
c
      else
c
  721   continue
c
        write (ulsost,texte(langue,41))
c
cgn        write (ulsost,10000) 'norme'
        do 722 , iaux1 = 1 , nbcomp
          write (ulsost,10000) smem(adnocp+3+2*iaux1-1)//
     >                         smem(adnocp+3+2*iaux1)
  722   continue
c
        call dmflsh ( iaux )
        read (ulenst,*,err=72,end=72) nomcmp
        call utlgut ( iaux2, nomcmp,
     >                ulsort, langue, codret )
c
        do 723 , iaux1 = 1 , nbcomp
c
          if ( iaux1.eq.0 ) then
            iaux3 = 5
            saux16(1:iaux3) = 'norme'
          else
            call utlgut ( iaux3, smem(adnocp+3+2*iaux1-1),
     >                    ulsort, langue, codret )
            saux16(1:iaux3) = smem(adnocp+3+2*iaux1-1)(1:iaux3)
            if ( iaux3.eq.8 ) then
              call utlgut ( iaux3, smem(adnocp+3+2*iaux1),
     >                      ulsort, langue, codret )
              if ( iaux3.gt.0 ) then
                saux16(9:8+iaux3) = smem(adnocp+3+2*iaux1)(1:iaux3)
                iaux3 = iaux3 + 8
              endif
            endif
          endif
c
          if ( iaux2.eq.iaux3 ) then
            if ( nomcmp(1:iaux2).eq.saux16(1:iaux2) ) then
              nrocmp = iaux1
              write(ulfido,1000) nomcmp
              goto 73
            endif
          endif
  723   continue
c
        goto 721
c
      endif
c
      endif
c
c 7.3. ==> choix du pas de temps a representer
c
   73 continue
c
      if ( nbtvch.eq.1 ) then
c
        nrotab = 1
c
      else
c
        call gmalot ( saux08, 'entier  ', 2*nbtvch, adtrav, codret )
c
  731   continue
c
        lgtrav = 0
        do 732 , iaux1 = 1 , nbtvch
          iaux3 = imem(adcaen+nbinec*(iaux1-1)+2)
          do 733 , iaux2 = 1 , lgtrav
            if ( imem(adtrav+iaux2-1).eq.iaux3 ) then
              goto 732
            endif
  733     continue
          imem(adtrav+lgtrav) = iaux3
          imem(adtrav+nbtvch+lgtrav) = iaux1
          lgtrav = lgtrav + 1
  732   continue
        if ( lgtrav.eq.1 ) then
          nrotab = 1
          goto 736
        endif
c
        write (ulsost,texte(langue,42))
c
        do 724 , iaux1 = 1 , lgtrav
          write (ulsost,11000) imem(adtrav+iaux1-1)
  724   continue
c
        call dmflsh ( iaux )
        read (ulenst,*,err=731,end=731) iaux2
c
        do 735 , iaux1 = 1 , lgtrav
c
          if ( iaux2.eq.imem(adtrav+iaux1-1) ) then
            nrotab = imem(adtrav+nbtvch+iaux1-1)
            write(ulfido,1115) iaux2
            goto 736
          endif
  735   continue
c
        goto 731
c
  736   continue
c
        call gmlboj ( saux08, codret )
c
      endif
c
c 7.4. ==> le champ ou sa valeur absolue
c
   74 continue
c
      write (ulsost,texte(langue,48))
      call dmflsh ( iaux )
      read (ulenst,*,err=74,end=74) saux02
      if ( saux02.eq.'ch' ) then
        goto 741
      elseif ( saux02.eq.'va' ) then
        option = - option
      else
        write (ulsost,texte(langue,49))
        goto 74
      endif
      write(ulfido,1000) saux02
c
  741 continue
c
      endif
c
 1000 format(a)
 1115 format(i15)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
