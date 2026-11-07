      subroutine decr05 ( tyconf, homolo,
     >                    decfac, decare,
     >                    hetare, filare, posifa, facare,
     >                    hettri, aretri, voltri,
     >                    hetqua, arequa, volqua,
     >                    tritet, quahex, coquhe,
     >                    arehom,
     >                    afaire,
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
c traitement des DEcisions - Contraintes de Raffinement - 05
c                --          -              -             --
c    Pas de segments decoupes sans sa face voisine, ni de face decoupee
c    sans son volume voisin
c    Il faut faire ce controle a la fin de l'algorithme sur la
c    propagation du raffinement, car on ne peut pas prevoir au depart
c    tout ce qui va se passer. En particulier dans des cas bizarres pour
c    lesquels on aurait plusieurs boites.
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
c .        .     .        . -2 : non-conforme avec au maximum 1 arete  .
c .        .     .        .      decoupee en 2 (boite pour les         .
c .        .     .        .      quadrangles, hexaedres et pentaedres) .
c . homolo . e   .    1   . type de relations par homologues           .
c .        .     .        . 0 : pas d'homologues                       .
c .        .     .        . 1 : relations sur les noeuds               .
c .        .     .        . 2 : relations sur les noeuds et les aretes .
c .        .     .        . 3 : relations sur les noeuds, les aretes   .
c .        .     .        .     et les triangles                       .
c . decfac . e   . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . decare . es  . nbarto . decisions des aretes                       .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . filare . e   . nbarto . premiere fille des aretes                  .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . volqua . e   .2*nbquto. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . arehom . e   . nbarto . ensemble des aretes homologues             .
c . afaire . es  .    1   . que faire a la sortie                      .
c .        .     .        . 0 : aucune action                          .
c .        .     .        . 1 : refaire une iteration de l'algorithme  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . sinon : probleme                           .
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
      parameter ( nompro = 'DECR05' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer tyconf, homolo
      integer decfac(-nbquto:nbtrto), decare(0:nbarto)
      integer hetare(nbarto), filare(nbarto)
      integer posifa(0:nbarto), facare(nbfaar)
      integer hettri(nbtrto), aretri(nbtrto,3), voltri(2,nbtrto)
      integer hetqua(nbquto), arequa(nbquto,4), volqua(2,nbquto)
      integer tritet(nbtecf,4)
      integer quahex(nbhecf,6), coquhe(nbhecf,6)
      integer arehom(nbarto)
c
      integer afaire
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer ipos
      integer iaux, jaux, kaux
      integer ideb, ifin
      integer etatar, etatfa
      integer larete, laret1, larelo, laface, iface, letetr, lehexa
      integer nbarpb, nbfapb
      integer nbaret, listar(12)
#ifdef _DEBUG_HOMARD_
      integer glop
#endif
c
      integer nbmess
      parameter ( nbmess = 30 )
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
      texte(1,4) =
     >'(5x,''Pas de maille de bord decoupe sans son voisin.'',/)'
      texte(1,5) = '(7x,''Nombre de '',a,''a reconsiderer :'',i6,/)'
      texte(1,6) = '(7x,''Aucun changement.'')'
      texte(1,7) = '(7x,''Apres l''''analyse '',a)'
      texte(1,8) = '(a,''numero '',i8,'' : decision ='',i2)'
      texte(1,9) =
     > '(a,''numero '',i8,'' : decision ='',i2,'', etat ='',i5)'
      texte(1,10) = '(/,i1,''. Examen des'',i10,1x,a,)'
c
      texte(2,4) =
     > '(5x,''No border mesh cut without its neighbour.'',/)'
      texte(2,5) = '(7x,''Number of'',a,''to deal with :'',i6,/)'
      texte(2,6) = '(7x,''No modification.'')'
      texte(2,7) = '(7x,''After analysis '',a)'
      texte(2,8) = '(a,''#'',i8,'' : decision ='',i25)'
      texte(2,9) =
     > '(a,''#'',i8,'' : decision ='',i2,'', status ='',i5)'
      texte(2,10) = '(/,''Examination of the'',i10,1x,a,)'
c
#include "impr03.h"
c
#include "derco1.h"
c
      codret = 0
c
      write (ulsort,texte(langue,4))
c
      nbarpb = 0
      nbfapb = 0
c
c====
c 2. on interdit les situations ou on aurait un segment decoupe alors
c    qu'aucune des faces auxquelles il appartient ne le serait.
c    Cela peut arriver si on a fait du decoupage selon une zone
c    geometrique et que cette zone incluait une serie d'aretes.
c    Ou avec un indicateur sur aretes ou noeuds et que ce seul
c    segment a ete retenu.
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. face/arete ; codret', codret
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,10)) 1, nbarto, mess14(langue,3,1)
#endif
c
      do 20 , larete = 1 , nbarto
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,8)) mess14(langue,1,1),
     > larete,decare(larete)
#endif
c
        if ( decare(larete).eq.2 ) then
c
c 2.1. ==> on parcourt chacune des faces voisines de l'arete
c          on compte le nombre de faces a couper ou a reactualiser
c          s'il y a des equivalences, il faut traiter ensemble une
c          arete et son homologue
c
          kaux = 0
c
          nbaret = 1
          listar(1) = larete
          if ( homolo.ge.2 ) then
            laret1 = arehom(larete)
            if ( laret1.ne.0 ) then
              listar(2) = abs(laret1)
              nbaret = 2
            endif
          endif
c
          do 211 , iaux = 1 , nbaret
c
            laret1 = listar(iaux)
c
            ideb = posifa(laret1-1)+1
            ifin = posifa(laret1)
c
            do 2111 , ipos = ideb , ifin
c
              iface = facare(ipos)
              if ( iface.gt.0 ) then
                etatfa = mod( hettri(iface) , 10 )
              else
                etatfa = mod( hetqua(-iface) , 100 )
              endif
#ifdef _DEBUG_HOMARD_
         write (ulsort,texte(langue,9))'.. '//mess14(langue,1,8),
     > abs(iface),decfac(iface),etatfa
#endif
              if ( etatfa.ne.0 .and. decfac(iface).ne.-1 ) then
                goto 20
              else if ( decfac(iface).eq.4 ) then
                goto 20
              else
                kaux = kaux + 1
              endif
c
 2111       continue
c
  211     continue
c
c 2.2. ==> aucune face n'est a couper ou a reactualiser, on ne doit pas
c          couper l'arete
c
          if ( kaux.gt.0 ) then
            nbarpb = nbarpb + 1
            do 22 , iaux = 1 , nbaret
              laret1 = listar(iaux)
              decare(laret1) = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))'decare', laret1,decare(laret1),' '
        write (ulsort,*)' '
#endif
   22       continue
          endif
c
        endif
c
   20 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) 'face/arete'
      if ( nbarpb.gt.0 .or. nbfapb.gt.0 ) then
        write (ulsort,texte(langue,5)) mess14(langue,3,1), nbarpb
        write (ulsort,texte(langue,5)) mess14(langue,3,8), nbfapb
      else
        write (ulsort,texte(langue,6))
      endif
#endif
c
c====
c 3. on interdit les situations ou on aurait un triangle decoupe alors
c    qu'aucun de ses tetraedres voisins ne le serait.
c    Cela peut arriver si on a fait du decoupage selon une zone
c    geometrique et que cette zone incluait une zone purement 2D.
c    Ou avec un indicateur sur faces ou noeuds et que cette seule
c    face a ete retenue.
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. tetr/tria ; codret', codret
#endif
c
      if ( nbteto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,10)) 2, nbtrto, mess14(langue,3,2)
#endif
c
      do 30 , laface = 1 , nbtrto
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,8)) mess14(langue,1,2),
     > laface,decfac(laface)
#endif
c
        if ( decfac(laface).eq.4 ) then
c
          kaux = 0
c
c 3.1. ==> on parcourt chacun des tetraedres voisins du triangle
c          un tetraedre sera coupe si au moins une autre de ses faces
c          l'est
c   ATTENTION A FAIRE COMME LES HEXAS
c
          do 31 , iaux = 1 , 2
c
            letetr = voltri(iaux,laface)
c
            if ( letetr.gt.0 ) then
c
              do 311 , jaux = 1 , 4
c
                iface = tritet(letetr,jaux)
c
                if ( iface.ne.laface ) then
c
                  etatfa = mod( hettri(iface) , 10 )
#ifdef _DEBUG_HOMARD_
         write (ulsort,texte(langue,9))'.. '//mess14(langue,1,2),
     > iface,decfac(iface),etatfa
#endif
                  if ( etatfa.ne.0 .and. decfac(iface).ne.-1 ) then
                    goto 30
                  else if ( decfac(iface).eq.4 ) then
                    goto 30
                  else
                    kaux = kaux + 1
                  endif
c
                endif
c
 311          continue
c
            endif
c
  31      continue
c
c 3.2. ==> aucun tetraedre n'est a couper ou a reactualiser, on ne doit
c          pas couper le triangle, ni ses aretes
c
          if ( kaux.gt.0 ) then
            nbfapb = nbfapb + 1
            decfac(laface) = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))'decfac', laface,decfac(laface),' '
#endif
            do 32 , larelo = 1 , 3
              larete = aretri(laface,larelo)
              if ( decare(larete).eq.2 ) then
                nbarpb = nbarpb + 1
                decare(larete) = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))'decare', larete,decare(larete),' '
#endif
              endif
   32       continue
          endif
#ifdef _DEBUG_HOMARD_
        write (ulsort,*)' '
#endif
c
        endif
c
   30 continue
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) 'tetr/tria'
      if ( nbarpb.gt.0 .or. nbfapb.gt.0 ) then
        write (ulsort,texte(langue,5)) mess14(langue,3,1), nbarpb
        write (ulsort,texte(langue,5)) mess14(langue,3,8), nbfapb
      else
        write (ulsort,texte(langue,6))
      endif
#endif
c
c====
c 4. on interdit les situations ou on aurait un quadrangle decoupe alors
c    qu'aucun de ses hexaedres voisins ne le serait.
c    Cela peut arriver si on a fait du decoupage selon une zone
c    geometrique et que cette zone incluait une zone purement 2D.
c    Ou avec un indicateur sur faces ou noeuds et que cette seule
c    face a ete retenue.
c    Cela peut aussi arriver par contamination entre faces.
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. hexa/quad ; codret', codret
#endif
c
      if ( nbheto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,10)) 3, nbquto, mess14(langue,3,4)
#endif
c
      do 40 , laface = 1 , nbquto
c
#ifdef _DEBUG_HOMARD_
          if ( laface.eq.215996 .or.
     >         laface.eq.66980  ) then
            glop=1
          else
            glop=0
          endif
          if ( glop.gt.0 ) then
        write (ulsort,texte(langue,8)) mess14(langue,1,4),
     > laface,decfac(-laface)
        write (ulsort,*) ' volqua(*,laface) : ',
     >         volqua(1,laface),volqua(2,laface)
          do 401 , iaux = 1 , 2
            lehexa = volqua(iaux,laface)
            if ( lehexa.gt.0 ) then
         write (ulsort,*)'.. hexaedre ', lehexa
              do 4011 , jaux = 1 , 6
                iface = quahex(lehexa,jaux)
                  etatfa = mod( hetqua(iface) , 100 )
         write (ulsort,texte(langue,9))'.. '//mess14(langue,1,4),
     > iface,decfac(-iface),etatfa
 4011          continue
          endif
  401      continue
          endif
#endif
c
        if ( decfac(-laface).eq.4 ) then
c
c 4.1. ==> on parcourt chacun des hexaedres voisins du quadrangle
c          un hexaedre sera coupe si toutes ses faces le sont
c          kaux = nombre de faces coupees ou a couper pour le
c                 iaux-ime hexaedre
c
          do 41 , iaux = 1 , 2
c
            lehexa = volqua(iaux,laface)
c
            kaux = 1
c
            if ( lehexa.gt.0 ) then
#ifdef _DEBUG_HOMARD_
          if ( glop.gt.0 ) then
         write (ulsort,*)'.. hexaedre ', lehexa
          endif
#endif
c
              do 411 , jaux = 1 , 6
c
                iface = quahex(lehexa,jaux)
c
                if ( iface.ne.laface ) then
c
                  etatfa = mod( hetqua(iface) , 100 )
#ifdef _DEBUG_HOMARD_
          if ( glop.gt.0 ) then
         write (ulsort,texte(langue,9))'.. '//mess14(langue,1,4),
     > iface,decfac(-iface),etatfa
          endif
#endif
                  if ( etatfa.ne.0 .and. decfac(-iface).ne.-1 ) then
                    kaux = kaux + 1
                  else if ( decfac(-iface).eq.4 ) then
                    kaux = kaux + 1
                  endif
c
                endif
c
 411          continue
c
c             les 6 faces de l'hexaedre seront coupees, donc RAS
c
              if ( kaux.eq.6 ) then
                goto 40
              endif
c
            endif
c
  41      continue
c
c 4.2. ==> si on arrive ici, c'est qu'aucun des hexaedres voisins
c          n'est a couper
c          2 cas se presentent :
c          A. . si on est en mode non-conforme fidele a l'indicateur
c             . ou si les aretes de chacun des hexaedres voisins ne
c               sont pas decoupees plus d'une fois
c          ==> ne pas couper le quadrangle courant, ni ses aretes
c          B. . si on n'est pas en non-conforme fidele a l'indicateur
c             . et si au moins une des aretes des hexaedres voisins
c               a une de ses filles a couper
c          ==> couper toutes les faces et toutes les aretes du ou des
c              hexaedres voisins dont une face aura une fille coupee
c
c          Remarque : le cas A apparait dans le cas d'une contamination
c                     par la regle des 2 voisins
c                     le cas B apparait dans le cas d'une contamination
c                     par la regle des ecarts de niveau
c
#ifdef _DEBUG_HOMARD_
          if ( glop.gt.0 ) then
         write (ulsort,*) ' '
         write (ulsort,texte(langue,9))'.. '//mess14(langue,1,4),
     > laface,decfac(-laface),mod( hetqua(laface) , 100 )
          endif
#endif
c
          kaux = 0
          if ( tyconf.lt.3 ) then
c
            do 42 , iaux = 1 , 2
c
              lehexa = volqua(iaux,laface)
c
              if ( lehexa.gt.0 ) then
#ifdef _DEBUG_HOMARD_
          if ( glop.gt.0 ) then
         write (ulsort,*)'.. hexaedre voisin : ', lehexa
          endif
#endif
c
                call utarhe ( lehexa,
     >                        nbquto, nbhecf,
     >                        arequa, quahex, coquhe,
     >                        listar )
c
                do 421 , jaux = 1 , 12
c
                  larete = listar(jaux)
c
                  etatar = mod( hetare(larete) , 10 )
#ifdef _DEBUG_HOMARD_
          if ( glop.gt.0 ) then
         write (ulsort,texte(langue,9))'.... '//mess14(langue,1,1),
     > larete,decare(larete),etatar
          endif
#endif
                  if ( etatar.eq.2 ) then
                    if ( decare(filare(larete))  .eq.2 .or.
     >                   decare(filare(larete)+1).eq.2 ) then
                      kaux = 1
                      goto 43
                    endif
                  endif
c
  421           continue
c
              endif
c
   42       continue
c
          endif
c
c 4.3. ==> modification des decisions
c
   43     continue
c
c 4.3.1. ==> Cas A : ne pas couper le quadrangle courant, ni ses aretes
c
          if ( kaux.eq.0 ) then
c
            nbfapb = nbfapb + 1
            decfac(-laface) = 0
#ifdef _DEBUG_HOMARD_
          if ( glop.gt.0 ) then
      write (ulsort,texte(langue,30))'decfac',laface,decfac(-laface),' '
          endif
#endif
            do 431 , larelo = 1 , 4
              larete = arequa(laface,larelo)
#ifdef _DEBUG_HOMARD_
          if ( glop.gt.0 ) then
      write (ulsort,texte(langue,9))'. . '//mess14(langue,1,1),
     > larete,decare(larete),mod( hetare(larete) , 10 )
          endif
#endif
              if ( decare(larete).eq.2 ) then
                nbarpb = nbarpb + 1
                decare(larete) = 0
#ifdef _DEBUG_HOMARD_
          if ( glop.gt.0 ) then
      write (ulsort,texte(langue,30))'decare', larete,decare(larete),' '
          endif
#endif
              endif
c
  431       continue
c
c 4.3.2. ==> Cas B : couper toutes les faces et toutes les aretes du ou
c            des hexaedres voisins
c
          else
c
            do 432 , iaux = 1 , 2
c
              lehexa = volqua(iaux,laface)
c
              if ( lehexa.gt.0 ) then
#ifdef _DEBUG_HOMARD_
          if ( glop.gt.0 ) then
         write (ulsort,*)'.. hexaedre voisin : ', lehexa
          endif
#endif
                do 4321 , jaux = 1 , 6
c
                  iface = quahex(lehexa,jaux)
                  etatfa = mod( hetqua(iface) , 100 )
                  if ( etatfa.ne.0 .and. decfac(-iface).eq.-1 ) then
                    nbfapb = nbfapb + 1
                    decfac(-iface) = 0
#ifdef _DEBUG_HOMARD_
            if ( glop.gt.0 ) then
      write (ulsort,texte(langue,30))'decfac',iface,decfac(-iface),' '
          endif
#endif
                  else if ( etatfa.eq.0 .and. decfac(-iface).eq.0 ) then
                    nbfapb = nbfapb + 1
                    decfac(-iface) = 4
#ifdef _DEBUG_HOMARD_
            if ( glop.gt.0 ) then
      write (ulsort,texte(langue,30))'decfac',iface,decfac(-iface),' '
          endif
#endif
                  endif
c
 4321           continue
c
                call utarhe ( lehexa,
     >                        nbquto, nbhecf,
     >                        arequa, quahex, coquhe,
     >                        listar )
c
                do 4322 , jaux = 1 , 12
c
                  larete = listar(jaux)
                  etatar = mod( hetare(larete) , 10 )
                  if ( etatar.eq.2 .and. decare(larete).eq.-1 ) then
                    nbarpb = nbarpb + 1
                    decare(larete) = 0
#ifdef _DEBUG_HOMARD_
          if ( glop.gt.0 ) then
        write (ulsort,texte(langue,30)) 'decare',larete,decare(larete)
          endif
#endif
                  elseif ( etatar.eq.0 .and. decare(larete).eq.0 ) then
                    nbarpb = nbarpb + 1
                    decare(larete) = 2
#ifdef _DEBUG_HOMARD_
          if ( glop.gt.0 ) then
        write (ulsort,texte(langue,30)) 'decare',larete,decare(larete)
          endif
#endif
                  endif
c
 4322           continue
c
              endif
c
  432       continue
          endif
c
        endif
c
   40 continue
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) 'hexa/quad'
      if ( nbarpb.gt.0 .or. nbfapb.gt.0 ) then
        write (ulsort,texte(langue,5)) mess14(langue,3,1), nbarpb
        write (ulsort,texte(langue,5)) mess14(langue,3,8), nbfapb
      else
        write (ulsort,texte(langue,6))
      endif
#endif
c
c====
c 5. Les suppressions de decoupage d'aretes peuvent etre nefastes
c    pour les faces voisines. Il faut parcourir toutes les faces a
c    couper et controler que toutes leurs aretes sont soit coupees, soit
c    a couper.
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. menage ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      do 50 , laface = -nbquto, nbtrto
#ifdef _DEBUG_HOMARD_
          if ( laface.eq.-215996 .or.
     >         laface.eq.20633  ) then
            glop=1
          else
            glop=0
          endif
          if ( glop.gt.0 ) then
        write (ulsort,texte(langue,8)) mess14(langue,1,4),
     > -laface,decfac(laface)
        write (ulsort,*) ' volqua(*,laface) : ',
     >         volqua(1,-laface),volqua(2,-laface)
          do 501 , larelo = 1 , 4
            larete = arequa(-laface,larelo)
         write (ulsort,texte(langue,9))'.. '//mess14(langue,1,1),
     > larete,decare(larete),hetare(larete)
  501      continue
          endif
#endif
c
        if ( decfac(laface).eq.4 ) then
c
          if ( laface.lt.0 ) then
c
            do 51 , larelo = 1 , 4
              larete = arequa(-laface,larelo)
              if ( decare(larete).eq.0 ) then
                if ( mod(hetare(larete),10).eq.0 ) then
                  decare(larete) = 2
                  nbarpb = nbarpb - 1
                endif
              endif
   51       continue
c
          else
c
            do 52 , larelo = 1 , 3
              larete = aretri(laface,larelo)
              if ( decare(larete).eq.0 ) then
                if ( mod(hetare(larete),10).eq.0 ) then
                  decare(larete) = 2
                  nbarpb = nbarpb - 1
                endif
              endif
   52       continue
c
          endif
c
        endif
c
   50 continue
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) 'de coherence'
      if ( nbarpb.gt.0 .or. nbfapb.gt.0 ) then
        write (ulsort,texte(langue,5)) mess14(langue,3,1), nbarpb
        write (ulsort,texte(langue,5)) mess14(langue,3,8), nbfapb
      else
        write (ulsort,texte(langue,6))
      endif
#endif
c
c====
c 6. bilan
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. bilan ; codret', codret
#endif
c
      if ( nbarpb.gt.0 .or. nbfapb.gt.0 ) then
c
        afaire = 1
        write (ulsort,texte(langue,5)) mess14(langue,3,1), nbarpb
        write (ulsort,texte(langue,5)) mess14(langue,3,8), nbfapb
c
#ifdef _DEBUG_HOMARD_
      else
        write (ulsort,texte(langue,6))
#endif
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
