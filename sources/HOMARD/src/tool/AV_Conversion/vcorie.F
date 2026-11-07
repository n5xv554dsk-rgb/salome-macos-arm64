      subroutine vcorie ( eleinc, noeele, areele, typele,
     >                    somare, aretri, arequa,
     >                    nnosho, narsho, ntrsho, nqusho,
     >                    coexar,
     >                    tritet, cotrte, ntesho,
     >                    quahex, coquhe, nhesho,
     >                    facpen, cofape, npesho,
     >                    facpyr, cofapy, npysho,
     >                    ulsort, langue, codret  )
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
c    aVant adaptation - Conversion - ORIEntation
c     -                 -            ----
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c ______________________________________________________________________
c . eleinc . e   .   1    . elements incompatibles                     .
c .        .     .        . 0 : on bloque s'il y en a                  .
c .        .     .        . 1 : on les ignore s'il y en a              .
c . noeele . e   . nbelem . noeuds des elements                        .
c .        .     .*nbmane .                                            .
c . areele . e   . nbelem . aretes des elements                        .
c .        .     .*nbmaae .                                            .
c . typele . e   . nbelem . type des elements pour le code de calcul   .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . es  .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . es  .nbquto*4. numeros des 4 aretes des quadrangles       .
c . nnosho . e   . rsnoac . numero des noeuds dans HOMARD              .
c . narsho . e   . rsarac . numero des aretes dans HOMARD              .
c . ntrsho . e   . rstrac . numero des triangles dans HOMARD           .
c . nqusho . e   . rsquac . numero des quadrangles dans HOMARD         .
c . coexar . es  . nbarto*. codes de conditions aux limites portants   .
c .        .     . nctfar . sur les aretes                             .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte .  s  .nbtecf*4. code des 4 triangles des tetraedres        .
c . ntesho . e   . rsteac . numero des tetraedres dans HOMARD          .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe .  s  .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . nhesho . e   . rsheac . numero des hexaedres dans HOMARD           .
c . facpen . e   .nbpecf*5. numeros des 5 faces des pentaedres         .
c . cofape .  s  .nbpecf*5. codes des 5 faces des pentaedres           .
c . npesho . e   . rspeac . numero des pentaedres dans HOMARD          .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy .  s  .nbpycf*5. codes des faces des pyramides              .
c . npyrho . e   . repyac . numero des pyramides dans HOMARD           .
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
      parameter ( nompro = 'VCORIE' )
c
#include "nblang.h"
#include "referx.h"
#include "cofaar.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "dicfen.h"
#include "refert.h"
#include "refere.h"
#include "nbutil.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpe.h"
#include "nombpy.h"
#include "nombsr.h"
#include "envca1.h"
#include "rftmed.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer eleinc
      integer noeele(nbelem,nbmane)
      integer areele(nbelem,nbmaae)
      integer typele(nbelem)
      integer somare(2,nbarto), aretri(nbtrto,3)
      integer arequa(nbquto,4)
      integer nnosho(rsnoac), narsho(rsarac)
      integer ntrsho(rstrac), nqusho(rsquac)
      integer coexar(nbarto,nctfar)
      integer tritet(nbtecf,4), cotrte(nbtecf,4)
      integer ntesho(rsteac)
      integer quahex(nbhecf,6), coquhe(nbhecf,6)
      integer nhesho(rsheac)
      integer facpen(nbpecf,5), cofape(nbpecf,5)
      integer npesho(rspeac)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5)
      integer npysho(rspyac)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer elemen, typhom
      integer numfac
      integer letria, lequad
      integer letetr, lehexa, lepent, lapyra
      integer s1, s2
      integer sa1a2, sa1a3, sa1a4, sa2a3, sa3a4
      integer a1, a2, a3, a4
      integer orient
      integer code
#ifdef _DEBUG_HOMARD_
      integer glop
#endif
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
      texte(1,4) = '(''Element'',i10,'', de type HOMARD'',i4)'
      texte(1,5) =
     > '(4x,''==> '',a,i10,'', face de numero local'',i2,'' :'')'
      texte(1,7) = '(''Impossible de trouver le code'')'
c
      texte(2,4) = '(''Element'',i10,'', with HOMARD type'',i4)'
      texte(2,5) = '(4x,''==> '',a,i10,'', local face position'',i2)'
      texte(2,7) = '(''Code cannot be found'')'
c
#include "impr03.h"
c
c====
c 2. determination de l'orientation des aretes, des triangles et
c    des quadrangles
c====
c
      do 20 , elemen = 1 , nbelem
