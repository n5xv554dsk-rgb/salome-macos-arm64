      subroutine pcmar3 ( typenh, numead,
     >                    nbfato, nbvoto, nbffac,
     >                    hetfac, nivfac,
     >                    famfac, perfac, filfac,
     >                    hetvol, hetpyr,
     >                    volfac, pypefa,
     >                    nbfari, fareca,
     >                    npfarc, facrec,
     >                    npvorc, volrec,
     >                    npperc, penrec, nppyrc, pyrrec,
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
c    aPres adaptation - Conversion de MAillage - Recollements - phase 3
c     -                 -             --         -                    -
c    Reperage des faces de raccordement non conforme
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typenh . e   .   1    . code des entites au sens homard            .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   4 : quadrangles                          .
c . numead . e   .   1    . numero de la mere adoptive                 .
c . nbfato . e   .   1    . nombre de faces total                      .
c . nbvoto . e   .   1    . nombre de volumes total                    .
c . nbffac . e   .   1    . nombre de familles de faces                .
c . nivfac . e   . nbfato . niveau des faces                           .
c . hetfac . e   . nbfato . historique de l'etat des faces             .
c . famfac . es  . nbfato . famille des faces                          .
c . perfac . e   . nbfato . pere des faces                             .
c . perfac . e   . nbfato . filles des faces                           .
c . hetvol . e   . nbvoto . historique de l'etat des volumes           .
c . hetpyr . e   . nbpyto . historique de l'etat des pyramides         .
c . volfac . e   .2*nbfato. numeros des 2 volumes par face             .
c .        .     .        . volfac(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre/tetraedre j                 .
c .        .     .        . j<0 : pyramide/pentaedre dans pypefa(1/2,j).
c . pypefa . e   .2*lgpype. pypefa(1,j) = numero de la pyramide voisine.
c .        .     .        . de la face k tel que volfac(1/2,k) = -j    .
c .        .     .        . pypefa(2,j) = numero du pentaedre voisin   .
c .        .     .        . de la face k tel que volfac(1/2,k) = -j    .
c . npfarc .  s  .   1    . nombre de paires de faces a recoller       .
c . facrec .  s  .  2*x   . paires des faces a recoller                .
c . npvorc .  s  .   1    . nombre de paires de volumes a recoller     .
c . volrec .  s  .  3*x   . paires des volumes voisins faces a recoller.
c . npperc .  s  .   1    . nombre de paires de pentaedres a recoller  .
c . penrec .  s  .  3*x   . paires des penta. voisins faces a recoller .
c . nppyrc .  s  .   1    . nombre de paires de pyramides a recoller   .
c . pyrrec .  s  .  3*x   . paires des pyram. voisines faces a recoller.
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
      parameter ( nompro = 'PCMAR3' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer typenh, numead
      integer nbfato, nbvoto, nbffac
      integer hetfac(nbfato), nivfac(nbfato)
      integer famfac(nbfato), perfac(nbfato), filfac(nbfato)
      integer hetvol(*), hetpyr(*)
      integer volfac(2,nbfato), pypefa(2,*)
      integer nbfari
      integer fareca(nbfari)
      integer npfarc, facrec(2,*)
      integer npvorc, volrec(3,*)
      integer npperc, penrec(3,*)
      integer nppyrc, pyrrec(3,*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer laface, lafaci
      integer facbis, face
      integer nbfa2d, nbfabo, nbfav2, nbfav3, nbfav4, nbfanc
      integer tybofa
      integer mhistf, mhistv
      integer levolu, typvol
c
      integer adelre
#ifdef _DEBUG_HOMARD_
      integer glop
#endif
c
      character*8 noelre
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
      texte(1,13) = '(''. Etat du '',a,''numero    '',i10,'' :'',i10)'
      texte(1,14) = '(2x,''Apres la phase de limites de zone :'')'
      texte(1,15) = '(2x,''Apres les non conformites initiales :'')'
      texte(1,19) = '(''. Famille du '',a,''numero '',i10,'' :'',i10)'
      texte(1,20) = '(''. Niveau du '',a,'' numero '',i10,'' :'',i10)'
c
      texte(2,4) = '(a,'' should not be called.'')'
      texte(2,5) = '(''Examination of '',a,'',#'',i10)'
      texte(2,6) = '(2x,''Number of pairs of '',a,''to glue:'',i10)'
      texte(2,8) =
     > '(''.. Modification of the family of '',a,'',#'',i10)'
      texte(2,9) =
     > '(''.. Modification of the state of '',a,'',#'',i10)'
      texte(2,10) = '(5x,''==> old:'',i5,'', new:'',i5)'
      texte(2,11) = '(''Number of non-conformal situations:'',i10))'
      texte(2,13) = '(''. State for '',a,''#'',i10,'':'',i10)'
      texte(2,14) = '(2x,''After zone limit analysis:'')'
      texte(2,15) = '(2x,''After initial non conforming:'')'
      texte(2,19) = '(''. Family for '',a,''#'',i10,'':'',i10)'
c
#include "impr03.h"
c
      codret = 0
c
c====
c 2. recherche des faces a la limite entre deux zones de
c    raffinement de niveau different, sans tenir compte du
c    bord exterieur
c        -1 : face non classee
c         0 : face bidimensionnelle
c         1 : face au bord d'un seul volume
c         2 : face entre 2 volumes actifs
c         3 : face entre 2 volumes dont 1 seul actif
c         4 : face entre 2 volumes inactifs
c         5 : face de non conformite
c====
c
      if ( codret.eq.0 ) then
c
      call gmalot ( noelre, 'entier  ', nbfato, adelre, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTBOFA', nompro
#endif
      call utbofa ( typenh, numead,
     >              nbfato, nbvoto,
     >              nivfac, filfac, perfac,
     >              hetvol, hetpyr,
     >              volfac, pypefa,
     >              imem(adelre), nbfa2d, nbfabo,
     >              nbfav2, nbfav3, nbfav4, nbfanc,
     >              ulsort, langue, codret )
c
      endif
c
cgn      call gmprsx (nompro,noelre)
c====
c 3. examen des faces en limite de zone
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. faces limite de zone ; codret', codret
cgn      write (ulsort,90002) 'nbffac = ', nbffac
cgn      write (ulsort,*) filfac(5)
      call dmflsh (iaux)
#endif
c
      if ( typenh.eq.2 ) then
        mhistf =   10
        mhistv =  100
      else
        mhistf =  100
        mhistv = 1000
      endif
c
      if ( codret.eq.0 ) then
c
      do 31 , laface = 1 , nbfato
c
#ifdef _DEBUG_HOMARD_
        if ( laface.eq.0 )then
            glop=1
        write (ulsort,*) '==========================================='
        else
          glop=0
        endif
         if ( glop.eq.1 ) then
        write (ulsort,texte(langue,5)) mess14(langue,1,typenh), laface
        write (ulsort,texte(langue,13))
     >      mess14(langue,1,typenh), laface  , hetfac(laface)
        write (ulsort,texte(langue,19))
     >      mess14(langue,1,typenh), laface  , famfac(laface)
        write (ulsort,texte(langue,20))
     >      mess14(langue,1,typenh), laface  , nivfac(laface)
        write (ulsort,90112) 'filfac',laface,filfac(laface)
        write (ulsort,90112) 'perfac',laface,perfac(laface)
        endif
#endif
c
        tybofa = imem(adelre-1+laface)
#ifdef _DEBUG_HOMARD_
        if ( glop.eq.1 ) then
          write (ulsort,90002) 'type de bord', tybofa
        endif
#endif
c
c 3.1. ==> La face est a la limite entre 2 zones de niveaux de
c          raffinement differents. Si elle est active, on doit lui
c          attribuer la famille supplementaire ainsi qu'a son aieule
c
        if ( tybofa.eq.5 ) then
cgn      write (ulsort,90002) 'etat/famille : ',hetfac(laface),famfac(laface)
c
          if ( mod(hetfac(laface),mhistf).eq.0 ) then
c
c 3.1.1. ==> la face est a modifier
c
#ifdef _DEBUG_HOMARD_
        if ( glop.eq.1 ) then
          write (ulsort,*) 'face limite de zone'
          write (ulsort,texte(langue,8)) mess14(langue,1,typenh), laface
          write (ulsort,texte(langue,10)) famfac(laface), nbffac
        endif
#endif
            famfac(laface) = nbffac
c
c 3.1.2. ==> On cherche l'ascendant le plus ancien qui se trouve aussi
c            en limite de zone
c
            facbis = perfac(laface)
c
   32       continue
#ifdef _DEBUG_HOMARD_
      if ( glop.eq.1 ) then
        write(ulsort,90002) '... facbis', facbis
        write(ulsort,90015) '... bord de',
     >                      facbis,'=',imem(adelre-1+facbis)
      endif
#endif
c
            if ( imem(adelre-1+facbis).eq.5 ) then
              if ( perfac(facbis).gt.0 ) then
                facbis = perfac(facbis)
                goto 32
              endif
            endif
c
c 3.1.3. ==> Cet aieul doit faire partie du maillage de calcul
c
#ifdef _DEBUG_HOMARD_
            if ( glop.eq.1 ) then
          write (ulsort,texte(langue,8)) mess14(langue,1,typenh),facbis
          write (ulsort,texte(langue,10)) famfac(facbis), nbffac
            endif
#endif
c
c 3.1.3.1. ==> La famille doit valoir la famille supplementaire pour
c              que la maille appartienne au maillage de calcul
C          Remarque : il se peut que la famille d'une telle face soit
c                     deja la famille supplementaire. Il ne faut pas
c                     filtrer la-dessus car sinon on ne mettra pas son
c                     etat a 0 ; or cela est indispensable pour
c                     etre detectee en tant qu'element de calcul.
c
            famfac(facbis) = nbffac
c
c 3.1.3.2. ==> La maille doit etre active
c
            if ( mod(hetfac(facbis),mhistf).ne.0 ) then
#ifdef _DEBUG_HOMARD_
            if ( glop.eq.1 ) then
          write (ulsort,texte(langue,9)) mess14(langue,1,typenh), facbis
          write (ulsort,texte(langue,10)) hetfac(facbis), 0
            endif
#endif
              hetfac(facbis) = 0
            endif
c
c 3.1.3.3. ==> Enregistrement de la nouvelle paire
c
#ifdef _DEBUG_HOMARD_
cc            if ( glop.eq.1 ) then
          write (ulsort,*) 'enregistrement ',npfarc+1,
     >                     ' pour ',facbis,' et ',laface
cc            endif
#endif
c
            npfarc = npfarc + 1
            facrec(1,npfarc) = facbis
            facrec(2,npfarc) = laface
c
c 3.1.3.4. ==> Enregistrement des volumes voisins
c
            npvorc = npvorc + 1
            do 3134 , iaux = 1 , 2
c
              if ( iaux.eq.1 ) then
                face = facbis
              else
                face = laface
              endif
c
c             lequel des deux voisins ?
c
              do 31341 , jaux = 1 , 2
c
                kaux = volfac(jaux,face)
#ifdef _DEBUG_HOMARD_
cc            if ( glop.eq.1 ) then
                write (ulsort,90122) 'volfac', jaux, face, kaux
                if ( kaux.gt.0 ) then
                  write (ulsort,90002) 'd''etat', hetvol(kaux)
                endif
cc            endif
#endif
c               Le volume est tetra ou hexa
                if ( kaux.gt.0 ) then
                  if ( mod(hetvol(kaux),mhistv).eq.0 ) then
                    levolu = kaux
                    typvol = 1
                    goto 31342
                  endif
                endif
c
31341         continue
c
31342         continue
c
c             enregistrement du voisin
c
#ifdef _DEBUG_HOMARD_
cc            if ( glop.eq.1 ) then
              write (ulsort,90002) 'volume et type', levolu, typvol
cc            endif
#endif
c
              if ( typvol.eq.1 ) then
                volrec(iaux,npvorc) = levolu
                volrec(3,npvorc) = facbis
              endif
c
 3134       continue
c
          endif
c
        elseif ( tybofa.eq.2 .or. tybofa.eq.4 ) then
c
c 3.2. ==> La face est interne au domaine.
c          . Si elle borde deux volumes actifs ou deux volumes inactifs
c            et qu'elle est de la famille supplementaire, on doit la
c            ramener a la famille libre
c          Remarque : bug possible si des elements internes ont ete
c                     mis dans des groupes au depart ...
c
          if ( famfac(laface).eq.nbffac ) then
c
#ifdef _DEBUG_HOMARD_
        if ( glop.eq.1 ) then
          write (ulsort,*) 'face interne au domaine'
          write (ulsort,texte(langue,8)) mess14(langue,1,typenh), laface
          write (ulsort,texte(langue,10)) famfac(laface), 1
        endif
#endif
            famfac(laface) = 1
c
#ifdef _DEBUG_HOMARD_
          elseif ( famfac(laface).ne.1 ) then
c
            write (ulsort,texte(langue,19))
     >      mess14(langue,1,typenh), laface  , famfac(laface)
            write (ulsort,texte(langue,20))
     >      mess14(langue,1,typenh), laface  , nivfac(laface)
            codret = 12
            goto 310
#endif
c
          endif
c
        endif
c
   31 continue
c
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,3,typenh), npfarc
      if ( npfarc.gt.0 ) then
      jaux = 1
      laface = facrec(1,1)
cgn      print *,'laface = ', laface
cgn      print *,'adelre-1+laface = ', adelre-1+laface
      write (ulsort,90002) 'face', laface, imem(adelre-1+laface)
      do 3100 , iaux = 1 , npfarc
        if ( imem(adelre-1+laface).ne.3 ) then
        stop
        elseif ( imem(adelre-1+facrec(2,iaux)).ne.5 ) then
        stop
        endif
          write (ulsort,*)'   ',imem(adelre-1+facrec(2,iaux))
        if ( jaux.eq.2 .or. jaux.eq.3 .or. jaux.eq.4 ) then
          if ( laface.ne.facrec(1,iaux) ) then
            write (ulsort,*) jaux
            write (ulsort,*) facrec(2,iaux)
             write (ulsort,texte(langue,13))
     >      mess14(langue,1,typenh), laface  , hetfac(laface)
            write (ulsort,texte(langue,19))
     >       mess14(langue,1,typenh), laface  , famfac(laface)
            write (ulsort,texte(langue,20))
     >      mess14(langue,1,typenh), laface  , nivfac(laface)
            write (ulsort,90002) 'fils', filfac(laface)
             write (ulsort,texte(langue,13))
     > mess14(langue,1,typenh), filfac(laface), hetfac(filfac(laface))
             write (ulsort,texte(langue,13))
     >mess14(langue,1,typenh),filfac(laface)+1,hetfac(filfac(laface)+1)
             write (ulsort,texte(langue,13))
     >mess14(langue,1,typenh),filfac(laface)+2,hetfac(filfac(laface)+2)
             write (ulsort,texte(langue,13))
     >mess14(langue,1,typenh),filfac(laface)+3,hetfac(filfac(laface)+3)
           stop
         endif
       elseif ( jaux.eq.5 ) then
         if ( laface.eq.facrec(1,iaux) ) then
          write (ulsort,*) '5'
          write (ulsort,texte(langue,19))
     >     mess14(langue,1,typenh), laface  , famfac(laface)
          write (ulsort,texte(langue,20))
     >      mess14(langue,1,typenh), laface  , nivfac(laface)
         stop
         endif
         jaux = 1
         laface = facrec(1,iaux)
            write (ulsort,*)imem(adelre-1+laface)
        endif
        jaux = jaux + 1
 3100 continue
      endif
c
      do 3101 , laface = 1 , nbfato
        if ( imem(adelre-1+laface).eq.3 ) then
          do 3102 , iaux = 1 , npfarc
            if ( laface.eq.facrec(1,iaux) ) then
              goto 3101
            endif
 3102     continue
        elseif ( imem(adelre-1+laface).eq.5 ) then
          do 3103 , iaux = 1 , npfarc
            if ( laface.eq.facrec(2,iaux) ) then
              goto 3101
            endif
 3103     continue
        else
          goto 3101
        endif
            write (ulsort,*) jaux
            write (ulsort,*) facrec(1,iaux), facrec(2,iaux)
             write (ulsort,texte(langue,13))
     >      mess14(langue,1,typenh), laface  , hetfac(laface)
            write (ulsort,texte(langue,19))
     >       mess14(langue,1,typenh), laface  , famfac(laface)
            write (ulsort,texte(langue,20))
     >      mess14(langue,1,typenh), laface  , nivfac(laface)
            write (ulsort,90002) 'fils', filfac(laface)
             write (ulsort,texte(langue,13))
     > mess14(langue,1,typenh), filfac(laface), hetfac(filfac(laface))
             write (ulsort,texte(langue,13))
     >mess14(langue,1,typenh),filfac(laface)+1,hetfac(filfac(laface)+1)
             write (ulsort,texte(langue,13))
     >mess14(langue,1,typenh),filfac(laface)+2,hetfac(filfac(laface)+2)
             write (ulsort,texte(langue,13))
     >mess14(langue,1,typenh),filfac(laface)+3,hetfac(filfac(laface)+3)
           stop
 3101 continue
#endif
c
#ifdef _DEBUG_HOMARD_
  310 continue
#endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,texte(langue,14))
      write (ulsort,texte(langue,6)) mess14(langue,3,typenh), npfarc
      write (ulsort,*) ' '
      endif
#endif
c
#ifdef _DEBUG_HOMARD_
cgn      do 300 , laface = 1 , nbfato
      do 300 , laface = 1 , -nbfato
      if ( famfac(laface).ne.1 ) then
      if ( imem(adelre-1+laface).eq.0 ) then
          write (ulsort,texte(langue,5)) mess14(langue,1,typenh), laface
          write (ulsort,90002) 'etat   ',hetfac(laface)
          write (ulsort,90002) 'pere   ',perfac(laface)
          write (ulsort,90002) 'famille',famfac(laface)
          write (ulsort,90002) 'bord   ',imem(adelre-1+laface)
       call dmflsh(iaux)
      endif
      endif
  300 continue
      laface = 12279
      do 3010 , laface = 1 , nbfato
        if ( famfac(laface).eq.nbffac ) then
          write (ulsort,texte(langue,5)) mess14(langue,1,typenh), laface
          write (ulsort,*) 'etat    = ',hetfac(laface),
     <                     ', pere    = ',perfac(laface),
     <                     ', bord = ',imem(adelre-1+laface)
        endif
 3010 continue
       call dmflsh(iaux)
          write (ulsort,*) ' '
      do 3020 , laface = 1 , -nbfato
      if ( famfac(laface).ge.2 .and. famfac(laface).le.7) then
          write (ulsort,texte(langue,5)) mess14(langue,1,typenh), laface
          write (ulsort,*) 'etat    = ',hetfac(laface),
     >                     ', pere    = ',perfac(laface),
     >                     ', bord = ',imem(adelre-1+laface)
      endif
 3020 continue
       call dmflsh(iaux)
#endif
c
c====
c 4. chaque face de la non conformite initiale doit devenir
c    un element si elle apparait
c    on va s'interesser aux faces recouvrantes qui sont
c    decoupees en 4 et dont l'element voisin n'est pas decoupe ;
c    cela correspond en effet a la situation semblable au depart.
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. conformite initiale ; codret', codret
      call dmflsh(iaux)
      write (ulsort,texte(langue,11)) nbfari
#endif
c
      if ( nbfari.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
        do 41 , iaux = 1 , nbfari
c
          laface = fareca(iaux)
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,5)) mess14(langue,1,4), laface
        write (ulsort,*) filfac(laface)
#endif
c
          if ( mod(hetfac(laface),mhistf).eq.4 ) then
c
c 4.1. ==> Si on a deja traite cette face, on passe a la suite
c
            do 411 , kaux = npfarc, 1, -1
c
              if ( facrec(1,kaux).eq.laface .or.
     >             facrec(2,kaux).eq.laface ) then
                goto 41
              endif
c
  411       continue
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,13))
     >  mess14(langue,1,typenh), laface  , hetfac(laface)
#endif
c
c 4.2. ==> Si son volume voisin est decoupe, on passe a la suite
c
            kaux = volfac(1,laface)
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,13))
     >  mess14(langue,1,9), kaux  , hetvol(kaux)
