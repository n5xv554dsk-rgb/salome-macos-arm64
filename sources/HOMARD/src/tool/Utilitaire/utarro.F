      subroutine utarro ( x1, x2, xar1, xar2,
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
c    UTilitaire - ARROndi
c    --           ----
c
c    retourne un encadrement arrondi a une "bonne" puissance de 10
c    d'un intervalle reel
c    le but est d'avoir 2 chiffres de difference entre les bornes
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . x1     . e   .   1    . premiere valeur a arrondir                 .
c . x2     . e   .   1    . seconde valeur a arrondir                  .
c . xar1   .   s .   1    . premiere valeur arrondie                   .
c . xar2   .   s .   1    . seconde valeur arrondie                    .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c .____________________________________________________________________.
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
      parameter ( nompro = 'UTARRO' )
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
      double precision x1, x2, xar1, xar2
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer vmiexp, vmaexp, vecexp
c
      double precision vminia, vmaxia
      double precision dxmax, dxmin
      double precision vmiman, vmaman, vecman
      double precision daux
c
      integer nbmess
      parameter (nbmess = 10 )
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
      texte(1,4) = '(''Valeur '',i1,'' a arrondir :'',g25.17)'
      texte(1,6) = '(''--> valeur '',i1,'' arrondie :'',g25.17)'
c
      texte(2,4) = '(''Value '',i1,'' to round :'',g25.17)'
      texte(2,6) = '(''--> round value '',i1,'' :'',g25.17)'
c
#include "impr03.h"
 1001 format(a,' :',f20.17,' * 10**',i3)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) 1, x1
      write (ulsort,texte(langue,4)) 2, x2
      write (ulsort,90004) 'epsima', epsima
      write (ulsort,90004) 'dmxent', dmxent
#endif
c
      codret = 0
c
c====
c 2. recherche des bornes
c    j = 0 : les deux valeurs sont confondues
c            . soit parce qu'elles sont toutes les deux inferieures
c              au zero machine
c            . soit parce que leur ecart relatif est inferieur au nombre
c              de chiffres significatifs decelables
c    j = 1 : 0 <= x1 < x2
c    j = 2 : x1 < 0 < x2 et abs(x2)>=abs(x1)
c    j = 3 : x1 < 0 < x2 et abs(x1)>abs(x2)
c    j = 4 : x1 < x2 < 0
c    j = 5 : 0 <= x2 < x1
c    j = 6 : x2 < 0 < x1 et abs(x2)>=abs(x1)
c    j = 7 : x2 < 0 < x1 et abs(x1)>=abs(x2)
c    j = 8 : x2 < x1 < 0
c====
c
      daux = abs(x1) + abs(x2)
#ifdef _DEBUG_HOMARD_
      write (ulsort,90004) 'Somme des valeurs absolues', daux
#endif
      if ( daux.le.zeroma ) then
c
        jaux = 0
c
      else
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90004) '. Ecart en v abs', abs(x2-x1)
      write (ulsort,90004) '. Ecart en v rel', abs(x2-x1)/daux
      write (ulsort,90004) '. Ecart teste', dmxent*abs(x2-x1)/daux
#endif
c
        if ( dmxent*abs(x2-x1)/daux.le.1.d0 ) then
c
          jaux = 0
c
        elseif ( x2.gt.x1 ) then
c
          if ( x1.ge.0.d0 ) then
            jaux = 1
            vmaxia = x2
            vminia = x1
          elseif ( x2.ge.0.d0 ) then
            if ( abs(x2).ge.abs(x1) ) then
              jaux = 2
              vmaxia = abs(x2)
              vminia = abs(x1)
            else
              jaux = 3
              vmaxia = abs(x1)
              vminia = abs(x2)
            endif
          else
            jaux = 4
            vmaxia = abs(x1)
            vminia = abs(x2)
          endif
c
        else
c
          if ( x2.ge.0.d0 ) then
            jaux = 5
            vmaxia = x1
            vminia = x2
          elseif ( x1.ge.0.d0 ) then
            if ( abs(x2).ge.abs(x1) ) then
              jaux = 6
              vmaxia = abs(x2)
              vminia = abs(x1)
            else
              jaux = 7
              vmaxia = abs(x1)
              vminia = abs(x2)
            endif
          else
            jaux = 8
            vmaxia = abs(x2)
            vminia = abs(x1)
          endif
c
        endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) '=> jaux', jaux
#endif
c
c====
c 3. Recherche d'un ecart en puissance de 10 quand les valeurs sont
c    differentes
c    Attention a gerer les cas >0 et <0 ...
c====
c
      if ( jaux.eq.0 ) then
c
        xar1 = (x1+x2)/2.d0
        xar2 = xar1
c
      else
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) '. jaux', jaux
        write (ulsort,90004) '. vminia', vminia
        write (ulsort,90004) '. vmaxia', vmaxia
#endif
c
c 3.1. ==> transformation en mantisse/exposant
c
        call utpd10 ( vminia, vmiman, vmiexp,
     >                ulsort, langue, codret )
c
        call utpd10 ( vmaxia, vmaman, vmaexp,
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,1001) 'v abs mini', vmiman, vmiexp
        write (ulsort,1001) 'v abs maxi', vmaman, vmaexp
#endif
c
c 3.2. ==> Si l'ecart de puissance est d'au moins 2 :
c          . la plus grande variable en valeur absolue est
c            du type +/-0.xx000dn
c          . la plus petite variable en valeur absolue est
c            . mise a zero si les deux variables sont de meme signe
c            . -/+0.01dn si les variables sont de signe oppose
c
        if ( abs(vmaexp-vmiexp).ge.2 ) then