c
        typhom = medtrf(typele(elemen))
c
#ifdef _DEBUG_HOMARD_
        if ( elemen.eq.-12 ) then
          glop = 1
        else
          glop = 0
        endif
#endif
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,texte(langue,4)) elemen, typhom
        endif
#endif
c
c 2.1. ==> on saute si c'est un element incompatible avec le mode
c          d'utilisation de HOMARD
c
        if ( eleinc.ne.0 ) then
          if ( tyeref(typhom).ne.0 ) then
            goto 20
          endif
        endif
c
c 2.2. ==> les aretes
c
c     code de calcul : x--------x    HOMARD : x---------x
c                      s1      s2             iaux      n2
c
        if ( typhom.eq.tyhse1 .or. typhom.eq.tyhse2 ) then
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
       write (ulsort,90002) mess14(langue,1,1), narsho(elemen)
        endif
#endif
c
c         s1 = numero dans HOMARD du 1er noeud de l'element dans MED
c
          s1 = nnosho(noeele(elemen,1))
c
c         iaux = numero dans HOMARD du 1er noeud de l'arete
c         narsho(elemen) correspondant a l'element elemen dans MED
c
          iaux = somare(1,narsho(elemen))
c
          if ( iaux.eq.s1 ) then
            orient =  1
          else
            orient = -1
          endif
c
          coexar(narsho(elemen),coorfa) = orient
c
c 2.3. ==> les triangles
c      en fonction du positionnement relatif des noeuds, on a une valeur
c      d'orientation.
c      il y a 6 possibilites :
c      . la valeur absolue est le numero local MED du sommet en face
c        de l'arete a1
c      . on note positif quand la description par
c        aretes (HOMARD) tourne dans le meme sens que la description
c        par noeuds (MED), negatif pour le sens inverse :
c
c         s3                   s3                   s3
c         /\                   /\                   /\
c        /  \                 /  \                 /  \
c     a2/  1 \a1           a1/  2 \a3           a3/  3 \a2
c      /      \             /      \             /      \
c     /________\           /________\           /________\
c    s1   a3   s2         s1   a2   s2         s1   a1   s2
c
c         s3                   s3                   s3
c         /\                   /\                   /\
c        /  \                 /  \                 /  \
c     a3/ -1 \a1           a1/ -2 \a2           a2/ -3 \a3
c      /      \             /      \             /      \
c     /________\           /________\           /________\
c    s1   a2   s2         s1   a3   s2         s1   a1   s2
c
c      on va modifier la description du triangle pour faire coincider
c      les numero si et les sommets des aretes ai, saiaj :
c
c                        s3                     sa2a3
c                        /\                      /\
c                MED :  /  \         HOMARD : a3/  \a2
c                      /    \                  /    \
c                     /______\                /______\
c                    s1      s2            sa1a3 a1 sa1a2
c
        elseif ( typhom.eq.tyhtr1 .or. typhom.eq.tyhtr2 ) then
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
       write (ulsort,90002) mess14(langue,1,2), ntrsho(elemen)
        endif
#endif
c
c         numeros dans HOMARD du 1er et 2eme noeud
c         de l'element elemen dans MED
c
          s1 = nnosho(noeele(elemen,1))
          s2 = nnosho(noeele(elemen,2))
c
c         ak = numero dans HOMARD de la k-eme arete
c         du triangle ntrsho(elemen) correspondant a l'element elemen
c         dans MED
c         sajak = numero dans HOMARD du noeud
c         commun aux aretes aj et ak
c
          a1 = aretri(ntrsho(elemen),1)
          a2 = aretri(ntrsho(elemen),2)
          a3 = aretri(ntrsho(elemen),3)
c
          if ( somare(1,a1) .eq. somare(1,a3)  .or.
     >         somare(1,a1) .eq. somare(2,a3) ) then
c           le 1er noeud de l'arete 1 est un des sommets de a3 ;
c           donc le 2nd noeud de l'arete 1 est un des sommets de a2
            sa1a3 = somare(1,a1)
            sa1a2 = somare(2,a1)
          else
c           le 1er noeud de l'arete 1 n'est pas un des sommets de a3 ;
c           donc c'est qu'il est un des sommets de a2
c           donc le 2nd noeud de l'arete 1 est un des sommets de a3
            sa1a3 = somare(2,a1)
            sa1a2 = somare(1,a1)
          endif
