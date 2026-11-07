      subroutine cmcdhe ( indnoe, indare, indtet, indpyr, indhex,
     >                    coonoe, hetnoe, arenoe,
     >                    famnoe,
     >                    hetare, somare,
     >                    filare, merare, famare,
     >                    aretri,
     >                    arequa, filqua,
     >                    hettet, aretet,
     >                    filtet, pertet, famtet,
     >                    pthepe,
     >                    hetpyr, arepyr,
     >                    filpyr, perpyr, fampyr,
     >                    pphepe,
     >                    hethex, arehex,
     >                    filhex, fhpyte, perhex,
     >                    famhex, cfahex,
     >                    quahex, coquhe,
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
c    Creation du Maillage - Conformite - Decoupage des HExaedres
c    -           -          -            -             --
c ______________________________________________________________________
c
c but : decoupage des hexaedres pour mise en conformite
c       remarque : description des fils par leurs aretes
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . indnoe . es  .   1    . indice du dernier noeud cree               .
c . indare . es  .   1    . indice de la derniere arete creee          .
c . indtet . es  .   1    . indice du dernier tetraedre cree           .
c . indpyr . es  .   1    . indice de la derniere pyramide creee       .
c . indhex . es  .   1    . indice du dernier hexaedre cree            .
c . coonoe . es  .nouvno*3. coordonnees des noeuds                     .
c . hetnoe . es  . nouvno . historique de l'etat des noeuds            .
c . arenoe . es  . nouvno . arete liee a un nouveau noeud              .
c . famnoe . es  . nouvno . famille des noeuds                         .
c . hetare . es  . nouvar . historique de l'etat des aretes            .
c . somare . es  .2*nouvar. numeros des extremites d'arete             .
c . filare . es  . nouvar . premiere fille des aretes                  .
c . merare . es  . nouvar . mere des aretes                            .
c . famare . es  . nouvar . famille des aretes                         .
c . aretri . e   .nouvtr*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nouvqu*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nouvqu . premier fils des quadrangles               .
c . hettet . es  . nouvte . historique de l'etat des tetraedres        .
c . aretet . es  .nouvta*6. numeros des 6 aretes des tetraedres        .
c . filtet . es  . nouvte . premier fils des tetraedres                .
c . pertet . es  . nouvte . pere des tetraedres                        .
c .        .     .        . si pertet(i) > 0 : numero du tetraedre     .
c .        .     .        . si pertet(i) < 0 : -numero dans pthepe     .
c . famtet . es  . nouvte . famille des tetraedres                     .
c . pthepe . es  .    *   . si i <= nbheco : numero de l'hexaedre      .
c .        .     .        . si non : numero du pentaedre               .
c . hetpyr . es  . nouvpy . historique de l'etat des pyramides         .
c . arepyr . es  .nouvya*8. numeros des 8 aretes des pyramides         .
c . filpyr . es  . nouvpy . premier fils des pyramides                 .
c . perpyr . es  . nouvpy . pere des pyramides                         .
c .        .     .        . si perpyr(i) > 0 : numero de la pyramide   .
c .        .     .        . si perpyr(i) < 0 : -numero dans pphepe     .
c . fampyr . es  . nouvpy . famille des pyramides                      .
c . pphepe . es  .    *   . si i <= nbheco : numero de l'hexaedre      .
c .        .     .        . si non : numero du pentaedre               .
c . quahex . e   .nouvhf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nouvhf*6. codes des 6 quadrangles des hexaedres      .
c . arehex . es  .nouvha12. numeros des 12 aretes des hexaedres        .
c . hethex . es  . nouvhe . historique de l'etat des hexaedres         .
c . perhex . es  . nouvhe . pere des hexaedres                         .
c . filhex . es  . nouvhe . premier fils des hexaedres                 .
c . fhpyte . es  .2*nbheco. fhpyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille de l'hexaedre k tel que filhex(k) =-j.
c .        .     .        . fhpyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils de l'hexaedre k tel que filhex(k) = -j.
c . famhex . es  . nouvhe . famille des hexaedres                      .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
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
      parameter ( nompro = 'CMCDHE' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "dicfen.h"
#include "nbfami.h"
#include "nouvnb.h"
#include "nombhe.h"
#include "hexcf0.h"
#include "hexcf1.h"
#include "ope002.h"
c
c 0.3. ==> arguments
c
      integer indnoe, indare, indtet, indpyr, indhex
      integer hetnoe(nouvno), arenoe(nouvno)
      integer famnoe(nouvno)
      integer hetare(nouvar), somare(2,nouvar)
      integer filare(nouvar), merare(nouvar), famare(nouvar)
      integer aretri(nouvtr,3)
      integer arequa(nouvqu,4)
      integer filqua(nouvqu)
      integer hettet(nouvte), aretet(nouvta,6)
      integer filtet(nouvte), pertet(nouvte), famtet(nouvte)
      integer pthepe(*)
      integer hetpyr(nouvpy), arepyr(nouvya,8)
      integer filpyr(nouvpy), perpyr(nouvpy), fampyr(nouvpy)
      integer quahex(nouvhf,6), coquhe(nouvhf,6), arehex(nouvha,12)
      integer pphepe(*)
      integer hethex(nouvhe)
      integer filhex(nouvhe), perhex(nouvhe), fhpyte(2,nbheco)
      integer cfahex(nctfhe,nbfhex), famhex(nouvhe)
c
      double precision coonoe(nouvno,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "hexcf3.h"
c
      integer iaux
      integer decbin, decbrf
      integer lehexa, lehexo
      integer nbfihe
      integer listso(8), listar(12)
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. intialisations
c====
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Code binaire du decoupage     :'',i5)'
      texte(1,5) = '(''==> Code binaire de reference :'',i5)'
      texte(1,6) = '(''Permutation :'',i5)'
      texte(1,7) = '(''Nouvel etat de l''''hexaedre :'',i5)'
c
      texte(2,4) = '(''Binary code for the cutting:'',i5)'
      texte(2,5) = '(''==> reference binary code  :'',i5)'
      texte(2,6) = '(''Permutation:'',i5)'
      texte(2,7) = '(''New status for the hexahedron:'',i5)'
c
#include "impr03.h"
#include "impr04.h"
c
c 1.2. ==> variables de travail
c
      codret = 0
c
      nbfihe = 0
c
#include "hexcf2.h"
c
c Parcours des hexaedres actifs
c
      do 200 , lehexo = 1 , permhe
c
        lehexa = lehexo
c
        if ( codret.eq.0 ) then
c
cgn        write(ulsort,90015) 'hethex(', lehexa,') =',hethex(lehexa)
c
        if ( mod(hethex(lehexa),1000).eq.0 ) then
cgn      if ( lehexa.le.-12 ) then
cgn       write(ulsort,90002) 'faces', (quahex(lehexa,iaux),iaux=1,6)
cgn       write(ulsort,90002) 'codes', (coquhe(lehexa,iaux),iaux=1,6)
cgn      endif
c
c====
c 2. Recherche des etats des aretes de l'hexaedre
c====
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'UTARHE', nompro
#endif
          call utarhe ( lehexa,
     >                  nouvqu, nouvhf,
     >                  arequa, quahex, coquhe,
     >                  listar )
c
          decbin = 0
          do 21 , iaux = 1, 12
cgn      write(ulsort,90015) 'hetare(',listar(iaux), ') =',
cgn     >                    hetare(listar(iaux))
            if ( mod(hetare(listar(iaux)),10).eq.2 .or.
     >           mod(hetare(listar(iaux)),10).eq.9 ) then
              decbin = decbin + 2**(iaux-1)
            endif
   21     continue
c
          decbrf = chbirf(decbin)
c
          if ( decbrf.gt.0 .and. decbrf.lt.4095 ) then
c
#ifdef _DEBUG_HOMARD_
      if ( lehexa.le.-12 ) then
        write (ulsort,texte(langue,4)) decbin
        write (ulsort,texte(langue,5)) decbrf
        write (ulsort,texte(langue,6)) chperm(decbin)
      endif
#endif
cgn       write(15,*) 'Classe', chclas(decbin)
c
c====
c 3. Les numeros globaux apres permutation
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSOHE', nompro
#endif
          call utsohe ( somare, listar, listso )
c
#include "hexcf4.h"
c
c====
c 4. L'etat final de l'hexaedre
c====
c
          hethex(lehexa) = hethex(lehexa) + chetat(decbin)
#ifdef _DEBUG_HOMARD_
      if ( lehexa.le.-12 ) then
          write (ulsort,texte(langue,7)) hethex(lehexa)
      endif
#endif
c
c====
c 5. La filiation : avec ou sans hexaedres ?
c====
c
cgn          write(ulsort,*) 'chnhe(',decbin,')=',chnhe(decbin)
          if ( chnhe(decbin).gt.0 ) then
c
            filhex(lehexa) = indhex + 1
c
          else
c
            nbfihe = nbfihe + 1
            filhex(lehexa) = -nbfihe
cgn            write(ulsort,90002)'nbfihe ',nbfihe
c
            fhpyte(1,nbfihe) = 0
            fhpyte(2,nbfihe) = 0
c
            if ( nouvpy.ne.0 ) then
              pphepe(nbfihe) = lehexa
              if ( chnpy(decbin).gt.0 ) then
                fhpyte(1,nbfihe) = indpyr + 1
              endif
            endif
c
            if ( nouvte.ne.0 ) then
              pthepe(nbfihe) = lehexa
              if ( chnte(decbin).gt.0 ) then
                fhpyte(2,nbfihe) = indtet + 1
              endif
            endif
c
#ifdef _DEBUG_HOMARD_
          write(ulsort,90002)'nbfihe',nbfihe
          write(ulsort,90002)'fhpyte',fhpyte(1,nbfihe),fhpyte(2,nbfihe)
#endif
c
          endif
c
c====
c 6. Parcours des differents modes de decoupage
c====
c
c 6.1 ==> Classe 1/00
c
      if ( decbrf.eq.1) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH100', nompro
#endif
        call cmh100 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.2 ==> Classe 2/00
c
      elseif ( decbrf.eq.65) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH200', nompro
#endif
        call cmh200 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.3 ==> Classe 2/01
c
      elseif ( decbrf.eq.129) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH201', nompro
#endif
        call cmh201 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.4 ==> Classe 2/02
c
      elseif ( decbrf.eq.2049) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH202', nompro
#endif
        call cmh202 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.5 ==> Classe 2/03
c
      elseif ( decbrf.eq.3) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH203', nompro
#endif
        call cmh203 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.6 ==> Classe 2/04
c
      elseif ( decbrf.eq.9) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH204', nompro
#endif
        call cmh204 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.7 ==> Classe 3/00
c
      elseif ( decbrf.eq.1089) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH300', nompro
#endif
        call cmh300 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.8 ==> Classe 3/01
c
      elseif ( decbrf.eq.641) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH301', nompro
#endif
        call cmh301 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.9 ==> Classe 3/02
c
      elseif ( decbrf.eq.19) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH302', nompro
#endif
        call cmh302 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.10 ==> Classe 3/03
c
      elseif ( decbrf.eq.259) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH303', nompro
#endif
        call cmh303 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.11 ==> Classe 3/04
c
      elseif ( decbrf.eq.515) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH304', nompro
#endif
        call cmh304 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.12 ==> Classe 3/05
c
      elseif ( decbrf.eq.1027) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH305', nompro
#endif
        call cmh305 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.13 ==> Classe 3/06
c
      elseif ( decbrf.eq.2051) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH306', nompro
#endif
        call cmh306 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.14 ==> Classe 3/07
c
      elseif ( decbrf.eq.35) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH307', nompro
#endif
        call cmh307 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.15 ==> Classe 3/08
c
      elseif ( decbrf.eq.67) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH308', nompro
#endif
        call cmh308 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.16 ==> Classe 3/09
c
      elseif ( decbrf.eq.131) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH309', nompro
#endif
        call cmh309 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.17 ==> Classe 3/10
c
      elseif ( decbrf.eq.265) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH310', nompro
#endif
        call cmh310 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.18 ==> Classe 3/11
c
      elseif ( decbrf.eq.521) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH311', nompro
#endif
        call cmh311 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.19 ==> Classe 4/00
c
      elseif ( decbrf.eq.15) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH400', nompro
#endif
        call cmh400 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.20 ==> Classe 4/01
c
      elseif ( decbrf.eq.771) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH401', nompro
#endif
        call cmh401 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.21 ==> Classe 4/02
c
      elseif ( decbrf.eq.1283) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH402', nompro
#endif
        call cmh402 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.22 ==> Classe 4/03
c
      elseif ( decbrf.eq.2563) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH403', nompro
#endif
        call cmh403 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.23 ==> Classe 4/04
c
      elseif ( decbrf.eq.3075) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH404', nompro
#endif
        call cmh404 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.24 ==> Classe 4/05
c
      elseif ( decbrf.eq.163) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH405', nompro
#endif
        call cmh405 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.25 ==> Classe 4/06
c
      elseif ( decbrf.eq.195) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH406', nompro
#endif
        call cmh406 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.26 ==> Classe 4/07
c
      elseif ( decbrf.eq.387) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH407', nompro
#endif
        call cmh407 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.27 ==> Classe 4/08
c
      elseif ( decbrf.eq.643) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH408', nompro
#endif
        call cmh408 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.28 ==> Classe 4/09
c
      elseif ( decbrf.eq.2083) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH409', nompro
#endif
        call cmh409 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.29 ==> Classe 4/10
c
      elseif ( decbrf.eq.1091) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH410', nompro
#endif
        call cmh410 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.30 ==> Classe 4/11
c
      elseif ( decbrf.eq.99) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH411', nompro
#endif
        call cmh411 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.31 ==> Classe 4/12
c
      elseif ( decbrf.eq.2307) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH412', nompro
#endif
        call cmh412 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.32 ==> Classe 4/13
c
      elseif ( decbrf.eq.1539) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH413', nompro
#endif
        call cmh413 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.33 ==> Classe 4/14
c
      elseif ( decbrf.eq.1155) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH414', nompro
#endif
        call cmh414 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.34 ==> Classe 4/15
c
      elseif ( decbrf.eq.2179) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH415', nompro
#endif
        call cmh415 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.35 ==> Classe 4/16
c
      elseif ( decbrf.eq.147) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH416', nompro
#endif
        call cmh416 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.36 ==> Classe 4/17
c
      elseif ( decbrf.eq.1545) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH417', nompro
#endif
        call cmh417 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.37 ==> Classe 4/18
c
      elseif ( decbrf.eq.2313) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH418', nompro
#endif
        call cmh418 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.38 ==> Classe 5/00
c
      elseif ( decbrf.eq.2211) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH500', nompro
#endif
        call cmh500 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.39 ==> Classe 5/01
c
      elseif ( decbrf.eq.1219) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH501', nompro
#endif
        call cmh501 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.40 ==> Classe 5/02
c
      elseif ( decbrf.eq.2435) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH502', nompro
#endif
        call cmh502 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.41 ==> Classe 5/03
c
      elseif ( decbrf.eq.1667) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH503', nompro
#endif
        call cmh503 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.42 ==> Classe 5/04
c
      elseif ( decbrf.eq.227) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH504', nompro
#endif
        call cmh504 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.43 ==> Classe 5/05
c
      elseif ( decbrf.eq.899) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH505', nompro
#endif
        call cmh505 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.44 ==> Classe 5/06
c
      elseif ( decbrf.eq.675) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH506', nompro
#endif
        call cmh506 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.45 ==> Classe 5/07
c
      elseif ( decbrf.eq.451) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH507', nompro
#endif
        call cmh507 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.46 ==> Classe 5/08
c
      elseif ( decbrf.eq.1123) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH508', nompro
#endif
        call cmh508 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.47 ==> Classe 5/09
c
      elseif ( decbrf.eq.2147) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH509', nompro
#endif
        call cmh509 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.48 ==> Classe 5/10
c
      elseif ( decbrf.eq.1171) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH510', nompro
#endif
        call cmh510 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.49 ==> Classe 5/11
c
      elseif ( decbrf.eq.31) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH511', nompro
#endif
        call cmh511 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.50 ==> Classe 5/12
c
      elseif ( decbrf.eq.271) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH512', nompro
#endif
        call cmh512 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.51 ==> Classe 6/00
c
      elseif ( decbrf.eq.3219) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH600', nompro
#endif
        call cmh600 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.52 ==> Classe 6/01
c
      elseif ( decbrf.eq.783) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH601', nompro
#endif
        call cmh601 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.53 ==> Classe 6/02
c
      elseif ( decbrf.eq.2319) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH602', nompro
#endif
        call cmh602 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.54 ==> Classe 6/03
c
      elseif ( decbrf.eq.1055) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH603', nompro
#endif
        call cmh603 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.55 ==> Classe 6/04
c
      elseif ( decbrf.eq.2079) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH604', nompro
#endif
        call cmh604 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.56 ==> Classe 6/05
c
      elseif ( decbrf.eq.159) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH605', nompro
#endif
        call cmh605 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.57 ==> Classe 6/06
c
      elseif ( decbrf.eq.3171) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH606', nompro
#endif
        call cmh606 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.58 ==> Classe 6/07
c
      elseif ( decbrf.eq.2723) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH607', nompro
#endif
        call cmh607 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.59 ==> Classe 6/08
c
      elseif ( decbrf.eq.1475) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH608', nompro
#endif
        call cmh608 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.60 ==> Classe 7/00
c
      elseif ( decbrf.eq.319) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH700', nompro
#endif
        call cmh700 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.61 ==> Classe 7/01
c
      elseif ( decbrf.eq.3103) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH701', nompro
#endif
        call cmh701 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.62 ==> Classe 8/00
c
      elseif ( decbrf.eq.3855) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH800', nompro
#endif
        call cmh800 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.63 ==> Classe 8/01
c
      elseif ( decbrf.eq.2367) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH801', nompro
#endif
        call cmh801 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
c
c 6.64 ==> Classe 9/00
c
      elseif ( decbrf.eq.895) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMH900', nompro
#endif
        call cmh900 ( lehexa,
     >              indnoe, indare, indtet, indpyr, indhex, nbfihe,
     >              hepers(1,chperm(decbin)), hepera(1,chperm(decbin)),
     >              heperf(1,chperm(decbin)), heperc(1,chperm(decbin)),
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              aretri,
     >              arequa, filqua,
     >              hettet, aretet,
     >              filtet, pertet, famtet,
     >              hetpyr, arepyr,
     >              filpyr, perpyr, fampyr,
     >              hethex, arehex,
     >              filhex, perhex, famhex,
     >              cfahex,
     >              ulsort, langue, codret )
      endif
c
        endif
c
        endif
c
        endif
c
  200 continue
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

