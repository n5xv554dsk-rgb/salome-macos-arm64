      subroutine deinii ( pilraf, pilder, nivmax, nivmin, iniada,
     >                    decare, decfac,
     >                    somare, hetare, filare, merare, np2are,
     >                    posifa, facare,
     >                    aretri, hettri, filtri, pertri, nivtri,
     >                    arequa, hetqua, filqua, perqua, nivqua,
     >                    tritet, hettet, filtet,
     >                    quahex, hethex, filhex,
     >                    facpyr, hetpyr,
     >                    facpen, hetpen, filpen,
     >                    nbvpen, nbvpyr, nbvhex, nbvtet,
     >                    nbvqua, nbvtri, nbvare, nbvnoe,
     >                    nosupp, noindi,
     >                    arsupp, arindi,
     >                    trsupp, trindi,
     >                    qusupp, quindi,
     >                    tesupp, teindi,
     >                    hesupp, heindi,
     >                    pysupp, pyindi,
     >                    pesupp, peindi,
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
c traitement des DEcisions - INitialisation de l'indicateur entier
c                --          --
c ______________________________________________________________________
c
c but : initialisation des decisions sur les faces et les aretes
c       dans le cas ou les valeurs de l'indicateur sont entieres
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . pilraf . e   .   1    . pilotage du raffinement                    .
c .        .     .        . -1 : raffinement uniforme                  .
c .        .     .        .  0 : pas de raffinement                    .
c .        .     .        .  1 : raffinement libre                     .
c .        .     .        .  2 : raff. libre homogene en type d'element.
c . pilder . e   .   1    . pilotage du deraffinement                  .
c .        .     .        . -1 : deraffinement uniforme                .
c .        .     .        .  0 : pas de deraffinement                  .
c .        .     .        .  1 : deraffinement libre                   .
c . nivmax . e   .   1    . niveau max a ne pas depasser en raffinement.
c . nivmin . e   .   1    . niveau min a ne pas depasser en deraffinemt.
c . iniada . e   .   1    . initialisation de l'adaptation             .
c .        .     .        . 0 : on garde tout (defaut)                 .
c .        .     .        .-1 : reactivation des mailles ou aucun      .
c .        .     .        .     indicateur n'est defini                .
c .        .     .        . 1 : raffinement des mailles ou aucun       .
c .        .     .        .     indicateur n'est defini                .
c . decare .  s  .0:nbarto. decisions des aretes                       .
c . decfac .  s  . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . filare . e   . nbarto . premiere fille des aretes                  .
c . merare . e   . nbarto . mere des aretes                            .
c . np2are . e   . nbarto . noeud milieux des aretes                   .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . filtri . e   . nbtrto . premier fils des triangles                 .
c . pertri . e   . nbtrto . pere des triangles                         .
c . nivtri . e   . nbtrto . niveau des triangles                       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . perqua . e   . nbquto . pere des quadrangles                       .
c . nivqua . e   . nbquto . niveau des quadrangles                     .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . filtet . e   . nbteto . premier fils des tetraedres                .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . filhex . e   . nbheto . premier fils des hexaedres                 .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . hetpyr . e   . nbpyto . historique de l'etat des pyramides         .
c . facpen . e   .nbpecf*5. numeros des faces des pentaedres           .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . filpen . e   . nbpeto . premier fils des pentaedres                .
c . nbvpen . e   .   1    . nombre de valeurs par pentaedres           .
c . nbvpyr . e   .   1    . nombre de valeurs par pyramides            .
c . nbvhex . e   .   1    . nombre de valeurs par hexaedres            .
c . nbvtet . e   .   1    . nombre de valeurs par tetraedres           .
c . nbvqua . e   .   1    . nombre de valeurs par quadrangles          .
c . nbvtri . e   .   1    . nombre de valeurs par triangles            .
c . nbvare . e   .   1    . nombre de valeurs par aretes               .
c . nbvnoe . e   .   1    . nombre de valeurs par noeuds               .
c . nosupp . e   . nbnoto . support pour les noeuds                    .
c . noindi . e   . nbnoto . valeurs entieres pour les noeuds           .
c . arsupp . e   . nbarto . support pour les aretes                    .
c . arindi . e   . nbarto . valeurs entieres pour les aretes           .
c . trsupp . e   . nbtrto . support pour les triangles                 .
c . trindi . e   . nbtrto . valeurs entieres pour les triangles        .
c . qusupp . e   . nbquto . support pour les quadrangles               .
c . quindi . e   . nbquto . valeurs entieres pour les quadrangles      .
c . tesupp . e   . nbteto . support pour les tetraedres                .
c . teindi . e   . nbteto . valeurs entieres pour les tetraedres       .
c . hesupp . e   . nbheto . support pour les hexaedres                 .
c . heindi . e   . nbheto . valeurs entieres pour les hexaedres        .
c . pysupp . e   . nbpyto . support pour les pyramides                 .
c . pyindi . e   . nbpyto . valeurs entieres pour les pyramides        .
c . pesupp . e   . nbpeto . support pour les pentaedres                .
c . peindi . e   . nbpeto . valeurs entieres pour les pentaedres       .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme dans le traitement            .
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
      parameter ( nompro = 'DEINII' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envada.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      integer pilraf, pilder, nivmax, nivmin, iniada
      integer decare(0:nbarto), decfac(-nbquto:nbtrto)
      integer somare(2,nbarto)
      integer hetare(nbarto), filare(nbarto), merare(nbarto)
      integer np2are(nbarto)
      integer posifa(0:nbarto), facare(nbfaar)
      integer aretri(nbtrto,3), hettri(nbtrto)
      integer filtri(nbtrto), pertri(nbtrto), nivtri(nbtrto)
      integer arequa(nbquto,4), hetqua(nbquto)
      integer filqua(nbquto), perqua(nbquto), nivqua(nbquto)
      integer tritet(nbtecf,4), hettet(nbteto), filtet(nbteto)
      integer quahex(nbhecf,6), hethex(nbheto), filhex(nbheto)
      integer facpyr(nbpycf,5), hetpyr(nbpyto)
      integer facpen(nbpecf,5), hetpen(nbpeto), filpen(nbpeto)
      integer nbvpen, nbvpyr, nbvhex, nbvtet
      integer nbvqua, nbvtri, nbvare, nbvnoe
      integer nosupp(nbnoto), noindi(nbnoto)
      integer arsupp(nbarto), arindi(nbarto)
      integer trsupp(nbtrto), trindi(nbtrto)
      integer qusupp(nbquto), quindi(nbquto)
      integer tesupp(nbteto), teindi(nbteto)
      integer hesupp(nbheto), heindi(nbheto)
      integer pysupp(nbpyto), pyindi(nbpyto)
      integer pesupp(nbpeto), peindi(nbpeto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer etat
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisation
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
     > '(/5x,''Deraffinement des mailles sans indicateur'')'
      texte(1,5) =
     > '(/5x,''Raffinement des mailles sans indicateur'')'
      texte(1,6) = '(''Apres initialisation brute'')'
      texte(1,7) = '(''Apres prise en compte des lieux du champ'')'
      texte(1,8) = '(5x,''Apres prise en compte du deraffinement'')'
      texte(1,9) = '(5x,''Apres prise en compte du raffinement'')'
c
      texte(2,4) =
     > '(/5x,''Unrefinement of the meshes without any indicator'')'
      texte(2,5) =
     > '(/5x,''Refinement of the meshes without any indicator'')'
      texte(2,6) = '(''After brute initialization'')'
      texte(2,7) = '(''After localization of the field'')'
      texte(2,8) = '(5x,''After unrefinement indications'')'
      texte(2,9) = '(5x,''After refinement indications'')'
c
#include "impr03.h"
c
      codret = 0
c
c====
c 2. Initialisations des tableaux de decisions
c    . Dans l'option 0, les decisions sont initialisees a 0, ce qui
c    veut dire qu'a priori, rien ne se passe
c    . Dans l'option -1, les decisions sont initialisees a -1 partout
c    ou l'indicateur n'est pas defini ; cela force le deraffinement
c    des regions ou rien n'a ete precise
c    . Dans l'option 1, les decisions sont initialisees a 2 partout
c    ou l'indicateur n'est pas defini ; cela force le raffinement
c    des regions ou rien n'a ete precise
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. initialisations ; codret', codret
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbiter', nbiter
      write (ulsort,90002) 'iniada', iniada
#endif
c
      if ( nbiter.gt.0 .and. iniada.ne.0 ) then
c
c 2.0. ==> initialisations au defaut
c
      if ( iniada.eq.-1 ) then
c
        write (ulsort,texte(langue,4))
c
cgn                  write(ulsort,*) 'aretes'
        do 201 , iaux = 1, nbarto
          if (  mod(hetare(iaux),10).ge.2 ) then
            decare (iaux) = -1
cgn                    write(ulsort,*) iaux
          endif
  201   continue
c
cgn                  write(ulsort,*) 'triangles'
        do 202 , iaux = 1, nbtrto
          etat = mod(hettri(iaux),10)
          if ( etat.eq.4 .or.
     >         etat.eq.6 .or. etat.eq.7 .or. etat.eq.8 .or.
     >         etat.eq.9 ) then
            decfac (iaux) = -1
cgn                    write(ulsort,*) iaux
          endif
  202   continue
c
cgn                    write(ulsort,*) 'quadrangles'
        do 203 , iaux = 1, nbquto
          etat = mod(hetqua(iaux),100)
          if ( etat.eq.4 .or.
     >         etat.eq.99 ) then
            decfac (-iaux) = -1
          endif
  203   continue
c
      elseif ( iniada.eq.1 ) then
c
        write (ulsort,texte(langue,5))
c
cgn                  write(ulsort,*) 'aretes'
        do 204 , iaux = 1, nbarto
          if (  mod(hetare(iaux),10).eq.0 ) then
            decare (iaux) = 2
cgn                    write(ulsort,*) iaux
          endif
  204   continue
c
cgn                  write(ulsort,*) 'triangles'
        do 205 , iaux = 1, nbtrto
          if ( mod(hettri(iaux),10).eq.0 ) then
            decfac (iaux) = 4
cgn                    write(ulsort,*) iaux
          endif
  205   continue
c
cgn                    write(ulsort,*) 'quadrangles'
        do 206 , iaux = 1, nbquto
          if ( mod(hetqua(iaux),100).eq.0 ) then
            decfac (-iaux) = 4
          endif
  206   continue
c
      endif
c
#ifdef _DEBUG_HOMARD_
c
      if ( codret.eq.0 ) then
c
      write (ulsort,texte(langue,6))
c
      call decpte ( pilraf, pilder,
     >              decare, decfac,
     >              hettri, hetqua, tritet, hettet,
     >              quahex, hethex,
     >              facpyr, hetpyr,
     >              facpen, hetpen,
     >              ulsort, langue, codret )
c
      endif
c
#endif
c
c 2.1. ==> traitement des indicateurs portant sur les noeuds
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.1. noeuds ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbvnoe.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINOI', nompro
#endif
        call deinoi ( decare, decfac,
     >                somare, merare,
     >                np2are, posifa, facare,
     >                nosupp,
     >                ulsort, langue, codret)
c
      endif
c
      endif
c
c 2.2. ==> traitement des indicateurs portant sur les aretes
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2. aretes ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbvare.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEIARI', nompro
#endif
        call deiari ( decare, decfac,
     >                merare,
     >                posifa, facare,
     >                arsupp,
     >                ulsort, langue, codret)
c
      endif
c
      endif
c
c 2.3. ==> traitement des indicateurs portant sur les triangles
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.3. Triangles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbvtri.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEITRI', nompro
#endif
        call deitri ( decare, decfac,
     >                aretri, pertri,
     >                trsupp,
     >                ulsort, langue, codret)
c
      endif
c
      endif
c
c 2.4. ==> traitement des indicateurs portant sur les quadrangles
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.4. Quadrangles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbvqua.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEIQUI', nompro
#endif
        call deiqui ( decare, decfac,
     >                arequa, perqua,
     >                qusupp,
     >                ulsort, langue, codret)
c
      endif
c
      endif
c
c 2.5. ==> traitement des indicateurs portant sur les tetraedres
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.5. Tetraedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbvtet.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEITEI', nompro
#endif
        call deitei ( decare, decfac,
     >                aretri, pertri,
     >                tritet,
     >                tesupp,
     >                ulsort, langue, codret)
c
      endif
c
      endif
c
c 2.6. ==> traitement des indicateurs portant sur les hexaedres
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.6. Hexaedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbvhex.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEIHEI', nompro
#endif
        call deihei ( decare, decfac,
     >                arequa, perqua,
     >                quahex,
     >                hesupp,
     >                ulsort, langue, codret)
c
      endif
c
      endif
c
c 2.7. ==> traitement des indicateurs portant sur les pyramides
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.7. Pyramides ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbvpyr.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEIPYI', nompro
#endif
        call deipyi ( decare, decfac,
     >                aretri, pertri,
     >                arequa, perqua,
     >                facpyr,
     >                pysupp,
     >                ulsort, langue, codret)
c
      endif
c
      endif
c
c 2.8. ==> traitement des indicateurs portant sur les pentaedres
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.8. pentaedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbvpen.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEIPEI', nompro
#endif
        call deipei ( decare, decfac,
     >                aretri, pertri,
     >                arequa, perqua,
     >                facpen,
     >                pesupp,
     >                ulsort, langue, codret)
c
      endif
c
      endif
c
c 2.9. ==> Bilan
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7))
#endif
c
      call decpte
     >        ( pilraf, pilder,
     >          decare, decfac,
     >          hettri, hetqua, tritet, hettet,
     >          quahex, hethex,
     >          facpyr, hetpyr,
     >          facpen, hetpen,
     >          ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 3. traitement du deraffinement
c    il faut d'abord examiner les decisions de deraffinement exprimees
c    sur tous les types d'entites. ensuite, on examinera les decisions
c    de raffinement. ainsi, en cas de conflit, on est certain d'avoir
c    ecrasement du deraffinement par le raffinement.
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. deraffinement ; codret', codret
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbiter', nbiter
      write (ulsort,90002) 'pilder', pilder
#endif
c
      if ( pilder.ne.0 .and. nbiter.ne.0 ) then
c
c 3.1. ==> traitement des indicateurs portant sur les noeuds
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.1. noeuds ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbvnoe.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINOD', nompro
#endif
        call deinod ( nivmin,
     >                decare, decfac,
     >                somare, hetare, filare,
     >                np2are, posifa, facare,
     >                aretri, hettri, nivtri,
     >                arequa, hetqua, nivqua,
     >                nosupp, noindi,
     >                ulsort, langue, codret)
c
      endif
c
      endif
c
c 3.2. ==> traitement des indicateurs portant sur les aretes
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.2. aretes ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbvare.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEIARD', nompro
#endif
        call deiard ( nivmin,
     >                decare, decfac,
     >                hetare, filare,
     >                posifa, facare,
     >                aretri, hettri, nivtri,
     >                arequa, hetqua, nivqua,
     >                arsupp, arindi,
     >                ulsort, langue, codret)
c
      endif
c
      endif
c
c 3.3. ==> traitement des indicateurs portant sur les triangles
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.3. Triangles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbvtri.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEITRD', nompro
#endif
        call deitrd ( nivmin,
     >                decare, decfac,
     >                aretri, hettri, filtri, nivtri,
     >                trsupp, trindi,
     >                ulsort, langue, codret)
c
      endif
c
      endif
c
c 3.4. ==> traitement des indicateurs portant sur les quadrangles
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.4. Quadrangles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbvqua.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEIQUD', nompro
#endif
        call deiqud ( nivmin,
     >                decare, decfac,
     >                arequa, hetqua, filqua, nivqua,
     >                qusupp, quindi,
     >                ulsort, langue, codret)
c
      endif
c
      endif
c
c 3.5. ==> traitement des indicateurs portant sur les tetraedres
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.5. Tetraedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbvtet.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEITED', nompro
#endif
        call deited ( nivmin,
     >                decare, decfac,
     >                aretri, nivtri,
     >                tritet, hettet, filtet,
     >                tesupp, teindi,
     >                ulsort, langue, codret)
c
      endif
c
      endif
c
c 3.6. ==> traitement des indicateurs portant sur les hexaedres
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.6. Hexaedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbvhex.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEIHED', nompro
#endif
        call deihed ( nivmin,
     >                decare, decfac,
     >                arequa, nivqua,
     >                quahex, hethex, filhex,
     >                hesupp, heindi,
     >                ulsort, langue, codret)
c
      endif
c
      endif
c
c 3.7. ==> traitement des indicateurs portant sur les pyramides
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.7. Pyramides ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbvpyr.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEIPYD', nompro
#endif
        call deipyd ( nivmin,
     >                hetpyr,
     >                ulsort, langue, codret)
c
      endif
c
      endif
c
c 3.8. ==> traitement des indicateurs portant sur les pentaedres
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.8. pentaedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbvpen.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEIPED', nompro
#endif
        call deiped ( nivmin,
     >                decare, decfac,
     >                aretri, nivtri,
     >                arequa,
     >                facpen, hetpen, filpen,
     >                pesupp, peindi,
     >                ulsort, langue, codret)
c
      endif
c
      endif
c
c
      if ( codret.eq.0 ) then
c
      write (ulsort,texte(langue,8))
c
      call decpte
     >        ( pilraf, pilder,
     >          decare, decfac,
     >          hettri, hetqua, tritet, hettet,
     >          quahex, hethex,
     >          facpyr, hetpyr,
     >          facpen, hetpen,
     >          ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 4. traitement du raffinement
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. raffinement ; codret', codret
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'pilraf', pilraf
#endif
c
      if ( pilraf.ne.0 ) then
c
c 4.1. ==> traitement des indicateurs portant sur les noeuds
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.1. noeuds ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbvnoe.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEINOR', nompro
#endif
        call deinor ( nivmax,
     >                decare,
     >                somare, hetare,
     >                np2are, posifa, facare,
     >                nivtri,
     >                nivqua,
     >                nosupp, noindi,
     >                ulsort, langue, codret)
c
      endif
c
      endif
c
c 4.2. ==> traitement des indicateurs portant sur les aretes
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.2. aretes ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbvare.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEIARR', nompro
#endif
        call deiarr ( nivmax,
     >                decare,
     >                hetare,
     >                posifa, facare,
     >                nivtri,
     >                nivqua,
     >                arsupp, arindi,
     >                ulsort, langue, codret)
c
      endif
c
      endif
c
c 4.3. ==> traitement des indicateurs portant sur les triangles
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.3. Triangles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbvtri.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEITRR', nompro
#endif
        call deitrr ( nivmax,
     >                decare, decfac,
     >                hetare,
     >                aretri, hettri, nivtri,
     >                trsupp, trindi,
     >                ulsort, langue, codret)
c
      endif
c
      endif
c
c 4.4. ==> traitement des indicateurs portant sur les quadrangles
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.4. Quadrangles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbvqua.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEIQUR', nompro
#endif
        call deiqur ( nivmax,
     >                decare, decfac,
     >                hetare,
     >                arequa, hetqua, nivqua,
     >                qusupp, quindi,
     >                ulsort, langue, codret)
c
      endif
c
      endif
c
c 4.5. ==> traitement des indicateurs portant sur les tetraedres
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.5. Tetraedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbvtet.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEITER', nompro
#endif
        call deiter ( nivmax,
     >                decare, decfac,
     >                hetare,
     >                aretri, hettri, nivtri,
     >                tritet,
     >                tesupp, teindi,
     >                ulsort, langue, codret)
c
      endif
c
      endif
c
c 4.6. ==> traitement des indicateurs portant sur les hexaedres
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.6. Hexaedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbvhex.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEIHER', nompro
#endif
        call deiher ( nivmax,
     >                decare, decfac,
     >                hetare,
     >                arequa, hetqua, nivqua,
     >                quahex,
     >                hesupp, heindi,
     >                ulsort, langue, codret)
c
      endif
c
      endif
c
c 4.7. ==> traitement des indicateurs portant sur les pyramides
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.7. Pyramides ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbvpyr.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEIPYR', nompro
#endif
        call deipyr ( nivmax,
     >                decare, decfac,
     >                hetare,
     >                aretri, hettri, nivtri,
     >                arequa, hetqua,
     >                facpyr,
     >                pysupp, pyindi,
     >                ulsort, langue, codret)
c
      endif
c
      endif
c
c 4.8. ==> traitement des indicateurs portant sur les pentaedres
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.8. pentaedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbvpen.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEIPER', nompro
#endif
        call deiper ( nivmax,
     >                decare, decfac,
     >                hetare,
     >                aretri, hettri, nivtri,
     >                arequa, hetqua,
     >                facpen,
     >                pesupp, peindi,
     >                ulsort, langue, codret)
c
      endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      write (ulsort,texte(langue,9))
c
      call decpte
     >        ( pilraf, pilder,
     >          decare, decfac,
     >          hettri, hetqua, tritet, hettet,
     >          quahex, hethex,
     >          facpyr, hetpyr,
     >          facpen, hetpen,
     >          ulsort, langue, codret )
c
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
cgn      write (ulsort,*) 'en sortie de ', nompro
cgn        do 1105 , iaux = 1 , nbquto
cgn          write (ulsort,90001) 'decision quadrangle', iaux,decfac(-iaux)
cgn          write (ulsort,90001) 'quadrangle', iaux,
cgn     >    arequa(iaux,1), arequa(iaux,2),
cgn     >    arequa(iaux,3), arequa(iaux,4)
cgn 1105   continue
#endif
cgn      iaux = 14808
cgn      write (ulsort,90002) 'quadrangle ', iaux
cgn      write (ulsort,*) 'decfac(',iaux,') =',decfac(-iaux)
cgn      write (ulsort,*) arequa(iaux,1),arequa(iaux,2),
cgn     >arequa(iaux,3),arequa(iaux,4)
cgn      write (ulsort,*) decare(arequa(iaux,1)),decare(arequa(iaux,2)),
cgn     >decare(arequa(iaux,3)),decare(arequa(iaux,4))
cgn      write (ulsort,*) hetare(arequa(iaux,1)),hetare(arequa(iaux,2)),
cgn     >hetare(arequa(iaux,3)),hetare(arequa(iaux,4))
cgn      write (ulsort,*) ' '
cgn      print 1789,(iaux, decfac(iaux),iaux = 0, nbtrto)
cgn      print 1789,(iaux, decfac(iaux),iaux = -nbquto,0)
cgn      print 1789,(iaux, decare(iaux),iaux = 1, nbarto)
c
cgn      write (ulsort,*) 'decision triangle'
cgn      write (ulsort,91030) (decfac(iaux),iaux= 1 , nbtrto)
cgn      write (ulsort,*) 'decision quadrangle'
cgn      write (ulsort,91030) (decfac(-iaux),iaux= 1 , nbquto)
c
c====
c 5. la fin
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