c
c         comparaison des deux numerotations
c
          if ( s1 .eq. sa1a3 ) then
            if ( s2 .eq. sa1a2 ) then
cgn              orient = 3
              aretri(ntrsho(elemen),1) = a2
              aretri(ntrsho(elemen),2) = a3
              aretri(ntrsho(elemen),3) = a1
            else
cgn              orient = -2
              aretri(ntrsho(elemen),1) = a2
              aretri(ntrsho(elemen),2) = a1
              aretri(ntrsho(elemen),3) = a3
            endif
          elseif ( s1 .eq. sa1a2 ) then
            if ( s2 .eq. sa1a3 ) then
cgn              orient = -3
              aretri(ntrsho(elemen),1) = a3
              aretri(ntrsho(elemen),3) = a1
            else
cgn              orient = 2
              aretri(ntrsho(elemen),1) = a3
              aretri(ntrsho(elemen),2) = a1
              aretri(ntrsho(elemen),3) = a2
            endif
          else
c           on a alors s1 .eq. sa2a3
            if ( s2 .ne. sa1a3 ) then
cgn              orient = -1
              aretri(ntrsho(elemen),2) = a3
              aretri(ntrsho(elemen),3) = a2
cgn            else
cgn              orient = 1
            endif
          endif
c
c 2.4. ==> les quadrangles
c      en fonction du positionnement relatif des noeuds, on a une valeur
c      d'orientation.
c      il y a 8 possibilites :
c      . on note positif quand la description par
c        aretes (HOMARD) tourne dans le meme sens que la description
c        par noeuds (MED), negatif pour le sens inverse
c      . la valeur absolue est le numero local MED du sommet commun
c        aux aretes a1 et a4 si >0, a1 et a2 si <0
c
c      remarque : entre deux orientations de signes opposes,
c                 les aretes 1 et 3 sont a la meme place et
c                 les aretes 2 et 4 sont permutees.
c
c
c   s1   a4   s4      s1   a3   s4      s1   a2   s4      s1   a1   s4
c    .________.        .________.        .________.        .________.
c    .        .        .        .        .        .        .        .
c    .        .        .        .        .        .        .        .
c  a1.    1   .a3    a4.    2   .a2    a3.    3   .a1    a2.    4   .a4
c    .        .        .        .        .        .        .        .
c    .________.        .________.        .________.        .________.
c   s2   a2   s3      s2   a1   s3      s2   a4   s3      s2   a3   s3
c
c
c
c   s1   a2   s4      s1   a3   s4      s1   a4   s4      s1   a1   s4
c    .________.        .________.        .________.        .________.
c    .        .        .        .        .        .        .        .
c    .        .        .        .        .        .        .        .
c  a1.   -1   .a3    a2.   -2   .a4    a3.   -3   .a1    a4.   -4   .a2
c    .        .        .        .        .        .        .        .
c    .________.        .________.        .________.        .________.
c   s2   a4   s3      s2   a1   s3      s2   a2   s3      s2   a3   s3
c
c      on va modifier la description du quadrangle pour faire coincider
c      les numero si et les sommets des aretes ai, saiaj :
c
c
c                  s1        s4               sa4a1   a4   sa3a4
c                   .________.                    .________.
c                   .        .                    .        .
c                   .        .                    .        .
c        MED :      .        .        HOMARD :  a1.        .a3
c                   .        .                    .        .
c                   .________.                    .________.
c                  s2        s3               sa1a2   a2   sa2a3
c
c
        elseif ( typhom.eq.tyhqu1 .or. typhom.eq.tyhqu2 ) then
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
       write (ulsort,90002) mess14(langue,1,4), nqusho(elemen)
        endif
#endif
c
c         numeros dans HOMARD du 1er et 2eme noeud
c         de l'element elemen dans MED
c
          s1 = nnosho(noeele(elemen,1))
          s2 = nnosho(noeele(elemen,2))
c
c         ak = numero dans HOMARD de la k-eme arete
c         du quadrangle nqusho(elemen) correspondant a l'element elemen
c         dans MED
c         sajak = numero dans HOMARD du noeud
c         commun aux aretes aj et ak
c
c         on commence par regarder si le sommet s1 est une extremite de
c         l'arete a1
c
          a1 = arequa(nqusho(elemen),1)
          a2 = arequa(nqusho(elemen),2)
          a3 = arequa(nqusho(elemen),3)
          a4 = arequa(nqusho(elemen),4)
