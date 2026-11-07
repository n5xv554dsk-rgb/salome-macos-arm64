      subroutine uthcai ( lehexa, bindec,
     >                    aretri,
     >                    arequa,
     >                    quahex, coquhe, arehex,
     >                    filhex, fhpyte,
     >                    tritet, cotrte, aretet,
     >                    facpyr, cofapy, arepyr,
     >                    areint )
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
c     UTilitaire : Hexaedre coupe par Conformite - Aretes Internes
c     --           -                  -            -      -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lehexa . e   .  1     . numero de l'hexaedre a examiner            .
c . bindec . e   .  1     . binaire du decoupage                       .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. code des 4 triangles des tetraedres        .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . arehex . e   .nbheca12. numeros des 12 aretes des hexaedres        .
c . filhex . e   . nbheto . premier fils des hexaedres                 .
c . fhpyte . e   .2*nbheco. fhpyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille de l'hexaedre k tel que filhex(k) =-j.
c .        .     .        . fhpyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils de l'hexaedre k tel que filhex(k) = -j.
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des faces des pyramides              .
c . arepyr . e   .nbpyca*8. numeros des 8 aretes des pyramides         .
c . areint .  s  . nbarhi . les aretes internes a l'hexaedre           .
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
c 0.2. ==> communs
c
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombte.h"
#include "hexcf0.h"
c
c 0.3. ==> arguments
c
      integer lehexa, bindec
      integer aretri(nbtrto,3)
      integer arequa(nbquto,4)
      integer quahex(nbhecf,6), coquhe(nbhecf,6), arehex(nbheca,12)
      integer filhex(nbheto), fhpyte(2,nbheco)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
      integer areint(*)
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer f1hp, lequad
      integer listar(12), listaf(12)
      integer nbarmx, nbarhi
      integer nbfipy, filspy
      integer nbfite, filste
      integer nbfihe, filshe
c
#include "impr03.h"
c
c====
c 1. Les aretes externes de l'hexaedre
c====
c
      call utarhe ( lehexa,
     >              nbquto, nbhecf,
     >              arequa, quahex, coquhe,
     >              listar )
c
c====
c 2. Les aretes internes de l'hexaedre
c    On examine les aretes de chaque fils. Si elle est interne, on
c    l'ajoute a la liste. On s'arrete quand le compte est bon
c====
c
      nbarmx = nbarto - nbarin
      nbarhi = 0
c
c 2.1. ==> nombre de fils
c
      nbfihe = chnhe(bindec)
      nbfipy = chnpy(bindec)
      nbfite = chnte(bindec)
#ifdef _DEBUG_HOMARD_
      write (*,90002) 'bindec', bindec
      write (*,90002) 'nbfihe', nbfihe
      write (*,90002) 'nbfipy', nbfipy
      write (*,90002) 'nbfite', nbfite
#endif
c
      f1hp = filhex(lehexa)
cgn      write (*,90002) 'f1hp', f1hp
c
c 2.2. ==> Examen des pyramides
c
      if ( nbfipy.ne.0 ) then
c
        filspy = fhpyte(1,-f1hp)
cgn        write (*,90002) 'filspy', bindec
        do 22 , kaux = 1 , nbfipy
#ifdef _DEBUG_HOMARD_
          write (*,90002) '. Pyramide', filspy
#endif
          if ( filspy.le.nbpycf ) then
            call utarpy ( filspy,
     >                    nbtrto, nbpycf,
     >                    aretri, facpyr, cofapy,
     >                    listaf )
          else
            do 221 , iaux = 1 , 8
              listaf(iaux) = arepyr(filspy-nbpycf,iaux)
  221       continue
          endif
c
          do 222 , iaux = 1 , 8
            if ( listaf(iaux).gt.nbarmx ) then
              do 2221 , jaux = 1 , nbarhi
                if ( listaf(iaux).eq.areint(jaux) ) then
                  goto 222
                endif
 2221         continue
              nbarhi = nbarhi + 1
              areint(nbarhi) = listaf(iaux)
              if ( nbarhi.eq.chnar(bindec) ) then
                goto 9999
              endif
            endif
  222     continue
c
          filspy = filspy + 1
c
   22   continue
c
      endif
c
c 2.3. ==> Examen des tetraedres
c
      if ( nbfite.ne.0 ) then
c
        filste = fhpyte(2,-f1hp)
        do 23 , kaux = 1 , nbfite
#ifdef _DEBUG_HOMARD_
          write (*,90002) '. Tetraedre', filste
#endif
          if ( filste.le.nbtecf ) then
            call utarte ( filste,
     >                    nbtrto, nbtecf,
     >                    aretri, tritet, cotrte,
     >                    listaf )
          else
            do 231 , iaux = 1 , 4
              listaf(iaux) = aretet(filste-nbtecf,iaux)
  231       continue
          endif
c
          do 232 , iaux = 1 , 4
            if ( listaf(iaux).gt.nbarmx ) then
              do 2321 , jaux = 1 , nbarhi
                if ( listaf(iaux).eq.areint(jaux) ) then
                  goto 232
                endif
 2321         continue
              nbarhi = nbarhi + 1
              areint(nbarhi) = listaf(iaux)
              if ( nbarhi.eq.chnar(bindec) ) then
                goto 9999
              endif
            endif
  232     continue
c
          filste = filste + 1
c
   23   continue
c
      endif
c
c 2.4. ==> Examen des hexaedres
c 2.4.1. ==> Cas du decoupage en 8
c
      if ( bindec.eq.4095 ) then
#ifdef _DEBUG_HOMARD_
          write (*,*) '. Hexaedre coupe en 8'
#endif
c
        do 241 , iaux = 1 , 6
c
          if ( iaux.eq.1) then
            lequad = quahex(f1hp,5)
          elseif ( iaux.eq.2) then
            lequad = quahex(f1hp,4)
          elseif ( iaux.eq.3) then
            lequad = quahex(f1hp,6)
          elseif ( iaux.eq.4) then
            lequad = quahex(f1hp+7,1)
          elseif ( iaux.eq.5) then
            lequad = quahex(f1hp+7,3)
          else
            lequad = quahex(f1hp+7,2)
          endif
          nbarhi = nbarhi + 1
          areint(nbarhi) = arequa(lequad,2)
c
  241   continue
c
c 2.4.2. ==> Cas du decoupage de conformite
c
      else
c
        filshe = f1hp
        do 242 , kaux = 1 , nbfihe
#ifdef _DEBUG_HOMARD_
          write (*,90002) '. Hexaedre', filshe
#endif
          if ( filshe.le.nbhecf ) then
            call utarhe ( filshe,
     >                    nbquto, nbhecf,
     >                    arequa, quahex, coquhe,
     >                    listaf )
          else
            do 2421 , iaux = 1 , 12
              listaf(iaux) = arehex(filshe-nbhecf,iaux)
 2421       continue
          endif
c
          do 2422 , iaux = 1 , 12
            if ( listaf(iaux).gt.nbarmx ) then
              do 24221 , jaux = 1 , nbarhi
                if ( listaf(iaux).eq.areint(jaux) ) then
                  goto 2422
                endif
24221         continue
              nbarhi = nbarhi + 1
              areint(nbarhi) = listaf(iaux)
              if ( nbarhi.eq.chnar(bindec) ) then
                goto 9999
              endif
            endif
 2422     continue
c
          filshe = filshe + 1
c
  242   continue
c
      endif
c
 9999 continue
#ifdef _DEBUG_HOMARD_
          write (*,90002) '. Nombre d''aretes internes', nbarhi
#endif
c
      end
