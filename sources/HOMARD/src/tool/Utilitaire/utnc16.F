      subroutine utnc16 ( hettri, aretri, filtri,
     >                    hetqua, arequa, filqua,
     >                    filare,
     >                    quahex, coquhe, volqua,
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
c    UTilitaire - Non Conformite - phase 16
c    --           -   -                  --
c    On cherche a reorienter les faces recouvertes
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . filtri . e   . nbtrto . premier fils des triangles                 .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . es  .nbquto*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . filare . e   . nbarto . premiere fille des aretes                  .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . es  .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . volqua . e   .nbquto*2. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 3 : probleme                               .
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
      parameter ( nompro = 'UTNC16' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "ope1a4.h"
#include "j1234j.h"
#include "impr02.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombhe.h"
c
c 0.3. ==> arguments
c
      integer hettri(nbtrto), aretri(nbtrto,3)
      integer filtri(nbtrto)
      integer hetqua(nbquto), arequa(nbquto,4)
      integer filqua(nbquto)
      integer filare(nbarto)
      integer quahex(nbhecf,6), coquhe(nbhecf,6)
      integer volqua(2,nbquto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, laux
      integer iauxm1
      integer lepere, lefils
      integer arei, areim1
      integer f1ai, f2ai, f1aim1, f2aim1
      integer aretf(4)
      integer jdei, jdeim1
      integer areti1, areti2
      integer orient
      integer lehexa, codefa
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. preliminaires
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
      texte(1,4) = '(a,''Examen du '',a,'' numero'',i10)'
      texte(1,5) = '(''.. couvert par le '',a,'' numero'',i10)'
      texte(1,6) = '(a,''dont les '',a,'' sont :'',6i10)'
      texte(1,7) = '(''. Arete'',i10,'' de'',i10,'' a'',i10)'
      texte(1,8) = '(''2 hexaedres voisins ?'')'
      texte(1,9) = '(''Incoherence de voisins'')'
      texte(1,10) = '(5x,''Le '',a,'' numero'',i10,'' est la face'',i2)'
      texte(1,11) = '(5x,''Le code '',a,'' vaut'',i2)'
c
      texte(2,4) = '(a,''Examination of '',a,'' #'',i10)'
      texte(2,5) = '(''.. covered by '',a,'' #'',i10)'
      texte(2,6) = '(a,''with '',a,'' # :'',6i10)'
      texte(2,7) = '(''. Edge #'',i10,'' from'',i10,'' to'',i10)'
      texte(2,8) = '(''2 hexa for this quad ?'')'
      texte(2,9) = '(''Non coherence for neighbours.'')'
c
      codret = 0
c
c====
c 2. On explore les quadrangles decoupes en 4
c    On doir arriver a la convention decrite par cmrdqu :
c
c   Quadrangle pere :
c     ak = numero de la k-eme arete du quadrangle pere
c     sajak = numero du noeud commun aux aretes aj et ak
c
c       sa4a1                       a4                        sa3a4
c           ._________________________________________________.
c           .                                                 .
c           .                                                 .
c           .                                                 .
c           .                                                 .
c           .                                                 .
c           .                                                 .
c        a1 .                                                 . a3
c           .                                                 .
c           .                                                 .
c           .                                                 .
c           .                                                 .
c           .                                                 .
c           .                                                 .
c           ._________________________________________________.
c       sa1a2                       a2                        sa2a3
c
c   Remarque : on appelle ici le sens standard celui correspondant
c              a l'enchainement (a1,a2,a3,a4)
c
c   Quadrangles fils :
c     n0 = numero du noeud barycentre des 4 sommets du quadrangle pere
c     nk = numero du noeud milieu de la k-eme arete du quadrangle pere
c     akf1/2 = numero des filles de la k-eme arete du quadrangle pere
c              akf1 : la premiere dans le sens standard
c              akf2 : la seconde dans le sens standard
c     nfk = numero du k-eme quadrangle fils : celui qui contient la
c           premiere (au sens standard) des filles de l'arete ak
c     ankn0 = numero de l'arete qui va de nk a n0. (Par construction,
c             n0>nk). Elle est commune aux filles nfk et nf(k+1).
c
c       sa4a1          a4f2        a4/n4        a4f1          sa3a4
c           .________________________.________________________.
c           .                        .                        .
c           .                        .                        .
c           .                        .an4n0                   .
c      a1f1 .          nf1           .          nf4           . a3f2
c           .                        .                        .
c           .                        .                        .
c     a1/n1 .________________________.________________________. a3/n3
c           .         an1n0          .n0       an3n0          .
c           .                        .                        .
c           .                        .an2n0                   .
c      a1f2 .          nf2           .          nf3           . a3f1
c           .                        .                        .
c           .                        .                        .
c           .________________________.________________________.
c       sa1a2         a2f1         a2/n2        a2f2          sa2a3
c
c
c====
c
      do 20 , lepere = 1 , nbquto
cgn        write (ulsort,*) ' lepere = ', lepere
c
        if ( hetqua(lepere).eq.4 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) ' '
        write (ulsort,texte(langue,4)) ' ', mess14(langue,1,4)//'pere',
     >                                   lepere
         write (ulsort,texte(langue,6)) ' ', mess14(langue,3,1), 
     >                     arequa(lepere,1), arequa(lepere,2),
     >                     arequa(lepere,3), arequa(lepere,4)
#endif
c
c On examine chacun des fils :
c
          do 21 , iaux = 1 , 4
c
            if ( codret.eq.0 ) then
c
            lefils = filqua(lepere)+iaux-1
c
c 2.1. ==> Les 2 aretes i et i-1 du pere ainsi que leurs filles
c
            arei = arequa(lepere,iaux)
            f1ai = filare(arei)
            f2ai = f1ai + 1
c
            iauxm1 = per1a4(-1,iaux)
            areim1 = arequa(lepere,iauxm1)
            f1aim1 = filare(areim1)
            f2aim1 = f1aim1 + 1
c
c 2.2. ==> Les aretes du fils
c
            do 221 , jaux = 1 , 4
              aretf(jaux) = arequa(lefils,jaux)
  221       continue
c
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,4)) '.. ',
     >                                mess14(langue,1,4)//'fils', lefils
            write (ulsort,texte(langue,6)) '   ',mess14(langue,3,1), 
     >                                     aretf