c
          if ( somare(1,a1) .eq. somare(1,a2)  .or.
     >         somare(1,a1) .eq. somare(2,a2) ) then
c           le 1er noeud de l'arete 1 est un des sommets de a2 ;
c           donc le 2nd noeud de l'arete 1 est un des sommets de a4
            sa1a2 = somare(1,a1)
            sa1a4 = somare(2,a1)
          else
c           le 1er noeud de l'arete 1 n'est pas un des sommets de a2 ;
c           donc c'est qu'il est un des sommets de a4
c           donc le 2nd noeud de l'arete 1 est un des sommets de a2
            sa1a2 = somare(2,a1)
            sa1a4 = somare(1,a1)
          endif
c
          if ( s1 .eq. sa1a4 ) then
            if ( s2 .ne. sa1a2 ) then
cgn              orient = -4
              arequa(nqusho(elemen),1) = a4
              arequa(nqusho(elemen),2) = a3
              arequa(nqusho(elemen),3) = a2
              arequa(nqusho(elemen),4) = a1
cgn            else
cgn              orient = 1
            endif
          elseif ( s1 .eq. sa1a2 ) then
            if ( s2 .eq. sa1a4 ) then
cgn              orient = -1
              arequa(nqusho(elemen),2) = a4
              arequa(nqusho(elemen),4) = a2
            else
cgn              orient = 4
              arequa(nqusho(elemen),1) = a2
              arequa(nqusho(elemen),2) = a3
              arequa(nqusho(elemen),3) = a4
              arequa(nqusho(elemen),4) = a1
            endif
c
          else
c
c           le sommet s1 n'est pas une extremite de l'arete a1
c           il est donc un sommet de a3. on precise comment
c
            if ( somare(1,a3) .eq. somare(1,a2)  .or.
     >           somare(1,a3) .eq. somare(2,a2) ) then
c             le 1er noeud de l'arete 3 est un des sommets de a2 ;
c             donc le 2nd noeud de l'arete 3 est un des sommets de a4
              sa2a3 = somare(1,a3)
              sa3a4 = somare(2,a3)
            else
c             le 1er noeud de l'arete 3 n'est pas un des sommets de a2 ;
c             donc c'est qu'il est un des sommets de a4
c             donc le 2nd noeud de l'arete 3 est un des sommets de a2
              sa2a3 = somare(2,a3)
              sa3a4 = somare(1,a3)
            endif
c
            if ( s1 .eq. sa3a4 ) then
              if ( s2 .eq. sa2a3 ) then
cgn                orient = -3
                arequa(nqusho(elemen),1) = a3
                arequa(nqusho(elemen),3) = a1
              else
cgn                orient = 2
                arequa(nqusho(elemen),1) = a4
                arequa(nqusho(elemen),2) = a1
                arequa(nqusho(elemen),3) = a2
                arequa(nqusho(elemen),4) = a3
              endif
            else
              if ( s2 .eq. sa3a4 ) then
cgn                orient = 3
                arequa(nqusho(elemen),1) = a3
                arequa(nqusho(elemen),2) = a4
                arequa(nqusho(elemen),3) = a1
                arequa(nqusho(elemen),4) = a2
              else
cgn                orient = -2
                arequa(nqusho(elemen),1) = a2
                arequa(nqusho(elemen),2) = a1
                arequa(nqusho(elemen),3) = a4
                arequa(nqusho(elemen),4) = a3
              endif
            endif
c
          endif
cgn          print *,elemen,nnosho(noeele(elemen,1)),
cgn     >                   nnosho(noeele(elemen,2)),
cgn     >                   nnosho(noeele(elemen,3)),
cgn     >                   nnosho(noeele(elemen,4))
cgn          print *,nqusho(elemen),arequa(nqusho(elemen),1),
cgn     >                   arequa(nqusho(elemen),2),
cgn     >                   arequa(nqusho(elemen),3),
cgn     >                   arequa(nqusho(elemen),4)
cgn      print *,orient
c
        endif
c
   20 continue
c
c====
c 3. determination des codes des faces dans les volumes
c====
c
      do 30 , elemen = 1 , nbelem
c
        typhom = medtrf(typele(elemen))
c
#ifdef _DEBUG_HOMARD_
        if ( elemen.ge.-12 ) then
          glop = 1
        else
          glop = 0
        endif
#endif
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,texte(langue,4)) elemen, typhom
        endif
#endif
c
c 3.1. ==> on saute si c'est un element incompatible avec le mode
c          d'utilisation de HOMARD
c
        if ( eleinc.ne.0 ) then
          if ( tyeref(typhom).ne.0 ) then
            goto 30
          endif
        endif
