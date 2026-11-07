      subroutine pcmar2 ( hetare, filare, merare,
     >                    famare, posifa, facare,
     >                    aretri, hettri, nivtri,
     >                    voltri,
     >                    arequa, hetqua, nivqua,
     >                    nbanci, nbenrc,
     >                    arreca,
     >                    nparrc, arerec,
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
c    aPres adaptation - Conversion de MAillage - Recollements - phase 2
c     -                 -             --         -                    -
c    Reperage des aretes de raccordement non conforme
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . filare . e   . nbarto . fille ainee de chaque arete                .
c . merare . e   . nbarto . mere de chaque arete                       .
c . famare . es  . nbarto . famille des aretes                         .
c . posifa . e   .0:nbarto. pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . nivtri . e   . nbtrto . niveau des triangles                       .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . nivqua . e   . nbquto . niveau des quadrangles                     .
c . nbanci . e   .    1   . nombre de non conformites initiales        .
c . nbenrc . e   .    1   . nombre d'entites par recollement unitaire  .
c . arreca . e   .2*nbanci. liste des aretes recouvrant une autre      .
c . nparrc .  s  .   1    . nombre de paires d'aretes a recoller       .
c . arerec .  s  .2*nbarto. paires des aretes a recoller               .
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
      parameter ( nompro = 'PCMAR2' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
#include "nbfami.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer hetare(nbarto), filare(nbarto), merare(nbarto)
      integer famare(nbarto)
      integer posifa(0:nbarto), facare(nbfaar)
      integer aretri(nbtrto,3), hettri(nbtrto), nivtri(nbtrto)
      integer voltri(2,nbtrto)
      integer arequa(nbquto,4), hetqua(nbquto), nivqua(nbquto)
      integer nbanci, nbenrc
      integer arreca(nbenrc*nbanci)
      integer nparrc
      integer arerec(2,nbarto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, laux
      integer kdeb , kfin
      integer nbar2d, nbar3d
      integer larete, lareta
      integer adelre
#ifdef _DEBUG_HOMARD_
      integer glop
#endif
c
      character*8 noelre
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
      texte(1,4) = '(''On ne devrait pas passer dans '',a)'
      texte(1,5) = '(''Examen du '',a,''numero '',i10)'
      texte(1,6) =
     > '(2x,''Nombre de paires de '',a,''a recoller :'',i10)'
      texte(1,8) =
     > '(''.. Modification de la famille du '',a,''numero '',i10)'
      texte(1,9) =
     > '(''.. Modification de l''''etat du '',a,''numero '',i10)'
      texte(1,10) = '(5x,''==> avant :'',i5,'', apres :'',i5)'
      texte(1,11) = '(''Nombre de non-conformites initiales :'',i10))'
      texte(1,12) = '(''. de fils :'',2i10))'
      texte(1,13) = '(''. Etat du '',a,''numero '',i10,'' :'',i10)'
      texte(1,14) = '(2x,''Apres la phase de limites de zone :'')'
      texte(1,15) = '(2x,''Apres les non conformites initiales :'')'
      texte(1,19) = '(''. Famille du '',a,''numero '',i10,'' :'',i10)'
      texte(1,20) = '(''Impossible d''''avoir des groupes internes'')'
c
      texte(2,4) = '(a,'' should not be called.'')'
      texte(2,5) = '(''Examination of '',a,'',# '',i10)'
      texte(2,6) = '(2x,''Number of pairs of '',a,''to glue :'',i10)'
      texte(2,8) =
     > '(''.. Modification of the family of '',a,'',# '',i10)'
      texte(2,9) =
     > '(''.. Modification of the state of '',a,'',# '',i10)'
      texte(2,10) = '(5x,''==> old :'',i5,'', new :'',i5)'
      texte(2,11) = '(''Number of non-conformal situations :'',i10))'
      texte(2,12) = '(''. with sons :'',2i10))'
      texte(2,13) = '(''. State for '',a,''# '',i10,'' :'',i10)'
      texte(2,14) = '(2x,''After zone limit analysis :'')'
      texte(2,15) = '(2x,''After initial non conforming :'')'
      texte(2,19) = '(''. Family for '',a,''# '',i10,'' :'',i10)'
      texte(2,20) = '(''Impossible d''''avoir des groupes internes'')'
c
#include "impr03.h"
c
      codret = 0
c
      nparrc = 0
c
c====
c 2. recherche des aretes a la limite entre deux zones de
c    raffinement de niveau different, sans tenir compte du
c    bord exterieur
c====
c
      if ( codret.eq.0 ) then
c
      call gmalot ( noelre, 'entier  ', nbarto, adelre, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTBOAR', nompro
#endif
      iaux = 3
      call utboar ( iaux,
     >              nbarto, nbtrto, nbquto, nbteto, nbfaar,
     >              hetare, filare,
     >              posifa, facare,
     >              aretri, hettri, voltri,
     >              arequa, hetqua,
     >              nbar2d, nbar3d, imem(adelre),
     >              ulsort, langue, codret )
c
      endif
c
cgn      call gmprsx (nompro,noelre)
c====
c 3. examen des aretes en fonction de la limite de zone
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. examen des aretes ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      do 31 , larete = 1 , nbarto
c
#ifdef _DEBUG_HOMARD_
        if ( larete.eq.-7 ) then
          glop = 1
        else
          glop = 0
        endif
#endif
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,texte(langue,5)) mess14(langue,1,1), larete
        write (ulsort,90002) 'borare', imem(adelre-1+larete)
        endif
#endif
c
        iaux = imem(adelre-1+larete)
c
c 3.1. ==> L'arete est a la limite entre 2 zones de niveaux de
c          raffinement differents. Si elle est active, on doit lui
c          attribuer la famille supplementaire ainsi qu'a son aieule
c
        if ( iaux.eq.1 ) then
c
          if ( mod(hetare(larete),10).eq.0 ) then
c
c 3.1.1. ==> L'arete est a modifier
c
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
          write (ulsort,texte(langue,8)) mess14(langue,1,1), larete
          write (ulsort,texte(langue,10)) famare(larete), nbfare
        endif
#endif
            famare(larete) = nbfare
c
c 3.1.2. ==> Reperage de l'aieule qui borde 2 surfaces
c          on cherche l'ascendant le plus ancien qui se trouve
c          en limite de zone
c
            lareta = merare(larete)
c
   32       continue
cgn            write(ulsort,90002) '... lareta', lareta
c
            if ( imem(adelre-1+lareta).eq.1 ) then
              lareta = merare(lareta)
              goto 32
            endif
cgn       write(ulsort,90112) 'famare', lareta, famare(lareta)
c
c 3.1.3. ==> Cet aieul doit faire partie du maillage de calcul. Pour
c            cela, sa famille doit valoir la famille supplementaire et
c            il doit passer actif.
C          Remarque : il se peut que la famille d'une telle arete soit
c                     deja la famille supplementaire. Il ne faut pas
c                     filtrer la-dessus car sinon on ne mettra pas son
c                     etat a 0 ; or cela est indispensable pour
c                     etre detectee en tant qu'element de calcul.
c
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
            write (ulsort,texte(langue,8)) mess14(langue,1,1), lareta
            write (ulsort,texte(langue,10)) famare(lareta), nbfare
        endif
#endif
            famare(lareta) = nbfare
c
            if ( mod(hetare(lareta),10).ne.0 ) then
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
              write (ulsort,texte(langue,9)) mess14(langue,1,1), lareta
              write (ulsort,texte(langue,10)) hetare(lareta), 0
        endif
#endif
              hetare(lareta) = 0
            endif
c
            nparrc = nparrc + 1
            arerec(1,nparrc) = lareta
            arerec(2,nparrc) = larete
c
          endif
c
        else
c
c 3.2. ==> L'arete est interne au domaine. Si elle est de la famille
c          supplementaire, on doit la ramener a la famille libre
c          Remarque : bug possible si des elements internes ont ete
c                     mis dans des groupes au depart ...
c
          if ( famare(larete).eq.nbfare ) then
c
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
            write (ulsort,texte(langue,8)) mess14(langue,1,1), larete
            write (ulsort,texte(langue,10)) famare(larete), 1
        endif
#endif
            famare(larete) = 1
c
c
#ifdef _DEBUG_HOMARD_
          elseif ( famare(larete).ne.1 ) then
c
            write (ulsort,texte(langue,19))
     >      mess14(langue,1,1), larete  , famare(larete)
            write (ulsort,texte(langue,20))
ccc            codret = 12
#endif
c
          endif
c
        endif
c
   31 continue
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,texte(langue,14))
      write (ulsort,texte(langue,6)) mess14(langue,3,1), nparrc
      write (ulsort,*) ' '
      endif
#endif
c
c====
c 4. chaque arete de la non conformite initiale doit devenir
c    un element si elle apparait
c    on va s'interesser aux aretes recouvrantes qui sont
c    decoupees en 2 et dont aucune des faces voisines n'est
c    decoupee ; cela correspond en effet a la situation semblable
c    au depart.
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. non conf initiale ; codret', codret
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,11)) nbanci
      write (ulsort,90002) 'nbenrc', nbenrc
#endif
c
      if ( nbanci.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
        jaux = nbanci*nbenrc
c
        do 41 , iaux = 1 , jaux
c
          larete = arreca(iaux)
c
#ifdef _DEBUG_HOMARD_
        if ( larete.eq.12 ) then
          glop = 1
        else
          glop = 0
        endif
#endif
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,texte(langue,5)) mess14(langue,1,1), larete
        endif
#endif
c
          if ( mod(hetare(larete),10).eq.2 ) then
c
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,texte(langue,12)) filare(larete), filare(larete)+1
        write (ulsort,texte(langue,13))
     >  mess14(langue,1,1), filare(larete)  , hetare(filare(larete))
        write (ulsort,texte(langue,13))
     >  mess14(langue,1,1), filare(larete)+1, hetare(filare(larete)+1)
        endif
#endif
c
c 4.1. ==> Si on a deja traite cette arete, on passe a la suite
c
            do 411 , kaux = nparrc, 1, -1
c
              if ( arerec(1,kaux).eq.larete .or.
     >             arerec(2,kaux).eq.larete ) then
                goto 41
              endif
c
  411       continue
c
c 4.2. ==> Si une de ses faces voisines est decoupee, on passe
c            a la suite
c
            kdeb = posifa(larete-1)+1
            kfin = posifa(larete)
            do 412 , kaux = kdeb , kfin
c
              laux = facare(kaux)
              if ( laux.gt.0 ) then
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,texte(langue,5)) mess14(langue,1,2), laux
        write (ulsort,texte(langue,13))
     >  mess14(langue,1,2), laux, hettri(laux)
        endif
#endif
                if ( mod(hettri(laux),10).ne.0 ) then
                  goto 41
                endif
              else
                laux = -laux
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,texte(langue,5)) mess14(langue,1,4), laux
        write (ulsort,texte(langue,13))
     >  mess14(langue,1,4), laux, hetqua(laux)
        endif
#endif
                if ( mod(hetqua(laux),100).ne.0 ) then
                  goto 41
                endif
              endif
c
c
  412       continue
c
c 4.3. ==> L'arete mere est a modifier
c
#ifdef _DEBUG_HOMARD_
         if ( glop.ne.0 ) then
           write (ulsort,texte(langue,8)) mess14(langue,1,1), larete
            write (ulsort,texte(langue,10)) famare(larete), nbfare
            write (ulsort,texte(langue,10)) hetare(larete), 0
        endif
#endif
c
            famare(larete) = nbfare
            hetare(larete) = 0
c
c 4.4. ==> Ses filles sont a modifier
c
            do 414 , lareta = filare(larete), filare(larete)+1
c
              if ( famare(lareta).ne.nbfare ) then
c
#ifdef _DEBUG_HOMARD_
         if ( glop.ne.0 ) then
            write (ulsort,texte(langue,8)) mess14(langue,1,1), lareta
            write (ulsort,texte(langue,10)) famare(lareta), nbfare
        endif
#endif
                famare(lareta) = nbfare
c
                if ( mod(hetare(lareta),10).ne.0 ) then
#ifdef _DEBUG_HOMARD_
         if ( glop.ne.0 ) then
              write (ulsort,texte(langue,9)) mess14(langue,1,1), lareta
              write (ulsort,texte(langue,10)) hetare(lareta), 0
        endif
#endif
                  hetare(lareta) = 0
                endif
c
              endif
c
              nparrc = nparrc + 1
              arerec(1,nparrc) = lareta
              arerec(2,nparrc) = larete
c
  414       continue
c
          endif
c
   41   continue
c
        endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,texte(langue,15))
      write (ulsort,texte(langue,6)) mess14(langue,3,1), nparrc
      write (ulsort,*) ' '
      endif
#endif
c
c====
c 5. Bilan
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. Bilan ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( noelre, codret )
c
      endif
c
c====
c 6. la fin
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