#endif
            if ( kaux.gt.0 ) then
              if ( mod(hetvol(kaux),100).ne.0 ) then
                goto 41
              endif
            else
              kaux = -kaux
              if ( pypefa(1,kaux).ne.0 ) then
                if ( mod(hetpyr(pypefa(1,kaux)),100).ne.0 ) then
                  goto 41
                endif
              endif
              if ( pypefa(2,kaux).ne.0 ) then
                codret = 1793
              endif
            endif
c
c 4.3. ==> La face mere est a modifier
c
#ifdef _DEBUG_HOMARD_
         write (ulsort,texte(langue,8)) mess14(langue,1,typenh), laface
         write (ulsort,texte(langue,10)) famfac(laface), nbffac
         write (ulsort,texte(langue,10)) hetfac(laface), 0
#endif
c
            famfac(laface) = nbffac
            hetfac(laface) = 0
c
c 4.4. ==> Ses filles sont a modifier
c
            do 414 , lafaci = filfac(laface), filfac(laface)+3
c
              if ( famfac(lafaci).ne.nbffac ) then
c
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,8))
     >                    mess14(langue,1,typenh), lafaci
            write (ulsort,texte(langue,10)) famfac(lafaci), nbffac
#endif
                famfac(lafaci) = nbffac
c
                if ( mod(hetfac(lafaci),mhistf).ne.0 ) then
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,9))
     >                    mess14(langue,1,typenh), lafaci
              write (ulsort,texte(langue,10)) hetfac(lafaci), 0
#endif
                  hetfac(lafaci) = 0
                endif
c
              endif
c
              npfarc = npfarc + 1
              facrec(1,npfarc) = lafaci
              facrec(2,npfarc) = laface
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
      write (ulsort,texte(langue,6)) mess14(langue,3,typenh), npfarc
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
