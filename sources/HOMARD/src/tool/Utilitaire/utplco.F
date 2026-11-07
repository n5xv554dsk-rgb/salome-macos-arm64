      subroutine utplco ( tyconf,
     >                    decare, decfac,
     >                    hetare,
     >                    hettri, aretri,
     >                    hetqua, arequa,
     >                    hettet, tritet,
     >                    hethex, quahex, coquhe,
     >                    hetpen, facpen,
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
c     UTilitaire : PLace pour la COnformite
c     --           --            --
c ______________________________________________________________________
c
c but : decompte les entites a creer lors du decoupage de conformite
c       des triangles, des quadrangles, des tetraedres, des hexaedres
c       et des pentaedres.
c       remarque : met a jour les decisions de decoupage en 2 des
c                  faces (on suppose que cela n'a pas deja ete fait).
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . tyconf . e   .   1    .  0 : conforme (defaut)                     .
c .        .     .        .  1 : non-conforme avec au minimum 2 aretes .
c .        .     .        .      non decoupees en 2                    .
c .        .     .        .  2 : non-conforme avec 1 seul noeud        .
c .        .     .        .      pendant par arete                     .
c .        .     .        .  3 : non-conforme fidele a l'indicateur    .
c .        .     .        . -1 : conforme, avec des boites pour les    .
c .        .     .        .      quadrangles, hexaedres et pentaedres  .
c .        .     .        . -2 : non-conforme avec au maximum 1 arete  .
c .        .     .        .      decoupee en 2 (boite pour les         .
c .        .     .        .      quadrangles, hexaedres et pentaedres) .
c . decare . e   . nbarto . decisions des aretes                       .
c . decfac . e   . -permqu. decision sur les faces (quad. + tri.)      .
c .        .     . :permtr.                                            .
c . hetare . e   . permar . historique de l'etat des aretes            .
c . hettri . e   . permtr . historique de l'etat des triangles         .
c . aretri . e   .permtr*3. numeros des 3 aretes des triangles         .
c . hetqua . e   . permqu . historique de l'etat des quadrangles       .
c . arequa . e   .permqu*4. numeros des 4 aretes des quadrangles       .
c . hettet . e   . permte . historique de l'etat des tetraedres        .
c . tritet . e   .permte*4. numeros des 4 triangles des tetraedres     .
c . hethex . e   . permhe . historique de l'etat des hexaedres         .
c . quahex . e   .permhe*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .permhe*6. codes des 6 quadrangles des hexaedres      .
c . hetpen . e   . permpe . historique de l'etat des pentaedres        .
c . facpen . e   .permpe*5. numeros des faces des pentaedres           .
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
      parameter ( nompro = 'UTPLCO' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
#include "nouvnb.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer tyconf
      integer decare(0:nbarto)
      integer decfac(-permqu:permtr)
      integer hetare(permar)
      integer aretri(permtr,3), hettri(permtr)
      integer arequa(permqu,4), hetqua(permqu)
      integer tritet(permte,4), hettet(permte)
      integer hethex(permhe)
      integer quahex(permhe,6), coquhe(permhe,6)
      integer facpen(permpe,5), hetpen(permpe)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer listar(12), etdare(12)
      integer lamail
      integer nbreso, nbrear, nbrepy, nbrete, nbrehe
      integer cpt0, cpt1, cpt2, cpt3, cpt4, cpt5
      integer nbfad2, nbfad3, nbfad4
      integer nbfat4, nbfaq4, et, dt
      integer fj
      integer dectot
#ifdef _DEBUG_HOMARD_
      integer glop
#endif
c
      logical noinma
c
      integer nbmess
      parameter ( nbmess = 10 )
c
      character*80 texte(nblang,nbmess)
      character*40 mess40(nblang,1)
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
c                    1234567890123456789012345678901234567890
      mess40(1,1) = ' Nombres d''entites du nouveau maillage  '
c
      mess40(2,1) = '   Number of entities of the new mesh   '
c
#include "impr03.h"
c
cgn      write(ulsort,91040) decare
c
60000 format(
     >  5x,'==========================================================',
     >/,5x,'!        ',a40                                 ,'        !'
     >/,5x,'==========================================================',
     >/,5x,'!     ',       a14,'   !      Total     ! ',       a14,' !',
     >/,5x,'==========================================================')
c                                     1234567890
61000 format(
     >  5x,'!     ',       a14,'   !  ',   i10,'    !  ',   i10,'    !')
62000 format(
     >  5x,'==========================================================',
     > /)
c
c====
c 2. initialisation des nombres d'entites provisoires
c====
c
      provp1 = 0
      provp2 = 0
      provim = 0
      provar = 0
      provtr = 0
      provqu = 0
      provtf = 0
      provta = 0
      provte = 0
      provhf = 0
      provha = 0
      provhe = 0
      provyf = 0
      provya = 0
      provpy = 0
      provpf = 0
      provpa = 0
      provpe = 0
c
c====
c 3. entites nouvelles crees par decoupage des triangles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. triangles ; codret', codret
#endif
c
      if ( nbtrto.ne.0 ) then
c
        if ( mod(mailet,2).eq.0 ) then
          noinma = .true.
        else
          noinma = .false.
        endif
c
        cpt0 = 0
c
        do 30 , iaux = 1 , permtr
c
          lamail = iaux
#ifdef _DEBUG_HOMARD_
        if ( lamail.eq.-830 ) then
          glop = 1
        else
          glop = 0
        endif
#endif
c
#ifdef _DEBUG_HOMARD_
        if ( glop .eq. 1 ) then
         write (ulsort,*) '. Triangle ', lamail,
     >                     ', de decision ',decfac(lamail),
     >                     ', d''etat ',hettri(lamail)
          do 222 , jaux =1,3
         write (ulsort,*) '. Arete ', aretri(lamail,jaux),
     >                     ', d''etat ',hetare(aretri(lamail,jaux))
  222     continue
        endif
#endif
c
          if ( mod(hettri(lamail),10).eq.0 ) then
c
            dectot = mod(hetare(aretri(lamail,1)),10)
     >             + mod(hetare(aretri(lamail,2)),10)
     >             + mod(hetare(aretri(lamail,3)),10)
c
            if ( dectot.eq.2 ) then
c
c             decoupage du triangle en 2 triangles
c             ------------------------------------
c
              cpt0 = cpt0 + 1
              decfac(lamail) = 2
c
            endif
c
         endif
c
   30   continue
c
        if ( degre.eq.2 ) then
          provp2 = provp2 + cpt0
        endif
        if ( noinma ) then
          provim = provim + 2*cpt0
        endif
        provar = provar +   cpt0
        nbart2 = nbart2 +   cpt0
        provtr = provtr + 2*cpt0
        nbtrt2 = nbtrt2 + 2*cpt0
c
      endif
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'provar',provar
      write(ulsort,90002) 'provtr',provtr
#endif
c
c====
c 4. entites nouvelles crees par decoupage des quadrangles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. quadrangles ; codret', codret
#endif
c
      if ( nbquto.ne.0 ) then
c
        if ( mod(mailet,3).eq.0 ) then
          noinma = .true.
        else
          noinma = .false.
        endif
c
        cpt2 = 0
        cpt3 = 0
        cpt5 = 0
c
        do 40 , iaux = 1 , permqu
c
          lamail = iaux
c
          if ( mod(hetqua(lamail),100).eq.0 ) then
c
            jaux = mod(hetare(arequa(lamail,1)),10)
     >           + mod(hetare(arequa(lamail,3)),10)
            kaux = mod(hetare(arequa(lamail,2)),10)
     >           + mod(hetare(arequa(lamail,4)),10)
            dectot = jaux + kaux
c
            if ( dectot.eq.2 ) then
c
c             decoupage du quadrangle en 3 triangles
c             --------------------------------------
c
              cpt3 = cpt3 + 1
              decfac(-lamail) = 3
c
            elseif ( dectot.eq.4 ) then
c
              if ( ( jaux.eq.4 ) .or. ( kaux.eq.4 ) ) then
c
c               decoupage du quadrangle en 2 quadrangles
c               ----------------------------------------
c
                cpt2 = cpt2 + 1
                decfac(-lamail) = 2
c
              else
c
c               decoupage du quadrangle en 3 quadrangles
c               ----------------------------------------
c
                cpt5 = cpt5 + 1
                decfac(-lamail) = 5
c
              endif
c
            endif
c
          endif
c
   40   continue
c
cgn      write (ulsort,90002) 'cpt2', cpt2
cgn      write (ulsort,90002) 'cpt3', cpt3
cgn      write (ulsort,90002) 'cpt5', cpt5
        provp1 = provp1                   + cpt5
        if ( degre.eq.2 ) then
          provp2 = provp2 + cpt2 + 2*cpt3 + 3*cpt5
        endif
        if ( noinma ) then
          provim = provim + 2*cpt2 + 3*cpt3 + 3*cpt5
        endif
        provar = provar +   cpt2 + 2*cpt3 + 3*cpt5
        nbarq2 = nbarq2 +   cpt2
        nbarq3 = nbarq3          + 2*cpt3
        nbarq5 = nbarq5                   + 3*cpt5
        provtr = provtr          + 3*cpt3
        nbtrq3 = nbtrq3          + 3*cpt3
        provqu = provqu + 2*cpt2          + 3*cpt5
        nbquq2 = nbquq2 + 2*cpt2
        nbquq5 = nbquq5                   + 3*cpt5
c
      endif
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'provar',provar
      write(ulsort,90002) 'provtr',provtr
      write(ulsort,90002) 'provqu',provqu
#endif
c
c====
c 5. entites nouvelles crees par decoupage des tetraedres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. tetraedres ; codret', codret
#endif
c
      if ( nbteto.ne.0 ) then
c
        cpt0 = 0
        cpt1 = 0
        cpt2 = 0
c
        do 50 , iaux = 1 , permte
c
          lamail = iaux
c
          if ( mod(hettet(lamail),100).eq.0 ) then
c
            nbfad2 = 0
            nbfad4 = 0
            do 500 , jaux = 1 , 4
              fj = tritet(lamail,jaux)
              et = mod(hettri(fj),10)
              dt = decfac(fj)
cgn            write(ulsort,*) '. face numero', jaux,' :', fj, et, dt
              if ( dt.eq.2 ) then
                nbfad2 = nbfad2 + 1
              elseif ( et.eq.4 .or. dt.eq.4 ) then
                nbfad4 = nbfad4 + 1
              endif
  500       continue
c
            if ( nbfad2.eq.3 .and. nbfad4.eq.1 ) then
c
c             decoupage en 4 pour mise en conformite par 1 face
c             -------------------------------------------------
c
              cpt0 = cpt0 + 1
c
            elseif ( nbfad2.eq.4 .and. nbfad4.eq.0 ) then
c
c             decoupage en 4 pour mise en conformite par 2 aretes
c             ---------------------------------------------------
c
              cpt1 = cpt1 + 1
c
            elseif ( nbfad2.eq.2 .and. nbfad4.eq.0 ) then
c
c             decoupage en 2 pour mise en conformite par 1 arete
c             --------------------------------------------------
c
              cpt2 = cpt2 + 1
c
            endif
c
          endif
c
   50   continue
c
        if ( degre.eq.2 ) then
          provp2 = provp2 + cpt1
        endif
        provar = provar +   cpt1
        provtr = provtr + 3*cpt0 + 4*cpt1 +   cpt2
        provtf = provtf + 4*cpt0 + 4*cpt1 + 2*cpt2
        nbarin = nbarin +   cpt1
        nbtrtc = nbtrtc + 3*cpt0 + 4*cpt1 +   cpt2
        nbtea2 = nbtea2 + 2*cpt2
        nbtea4 = nbtea4 + 4*cpt1
        nbtef4 = nbtef4 + 4*cpt0
c
        provte = provtf + provta
c
      endif
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'provar',provar
      write(ulsort,90002) 'provtr',provtr
      write(ulsort,90002) 'provtf',provtf
      write(ulsort,90002) 'provta',provta
#endif
c
c====
c 6. entites nouvelles crees par decoupage des hexaedres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. hexaedres ; codret', codret
cgn      write(ulsort,90002) 'nbheto',nbheto
cgn      write(ulsort,90002) 'permhe',permhe
cgn      write(ulsort,90002) 'provp1',provp1
cgn      write(ulsort,90002) 'provp2',provp2
cgn      write(ulsort,90002) 'provya',provya
#endif
c
      if ( nbheto.ne.0 ) then
c
      nbheco = 0
c
c 6.1. ==> conforme, avec des boites pour les hexaedres
c
      if ( tyconf.eq.-1 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'Option conforme avec des boites'
#endif
c
        cpt0 = 0
        cpt1 = 0
        cpt2 = 0
        cpt3 = 0
c
cgn        write(ulsort,90002) 'permhe', permhe
        do 61 , iaux = 1 , permhe
c
          lamail = iaux
c
cgn          write(ulsort,90112) 'hethex', lamail, hethex(lamail)
          if ( mod(hethex(lamail),1000).eq.0 ) then
c
            nbfad3 = 0
            nbfad4 = 0
            do 610 , jaux = 1 , 6
              fj = quahex(lamail,jaux)
              et = mod(hetqua(fj),100)
              dt = decfac(-fj)
cgn          write(ulsort,90015) '.. face numero', jaux,' :', fj, et, dt
              if ( dt.eq.3 ) then
                nbfad3 = nbfad3 + 1
              elseif ( et.eq.4 .or. dt.eq.4 ) then
                nbfad4 = nbfad4 + 1
              endif
  610       continue
c
cgn        if ( nbfad3*nbfad4 > 0 ) then
cgn        write(ulsort,90015) '. nbfad3 = ',nbfad3,', nbfad4 = ',nbfad4
cgn        endif
c
c 6.1.1 ==> decoupage a partir d'une face
c
            if ( nbfad3.eq.4 .and. nbfad4.eq.1 ) then
cgn              write(ulsort,*) '==> dec. en 4+5 a partir d''une face'
              cpt0 = cpt0 + 1
c
c 6.1.2 ==> decoupage a partir de 3 aretes
c
            elseif ( nbfad3.eq.6 .and. nbfad4.eq.0 ) then
cgn              write(ulsort,*) '==> dec. en 18 a partir de 3 aretes'
              cpt1 = cpt1 + 1
c
c 6.1.3 ==> decoupage a partir de 2 aretes
c
            elseif ( nbfad3.eq.4 .and. nbfad4.eq.0 ) then
cgn              write(ulsort,*) '==> dec. en 12+2 a partir de 2 aretes'
              cpt2 = cpt2 + 1
c
c 6.1.4 ==> decoupage a partir d'1 arete
c
            elseif ( nbfad3.eq.2 ) then
cgn              write(ulsort,*) '==> dec. en 14 a partir d''1 arete'
              cpt3 = cpt3 + 1
c
            endif
c
          endif
c
   61   continue
c
cgn        write (ulsort,90002) 'cpt0', cpt0
cgn        write (ulsort,90002) 'cpt1', cpt1
cgn        write (ulsort,90002) 'cpt2', cpt2
cgn        write (ulsort,90002) 'cpt3', cpt3
        provp1 = provp1           + cpt1   + cpt2
c
        iaux  =  4*cpt0 + 11*cpt1 + 10*cpt2 + 2*cpt3
        provar = provar + iaux
        nbarin = nbarin + iaux
        if ( degre.eq.2 ) then
          provp2 = provp2 +  iaux
        endif
c
        iaux  = 12*cpt0 + 27*cpt1 + 22*cpt2 + 5*cpt3
        provtr = provtr + iaux
        nbtrhc = nbtrhc + iaux
c
        provtf = provtf +  4*cpt0 + 18*cpt1 + 12*cpt2
        nbteh1 = nbteh1 +  4*cpt0
        nbteh2 = nbteh2           + 18*cpt1
        nbteh3 = nbteh3                     + 12*cpt2
c
        provyf = provyf +  5*cpt0           +  2*cpt2 + 4*cpt3
        nbpyh1 = nbpyh1 +  5*cpt0
        nbpyh3 = nbpyh3                     +  2*cpt2
        nbpyh4 = nbpyh4                               + 4*cpt3
c
        nbheco = nbheco + cpt0 + cpt1 + cpt2 + cpt3
c
c 6.2. ==> conforme general
c
      else
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'Option conforme'
#endif
c
        do 62 , iaux = 1 , permhe
c
          lamail = iaux
c
cgn          write(ulsort,90112) 'hethex', lamail, hethex(lamail)
c
          if ( mod(hethex(lamail),1000).eq.0 ) then
c
            call utarhe ( lamail,
     >                    permqu, permhe,
     >                    arequa, quahex, coquhe,
     >                    listar )
c
            do 620 , jaux = 1 , 12
cgn            write(ulsort,90002) 'etat', hetare(listar(jaux))
              etdare(jaux) = 0
              if ( hetare(listar(jaux)).ne.50 ) then
cgn            write(ulsort,90002) 'decare', decare(listar(jaux))
                et = mod(hetare(listar(jaux)),10)
                dt = decare(listar(jaux))
                if ( et.eq.2 .or. et.eq.9 .or. dt.eq.2 ) then
                  etdare(jaux) = 1
                endif
              endif
  620       continue
cgn            write(ulsort,90015) 'etdare(', lamail, ') :', etdare
c
            call uthcnb ( etdare,
     >                    nbreso, nbrear, nbrepy, nbrete, nbrehe,
     >                    ulsort, langue, codret )
cgn         write(ulsort,90002) 'nbreso, nbrear, nbrepy, nbrete, nbrehe',
cgn     >                        nbreso, nbrear, nbrepy, nbrete, nbrehe
c
            provp1 = provp1 + nbreso
            provar = provar + nbrear
            nbarin = nbarin + nbrear
            provta = provta + nbrete
            nbtedh = nbtedh + nbrete
            provya = provya + nbrepy
            nbpydh = nbpydh + nbrepy
            provha = provha + nbrehe
            nbhedh = nbhedh + nbrehe
            if ( degre.eq.2 ) then
              provp2 = provp2 + nbrear
            endif
cgn            print *, 'provp1',provp1,'provp2',provp2,'provar',provar
cgn            print *, 'provte',provte,'provhe',provhe,'provya',provya
c
            if ( nbrepy.gt.0 .or. nbrete.gt.0 ) then
              nbheco = nbheco + 1
            endif
          endif
c
   62   continue
c
      endif
c
      provte = provtf + provta
      provpy = provyf + provya
      provhe = provhf + provha
c
      endif
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'nbheco',nbheco
      write(ulsort,90002) 'permhe',permhe
      write(ulsort,90002) 'provp1',provp1
      write(ulsort,90002) 'provp2',provp2
      write(ulsort,90002) 'provar',provar
      write(ulsort,90002) 'provtr',provtr
      write(ulsort,90002) 'provqu',provqu
      write(ulsort,90002) 'provta',provta
      write(ulsort,90002) 'provtf',provtf
      write(ulsort,90002) 'provya',provya
      write(ulsort,90002) 'provyf',provyf
      write(ulsort,90002) 'provha',provha
      write(ulsort,90002) 'provhf',provhf
#endif
c
c====
c 7. entites nouvelles crees par decoupage des pentaedres
c    Remarque : l'indice 0, 1, ... 5 correspond a la dizaine de l'etat
c               du pentaedre apres decoupage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. pentaedres ; codret', codret
      write(ulsort,90002) 'permpe',permpe
cgn      write(ulsort,90002) 'provp1',provp1
cgn      write(ulsort,90002) 'provp2',provp2
cgn      write(ulsort,90002) 'provar',provar
cgn      write(ulsort,90002) 'provta',provta
cgn      write(ulsort,90002) 'provya',provya
#endif
c
      if ( nbpeto.ne.0 ) then
c
        cpt0 = 0
        cpt1 = 0
        cpt2 = 0
        cpt3 = 0
        cpt4 = 0
        cpt5 = 0
c
        do 70 , iaux = 1 , permpe
c
          lamail = iaux
c
cgn          write(ulsort,*) '. pentaedre numero', lamail,' :',hetpen(lamail)
          if ( mod(hetpen(lamail),100).eq.0 ) then
c
            nbfad2 = 0
            nbfad3 = 0
            nbfat4 = 0
            nbfaq4 = 0
            do 701 , jaux = 1 , 2
              fj = facpen(lamail,jaux)
cgn            write(ulsort,*) '. face numero', jaux,' :', fj
              et = mod(hettri(fj),10)
              dt = decfac(fj)
cgn            write(ulsort,*) '. face numero', jaux,' :', fj, et, dt
              if ( dt.eq.2 ) then
                nbfad2 = nbfad2 + 1
              elseif ( et.eq.4 .or. dt.eq.4 ) then
                nbfat4 = nbfat4 + 1
              endif
  701       continue
            do 702 , jaux = 3 , 5
              fj = facpen(lamail,jaux)
              et = mod(hetqua(fj),100)
              dt = decfac(-fj)
cgn            write(ulsort,*) '. face numero', jaux,' :', fj, et, dt
              if ( dt.eq.3 ) then
                nbfad3 = nbfad3 + 1
              elseif ( et.eq.4 .or. dt.eq.4 ) then
                nbfaq4 = nbfaq4 + 1
              endif
  702       continue
cgn            write(ulsort,*) '. nbfad2', nbfad2
cgn            write(ulsort,*) '. nbfad3', nbfad3
cgn            write(ulsort,*) '. nbfat4', nbfat4
cgn            write(ulsort,*) '. nbfaq4', nbfaq4
c
c 7.1 ==> decoupage a partir d'1 arete de triangle
c
            if ( nbfad2.eq.1 .and. nbfad3.eq.1 .and.
     >           nbfaq4.eq.0 .and. nbfat4.eq.0 ) then
cgn             write(ulsort,*) 'dec. en 2+1 a partir de 1 arete tri'
              cpt0 = cpt0 + 1
c
c 7.2 ==> decoupage a partir d'1 arete de quadrangle
c
            elseif ( nbfad2.eq.0 .and. nbfad3.eq.2 .and.
     >               nbfaq4.eq.0 .and. nbfat4.eq.0 ) then
cgn             write(ulsort,*) 'dec. en 1+2 a partir de 1 arete qua'
              cpt1 = cpt1 + 1
c
c 7.3 ==> decoupage a partir de 1 arete de tria et
c                               1 arete de quad
            elseif ( nbfad2.eq.1 .and. nbfad3.eq.3 .and.
     >               nbfaq4.eq.0 .and. nbfat4.eq.0 ) then
cgn           write(ulsort,*) 'dec. en 6 a partir de 1 ar tri / 1 qua'
              cpt2 = cpt2 + 1
c
c 7.4 ==> decoupage a partir de 2 aretes de tria
c
            elseif ( nbfad2.eq.2 .and. nbfad3.eq.2 .and.
     >               nbfaq4.eq.0 .and. nbfat4.eq.0 ) then
cgn           write(ulsort,*) 'dec. en 10+1 a partir de 2 ar tri'
              cpt3 = cpt3 + 1
c
c 7.5 ==> decoupage a partir de 1 face quad
c
            elseif ( nbfad2.eq.2 .and. nbfad3.eq.2 .and.
     >               nbfaq4.eq.1 .and. nbfat4.eq.0 ) then
cgn           write(ulsort,*) 'dec. en 4+2 a partir de 1 face qua'
              cpt4 = cpt4 + 1
c
c 7.4 ==> decoupage a partir de 1 face tria
c
            elseif ( nbfad2.eq.0 .and. nbfad3.eq.3 .and.
     >               nbfaq4.eq.0 .and. nbfat4.eq.1 ) then
cgn           write(ulsort,*) 'dec. en 11 te a partir de 1 face tria'
              cpt5 = cpt5 + 1
c
            endif
c
          endif
c
   70   continue
c
        provp1 = provp1 + cpt3 + cpt5
c
        iaux  = cpt0 + cpt2 + 8*cpt3 + 2*cpt4 + 6*cpt5
        provar = provar + iaux
        nbarin = nbarin + iaux
        if ( degre.eq.2 ) then
          provp2 = provp2 +  iaux
        endif
c
        iaux  = 3*cpt0 + 2*cpt1 + 6*cpt2 + 17*cpt3 + 7*cpt4 + 15*cpt5
        provtr = provtr + iaux
        nbtrpc = nbtrpc + iaux
c
        provtf = provtf +    cpt0 +  2*cpt1 + 6*cpt2 + 10*cpt3
     >                  +  2*cpt4 + 11*cpt5
        nbtep0 = nbtep0 +    cpt0
        nbtep1 = nbtep1           +  2*cpt1
        nbtep2 = nbtep2                     + 6*cpt2
        nbtep3 = nbtep3                              + 10*cpt3
        nbtep4 = nbtep4 +  2*cpt4
        nbtep5 = nbtep5           + 11*cpt5
c
        provyf = provyf +  2*cpt0 +    cpt1          +    cpt3
     >                  +  4*cpt4
        nbpyp0 = nbpyp0 +  2*cpt0
        nbpyp1 = nbpyp1           +    cpt1
        nbpyp2 = nbpyp2                              +    cpt3
        nbpyp4 = nbpyp4 +  4*cpt4
c
        nbpeco = cpt0 + cpt1 + cpt2 + cpt3 + cpt4 + cpt5
c
        provte = provtf + provta
        provpy = provyf + provya
c
      endif
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'nbpeco',nbpeco
      write(ulsort,90002) 'provp1',provp1
      write(ulsort,90002) 'provp2',provp2
      write(ulsort,90002) 'provar',provar
      write(ulsort,90002) 'provtr',provtr
      write(ulsort,90002) 'provqu',provqu
      write(ulsort,90002) 'provta',provta
      write(ulsort,90002) 'provtf',provtf
      write(ulsort,90002) 'provya',provya
      write(ulsort,90002) 'provyf',provyf
      write(ulsort,90002) 'provpa',provpa
      write(ulsort,90002) 'provpf',provpf
#endif
c
c====
c 8. bilan, initialisations et impressions
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '8. bilan ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
cgn      write(ulsort,90002) 'nbteca', nbteca
cgn        write (ulsort,90002) 'permno', permno
cgn        write (ulsort,90002) 'provp1', provp1
cgn        write (ulsort,90002) 'provp2', provp2
cgn        write (ulsort,90002) 'provim', provim
      nouvno = permno + provp1 + provp2 + provim
      nouvp2 = permp2 + provp2
      nouvim = permim + provim
      nouvar = permar + provar
      nouvtr = permtr + provtr
      nouvqu = permqu + provqu
      nouvte = permte + provte
      nouvtf = nouvtf + provtf
      nouvta = nouvta + provta
      nbteca = nbtedh + nbtedp
      nouvhe = permhe + provhe
      nouvhf = nouvhf + provhf
      nouvha = nouvha + provha
      nbheca = nbhedh
      nouvpy = permpy + provpy
      nouvyf = nouvyf + provyf
      nouvya = nouvya + provya
      nbpyca = nbpydh + nbpydp
      nouvpe = permpe + provpe
      nouvpf = nouvpf + provpf
      nouvpa = nouvpa + provpa
      nbpeca = nbpedp
c
      write(ulsort,60000) mess40(langue,1),
     >                    mess14(langue,2,10), mess14(langue,2,11)
      write(ulsort,61000) mess14(langue,2,-1),
     >                    nouvno, provp1 + provp2 + provim
      write(ulsort,61000) mess14(langue,2,1), nouvar, provar
      if ( nbtrto.ne.0 .or. nbquto.ne.0 ) then
        write(ulsort,61000) mess14(langue,2,2), nouvtr, provtr
      endif
      if ( nbquto.ne.0 ) then
        write(ulsort,61000) mess14(langue,2,4), nouvqu, provqu
      endif
      if ( nbteto.ne.0 .or. nbheto.ne.0 .or. nbpeto.ne.0 ) then
        write(ulsort,61000) mess14(langue,2,3), nouvte, provte
      endif
      if ( nbheto.ne.0 ) then
        write(ulsort,61000) mess14(langue,2,6), nouvhe, provhe
      endif
      if ( nbheto.ne.0 .or. nbpeto.ne.0 ) then
        write(ulsort,61000) mess14(langue,2,5), nouvpy, provpy
      endif
      if ( nbpeto.ne.0 ) then
        write(ulsort,61000) mess14(langue,2,7), nouvpe, provpe
      endif
      write(ulsort,62000)
c
      endif
c
c====
c 9. la fin
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
