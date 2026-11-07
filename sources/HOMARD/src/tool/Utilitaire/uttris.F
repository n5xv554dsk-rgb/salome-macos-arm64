      subroutine uttris ( seuil,
     >                    typtri, classt,
     >                    fracti, nbval, valeur,
     >                    ulsort, langue, codret)
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
c    UTilitaire - TRI d'un tableau reel pour un Seuil
c    --           ---                           -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . seuil  .   s .   1    . seuil correspondant                        .
c . typtri . e   .   1    . 1 : grandes valeurs                        .
c .        .     .        . 2 : faibles valeurs                        .
c . fracti . e   .   1    . pourcentage d'entites a retenir            .
c . classt .  s  . nbval  . tableau auxiliaire                         .
c . nbval  . e   .   1    . nombre de valeurs a traiter                .
c . valeur . e   . nbval  . liste des valeurs a ranger                 .
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
      parameter ( nompro = 'UTTRIS' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "infini.h"
#include "precis.h"
c
c 0.3. ==> arguments
c
      integer typtri, nbval
      integer classt(nbval)
c
      double precision seuil, fracti, valeur(nbval)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer numero, nombre, nbvtri
c
      double precision daux, daux1
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
      texte(1,4) = '(''Recherche du seuil'')'
      texte(1,5) = '(''Nombre de valeurs a trier :'',i12)'
      texte(1,6) = '(''Pourcentage demande :'',g13.7)'
      texte(1,7) = '(''==> Nombre d''''entites :'',i12)'
      texte(1,8) = '(''Tri sur les grandes valeurs'')'
      texte(1,9) = '(''Tri sur les faibles valeurs'')'
      texte(1,10) = '(''Seuil :'',g13.7)'
      texte(1,11) = '(''Le pourcentage d''''entites est trop faible.'')'
      texte(1,12) = '(''Une seule valeur a trier.'')'
c
      texte(2,4) = '(''Sort of a real array'')'
      texte(2,5) = '(''Number of valeurs to sort :'',i12)'
      texte(2,6) = '(''Requested percentage :'',g13.7)'
      texte(2,7) = '(''==> Number of entities :'',i12)'
      texte(2,8) = '(''Sort for large values'')'
      texte(2,9) = '(''Sort for small values'')'
      texte(2,10) = '(''Threshold :'',g13.7)'
      texte(2,11) = '(''Requested percentage is too small.'')'
      texte(2,12) = '(''A unique value to sort.'')'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
      write (ulsort,texte(langue,5)) nbval
      write (ulsort,texte(langue,6)) fracti
#endif
c
c====
c 2. Prealable
c====
c
c 2.1. ==> controle du type de recherche
c
      if ( typtri.lt.1 .or. typtri.gt.2 ) then
        codret = 1
      else
        codret = 0
#ifdef _DEBUG_HOMARD_
        if ( typtri.eq.1 ) then
          write (ulsort,texte(langue,8))
        else
          write (ulsort,texte(langue,9))
        endif
#endif
      endif
cgn       print 88,(valeur(iaux),iaux =1,nbval)
cgn 88    format(12g10.3)
c
c 2.2. ==> nombre de valeurs a traiter
c
      if ( codret.eq.0 ) then
c
c 2.2.1. ==> Si 1 seule entite, le cas est particulier
c
      if ( nbval.eq.1 ) then
c
        nbvtri = 1
c
      else
c
c 2.2.2. ==> Avec au moins deux entites, on cherche le nombre
c            correspondant au pourcentage demande par l'entier le plus
c            proche.
c            si on a au moins deux valeurs, on ajoute 1, sauf si on est
c            deja au maximum.

        nbvtri = nint(fracti*dble(nbval)/100.d0)
c
        if ( nbvtri.ge.2 ) then
          nbvtri = min(nbvtri+1,nbval)
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) nbvtri
#endif
c
      endif
c
      endif
c
c====
c 3. calcul du seuil pour les grandes valeurs
c====
c
      if ( codret.eq.0 ) then
c
      if ( typtri.eq.1 ) then
c
        if ( nbvtri.eq.0 ) then
c
c 3.1. ==> Si 0 entite, le seuil est au dessus du maximum
c
          daux = vinfne
          do 311 , iaux = 1 , nbval
            daux = max(daux,valeur(iaux))
  311     continue
          seuil = 2.d0 * daux
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,11))
#endif
c
        elseif ( nbvtri.eq.1 ) then
c
c 3.2. ==> Si 1 entite, le seuil est juste au-dessous du maximum
c
          daux = valeur(1)
          daux1 = vinfpo
          do 321 , iaux = 2 , nbval
            if ( abs(valeur(iaux)-daux).gt.epsima ) then
              daux1 = min(daux1,abs(valeur(iaux)-daux))
            endif
            daux = max(daux,valeur(iaux))
  321     continue
cgn            print 88,daux,daux1
          seuil = daux - 0.5d0*daux1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,12))
      write (ulsort,90004) 'seuil', seuil
#endif
c
        else
c
c 3.3. ==> cas general
c          on stocke dans le tableau classt les indices des valeurs les
c          plus grandes. L'indice 1 correspond a la plus grande valeur
c          et ainsi de suite.
c
          nombre = 0
          daux = vinfne
c
          do 331 , iaux = 1 , nbval
