      subroutine cmch40 ( lehexa, nulofa, tabaux,
     >                    somm, arext1, arext2, arext3, arext4,
     >                    indare, indtri, indtet, indpyr, indptp,
     >                    hetare, somare,
     >                    filare, merare, famare,
     >                    hettri, aretri,
     >                    filtri, pertri, famtri,
     >                    nivtri,
     >                    arequa, filqua,
     >                    hettet, tritet, cotrte,
     >                    filtet, pertet, famtet,
     >                    hetpyr, facpyr, cofapy,
     >                    filpyr, perpyr, fampyr,
     >                    quahex, coquhe,
     >                    famhex, cfahex,
     >                    trigpy, facnde, cofnde,
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
c    Creation du Maillage - Conformite - decoupage des Hexaedres
c    -           -          -                          -
c                         - par 1 Face - etat 4x
c                                 -           -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lehexa . e   .   1    . hexaedre a decouper                        .
c . nulofa . e   .   1    . numero local de la face couppe en 4        .
c . tabaux . e   .    4   . numeros locaux des faces coupees en 3,     .
c .        .     .        . dans l'ordre des pyramides p/p1+1          .
c . somm   . e   .   1    . sommets de la face non decoupee            .
c . arexti . e   .   1    . aretes de la face non decoupee             .
c . indare . es  .   1    . indice de la derniere arete creee          .
c . indtri . es  .   1    . indice du dernier triangle cree            .
c . indtet . es  .   1    . indice du dernier tetraedre cree           .
c . indpyr . es  .   1    . indice de la derniere pyramide creee       .
c . indptp . e   .   1    . indice du dernier pere enregistre          .
c . hetare . es  . nouvar . historique de l'etat des aretes            .
c . somare . es  .2*nouvar. numeros des extremites d'arete             .
c . filare . es  . nouvar . premiere fille des aretes                  .
c . merare . es  . nouvar . mere des aretes                            .
c . famare .     . nouvar . famille des aretes                         .
c . hettri . es  . nouvtr . historique de l'etat des triangles         .
c . aretri . es  .nouvtr*3. numeros des 3 aretes des triangles         .
c . filtri . es  . nouvtr . premier fils des triangles                 .
c . pertri . es  . nouvtr . pere des triangles                         .
c . famtri . es  . nouvtr . famille des triangles                      .
c . nivtri . es  . nouvtr . niveau des triangles                       .
c . arequa . e   .nouvqu*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nouvqu . premier fils des quadrangles               .
c . hettet . es  . nouvte . historique de l'etat des tetraedres        .
c . tritet . es  .nouvtf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nouvtf*4. code des 4 triangles des tetraedres        .
c . filtet . es  . nouvte . premier fils des tetraedres                .
c . pertet . es  . nouvte . pere des tetraedres                        .
c .        .     .        . si pertet(i) > 0 : numero du tetraedre     .
c .        .     .        . si pertet(i) < 0 : -numero dans pthepe     .
c . famtet . es  . nouvte . famille des tetraedres                     .
c . hetpyr . e   . nouvpy . historique de l'etat des pyramides         .
c . facpyr . e   .nouvyf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nouvyf*5. codes des faces des pyramides              .
c . filpyr . e   . nouvpy . premier fils des pyramides                 .
c . perpyr . e   . nouvpy . pere des pyramides                         .
c .        .     .        . si perpyr(i) > 0 : numero de la pyramide   .
c .        .     .        . si perpyr(i) < 0 : -numero dans pphepe     .
c . fampyr . e   . nouvpy . famille des pyramides                      .
c . quahex . e   .nouvhf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nouvhf*6. codes des 6 quadrangles des hexaedres      .
c . famhex . e   . nouvhe . famille des hexaedres                      .
c . cfahex .     . nctfhe. codes des familles des hexaedres            .
c .        .     . nbfhex .   1 : famille MED                          .
c .        .     .        .   2 : type d'hexaedres                     .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
c . trigpy .  s  .   4    . triangle de la grande pyramide             .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : aucune face ne correspond              .
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
      parameter ( nompro = 'CMCH40' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "dicfen.h"
#include "nbfami.h"
#include "nouvnb.h"
#include "cofpfh.h"
#include "coftfh.h"
c
c 0.3. ==> arguments
c
      integer lehexa, nulofa, tabaux(4)
      integer somm(4)
      integer arext1, arext2, arext3, arext4
      integer indare, indtri, indtet, indpyr, indptp
      integer hetare(nouvar), somare(2,nouvar)
      integer filare(nouvar), merare(nouvar), famare(nouvar)
      integer hettri(nouvtr), aretri(nouvtr,3)
      integer filtri(nouvtr), pertri(nouvtr), famtri(nouvtr)
      integer nivtri(nouvtr)
      integer arequa(nouvqu,4), filqua(nouvqu)
      integer hettet(nouvte), tritet(nouvtf,4), cotrte(nouvtf,4)
      integer filtet(nouvte), pertet(nouvte), famtet(nouvte)
      integer hetpyr(nouvpy), facpyr(nouvyf,5), cofapy(nouvyf,5)
      integer filpyr(nouvpy), perpyr(nouvpy), fampyr(nouvpy)
      integer quahex(nouvhf,6), coquhe(nouvhf,6)
      integer famhex(nouvhe), cfahex(nctfhe,nbfhex)
      integer trigpy(4)
      integer facnde, cofnde
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
#ifdef _DEBUG_HOMARD_
      integer jaux
#endif
      integer noefac
      integer areint(4)
      integer facdec, cofdec
      integer quabas(4)
      integer arefad(4), areqtr(4,2)
      integer trifad(4,0:2), cotrvo(4,0:2)
      integer triint(4,2)
      integer niveau
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
#ifdef _DEBUG_HOMARD_
 1789 format(5(a,i5,', '))
#endif
c
      codret = 0
c
c====
c 2. initialisations
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCHFA', nompro
#endif
      call cmchfa ( facdec, cofdec, facnde, cofnde,
     >              niveau, noefac,
     >              quabas, arefad,
     >              trifad, cotrvo, areqtr,
     >              lehexa, nulofa,
     >              somare, aretri, nivtri,
     >              arequa, filqua,
     >              quahex, coquhe,
     >              tabaux,
     >              ulsort, langue, codret )
c
c====
c 3. Creation des quatres aretes internes
c    areint(p) relie le sommet somm(p) (de la pyramide fille p)
c    au centre de la face coupee
c====
c
      if ( codret.eq.0 ) then
c
      do 31 , iaux = 1 , 4
c
        indare = indare + 1
        areint(iaux) = indare
c
        somare(1,areint(iaux)) = min ( noefac , somm(iaux) )
        somare(2,areint(iaux)) = max ( noefac , somm(iaux) )
c
        famare(areint(iaux)) = 1
        hetare(areint(iaux)) = 50
        merare(areint(iaux)) = 0
        filare(areint(iaux)) = 0
#ifdef _DEBUG_HOMARD_
 3100   format('. Arete interne',i10,' de',i10,' a',i10)
        write(ulsort,3100) indare,
     >  somare(1,areint(iaux)), somare(2,areint(iaux))
#endif
c
   31 continue
c
      endif
c
c====
c 4. Creation des dix triangles internes
c     par convention, le niveau est le meme que les quadrangles fils
c     sur l'exterieur
c====
c
c 4.1. ==> triangles s'appuyant sur la face decoupee
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCHFB', nompro
cgn      write (ulsort,*) '.. triangles de ', indtri + 1, ' a ', indtri+8
#endif
      call cmchfb ( indtri, triint,
     >              hettri, aretri, nivtri,
     >              filtri, pertri, famtri,
     >              areint, arefad, areqtr, niveau,
     >              ulsort, langue, codret )
c
      endif
#ifdef _DEBUG_HOMARD_
      iaux = indtri-7
      write(ulsort,1789) 'TRIANGLE = ', iaux
      write(ulsort,1789) 'arete = ', aretri(iaux,1),
     >                   ' de ',somare(1,aretri(iaux,1)),
     >                   ' a ',somare(2,aretri(iaux,1))
      write(ulsort,1789) 'arete = ', aretri(iaux,2),
     >                   ' de ',somare(1,aretri(iaux,2)),
     >                   ' a ',somare(2,aretri(iaux,2))
      write(ulsort,1789) 'arete = ', aretri(iaux,3),
     >                   ' de ',somare(1,aretri(iaux,3)),
     >                   ' a ',somare(2,aretri(iaux,3))
#endif
c
c 4.2. ==> triangles s'appuyant sur les aretes de la face non decoupee
c          Ce sont ceux qui bordent la grande pyramide
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCHFC', nompro
cgn      write (ulsort,*) '.. triangles de ', indtri + 1, ' a ', indtri+4
#endif
      call cmchfc ( indtri, trigpy,
     >              hettri, aretri, nivtri,
     >              filtri, pertri, famtri,
     >              areint, arext1, arext2, arext3, arext4,
     >              niveau,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 5. Creation des 4 pyramides dans les coins
c====
c
      iaux = cfahex(cofpfh,famhex(lehexa))
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCHFD', nompro
#endif
      call cmchfd ( indpyr,
     >              facpyr, cofapy, fampyr,
     >              hetpyr, filpyr, perpyr,
     >              trifad, cotrvo, triint, quabas, cofdec,
     >              indptp, iaux )
c
#ifdef _DEBUG_HOMARD_
      do 5333 , iaux = indpyr-3, indpyr
      write(ulsort,1792) iaux, (facpyr(iaux,jaux),jaux=1,5)
 5333 continue
 1792 format('pyramide ',i6,' : ',5i6)
#endif
c
      endif
c
c====
c 6. Creation des tetraedres
c====
c
      iaux = cfahex(coftfh,famhex(lehexa))
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCHFE', nompro
#endif
      call cmchfe ( indtet, indptp,
     >              tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad, cotrvo, triint, trigpy,
     >              iaux )
c
#ifdef _DEBUG_HOMARD_
      do 6333 , iaux = indtet-3, indtet
      write(ulsort,1793) iaux, (tritet(iaux,jaux),jaux=1,4)
 6333 continue
 1793 format('tetraedre ',i6,' : ',4i6)
#endif
c
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