c
c 3.2.1. ==> Arrondi de la grande variable en valeur absolue
c
cgn          daux = vmaman*100.d0
          daux = vmaxia*(10.d0**(2-vmaexp))
          iaux = int(daux)
          dxmax = dble(iaux)*(10.d0**(vmaexp-2))
cgn          write (ulsort,*) iaux,dxmax,abs(dxmax-vmaxia)
          if ( abs(dxmax-vmaxia).gt.epsima ) then
            dxmax = dble(iaux+1)*(10.d0**(vmaexp-2))
          endif
c
c 3.2.2. ==> La petite variable en valeur absolue
c
          if ( jaux.eq.1 .or. jaux.eq.4 .or.
     >         jaux.eq.5 .or. jaux.eq.8 )then
            dxmin = 0.d0
          else
            dxmin = 0.01d0*(10.d0**vmaexp)
          endif
c
c 3.3. ==> Sinon :
c          . la plus grande variable en valeur absolue est
c            du type +/-0.x--xab000dn
c          . la plus petite variable en valeur absolue est
c            du type +/-0.x--xcd000dn
c
        else
c
c 3.3.1. ==> Calcul de l'ecart des valeurs absolues
c
          daux = abs(vmaxia-vminia)
          call utpd10 ( daux, vecman, vecexp,
     >                  ulsort, langue, codret )
#ifdef _DEBUG_HOMARD_
        write (ulsort,1001) 'ecart des va ', vecman, vecexp
#endif
c
c 3.3.2. ==> Arrondi de la grande variable en valeur absolue
c
          daux = vmaxia*(10.d0**(2-vecexp))
          iaux = int(daux)
cgn          write (ulsort,90044) 'daux =',daux,' => iaux =',iaux
cgn          write (ulsort,90002) 'vmaexp,vecexp,vmaexp-vecexp+2',
cgn     >                          vmaexp,vecexp,vmaexp-vecexp+2
          dxmax = dble(iaux)*(10.d0**(vecexp-2))
cgn          write (ulsort,90004) 'dxmax',dxmax,abs(dxmax-vmaxia)
          if ( abs(dxmax-vmaxia).gt.epsima ) then
            dxmax = dble(iaux+1)*(10.d0**(vecexp-2))
          endif
c
c 3.3.3. ==> La petite variable en valeur absolue
c
          daux = vminia*(10.d0**(2-vecexp))
          iaux = int(daux)
cgn          write (ulsort,*) daux,iaux
          dxmin = dble(iaux)*(10.d0**(vecexp-2))
          if ( jaux.eq.2 .or. jaux.eq.3 .or.
     >         jaux.eq.6 .or. jaux.eq.7 )then
            if ( abs(dxmin-vminia).gt.epsima ) then
              dxmin = dble(iaux+1)*(10.d0**(vecexp-2))
            endif
          endif
c
        endif
c
c 3.4. ==> Transfert
c
        if ( jaux.eq.1 ) then
          xar1 =  dxmin
          xar2 =  dxmax
        elseif ( jaux.eq.2 ) then
          xar1 = -dxmin
          xar2 =  dxmax
        elseif ( jaux.eq.3 ) then
          xar1 = -dxmax
          xar2 =  dxmin
        elseif ( jaux.eq.4 ) then
          xar1 = -dxmax
          xar2 = -dxmin
        elseif ( jaux.eq.5 ) then
          xar1 =  dxmax
          xar2 =  dxmin
        elseif ( jaux.eq.6 ) then
          xar1 =  dxmin
          xar2 = -dxmax
        elseif ( jaux.eq.7 ) then
          xar1 =  dxmax
          xar2 = -dxmin
        else
          xar1 = -dxmin
          xar2 = -dxmax
        endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) 1, xar1
      write (ulsort,texte(langue,6)) 2, xar2
#endif
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
c
      endif
cgn
cgn  programme de test
cgn
cgn      program toto
cgn      implicit none
cgn      double precision x1, x2, xar1, xar2
cgn      integer ulsort, langue, codret
cgn      integer iaux
cgn      ulsort = 6
cgn      langue = 1
cgnccc      write (6,*) 'x1, x2 ?'
cgnccc      read (5,*) x1, x2
cgn      do 11 , iaux = 1 , 8
cgn        xar1 = 100304.d0
cgn        xar2 =  99213.d0
cgn        xar1 = sqrt(2.d0)
cgn        xar2 = sqrt(3.d0)*1.d0
cgn        x1 = min(xar1,xar2)
cgn        x2 = max(xar1,xar2)
cgn        xar1 =  x1
cgn        xar2 =  x2
cgn        if ( iaux.eq.1 ) then
cgn          x1 = xar1
cgn          x2 = xar2
cgn        elseif ( iaux.eq.2 ) then
cgn          x1 = -xar1
cgn          x2 = xar2
cgn        elseif ( iaux.eq.3 ) then
cgn          x1 = -xar2
cgn          x2 = xar1
cgn        elseif ( iaux.eq.4 ) then
cgn          x1 = -xar2
cgn          x2 = -xar1
cgn        elseif ( iaux.eq.5 ) then
cgn          x1 = xar2
cgn          x2 = xar1
cgn        elseif ( iaux.eq.6 ) then
cgn          x1 = xar1
cgn          x2 = -xar2
cgn        elseif ( iaux.eq.7 ) then
cgn          x1 = xar2
cgn          x2 = -xar1
cgn        elseif ( iaux.eq.8 ) then
cgn          x1 = -xar1
cgn          x2 = -xar2
cgn        endif
cgn        call utarro ( x1, x2, xar1, xar2,
cgn     >                ulsort, langue, codret )
cgn        write (ulsort,*) x1,' ==> ',xar1
cgn        write (ulsort,*) x2,' ==> ',xar2
cgn        print * ,' '
cgn  11  continue
cgn      end
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