c
c 3.3.1. ==> si la valeur courante est plus grande que le mini des
c            valeurs deja classees, ou si on n'a pas encore classe au
c            moins nbvtri valeurs, il faut l'inserer dans le tableau.
c            on recherche la valeur juste inferieure
c            sinon, on passe a la valeur suivante
c
cgn       print *,valeur(iaux),daux,(valeur(classt(jaux)), jaux =1,nombre)
            if ( valeur(iaux).gt.daux .or. nombre.lt.nbvtri ) then
c
              do 3311 , jaux = 1 , nombre
                if ( valeur(classt(jaux)).lt.valeur(iaux) ) then
                  numero = jaux
                  goto 3312
                endif
 3311         continue
c
              if ( nombre.eq.nbvtri ) then
                numero = nbvtri
              else
                numero = nombre + 1
              endif
c
            else
c
cgn              print *,'goto 331'
              goto 331
c
            endif
c
c 3.3.2. ==> insertion de l'element courant a la bonne place
c            dans la liste
c
 3312       continue
cgn            print *,'numero = ',numero
c
            if ( nombre.eq.nbvtri ) then
              kaux = nbvtri - 1
            else
              kaux = nombre
            endif
            do 3313 , jaux = kaux, numero, -1
              classt(jaux+1) = classt(jaux)
 3313       continue
c
            classt(numero) = iaux
c
c 3.3.3. ==> nombre de valeurs classees : une de plus qu'avant, sauf si
c            on a deja classe toutes celles voulues.
c            Il ne faut surtout pas tout classer sinon c'est extremement
c            couteux (en o(n**2))
c
            if ( nombre.lt.nbvtri ) then
              nombre = nombre + 1
            endif
            daux = valeur(classt(nombre))
cgn            print *,daux,nombre
c
  331     continue
c
c 3.3.4. ==> le seuil est entre la valeur correspondant au pourcentage
c            d'element et celle immediatement superieure
c
cgn      print *,valeur(classt(nbvtri-1))
cgn      print *,valeur(classt(nbvtri))
          seuil = 0.5d0*
     >           (valeur(classt(nbvtri-1))+valeur(classt(nbvtri)))
c
        endif
c
c====
c 4. calcul du seuil pour les faibles valeurs
c====
c
      else
c
        if ( nbvtri.eq.0 ) then
c
c 4.1. ==> Si 0 entite, le seuil est au dessous du minimum
c
          daux = vinfpo
          do 411 , iaux = 1 , nbval
            daux = min(daux,valeur(iaux))
  411     continue
          seuil = 0.5d0 * daux
c
        elseif ( nbvtri.eq.1 ) then
c
c 4.2. ==> Si 1 entite, le seuil est juste au-dessus du minimum
c
          daux = valeur(1)
          daux1 = vinfpo
          do 421 , iaux = 2 , nbval
            if ( abs(valeur(iaux)-daux).gt.epsima ) then
              daux1 = min(daux1,abs(valeur(iaux)-daux))
            endif
            daux = min(daux,valeur(iaux))
  421     continue
          seuil = daux + 0.5d0*daux1
c
        else
c
c 4.3. ==> cas general
c          on stocke dans le tableau classt les indices des valeurs les
c          plus grandes. L'indice 1 correspond a la plus petite valeur
c          et ainsi de suite.
c
          nombre = 0
          daux = vinfpo
c
          do 431 , iaux = 1 , nbval
c
c 4.3.1. ==> si la valeur courante est plus petite que le maxi des
c            valeurs deja classees, ou si on n'a pas encore classe au
c            moins nbvtri valeurs, il faut l'inserer dans le tableau.
c            on recherche la valeur juste superieure
c            sinon, on passe a la valeur suivante
c
cgn       print 88,valeur(iaux),daux,(valeur(classt(jaux)),jaux =1,nombre)
cgn 88    format(12g10.3)
            if ( valeur(iaux).lt.daux .or. nombre.lt.nbvtri ) then
c
              do 4311 , jaux = 1 , nombre
                if ( valeur(classt(jaux)).gt.valeur(iaux) ) then
                  numero = jaux
                  goto 4312
                endif
 4311         continue
c
              if ( nombre.eq.nbvtri ) then
                numero = nbvtri
              else
                numero = nombre + 1
              endif
c
            else
c
cgn              print *,'goto 431'
              goto 431
c
            endif
c
c 4.3.2. ==> insertion de l'element courant a la bonne place
c            dans la liste
c
 4312       continue
cgn            print *,'numero = ',numero
c
            if ( nombre.eq.nbvtri ) then
              kaux = nbvtri - 1
            else
              kaux = nombre
            endif
            do 4313 , jaux = kaux, numero, -1
              classt(jaux+1) = classt(jaux)
 4313       continue
c
            classt(numero) = iaux
c
c 4.3.3. ==> nombre de valeurs classees : une de plus qu'avant, sauf si
c            on a deja classe toutes celles voulues.
c            Il ne faut surtout pas tout classer sinon c'est extremement
c            couteux (en o(n**2))
c
            if ( nombre.lt.nbvtri ) then
              nombre = nombre + 1
            endif
            daux = valeur(classt(nombre))
cgn            print *,daux,nombre
c
  431     continue
c
c 4.3.4. ==> le seuil est entre la valeur correspondant au pourcentage
c            d'element et celle immediatement inferieure
c
cgn      print *,valeur(classt(nbvtri-1))
cgn      print *,valeur(classt(nbvtri))
          seuil = 0.5d0*
     >           (valeur(classt(nbvtri-1))+valeur(classt(nbvtri)))
c
        endif
c
      endif
c
      endif
c
c====
c 5. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,texte(langue,10)) seuil
#endif
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