c
c 3.2. ==> les tetraedres
c
        if ( typhom.eq.tyhte1 .or. typhom.eq.tyhte2 ) then
c
          letetr = ntesho(elemen)
c
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,*) ' '
        write (ulsort,90002) mess14(langue,2,3), letetr
        write (ulsort,90002) mess14(langue,3,1),
     >                       (areele(elemen,iaux),iaux=1,6)
        endif
#endif
c
          do 321 , iaux = 1 , 4
c
            numfac = iaux
            letria = tritet(letetr,numfac)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCORI1', nompro
#endif
            call vcori1 ( elemen, typhom, numfac, letria,
     >                    areele, aretri,
     >                    code,
     >                    ulsort, langue, codret  )
            if ( codret.eq.0 ) then
              cotrte(letetr,numfac) = code
            endif
c
  321     continue
c
c 3.3. ==> les hexaedres
c
        elseif ( typhom.eq.tyhhe1 .or. typhom.eq.tyhhe2 ) then
c
          lehexa = nhesho(elemen)
c
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,*) ' '
        write (ulsort,90002) mess14(langue,2,6), lehexa
        write (ulsort,90002) mess14(langue,3,1),
     >                       (areele(elemen,iaux),iaux=1,6)
        write (ulsort,90002) mess14(langue,3,1),
     >                       (areele(elemen,iaux),iaux=7,12)
        endif
#endif
c
          do 331 , iaux = 1 , 6
c
            numfac = iaux
            lequad = quahex(lehexa,numfac)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCORI2', nompro
#endif
            call vcori2 ( elemen, typhom, numfac, lequad,
     >                    areele, arequa,
     >                    code,
     >                    ulsort, langue, codret  )
            if ( codret.eq.0 ) then
              coquhe(lehexa,numfac) = code
            endif
c
  331     continue
c
c 3.4. ==> les pentaedres
c
        elseif ( typhom.eq.tyhpe1 .or. typhom.eq.tyhpe2 ) then
c
          lepent = npesho(elemen)
c
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,*) ' '
        write (ulsort,90002) mess14(langue,2,7), lepent
        write (ulsort,90002) mess14(langue,3,1),
     >                       (areele(elemen,iaux),iaux=1,9)
        endif
#endif
c
          do 341 , iaux = 1 , 2
c
            numfac = iaux
            letria = facpen(lepent,numfac)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCORI1', nompro
#endif
            call vcori1 ( elemen, typhom, numfac, letria,
     >                    areele, aretri,
     >                    code,
     >                    ulsort, langue, codret  )
            if ( codret.eq.0 ) then
              cofape(lepent,iaux) = code
            endif
c
  341     continue
c
          do 344 , iaux = 3 , 5
c
            numfac = iaux
            lequad = facpen(lepent,numfac)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCORI2', nompro
#endif
            call vcori2 ( elemen, typhom, numfac, lequad,
     >                    areele, arequa,
     >                    code,
     >                    ulsort, langue, codret  )
            if ( codret.eq.0 ) then
              cofape(lepent,numfac) = code
            endif
c
  344     continue
c
c 3.5. ==> les pyramides
c
        elseif ( typhom.eq.tyhpy1 .or. typhom.eq.tyhpy2 ) then
c
          lapyra = npysho(elemen)
c
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,*) ' '
        write (ulsort,90002) mess14(langue,2,5), lapyra
        write (ulsort,90002) mess14(langue,3,1),
     >                       (areele(elemen,iaux),iaux=1,8)
        endif
#endif
c
          do 351 , iaux = 1 , 4
c
            numfac = iaux
            letria = facpyr(lapyra,numfac)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCORI1', nompro
#endif
            call vcori1 ( elemen, typhom, numfac, letria,
     >                    areele, aretri,
     >                    code,
     >                    ulsort, langue, codret  )
            if ( codret.eq.0 ) then
              cofapy(lapyra,numfac) = code
            endif
c
  351     continue
c
          numfac = 5
          lequad = facpyr(lapyra,numfac)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCORI2', nompro
#endif
          call vcori2 ( elemen, typhom, numfac, lequad,
     >                  areele, arequa,
     >                  code,
     >                  ulsort, langue, codret  )
          if ( codret.eq.0 ) then
            cofapy(lapyra,numfac) = code
          endif
c
        endif
c
   30 continue
c
c====
c 4. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