#endif
c
c 2.3. ==> Quelle arete du fils est fille de l'arete i ?
c
            do 231 , jaux = 1 , 4
c
              if ( aretf(jaux).eq.f1ai .or.
     >             aretf(jaux).eq.f2ai ) then
                jdei = jaux
                goto 232
              endif
c
  231       continue
c
  232       continue
c
c 2.4. ==> Quelle arete du fils est fille de l'arete i-1 ?
c
            do 241 , jaux = 1 , 4
c
              if ( aretf(jaux).eq.f1aim1 .or.
     >             aretf(jaux).eq.f2aim1 ) then
                jdeim1 = jaux
                goto 242
              endif
c
  241       continue
c
  242       continue
c
c 2.5. ==> On cherche le changement d'orientation
c          orient = nombre de 1/4 de tours a faire dans le sens de
c                   l'orientation de la mere pour que la 1ere arete
c                   du fils soit bien placee.
c
            if ( jdei.eq.1 ) then
              if ( jdeim1.eq.4 ) then
                orient = 0
              elseif ( jdeim1.eq.2 ) then
                orient = -2
              else
                codret = 142
              endif
c
            elseif ( jdei.eq.2 ) then
              if ( jdeim1.eq.1 ) then
                orient = 1
              elseif ( jdeim1.eq.3 ) then
                orient = -5
              else
                codret = 213
              endif
c
            elseif ( jdei.eq.3 ) then
              if ( jdeim1.eq.2 ) then
                orient = 2
              elseif ( jdeim1.eq.4 ) then
                orient = -4
              else
                codret = 324
              endif
c
            elseif ( jdei.eq.4 ) then
              if ( jdeim1.eq.3 ) then
                orient = 3
              elseif ( jdeim1.eq.1 ) then
                orient = -3
              else
                codret = 431
              endif
c
            else
              write (ulsort,texte(langue,4)) 'Pere : ',
     >                                       mess14(langue,1,4), lepere
              write (ulsort,texte(langue,6)) ' ', mess14(langue,3,1), 
     >                          arequa(lepere,1), arequa(lepere,2),
     >                          arequa(lepere,3), arequa(lepere,4)
              write (ulsort,texte(langue,4)) 'Fils : ',
     >                                       mess14(langue,1,4), lefils
              write (ulsort,texte(langue,6)) ' ', mess14(langue,3,1), 
     >                                       aretf
              codret = 1
            endif
