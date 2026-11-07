      subroutine cmhomt ( arehom, trihom,
     >                    somare,
     >                    aretri, filtri, hettri,
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
c    Creation du Maillage - HOMologues - les Triangles
c    -           -          ---              -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . arehom . es  . nbarto . ensemble des aretes homologues             .
c . trihom . es  . nbtrto . ensemble des triangles homologues          .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . filtri . e   . nbtrto . premier fils des triangles                 .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
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
      parameter ( nompro = 'CMHOMT' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "demitr.h"
#include "nombar.h"
#include "nombtr.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer arehom(nbarto), trihom(nbtrto)
      integer somare(2,nbarto)
      integer aretri(nbtrto,3), filtri(nbtrto), hettri(nbtrto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer letria
      integer fach
      integer hist, etafac, etafho, an2, an1, n2f, n1f
      integer a2f1, a2f2, a2f3, a1f1, a1f2, a1f3
      integer f2k, f2j, f1k, f1j
      integer na2k, na1k, na1j
      integer a2s2s3, a2s1s3
      integer a1s1s2, a1s2s3, a1s1s3
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Etat du '',a,i10,'' : '',i4)'
      texte(1,5) = '(/,''Les deux '',a,'' homologues'',2i10)'
      texte(1,6) = '(''devraient etre coupes en 2.'')'
      texte(1,7) = '(''Elle a pour homologue '',i10)'
      texte(1,8) = '(''Il faudrait l''''arete'',i10,'' ou '',i10)'
      texte(1,9) = '(''Arete'',i10,'' de sommets'',2i10)'
      texte(1,10) = '(5x,''Erreur sur les '',a,'' homologues.'')'
c
      texte(2,4) = '(''State of '',a,'' #'',i10,'' : '',i4)'
      texte(2,5) = '(/,''The two homologous '',a,'' #'',i10)'
      texte(2,6) = '(''should be cut into 2.'')'
      texte(2,7) = '(''Its homologous is ''i10)'
      texte(2,8) = '(''It should be edge #'',i10,'' or #'',i10)'
      texte(2,9) = '(''Edge #'',i10,'' with vertices #'',2i10)'
      texte(2,10) = '(5x,''Error for homologous '',a)'
c
c====
c 2. on boucle uniquement sur les triangles de la face periodique 2
c    qui viennent d'etre decoupes en 2 ou en 4
c====
c
      do 21, letria = 1, nbtrpe
c
        if ( trihom(letria).gt.0 ) then
c
          hist = hettri(letria)
          etafac = mod ( hist, 10 )
c
          if ( hist.eq. 4 .or. hist.eq.14 .or.
     >         hist.eq.24 .or. hist.eq.34 ) then
c
            fach = abs(trihom(letria))
c
c 2.1. ==> le triangle vient d'etre decoupe en 4
c
c 2.1.1. ==> recuperation des infos sur les fils de letria
c
            n2f = filtri(letria)
c
c           recuperation des numeros d'aretes
c
            a2s2s3 = aretri(letria,1)
            a2s1s3 = aretri(letria,2)
c
c           recuperation des aretes internes
c
            a2f1 = aretri(n2f,1)
            a2f2 = aretri(n2f,2)
            a2f3 = aretri(n2f,3)
c
c 2.1.2.  ==> recuperation des infos sur le triangle homologue
c
            n1f = filtri(fach)
c
c           recuperation des numeros d'aretes
c
            a1s1s2 = aretri(fach,3)
            a1s2s3 = aretri(fach,1)
            a1s1s3 = aretri(fach,2)
c
c           recuperation des aretes internes
c
            a1f1 = aretri(n1f,1)
            a1f2 = aretri(n1f,2)
            a1f3 = aretri(n1f,3)
c
c 2.1.3.  ==> reperage des homologues
c
c           dans tous les cas on a correspondance entre
c           les triangles n2f et n1f, fils aines.
c           n2f est sur la meme face que "larete" c'est-a-dire la face 2
c           donc noehom(n2f) est positif.
c           s1f est sur l'autre face, donc noehom(s1f) est negatif
c
            trihom(n2f) = n1f
            trihom(n1f) = -n2f
c
            if ( abs(arehom(a2s2s3)).eq.a1s2s3 ) then
c
c             les aretes 1 correspondent donc on a correspondance entre
c             les triangles n2f+1 et n1f+1
c             les aretes a2f1 et a1f1
c
              arehom(a2f1) = a1f1
              arehom(a1f1) = -a2f1
c
              trihom(n2f+1) = (n1f+1)
              trihom(n1f+1) = -(n2f+1)
c
              if ( abs(arehom(a2s1s3)).eq.a1s1s3 ) then
c
c               les aretes 2 correspondent donc
c               on a correspondance entre
c               les triangles n2f+2 et n1f+2
c               les triangles n2f+3 et n1f+3
c               les aretes a2f2 et a1f2
c               les aretes a2f3 et a1f3
c
                arehom(a2f2) = a1f2
                arehom(a1f2) = -a2f2
                arehom(a2f3) = a1f3
                arehom(a1f3) = -a2f3
c
                trihom(n2f+2) = (n1f+2)
                trihom(n1f+2) = -(n2f+2)
                trihom(n2f+3) = (n1f+3)
                trihom(n1f+3) = -(n2f+3)
c
              else
c
c               les aretes 2 et 3 correspondent
c               donc on a correspondance entre
c               les triangles n2f+2 et n1f+3
c               les triangles n2f+3 et n1f+2
c               les aretes a2f2 et a1f3
c               les aretes a2f3 et a1f2
c
                arehom(a2f2) = a1f3
                arehom(a1f3) = -a2f2
                arehom(a2f3) = a1f2
                arehom(a1f2) = -a2f3
c
                trihom(n2f+2) = (n1f+3)
                trihom(n1f+3) = -(n2f+2)
                trihom(n2f+3) = (n1f+2)
                trihom(n1f+2) = -(n2f+3)
c
              endif
c
            elseif ( abs(arehom(a2s2s3)).eq.a1s1s3 ) then
c
c             les aretes 1 et 2 correspondent
c             donc on a correspondance entre
c             les triangles n2f+1 et n1f+2
c             les aretes a2f1 et a1f2
c
              arehom(a2f1) = a1f2
              arehom(a1f2) = -a2f1
c
              trihom(n2f+1) = (n1f+2)
              trihom(n1f+2) = -(n2f+1)
c
              if ( abs(arehom(a2s1s3)).eq.a1s2s3 ) then
c
c               les aretes 2 et 1 correspondent
c               donc on a correspondance entre
c               les triangles n2f+2 et n1f+1
c               les triangles n2f+3 et n1f+3
c               les aretes a2f2 et a1f1
c               les aretes a2f3 et a1f3
c
                arehom(a2f2) = a1f1
                arehom(a1f1) = -a2f2
                arehom(a2f3) = a1f3
                arehom(a1f3) = -a2f3
c
                trihom(n2f+2) = (n1f+1)
                trihom(n1f+1) = -(n2f+2)
                trihom(n2f+3) = (n1f+3)
                trihom(n1f+3) = -(n2f+3)
c
              else
c
c               les aretes 2 et 3 correspondent
c               donc on a correspondance entre
c               les triangles n2f+2 et n1f+3
c               les triangles n2f+3 et n1f+1
c               les aretes a2f2 et a1f3
c               les aretes a2f3 et a1f1
c
                arehom(a2f2) = a1f3
                arehom(a1f3) = -a2f2
                arehom(a2f3) = a1f1
                arehom(a1f1) = -a2f3
c
                trihom(n2f+2) = (n1f+3)
                trihom(n1f+3) = -(n2f+2)
                trihom(n2f+3) = (n1f+1)
                trihom(n1f+1) = -(n2f+3)
c
              endif
c
            elseif ( abs(arehom(a2s2s3)).eq.a1s1s2 ) then
c
c             les aretes 1 et 3 correspondent
c             donc on a correspondance entre
c             les triangles n2f+1 et n1f+3
c             les aretes a2f1 et a1f3
c
              arehom(a2f1) = a1f3
              arehom(a1f3) = -a2f1
c
              trihom(n2f+1) = (n1f+3)
              trihom(n1f+3) = -(n2f+1)
c
              if ( abs(arehom(a2s1s3)).eq.a1s2s3 ) then
c
c               les aretes 2 et 1 correspondent
c               donc on a correspondance entre
c               les triangles n2f+2 et n1f+1
c               les triangles n2f+3 et n1f+2
c               les aretes a2f2 et a1f1
c               les aretes a2f3 et a1f2
c
                arehom(a2f2) = a1f1
                arehom(a1f1) = -a2f2
                arehom(a2f3) = a1f2
                arehom(a1f2) = -a2f3
c
                trihom(n2f+2) = (n1f+1)
                trihom(n1f+1) = -(n2f+2)
                trihom(n2f+3) = (n1f+2)
                trihom(n1f+2) = -(n2f+3)
c
              else
c
c               les aretes 2 correspondent
c               donc on a correspondance entre
c               les triangles n2f+2 et n1f+2
c               les triangles n2f+3 et n1f+1
c               les aretes a2f2 et a1f3
c               les aretes a2f3 et a1f1
c
                arehom(a2f2) = a1f2
                arehom(a1f2) = -a2f2
                arehom(a2f3) = a1f1
                arehom(a1f1) = -a2f3
c
                trihom(n2f+2) = (n1f+2)
                trihom(n1f+2) = -(n2f+2)
                trihom(n2f+3) = (n1f+1)
                trihom(n1f+1) = -(n2f+3)
c
              endif
c
            else
              write (ulsort,texte(langue,10)) mess14(langue,3,2)
            endif
c
          elseif ( etafac.eq.1 .or. etafac.eq.2 .or. etafac.eq.3 ) then
c
c 2.2. ==> le triangle vient d'etre decoupe en 2
c          . il n'y a aucune regle d'ordre de creation des
c          demi-triangles entre les deux meres homologues.
c          . il n'y a pas de probleme d'axe a gerer, car letria est
c          sur la face 2 par hypothese, et donc fach sur la face 1
c          . la seule information dont on est certain est la
c          correspondance entre les filles des aretes decoupees : le
c          tableau arehom a ete mis a jour precedemment
c
c             letria                         fach
c
c               s2i                           s1i
c                x                             x
c               ...                           ...
c              . . .                         . . .
c       are2j .  .  . are2k   <-->    are1j .  .  . are1k
c            .  a.   .                     .  a.   .
c           .   n.    .                   .   n.    .
c          .    2.     .                 .    1.     .
c         . f2k  . f2j  .               . f1k  . f1j  .
c        .       .       .             .       .       .
c       x-----------------x           x-----------------x
c     s2k  na2k n2  na2j  s2j       s1k na1k  n1  na1j  s1j
c
c        alternative :      f2k est homologue de f1k
c                      ou : f2k est homologue de f1j
c
c 2.2.1. ==> recuperation des infos sur les fils de letria
c
            if ( etafac.eq.1 ) then
c
c             le triangle a ete decoupe en 2 par l'arete numero 1
c
c             recuperation des triangles fils
c
              f2k = filtri(letria) + nutrde(1,2)
              f2j = filtri(letria) + nutrde(1,3)
c
c             recuperation des nouvelles aretes
c
              na2k = aretri(f2k,1)
c
              an2 = aretri(f2k,3)
c
            elseif ( etafac.eq.2 ) then
c
c             le triangle a ete decoupe en 2 par l'arete numero 2
c
c             recuperation des triangles fils
c
              f2k = filtri(letria) + nutrde(2,3)
              f2j = filtri(letria) + nutrde(2,1)
c
c             recuperation des nouvelles aretes
c
              na2k = aretri(f2k,2)
c
              an2 = aretri(f2k,1)
c
            elseif ( etafac.eq.3 ) then
c
c             le triangle a ete decoupe en 2 par l'arete numero 3
c
c             recuperation des triangles fils
c
              f2k = filtri(letria) + nutrde(3,1)
              f2j = filtri(letria) + nutrde(3,2)
c
c             recuperation des nouvelles aretes
c
              na2k = aretri(f2k,3)
c
              an2 = aretri(f2k,2)
c
            endif
c
c 2.2.2.  ==> recuperation des infos sur le triangle homologue
c
            fach = abs(trihom(letria))
c
            etafho = mod ( hettri(fach), 10 )
c
            if ( etafho.eq.1 ) then
c
c             le triangle a ete decoupe en 2 par l'arete numero 1
c
c             recuperation des triangles fils
c
              f1k = filtri(fach) + nutrde(1,2)
              f1j = filtri(fach) + nutrde(1,3)
c
c             recuperation des nouvelles aretes
c
              na1k = aretri(f1k,1)
              na1j = aretri(f1j,1)
c
              an1 = aretri(f1k,3)
c
            elseif ( etafho.eq.2 ) then
c
c             le triangle a ete decoupe en 2 par l'arete numero 2
c
c             recuperation des triangles fils
c
              f1k = filtri(fach) + nutrde(2,3)
              f1j = filtri(fach) + nutrde(2,1)
c
c             recuperation des nouvelles aretes
c
              na1k = aretri(f1k,2)
              na1j = aretri(f1j,2)
c
              an1 = aretri(f1k,1)
c
            elseif ( etafho.eq.3 ) then
c
c             le triangle a ete decoupe en 2 par l'arete numero 3
c
c             recuperation des triangles fils
c
              f1k = filtri(fach) + nutrde(3,1)
              f1j = filtri(fach) + nutrde(3,2)
c
c             recuperation des nouvelles aretes
c
              na1k = aretri(f1k,3)
              na1j = aretri(f1j,3)
c
              an1 = aretri(f1k,2)
c
            else
c
c             le triangle homologue n'est pas coupe en deux ???
c
              write (ulsort,texte(langue,5))mess14(langue,3,2),
     >                                      letria, fach
              write (ulsort,texte(langue,6))
              write (ulsort,texte(langue,4)) mess14(langue,1,2),
     >                                       letria, etafac
              write (ulsort,texte(langue,4)) mess14(langue,1,2),
     >                                       fach, etafho
              codret = 2
c
            endif
c
c 2.2.3.  ==> reperage des homologues
c
            arehom(an2) = an1
            arehom(an1) = -an2
c
            if ( arehom(na2k).eq.na1k ) then
c
              trihom(f2k) = f1k
              trihom(f2j) = f1j
              trihom(f1k) = -f2k
              trihom(f1j) = -f2j
c
            elseif ( arehom(na2k).eq.na1j ) then
c
              trihom(f2k) = f1j
              trihom(f2j) = f1k
              trihom(f1k) = -f2j
              trihom(f1j) = -f2k
c
            else
c
c             l'arete n'a pas d'homologue ?
c
              write (ulsort,texte(langue,5)) mess14(langue,3,2),
     >                                       letria, fach
              write (ulsort,texte(langue,9))
     >                              na2k, somare(1,na2k), somare(2,na2k)
              write (ulsort,texte(langue,7)) arehom(na2k)
              if ( arehom(na2k).ne.0 ) then
                write (ulsort,texte(langue,9)) abs(arehom(na2k)),
     >          somare(1,abs(arehom(na2k))), somare(2,abs(arehom(na2k)))
              endif
              write (ulsort,texte(langue,8)) na1k, na1j
              write (ulsort,texte(langue,9))
     >                              na1k, somare(1,na1k), somare(2,na1k)
              write (ulsort,texte(langue,9))
     >                              na1j, somare(1,na1j), somare(2,na1j)
              codret = 2
c
            endif
c
          endif
c
        endif
c
   21 continue
c
c====
c 3. la fin
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
