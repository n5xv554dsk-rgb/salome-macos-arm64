      subroutine pcmex3 ( indqua, indhex, nouvar, nouvqu, nouvhe,
     >                    hetqua, arequa,
     >                    filqua, perqua, nivqua,
     >                    famqua, cfaqua, hexqua,
     >                    quahex, coquhe,
     >                    hethex, filhex, perhex,
     >                    famhex,
     >                    somare,
     >                    entxar,
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
c    aPres adaptation - Conversion de Maillage EXtrude - phase 3
c     -                 -             -        --              -
c    Duplication des quadrangles et creation des hexaedres
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . indqua . es  . 1      . indice du dernier quadrangle cree          .
c . indhex . es  .   1    . indice du dernier hexaedre cree            .
c . nouvar . e   .   1    . nouveau nombre d'aretes                    .
c . nouvqu . e   .   1    . nouveau nombre de quadrangles              .
c . nouvhe . e   .   1    . nouveau nombre d'hexaedres                 .
c . hetqua . es  . nouvqu . historique de l'etat des quadrangles       .
c . arequa . es  .nouvqu*4. numeros des 4 aretes des quadrangles       .
c . filqua . es  . nouvqu . premier fils des quadrangles               .
c . perqua . es  . nouvqu . pere des quadrangles                       .
c . nivqua . es  . nouvqu . niveau des quadrangles                     .
c . famqua . es  . nouvqu . famille des quadrangles                    .
c . cfaqua . e   . nctfqu*. codes des familles des quadrangles         .
c .        .     . nbfqua .   1 : famille MED                          .
c .        .     .        .   2 : type de quadrangle                   .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
c .        .     .        . Pour un quadrangle a l'avant :             .
c .        .     .        .   7 : famille du quadrangle extrude        .
c .        .     .        .   8 : famille du volume perpendiculaire    .
c .        .     .        . Pour un quadrangle perpendiculaire :       .
c .        .     .        .   7 : sens de la 1ere compos. de la normale.
c .        .     .        .   8 : sens de la 2eme compos. de la normale.
c .        .     .        .   9 : code du quadrangle dans hexa ou penta.
c .        .     .        .  10 : position du quadrangle               .
c .        .     .        . si equivalence :                           .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . hexqua .  s  . nbquto . hexaedre sur un quadrangle de la face avant.
c . quahex . e   .nouvhe*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nouvhe*6. codes des 6 quadrangles des hexaedres      .
c . hethex . e   . nouvhe . historique de l'etat des hexaedres         .
c . filhex . e   . nouvhe . premier fils des hexaedres                 .
c . perhex . e   . nouvhe . pere des hexaedres                         .
c .        .     .        . si perhex(i) > 0 : numero de l'hexaedre    .
c .        .     .        . si perhex(i) < 0 : -numero dans pthepe     .
c . famhex . e   . nouvhe . famille des hexaedres                      .
c . somare . e   .2*nouvar. numeros des extremites d'arete             .
c . entxar . e   .2*nbarto. entites liees a l'extrusion de l'arete     .
c .        .     .        . 1 : l'arete                                .
c .        .     .        . 2 : le quadrangle perpendiculaire          .
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
      parameter ( nompro = 'PCMEX3' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nbfami.h"
#include "cofexq.h"
#include "dicfen.h"
#include "nombar.h"
#include "nombqu.h"
c
c 0.3. ==> arguments
c
      integer indqua, indhex, nouvar, nouvqu, nouvhe
c
      integer hetqua(nouvqu), arequa(nouvqu,4)
      integer filqua(nouvqu), perqua(nouvqu), nivqua(nouvqu)
      integer famqua(nouvqu), cfaqua(nctfqu,nbfqua)
      integer hexqua(nouvqu)
      integer quahex(nouvhe,6), coquhe(nouvhe,6)
      integer hethex(nouvhe)
      integer filhex(nouvhe), perhex(nouvhe)
      integer famhex(nouvhe)
c
      integer somare(2,nouvar)
      integer entxar(2,nbarto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer lequad
      integer aquba1, aquba2, aquba3, aquba4
      integer aquex1, aquex2, aquex3, aquex4
      integer arehex(12)
      integer somhe1, somhe2, somhe3, somhe4
c
      logical oripos, oripox
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
      texte(1,4) = '(''Nombre de quadrangles actifs :'',i10)'
c
      texte(2,4) = '(''Number of active quadrangles:'',i10)'
c
#include "impr03.h"
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbquac
#endif
c
c====
c 2. parcours des quadrangles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. parcours quadrangles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbquto', nbquto
      write (ulsort,90002) 'nouvqu', nouvqu
      write (ulsort,90002) 'nouvhe', nouvhe
cgn      write (ulsort,*) 'entxar'
cgn      do 2222 , iaux = 1 , nbarto
cgn        write (ulsort,90112) 'entxar',iaux,entxar(1,iaux),entxar(2,iaux)
cgn 2222 continue
#endif
c
      do 20 , lequad = 1 , nbquto
c
        if ( mod(hetqua(lequad),100).eq.0 ) then
c
cgn        write (ulsort,*) ' '
cgn        write (ulsort,90012) '.. Aretes du quadrangle de base',
cgn     >                       lequad, arequa(lequad,1),
cgn     >             arequa(lequad,2), arequa(lequad,3), arequa(lequad,4)
cgn        write (ulsort,90002) '.... Famille', famqua(lequad)
cgn        write (ulsort,90005) '.... codes',
cgn     >             (cfaqua(iaux,famqua(lequad)),iaux=1,nctfqu)
c
c 2.1. ==> Orientations
c          oripo. est vrai si le quadrangle entre dans le volume
c 2.1.1. ==> Orientation du quadrangle de base
c
          if ( cfaqua(cofxqo,famqua(lequad)).le.4 ) then
            oripos = .True.
          else
            oripos = .False.
          endif
cgn        write (ulsort,99001) '.. La base entre dans le volume', oripos
c
c 2.1.2. ==> Orientation du quadrangle extrude
c
          if ( cfaqua(cofxqo,cfaqua(cofxqt,famqua(lequad))).le.4 ) then
            oripox = .True.
          else
            oripox = .False.
          endif
cgn        write (ulsort,99001) '.. L''extru entre dans le volume', oripox
c
c 2.2. ===> Creation du nouveau quadrangle
c 2.2.1. ==> Aretes extrudees en tant que bord du quadrangle
c
          aquex1 = entxar(1,arequa(lequad,1))
          aquex2 = entxar(1,arequa(lequad,2))
          aquex3 = entxar(1,arequa(lequad,3))
          aquex4 = entxar(1,arequa(lequad,4))
c
c 2.2.2. ==> Creation
c            Attention a garder la meme orientation qu'au depart
c
          indqua = indqua + 1
c
          arequa(indqua,1) = aquex1
          arequa(indqua,3) = aquex3
          if ( (       oripos .and. .not. oripox ) .or.
     >         ( .not. oripos .and.       oripox ) ) then
            arequa(indqua,2) = aquex2
            arequa(indqua,4) = aquex4
          else
            arequa(indqua,2) = aquex4
            arequa(indqua,4) = aquex2
          endif
cgn        write (ulsort,90012) '.. Aretes du quadrangle extrude',
cgn     >                       indqua, aquex1, aquex2, aquex3, aquex4
          hetqua(indqua) = 5500
          filqua(indqua) = 0
          perqua(indqua) = 0
          nivqua(indqua) = nivqua(lequad)
          famqua(indqua) = cfaqua(cofxqt,famqua(lequad))
cgn      write (ulsort,90012) '.. Famille du quadrangle translate',
cgn     >                       indqua, famqua(indqua)
c
c 2.3. ===> Creation du volume joignant ces deux quadrangles
c       face 1 : on postule :
c                - c'est le quadrangle a la base de de l'extrusion
c                - sa 1ere arete est la 1ere de l'hexaedre
c                - il est positionne avec la meme orientation qu'au
c                  depart
c                On en deduit le code :
c                . si l'orientation est positive, code 1 : (a1,a2,a4,a3)
c                . si l'orientation est negative, code 5 : (a1,a3,a4,a2)
c       face 2 : c'est le quadrangle qui est l'extrusion de l'arete 1
c                de l'hexaedre.
c                1ere arete = a1 = 1ere arete du quadrangle de base
c                2eme arete = celle qui part d'un sommet de a1
c                3eme arete = extrusion de a1 = a9
c                             (= 1ere arete du quadrangle extrude)
c                4eme arete = celle qui part de l'autre sommet de a1
c                . si le 1er sommet de la 2eme arete du quadrangle est
c                  le premier sommet de l'hexaedre, cette arete est a5 ;
c                  la face est (a1,a5,a9,a6) donc code 5
c                . sinon, la face est (a1,a6,a9,a5) donc code 1
c       face 3 : c'est le quadrangle qui est l'extrusion de l'arete 2
c                de l'hexaedre.
c                1ere arete = a2
c                2eme arete = celle qui part d'un sommet de a2
c                3eme arete = extrusion de a2 = a10
c                4eme arete = celle qui part de l'autre sommet de a2
c                . si l'orientation est positive :
c                  a2 = 2eme arete du quadrangle de base
c                . sinon :
c                  a2 = 4eme arete du quadrangle de base
c                . si le 1er sommet de la 2eme arete du quadrangle est
c                  le 4eme sommet de l'hexaedre, cette arete est a7 ;
c                  la face est (a2,a7,a10,a5) donc code 5
c                . sinon, la face est (a2,a5,a10,a7) donc code 1
c       face 4 : c'est le quadrangle qui est l'extrusion de l'arete 3
c                de l'hexaedre.
c                1ere arete = a3
c                2eme arete = celle qui part d'un sommet de a3
c                3eme arete = extrusion de a3 = a11
c                4eme arete = celle qui part de l'autre sommet de a3
c                . si l'orientation est positive :
c                  a3 = 4eme arete du quadrangle de base
c                . sinon :
c                  a3 = 2eme arete du quadrangle de base
c                . si le 1er sommet de la 2eme arete du quadrangle est
c                  le 2eme sommet de l'hexaedre, cette arete est a6 ;
c                  la face est (a3,a6,a11,a8) donc code 5
c                . sinon, la face est (a3,a8,a11,a6) donc code 1
c       face 5 : c'est le quadrangle qui est l'extrusion de l'arete 4
c                de l'hexaedre.
c                1ere arete = a4 = 3eme arete du quadrangle de base
c                2eme arete = celle qui part d'un sommet de a4
c                3eme arete = extrusion de a4 = a12
c                4eme arete = celle qui part de l'autre sommet de a4
c                . si le 1er sommet de la 2eme arete du quadrangle est
c                  le 3eme sommet de l'hexaedre, cette arete est a8 ;
c                  la face est (a4,a8,a12,a7) donc code 5
c                . sinon, la face est (a4,a7,a12,a8) donc code 1
c       face 6 : c'est le quadrangle qui est l'extrusion de la face 1.
c                Ses aretes sont les extrudees des aretes de la face 1 :
c                1ere arete = extrusion de a1 = a9
c                3eme arete = extrusion de a4 = a12
c                Ce quadrangle etant une translation du quadrangle de
c                base, son code est le symetrique de celui de la face 1.
c                On en deduit le code :
c                . si la face 1 entre et la face 2 sort ou si la face 1
c                  sort et la face 2 entre :
c                  2eme arete = extrusion de a2 = a10
c                  4eme arete = extrusion de a3 = a11
c                  donc code 1
c                . sinon, code 5
c
c 2.3.1. ==> Quadrangle de base
c
          aquba1 = arequa(lequad,1)
          aquba2 = arequa(lequad,2)
          aquba3 = arequa(lequad,3)
          aquba4 = arequa(lequad,4)
c
cgn        write (ulsort,90002) '.... Fac ext',
cgn     >        entxar(2,aquba1), entxar(2,aquba2),
cgn     >        entxar(2,aquba3), entxar(2,aquba4)
c
c 2.3.2. ==> Les aretes et les sommets de l'hexaedre
c
          arehex(1) = aquba1
          if ( oripos ) then
            arehex(2) = aquba2
            arehex(3) = aquba4
            arehex(4) = aquba3
          else
            arehex(2) = aquba4
            arehex(3) = aquba2
            arehex(4) = aquba3
          endif
cgn          write (ulsort,90002) '.... Ar. Hex',
cgn     >           arehex(1), arehex(2), arehex(3), arehex(4)
c
          call utsoqu ( somare, arehex(1),arehex(2),arehex(4),arehex(3),
     >                  somhe1, somhe4, somhe3, somhe2 )
cgn        write (ulsort,90002) '.... So. Hex',somhe1,somhe2,somhe3,somhe4
c
c 2.3.3. ==> Creation de l'hexaedre
c            Remarque : on en profite pour ajuster les niveaux des
c                       faces laterales
c
          indhex = indhex + 1
cgn          write (ulsort,90002) '.... hexaedre ', indhex
c
c 2.3.3.1. ==> Face 1 : la base
c
          quahex(indhex,1) = lequad
          if ( oripos ) then
            coquhe(indhex,1) = 1
          else
            coquhe(indhex,1) = 5
          endif
cgn        write (ulsort,90012) '.... code de la face 1',quahex(indhex,1),
cgn     > coquhe(indhex,1)
c
c 2.3.3.2. ==> Face 2 : le quadrangle construit sur la 1ere arete
c
          quahex(indhex,2) = entxar(2,arehex(1))
cgn        write (ulsort,90012) '.. Aretes de la face 2 de numero',
cgn     >  quahex(indhex,2),
cgn     >  arequa(quahex(indhex,2),1),arequa(quahex(indhex,2),2),
cgn     >  arequa(quahex(indhex,2),3),arequa(quahex(indhex,2),4)
          iaux = somare(1,arequa(quahex(indhex,2),2))
cgn        write (ulsort,90012) '.... 1er som de l''arete',
cgn     >  arequa(quahex(indhex,2),2),iaux
          if ( iaux.eq.somhe1 ) then
            coquhe(indhex,2) = 5
          else
            coquhe(indhex,2) = 1
          endif
          nivqua(quahex(indhex,2)) = nivqua(lequad)
cgn        write (ulsort,90012) '.... code de la face 2',
cgn     >  quahex(indhex,2), coquhe(indhex,2)
c
c 2.3.3.3. ==> Face 3 : le quadrangle construit sur la 2eme arete
c
          quahex(indhex,3) = entxar(2,arehex(2))
cgn        write (ulsort,90012) '.. Aretes de la face 3 de numero',
cgn     >  quahex(indhex,3),
cgn     >  arequa(quahex(indhex,3),1),arequa(quahex(indhex,3),2),
cgn     >  arequa(quahex(indhex,3),3),arequa(quahex(indhex,3),4)
          iaux = somare(1,arequa(quahex(indhex,3),2))
cgn        write (ulsort,90012) '.... 1er som de l''arete',
cgn     >  arequa(quahex(indhex,3),2),iaux
          if ( iaux.eq.somhe4 ) then
            coquhe(indhex,3) = 5
          else
            coquhe(indhex,3) = 1
          endif
          nivqua(quahex(indhex,3)) = nivqua(lequad)
cgn        write (ulsort,90012) '.... code de la face 3',
cgn     >  quahex(indhex,3), coquhe(indhex,3)
c
c 2.3.3.4. ==> Face 4 : le quadrangle construit sur la 3eme arete
c
          quahex(indhex,4) = entxar(2,arehex(3))
cgn        write (ulsort,90012) '.. Aretes de la face 4 de numero',
cgn     >  quahex(indhex,4),
cgn     >  arequa(quahex(indhex,4),1),arequa(quahex(indhex,4),2),
cgn     >  arequa(quahex(indhex,4),3),arequa(quahex(indhex,4),4)
          iaux = somare(1,arequa(quahex(indhex,4),2))
cgn        write (ulsort,90012) '.... 1er som de l''arete',
cgn     >  arequa(quahex(indhex,4),2),iaux
          if ( iaux.eq.somhe2 ) then
            coquhe(indhex,4) = 5
          else
            coquhe(indhex,4) = 1
          endif
          nivqua(quahex(indhex,4)) = nivqua(lequad)
cgn        write (ulsort,90012) '.... code de la face 4',
cgn     >  quahex(indhex,4), coquhe(indhex,4)
c
c 2.3.3.5. ==> Face 5 : le quadrangle construit sur la 4eme arete
c
          quahex(indhex,5) = entxar(2,arehex(4))
cgn        write (ulsort,90012) '.. Aretes de la face 5 de numero',
cgn     >  quahex(indhex,5),
cgn     >  arequa(quahex(indhex,5),1),arequa(quahex(indhex,5),2),
cgn     >  arequa(quahex(indhex,5),3),arequa(quahex(indhex,5),4)
          iaux = somare(1,arequa(quahex(indhex,5),2))
cgn        write (ulsort,90012) '.... 1er som de l''arete',
cgn     >  arequa(quahex(indhex,5),2),iaux
          if ( iaux.eq.somhe3 ) then
            coquhe(indhex,5) = 5
          else
            coquhe(indhex,5) = 1
          endif
          nivqua(quahex(indhex,5)) = nivqua(lequad)
cgn        write (ulsort,90012) '.... code de la face 5',
cgn     >  quahex(indhex,5), coquhe(indhex,5)
c
c 2.3.3.6. ==> Face 6 : le quadrangle extrude
c
          quahex(indhex,6) = indqua
          if ( (       oripos .and. .not. oripox ) .or.
     >         ( .not. oripos .and.       oripox ) ) then
            coquhe(indhex,6) = 1
          else
            coquhe(indhex,6) = 5
          endif
cgn        write (ulsort,90012) '.... code de la face 6',
cgn     >  quahex(indhex,6), coquhe(indhex,6)
c
c 2.3.3.7. ==> Caracteristiques generales
c
          hethex(indhex) = 555000
          filhex(indhex) = 0
          perhex(indhex) = 0
          famhex(indhex) = cfaqua(cofxqx,famqua(lequad))
cgn        write (ulsort,90002) '.... Faces',(quahex(indhex,iaux),iaux=1,6)
cgn        write (ulsort,90002) '.... Codes',(coquhe(indhex,iaux),iaux=1,6)
cgn        write (ulsort,90002) '.... Famille',famhex(indhex)
c
        endif
c
c 2.3.4. ==> Correspondances
c
        if ( mod(hetqua(lequad),100).eq.0 ) then
c
          hexqua(lequad) = indhex
          hexqua(indqua) = 0
c
        else
c
          hexqua(lequad) = 0
c
        endif
c
   20 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'indqua', indqua
      write (ulsort,90002) 'indhex', indhex
#endif
c
      endif
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
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