cgn            write (ulsort,*) 'orient = ', orient
c
            endif
c
c 2.6. ==> Permutation des aretes du fils
c
            if ( orient.ne.0 ) then
c
            if ( codret.eq.0 ) then
c
            do 261 , jaux = 1 , 4
              arequa(lefils,jaux) = aretf(per1a4(orient,jaux))
  261       continue
c
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,4)) '.... ',
     >                                mess14(langue,1,4)//'fils', lefils
            write (ulsort,texte(langue,6)) '     ',
     >                          mess14(langue,3,1)//'apres', 
     >                          arequa(lefils,1), arequa(lefils,2),
     >                          arequa(lefils,3), arequa(lefils,4)
#endif
c
            endif
c
            endif
c
c 2.7. ==> Changement de code de la face dans l'hexaedre
c
            if ( orient.ne.0 ) then
c
            if ( codret.eq.0 ) then
c
c 2.7.1. ==> Controle du voisin de la face
c
            if ( volqua(1,lefils).lt.0 ) then
               codret = 12
               goto 33
            endif
            lehexa = volqua(1,lefils)
c
#ifdef _DEBUG_HOMARD_
cgn            if ( lehexa.eq.4 ) then
            write (ulsort,*) '.... orient = ', orient
            write (ulsort,texte(langue,4)) '.... ', mess14(langue,1,6),
     >                                     lehexa
         write (ulsort,texte(langue,6)) '     ', mess14(langue,3,4), 
     >                     quahex(lehexa,1), quahex(lehexa,2),
     >                     quahex(lehexa,3), quahex(lehexa,4),
     >                     quahex(lehexa,5), quahex(lehexa,6)
cgn            endif
#endif
c
            if ( volqua(2,lefils).ne.0 ) then
              write (ulsort,texte(langue,4)) 'Fils : ',
     >                                       mess14(langue,1,4), lefils
              write (ulsort,texte(langue,4)) ' ', mess14(langue,1,6),
     >                                     lehexa
              write (ulsort,texte(langue,4)) ' ', mess14(langue,1,6),
     >                                     volqua(2,lefils)
              write (ulsort,texte(langue,8))
              codret = 1
            endif
c
            do 271 , jaux = 1 , 6
              if ( quahex(lehexa,jaux).eq.lefils ) then
                kaux = jaux
                goto 2720
              endif
  271       continue
c
            write (ulsort,texte(langue,4)) 'Fils : ',
     >                                     mess14(langue,1,4), lefils
            write (ulsort,texte(langue,4)) ' ', mess14(langue,1,6),
     >                                   lehexa
            write (ulsort,texte(langue,9))
            codret = 1
c
            endif
c
c 2.7.2. ==> Changement de code
c
 2720       continue
c
            if ( codret.eq.0 ) then
c
c
            codefa = coquhe(lehexa,kaux)
#ifdef _DEBUG_HOMARD_
cgn            if ( lehexa.eq.4 ) then
            write (ulsort,texte(langue,10)) mess14(langue,1,4),
     >                                     lefils, kaux
            write (ulsort,texte(langue,11)) 'ancien', codefa
cgn            endif
#endif
cgn            write (ulsort,*) 'kaux, codefa = ', kaux, codefa
cgn            write (ulsort,*) 'j1(codefa) : ', j1(codefa)
cgn            write (ulsort,*) 'j2(codefa) : ', j2(codefa)
            laux = per1a4(orient,5)
            areti1 = per1a4(laux,j1(codefa))
            areti2 = per1a4(laux,j2(codefa))
cgn            write (ulsort,*) areti1, areti2
c
            do 272 , jaux = 1 , 8
              if ( areti1.eq.j1(jaux) ) then
                if ( areti2.eq.j2(jaux) ) then
                  codefa = jaux
                  goto 2721
                endif
              endif
  272       continue
c
            codret = 1
c
 2721       continue
#ifdef _DEBUG_HOMARD_
cgn            if ( lehexa.eq.4 ) then
            write (ulsort,texte(langue,11)) 'nouveau', codefa
cgn            endif
#endif
c
            coquhe(lehexa,kaux) = codefa
c
            endif
c
            endif
c
   21     continue
c
        endif
c
   20 continue
c
c====
c 3. la fin
c====
c
   33 continue
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
