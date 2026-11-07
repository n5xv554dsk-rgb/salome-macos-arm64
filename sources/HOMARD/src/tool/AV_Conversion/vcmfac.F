      subroutine vcmfac ( aretri, hettri,
     >                    filtri, pertri, nivtri,
     >                    nintri,
     >                    coextr, ntrsho, ntrsca,
     >                    arequa, hetqua,
     >                    filqua, perqua, nivqua,
     >                    ninqua,
     >                    coexqu, nqusho, nqusca,
     >                    tritet, hettet,
     >                    filtet, pertet,
     >                    coexte, ntesho, ntesca,
     >                    quahex, hethex,
     >                    filhex, perhex, ninhex,
     >                    coexhe, nhesho, nhesca,
     >                    facpen, hetpen,
     >                    filpen, perpen,
     >                    coexpe, npesho, npesca,
     >                    facpyr, hetpyr,
     >                    filpyr, perpyr,
     >                    coexpy, npysho, npysca,
     >                    areele, noeele, typele, fameel,
     >                    vofaar, povoar, prefac, dejavu,
     >                    somare, nnosho, nnosca,
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
c    aVant adaptation - Conversion de Maillage - FACes
c     -                 -             -          ---
c ______________________________________________________________________
c
c but : etablit la table de connectivite des elements par face
c       et initialise les tableaux lies aux faces
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . aretri .  s  .nbtr00*3. numeros des 3 aretes des triangles         .
c . hettri .  s  . nbtr00 . historique de l'etat des triangles         .
c . filtri .  s  . nbtr00 . premier fils des triangles                 .
c . pertri .  s  . nbtr00 . pere des triangles                         .
c . nivtri .  s  . nbtr00 . niveau des triangles                       .
c . nintri .  s  . nbtr00 . noeud interne au triangle                  .
c . coextr .  s  . nbtr00*. codes externes sur les triangles           .
c .        .     . nctftr .   1 : famille MED                          .
c .        .     .        .   2 : type de triangle                     .
c . ntrsho .  s  . rstrac . numero des triangles dans HOMARD           .
c . ntrsca .  s  . rbtr00 . numero des triangles du calcul             .
c . arequa .  s  .nbqu00*4. numeros des 4 aretes des quadrangles       .
c . hetqua .  s  . nbqu00 . historique de l'etat des quadrangles       .
c . filqua .  s  . nbqu00 . premier fils des quadrangles               .
c . perqua .  s  . nbqu00 . pere des quadrangles                       .
c . nivqua .  s  . nbqu00 . niveau des quadrangles                     .
c . ninqua .  s  . nbqu00 . noeud interne au quadrangle                .
c . coexqu .  s  . nbqu00*. codes externes sur les quadrangles         .
c .        .     . nctfqu .   1 : famille MED                          .
c .        .     .        .   2 : type de quadrangle                   .
c . nqusho .  s  . rsquac . numero des quadrangles dans HOMARD         .
c . nqusca .  s  . rbqu00 . numero des quadrangles du calcul           .
c . tritet .  s  .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . hettet .  s  . nbteto . historique de l'etat des tetraedres        .
c . filtet .  s  . nbteto . premier fils des tetraedres                .
c . pertet .  s  . nbteto . pere des tetraedres                        .
c .        .     .        . si pertet(i) > 0 : numero du tetraedre     .
c .        .     .        . si pertet(i) < 0 : -numero dans pthepe     .
c . coexte .  s  . nbteto*. codes externes sur les tetraedres          .
c .        .     . nctfte .   1 : famille MED                          .
c .        .     .        .   2 : type de tetraedres                   .
c . ntesho .  s  . rsteac . numero des tetraedres dans HOMARD          .
c . ntesca .  s  . rsteto . numero des tetraedres dans le calcul       .
c . quahex .  s  .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . hethex .  s  . nbheto . historique de l'etat des hexaedres         .
c . filhex .  s  . nbheto . premier fils des hexaedres                 .
c . perhex .  s  . nbheto . pere des hexaedres                         .
c . ninhex .  s  . nbheto . noeud interne a l'hexaedre                 .
c . coexhe .  s  . nbheto*. codes externes sur les hexaedres           .
c .        .     . nctfhe .   1 : famille MED                          .
c .        .     .        .   2 : type de hexaedres                    .
c . nhesho .  s  . rsheac . numero des hexaedres dans HOMARD           .
c . nhesca .  s  . rsheto . numero des hexaedres dans le calcul        .
c . facpen .  s  .nbpecf*5. numeros des 5 faces des pentaedres         .
c . hetpen .  s  . nbpeto . historique de l'etat des pentaedres        .
c . filpen .  s  . nbpeto . premier fils des pentaedres                .
c . perpen .  s  . nbpeto . pere des pentaedres                        .
c . coexpe .  s  . nbpeto*. codes externes sur les pentaedres          .
c .        .     . nctfpe .   1 : famille MED                          .
c .        .     .        .   2 : type de pentaedres                   .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
c . npesho .  s  . rspeac . numero des pentaedres dans HOMARD          .
c . npesca .  s  . rspeto . numero des pentaedres dans le calcul       .
c . facpyr .  s  .nbpycf*5. numeros des 5 faces des pyramides          .
c . hetpyr .  s  . nbpyto . historique de l'etat des pyramides         .
c . coexpy .  s  . nbpyto*. codes externes sur les pyramides           .
c .        .     . nctfpy .   1 : famille MED                          .
c .        .     .        .   2 : type de pyramides                    .
c . filpyr .  s  . nbpyto . premier fils des pyramides                 .
c . perpyr .  s  . nbpyto . pere des pyramides                         .
c .        .     .        . si perpyr(i) > 0 : numero de la pyramide   .
c .        .     .        . si perpyr(i) < 0 : -numero dans pphepe     .
c . npyrho .  s  . repyac . numero des pyramides dans HOMARD           .
c . npyrca .  s  .   *    . numero des pyramides dans le calcul        .
c . areele . e   . nbelem . aretes des elements                        .
c .        .     .*nbmaae .                                            .
c . noeele . e   . nbelem . noeuds des elements                        .
c .        .     .*nbmane .                                            .
c . typele . e   . nbelem . type des elements pour le code de calcul   .
c . fameel . e   . nbelem . famille med des elements                   .
c . vofaar . e   . nvoare . voisins des aretes en stockage morse       .
c . povoar . e   .0:nbarto. pointeur des voisins par arete             .
c . prefac .  a  .2*nbarto. premiere face partant d'une arete          .
c . dejavu .  a  .  2* *  . controle des doublons                      .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . nnosho . e   . rsnoac . numero des noeuds dans HOMARD              .
c . nnosca . e   . rsnoto . numero des noeuds dans le calcul           .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 3 : probleme                               .
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
      parameter ( nompro = 'VCMFAC' )
c
#include "coftex.h"
#include "referx.h"
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "dicfen.h"
#include "envca1.h"
#include "nbutil.h"
#include "refere.h"
#include "refert.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpe.h"
#include "nombpy.h"
#include "nombsr.h"
#include "nomest.h"
#include "nancnb.h"
#include "envada.h"
#include "rftmed.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer aretri(nbtr00,3), hettri(nbtr00)
      integer filtri(nbtr00), pertri(nbtr00), nivtri(nbtr00)
      integer nintri(nbtr00)
      integer coextr(nbtr00,nctftr)
      integer ntrsho(rstrac), ntrsca(rbtr00)
c
      integer arequa(nbqu00,4), hetqua(nbqu00)
      integer filqua(nbqu00), perqua(nbqu00), nivqua(nbqu00)
      integer ninqua(nbqu00)
      integer coexqu(nbqu00,nctfqu)
      integer nqusho(rsquac), nqusca(rbqu00)
c
      integer tritet(nbtecf,4), hettet(nbteto)
      integer filtet(nbteto), pertet(nbteto)
      integer coexte(nbteto,nctfte)
      integer ntesho(rsteac), ntesca(rsteto)
c
      integer quahex(nbhecf,6), hethex(nbheto)
      integer filhex(nbheto), perhex(nbheto), ninhex(nbheto)
      integer coexhe(nbheto,nctfhe)
      integer nhesho(rsheac), nhesca(rsheto)
c
      integer facpen(nbpecf,5), hetpen(nbpeto)
      integer filpen(nbpeto), perpen(nbpeto)
      integer coexpe(nbpeto,nctfpe)
      integer npesho(rspeac), npesca(rspeto)
c
      integer facpyr(nbpycf,5), hetpyr(nbpyto)
      integer filpyr(nbpyto), perpyr(nbpyto)
      integer coexpy(nbpyto,nctfpy)
      integer npysho(rspyac), npysca(rspyto)
c
      integer areele(nbelem,nbmaae)
      integer noeele(nbelem,nbmane), typele(nbelem), fameel(nbelem)
      integer vofaar(nvoare), povoar(0:nbarto), prefac(2,nbarto)
      integer dejavu(2,*)
      integer somare(2,nbarto)
      integer nnosho(rsnoac), nnosca(rsnoto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux(4)
      integer poinde, poinfi, point
      integer nbfa, nbar, nbarfa
      integer ar, aloc, bloc, cloc
      integer aglmin, larete
      integer f, fa, floc, nufa
      integer letria, lequad, letetr, tetr, tetrae
      integer hexa, lehexa, hexae
      integer lepent, penta
      integer lapyra, pyram
      integer numloc(4), elem, typhom, nucode
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
c 1. preliminaires
c====
c
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(//,''Examen de l''''arete :'',i10)'
      texte(1,5) =
     >'(/,''. Element voisin numero calcul'',i10,'', de type HOMARD'',
     >i8)'
      texte(1,6) = '(''.. Ses aretes : '',12i10)'
      texte(1,7) = '(''... Examen de sa face de rang'',i2)'
      texte(1,8) = '(''... Ses aretes '',a,'' : '',12i10)'
      texte(1,9) = '(''... Creation du '',a,i10)'
      texte(1,10) = '(''... Reperage du '',a,i10)'
      texte(1,11) = '(''Les deux elements suivants sont doubles :'')'
      texte(1,12) = '(''Numero dans le calcul   :'',i10)'
      texte(1,13) = '(''Famille MED : '',i4,'' ; type : '',i4)'
      texte(1,14) = '(''Aretes (numero HOMARD)         : '',6i10)'
      texte(1,15) = '(''Noeuds (numero dans le calcul) : '',4i10)'
c
      texte(2,4) = '(//,''Examination of edge # :'',i10)'
      texte(2,5) =
     > '(/,''. Neighbour element #'',i10,'', with HOMARD type'',i8)'
      texte(2,6) = '(''.. Its edges : '',12i10)'
      texte(2,7) = '(''... Examination of face #'',i2)'
      texte(2,8) = '(''... Its edges '',a,'' : '',12i10)'
      texte(2,9) = '(''... Creation of '',a,'' #'',i10)'
      texte(2,10) = '(''... Tracking of '',a,'' #'',i10)'
      texte(2,11) = '(/,''The following two elements are double:'')'
      texte(2,12) = '(''# in calculation    :'',i10)'
      texte(2,13) = '(''MED family : '',i4,'' ; type : '',i4)'
      texte(2,14) = '(''Edges (HOMARD #)      : '',6i10)'
      texte(2,15) = '(''Nodes (calculation #) : '',4i10)'
c
#include "impr03.h"
c
c 1.2. ==> mise a zero
c
      codret = 0
c
      nbtrto = 0
      nbquto = 0
c
c 1.2.1. ==> aretes
c
      do 121 , larete = 1 , nbarto
        prefac(1,larete) = 0
        prefac(2,larete) = 0
  121 continue
c
c 1.2.2. ==> triangles
c
      if ( nbtr00.ne.0 ) then
c
        do 1221 , letria = 1 , rstrac
          ntrsho(letria) = 0
 1221   continue
c
        do 1222 , nucode = 1 , nctftr
          do 1223 , letria = 1 , nbtr00
            coextr(letria,nucode) = 0
 1223     continue
 1222   continue
c
        do 1224 , letria = 1 , rbtr00
          dejavu(1,letria) = 0
 1224   continue
c
      endif
c
c 1.2.3. ==> quadrangles
c
      if ( nbqu00.ne.0 ) then
c
        do 1231 , lequad = 1 , rsquac
          nqusho(lequad) = 0
 1231   continue
c
        do 1232 , nucode = 1 , nctfqu
          do 1233 , lequad = 1 , nbqu00
            coexqu(lequad,nucode) = 0
 1233     continue
 1232   continue
c
        do 1234 , lequad = 1 , rbqu00
          dejavu(2,lequad) = 0
 1234   continue
c
      endif
c
c 1.2.4. ==> tetraedres
c
      if ( nbteto .ne. 0 ) then
c
        do 1241 , tetr = 1 , rsteto
          ntesca(tetr) = 0
 1241   continue
c
        do 1242 , tetr = 1 , rsteac
          ntesho(tetr) = 0
 1242   continue
c
        do 1243 , nucode = 1 , nctfte
          do 1244 , letetr = 1 , nbteto
            coexte(letetr,nucode) = 0
 1244     continue
 1243   continue
c
        letetr = 0
c
      endif
c
c 1.2.5. ==> hexaedres
c
      if ( nbheto .ne. 0 ) then
c
        do 1251 , hexa = 1 , rsheto
          nhesca(hexa) = 0
 1251   continue
c
        do 1252 , hexa = 1 , rsheac
          nhesho(hexa) = 0
 1252   continue
c
        do 1253 , nucode = 1 , nctfhe
          do 1254 , lehexa = 1 , nbheto
            coexhe(lehexa,nucode) = 0
 1254     continue
 1253   continue
c
        lehexa = 0
c
      endif
c
c 1.2.6. ==> pentaedres
c
      if ( nbpeto .ne. 0 ) then
c
        do 1261 , lepent = 1 , rspeto
          npesca(lepent) = 0
 1261   continue
c
        do 1262 , lepent = 1 , rspeac
          npesho(lepent) = 0
 1262   continue
c
        do 1263 , nucode = 1 , nctfpe
          do 1264 , lepent = 1 , nbpeto
            coexpe(lepent,nucode) = 0
 1264     continue
 1263   continue
c
        lepent = 0
c
      endif
c
c 1.2.7. ==> pyramides
c
      if ( nbpyto .ne. 0 ) then
c
        do 1271 , lapyra = 1 , rspyto
          npysca(lapyra) = 0
 1271   continue
c
        do 1272 , lapyra = 1 , rspyac
          npysho(lapyra) = 0
 1272   continue
c
        do 1273 , nucode = 1 , nctfpy
          do 1274 , lapyra = 1 , nbpyto
            coexpy(lapyra,nucode) = 0
 1274     continue
 1273   continue
c
        lapyra = 0
c
      endif
c
c====
c 2. on passe en revue chaque arete
c    ses elements voisins sont dans le tableau vofaar, aux places
c    comprises entre povoar(larete-1)+1 et povoar(larete)
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbarto', nbarto
#endif
cgn      do 2222,elem=1,20
cgn        print *,elem,somare(1,elem),somare(2,elem)
cgn 2222 continue
cgn       nbar = 12
cgn       elem = 1
cgn        write (ulsort,texte(langue,5)) elem, 11
cgn        write (ulsort,texte(langue,6)) (areele(elem,ar),ar=1,nbar)
cgn       elem = 2
cgn        write (ulsort,texte(langue,5)) elem, 11
cgn        write (ulsort,texte(langue,6)) (areele(elem,ar),ar=1,nbar)
c
      poinfi = 0
      do 21 , larete = 1 , nbarto
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        if ( larete.gt.0 ) then
          glop = 1
        else
          glop = 0
        endif
#endif
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,texte(langue,4)) larete
        endif
#endif
c
      poinde = poinfi + 1
      poinfi = povoar(larete)
c
      do 22 , point = poinde , poinfi
c
        if ( codret.eq.0 ) then
c
c 2.1. ==> caracterisation de l'element
c      elem : son numero global
c      typhom : son type dans HOMARD
c      nbar : son nombre d'aretes
c      nbfa : le nombre de faces qui s'appuient sur l'arete en cours
c      si c'est un element 1d, donc sans face, rien n'est a faire
c
        elem = vofaar(point)
        typhom = medtrf(typele(elem))
        nbar = nbaref(typhom)
        nbfa = nfaref(typhom)
c
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,texte(langue,5)) elem, typhom
        write (ulsort,texte(langue,6)) (areele(elem,ar),ar=1,nbar)
        endif
#endif
c
        if ( nbfa.gt.0 ) then
c
c 2.2. ==> recherche de aloc, numero local de l'arete en cours d'examen
c          vis-a-vis de la description de l'element de reference
c
        do 221 , ar = 1 , nbar
          if ( larete.eq.areele(elem,ar) ) then
            aloc = ar
            goto 2211
          endif
  221   continue
c
 2211   continue
c
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
      write (ulsort,*) '.. Numero local de l''arete ',larete,' : ', aloc
        endif
#endif
c
c 2.3. ==> on explore toutes les faces qui s'appuient sur cette arete
c          de numero local aloc
c
        do 223 , f = 1 , nbfa
c
c========= debut de if ( codret.eq.0 ) debut 223 ===========
          if ( codret.eq.0 ) then
c========= debut de if ( codret.eq.0 ) debut 223 ===========
c
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
          write (ulsort,texte(langue,7)) f
        endif
#endif
c
c 2.3.1. ==> on cherche les numeros locaux et globaux des autres aretes
c
          floc = faaref(typhom,aloc,f)
          nbarfa = nafref(typhom,floc)
          numloc(1) = aloc
ccc          	write(*,*) 'dans vcmfac',typhom
c
          aglmin = nbarto
          do 231 , ar = 1 , nbarfa
            bloc = defref(typhom,floc,ar)
            if ( bloc.ne.aloc ) then
              aglmin = min( aglmin, areele(elem,bloc) )
            endif
  231     continue
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
            write (ulsort,*) 'aglmin = ', aglmin
        endif
#endif
c
c 2.3.1.1. ==> face triangulaire
c
c========= debut de if ( nbarfa.eq.3 ) then ===========
          if ( nbarfa.eq.3 ) then
c========= debut de if ( nbarfa.eq.3 ) then ===========
c
            if ( defref(typhom,floc,1).eq.aloc ) then
              bloc = defref(typhom,floc,2)
              cloc = defref(typhom,floc,3)
            else if ( defref(typhom,floc,2).eq.aloc ) then
              bloc = defref(typhom,floc,3)
              cloc = defref(typhom,floc,1)
            else
              bloc = defref(typhom,floc,1)
              cloc = defref(typhom,floc,2)
            endif
c
            if ( areele(elem,bloc).lt.areele(elem,cloc) ) then
              numloc(2) = bloc
              numloc(3) = cloc
            else
              numloc(2) = cloc
              numloc(3) = bloc
            endif
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
            write (ulsort,texte(langue,8)) 'numloc',
     >      numloc(1), numloc(2), numloc(3)
        endif
#endif
c
c 2.3.1.2. ==> face quadrangulaire
c
          else
c
cccc            if ( nbfa.eq.1 ) then
c
            if ( defref(typhom,floc,1).eq.aloc ) then
              numloc(2) = defref(typhom,floc,2)
              numloc(3) = defref(typhom,floc,3)
              numloc(4) = defref(typhom,floc,4)
cgn              write(*,*) 1,numloc
            else if ( defref(typhom,floc,2).eq.aloc ) then
              numloc(2) = defref(typhom,floc,3)
              numloc(3) = defref(typhom,floc,4)
              numloc(4) = defref(typhom,floc,1)
cgn              write(*,*) 2,numloc
            else if ( defref(typhom,floc,3).eq.aloc ) then
              numloc(2) = defref(typhom,floc,4)
              numloc(3) = defref(typhom,floc,1)
              numloc(4) = defref(typhom,floc,2)
cgn              write(*,*) 3,numloc
            else
              numloc(2) = defref(typhom,floc,1)
              numloc(3) = defref(typhom,floc,2)
              numloc(4) = defref(typhom,floc,3)
cgn              write(*,*) 4,numloc
            endif
c
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
            write (ulsort,texte(langue,8)) 'numloc',
     >      numloc(1), numloc(2), numloc(3), numloc(4)
        endif
#endif
c
cccc          endif
c
c========= fin de if ( nbarfa.eq.3 ) then ===========
          endif
c========= fin de if ( nbarfa.eq.3 ) then ===========
c
c 2.3.2. ==> si l'arete en cours d'examen a un numero global plus grand
c            que l'une au moins des autres aretes, rien n'est a
c            faire, car le traitement a deja ete fait lors de
c            l'exploration de l'arete de plus petit numero global
c
c========= debut de if ( larete.lt.aglmin ) then ===========
          if ( larete.lt.aglmin ) then
c========= debut de if ( larete.lt.aglmin ) then ===========
c
c 2.3.2.1. ==> si l'arete en cours d'examen a un numero global plus
c              petit que les deux autres aretes, il faut d'abord
c              chercher si la face contenant ces aretes n'a pas
c              deja ete creee. la recherche de la face ne se fait pas
c              parmi toutes les faces deja creees, mais seulement
c              parmi celles qui s'appuient sur l'arete en cours. la
c              premiere d'entre elles, si elle existe, est
c              numerotee nufa=prefac(1/2,larete). Ce sont les
c              dernieres faces qui viennent d'etre creees, donc la
c              recherche est rapide car elle ne porte que sur quelques
c              faces : au pire toutes celles contenant l'arete en cours.
c              si on trouve cette face, on memorise son numero.
c
c              attention : cela part du principe qu'a un triplet ou
c              quadruplet d'aretes correspond une face et une seule.
c              Donc, pas d'elements doubles. Si on libere cette
c              contrainte, tout se passe bien : il y a creation d'une
c              autre face au meme endroit. L'algorithme d'adaptation
c              marche bien. La consequence est que sur le maillage
c              raffine, les faces filles ne sont plus doubles : elles ne
c              partagent que les aretes filles des aretes de bord des
c              faces meres. Les aretes internes sont creees
c              independamment les unes des autres. En effet, dans cmrdtr
c              ou cmrdqu, on cree ces aretes en incrementant le compteur
c              des aretes. Il faudrait verifier que les aretes
c              n'existent pas deja. Or le tableau des voisinages est
c              encore inconnu. Donc il est certainement complique. Il
c              faudrait une recherche sur les aretes qui viennent d'etre
c              creees mais la lourdeur du traitement meriterait qu'on le
c              rende optionnel.
c
c 2.3.2.1.1. ==> face triangulaire
c
            if ( nbarfa.eq.3 ) then
c
              letria = 0
              nufa = prefac(1,larete)
              if ( nufa.ne.0 ) then
                do 2231 , fa = nufa , nbtrto
                  if ( aretri(fa,2).eq.areele(elem,numloc(2)) .and.
     >                 aretri(fa,3).eq.areele(elem,numloc(3)) ) then
                    letria = fa
                    goto 2239
                  endif
 2231           continue
              endif
c
c 2.3.2.1.2. ==> face quadrangulaire
c
            else
c
              lequad = 0
              nufa = prefac(2,larete)
              if ( nufa.ne.0 ) then
                do 2232 , fa = nufa , nbquto
                  if ( arequa(fa,2).eq.areele(elem,numloc(2)) .and.
     >                 arequa(fa,3).eq.areele(elem,numloc(3)) .and.
     >                 arequa(fa,4).eq.areele(elem,numloc(4)) ) then
                    lequad = fa
                    goto 2239
                  elseif ( arequa(fa,2).eq.areele(elem,numloc(4)) .and.
     >                     arequa(fa,3).eq.areele(elem,numloc(3)) .and.
     >                     arequa(fa,4).eq.areele(elem,numloc(2)) ) then
                    lequad = fa
                    goto 2239
                  endif
 2232           continue
              endif
c
            endif
c
 2239       continue
c
c 2.3.2.2. ==> lorsque la face n'a pas ete trouvee, il faut la creer ;
c              une seule caracteristique est introduite.
c              si la face n'est pas un element au sens du code de
c              calcul, la caracteristique est nulle et il n'y a pas de
c              probleme pour la renumerotation.
c
c 2.3.2.2.1. ==> face triangulaire
c
            if ( nbarfa.eq.3 ) then
c
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
          if ( letria.eq.0 ) then
          write (ulsort,texte(langue,9)) mess14(langue,1,2), nbtrto+1
          else
          write (ulsort,texte(langue,10)) mess14(langue,1,2), letria
          endif
        endif
#endif
c
              if ( letria.eq.0 ) then
                nbtrto = nbtrto + 1
                letria = nbtrto
                aretri(letria,1) = larete
                aretri(letria,2) = areele(elem,numloc(2))
                aretri(letria,3) = areele(elem,numloc(3))
                if ( mod(mailet,2).eq.0 ) then
                  nintri(letria) = 0
                endif
                if ( prefac(1,larete).eq.0 ) then
                  prefac(1,larete) = letria
                endif
                if ( nbfa.ne.1 ) then
                  coextr(letria,cofamd) = 0
                  coextr(letria,cotyel) = 0
                  if ( rbtr00.ne.0 ) then
                    ntrsca(letria) = 0
                  endif
                endif
              endif
c
#ifdef _DEBUG_HOMARD_
         if ( glop.ne.0 ) then
         write (ulsort,texte(langue,8)) 'homard', aretri(letria,1),
     >aretri(letria,2),aretri(letria,3)
         endif
#endif
c
c 2.3.2.2.2. ==> face quadrangulaire
c
            else
c
#ifdef _DEBUG_HOMARD_
         if ( glop.ne.0 ) then
          if ( lequad.eq.0 ) then
          write (ulsort,texte(langue,9)) mess14(langue,1,4), nbquto+1
          else
          write (ulsort,texte(langue,10)) mess14(langue,1,4), lequad
          endif
         endif
#endif
c
              if ( lequad.eq.0 ) then
                nbquto = nbquto + 1
                lequad = nbquto
                arequa(lequad,1) = larete
                arequa(lequad,2) = areele(elem,numloc(2))
                arequa(lequad,3) = areele(elem,numloc(3))
                arequa(lequad,4) = areele(elem,numloc(4))
                if ( mod(mailet,3).eq.0 ) then
                  ninqua(lequad) = 0
                endif
                if ( prefac(2,larete).eq.0 ) then
                  prefac(2,larete) = lequad
                endif
                if ( nbfa.ne.1 ) then
                  coexqu(lequad,cofamd) = 0
                  coexqu(lequad,cotyel) = 0
                  if ( rbqu00.ne.0 ) then
                    nqusca(lequad) = 0
                  endif
                endif
              endif
#ifdef _DEBUG_HOMARD_
         if ( glop.ne.0 ) then
          write (ulsort,texte(langue,8)) 'homard', arequa(lequad,1),
     >arequa(lequad,2),arequa(lequad,3),arequa(lequad,4)
         endif
#endif
c
            endif
c
c 2.3.2.3. ==> si la face est un element au sens du code de calcul, il
c              faut se souvenir de son type et de sa famille MED.
c              attention : il faut se poser la question a chaque fois
c              car la face a pu etre definie auparavant comme un bord
c              d'element volumique et donc aura ete mise avec des
c              caracteristiques nulles.
c              en revanche, si on y est deja passe pour un autre
c              element, il y a malaise : c'est un element double !
c
            if ( nbfa.eq.1 ) then
c
c 2.3.2.3.1. ==> face triangulaire
c
              if ( nbarfa.eq.3 ) then
c
              if ( dejavu(1,letria).ne.0 .and.
     >             dejavu(1,letria).ne.elem ) then
c
                jaux(1) = nnosca(somare(1,areele(elem,1)))
                jaux(2) = nnosca(somare(2,areele(elem,1)))
                iaux = nnosca(somare(1,areele(elem,2)))
                if ( iaux.ne.jaux(1) .and. iaux.ne.jaux(2) ) then
                  jaux(3) = iaux
                else
                  jaux(3) = nnosca(somare(2,areele(elem,2)))
                endif
                write(ulsort,texte(langue,11))
                write(ulsort,texte(langue,12)) elem
                write(ulsort,texte(langue,13)) fameel(elem),typele(elem)
                write(ulsort,texte(langue,14))
     >                  (areele(elem,iaux), iaux = 1 , nbar)
                write(ulsort,texte(langue,15)) (jaux(iaux),iaux=1,3)
c
                jaux(1) = nnosca(somare(1,areele(dejavu(1,letria),1)))
                jaux(2) = nnosca(somare(2,areele(dejavu(1,letria),1)))
                iaux = nnosca(somare(1,areele(dejavu(1,letria),2)))
                if ( iaux.ne.jaux(1) .and. iaux.ne.jaux(2) ) then
                  jaux(3) = iaux
                else
                  jaux(3) = nnosca(somare(2,areele(dejavu(1,letria),2)))
                endif
                write(ulsort,texte(langue,12)) dejavu(1,letria)
                write(ulsort,texte(langue,13)) fameel(dejavu(1,letria)),
     >                                        typele(dejavu(1,letria))
                write(ulsort,texte(langue,14))
     >                    (areele(dejavu(1,letria),iaux),iaux = 1,nbar)
                write(ulsort,texte(langue,15)) (jaux(iaux),iaux=1,3)
c
                codret = 3
c
              endif
c
              if ( mod(mailet,2).eq.0 ) then
                nintri(letria) = nnosho(noeele(elem,nbnref(typhom,3)))
              endif
              coextr(letria,cofamd) = fameel(elem)
              coextr(letria,cotyel) = typele(elem)
              ntrsho(elem) = letria
              ntrsca(letria) = elem
              dejavu(1,letria) = elem
c
c 2.3.2.3.2. ==> face quadrangulaire
c
              else
c
              if ( dejavu(2,lequad).ne.0 .and.
     >             dejavu(2,lequad).ne.elem ) then
c
                jaux(1) = nnosca(somare(1,areele(elem,1)))
                jaux(2) = nnosca(somare(2,areele(elem,1)))
                iaux = nnosca(somare(1,areele(elem,2)))
                if ( iaux.ne.jaux(1) .and. iaux.ne.jaux(2) ) then
                  jaux(3) = iaux
                else
                  jaux(3) = nnosca(somare(2,areele(elem,2)))
                endif
                iaux = nnosca(somare(1,areele(elem,3)))
                if ( iaux.ne.jaux(3) ) then
                  jaux(3) = iaux
                else
                  jaux(3) = nnosca(somare(2,areele(elem,3)))
                endif
                write(ulsort,texte(langue,11))
                write(ulsort,texte(langue,12)) elem
                write(ulsort,texte(langue,13)) fameel(elem),typele(elem)
                write(ulsort,texte(langue,14))
     >                  (areele(elem,iaux), iaux = 1 , nbar)
                write(ulsort,texte(langue,15)) (jaux(iaux),iaux=1,4)
c
                jaux(1) = nnosca(somare(1,areele(dejavu(2,lequad),1)))
                jaux(2) = nnosca(somare(2,areele(dejavu(2,lequad),1)))
                iaux = nnosca(somare(1,areele(dejavu(2,lequad),2)))
                if ( iaux.ne.jaux(1) .and. iaux.ne.jaux(2) ) then
                  jaux(3) = iaux
                else
                  jaux(3) = nnosca(somare(2,areele(dejavu(2,lequad),2)))
                endif
                iaux = nnosca(somare(1,areele(dejavu(2,lequad),3)))
                if ( iaux.ne.jaux(3) ) then
                  jaux(3) = iaux
                else
                  jaux(3) = nnosca(somare(2,areele(dejavu(2,lequad),3)))
                endif
                write(ulsort,texte(langue,12)) dejavu(2,lequad)
                write(ulsort,texte(langue,13)) fameel(dejavu(2,lequad)),
     >                                        typele(dejavu(2,lequad))
                write(ulsort,texte(langue,14))
     >                    (areele(dejavu(2,lequad),iaux),iaux = 1,nbar)
                write(ulsort,texte(langue,15)) (jaux(iaux),iaux=1,4)
c
                codret = 3
c
              endif
c
              if ( mod(mailet,3).eq.0 ) then
                ninqua(lequad) = nnosho(noeele(elem,nbnref(typhom,3)))
              endif
              coexqu(lequad,cofamd) = fameel(elem)
              coexqu(lequad,cotyel) = typele(elem)
              nqusho(elem) = lequad
              nqusca(lequad) = elem
              dejavu(2,lequad) = elem
c
              endif
c
            endif
c
c 2.3.2.4. ==> la derniere etape consiste a completer la table de
c              connectivite des elements 3d par face et le code de
c              la face dans l'element.
c              - si le tetraedre n'a pas encore ete vu, c'est-a-dire
c              si l'element en cours n'a pas de numero dans HOMARD,
c              il faut etablir un numero et memoriser la correspondance.
c              - si le tetraedre a deja ete vu, on rappelle son numero
c              dans HOMARD.
c              ensuite, pour ce tetraedre de numero tetrae dans
c              homard, on enrichit sa table de connectivite.
c              numloc donne les trois numeros locaux dans l'element
c              de reference des trois aretes qui definissent la
c              face en cours
c              (larete,areele(elem,numloc(2)),areele(elem,numloc(3))).
c              lorsque le code vaut 1, la description de reference
c              de la face est donnee par le triplet a1, a2, a3 dans
c              cet ordre. ensuite, les changements de code sont
c              transcrits via les fonctions i1, i2 et i3.
c
c 2.3.2.4.1. ==> pour un tetraedre
c
            if ( typhom.eq.tyhte1 .or. typhom.eq.tyhte2 ) then
c
              if ( ntesho(elem).eq.0 ) then
c
                letetr = letetr + 1
                ntesca(letetr) = elem
                ntesho(elem) = letetr
                coexte(letetr,cofamd) = fameel(elem)
                coexte(letetr,cotyel) = typele(elem)
c
                tetrae = letetr
c
              else
c
                tetrae = ntesho(elem)
c
              endif
c
              tritet(tetrae,floc) = letria
c
c 2.3.2.4.2. ==> pour un hexaedre
c
            elseif ( typhom.eq.tyhhe1 .or. typhom.eq.tyhhe2 ) then
c
              if ( nhesho(elem).eq.0 ) then
c
                lehexa = lehexa + 1
                if ( mod(mailet,5).eq.0 ) then
                  ninhex(lehexa) = nnosca(noeele(elem,nbnref(typhom,3)))
                endif
                nhesca(lehexa) = elem
                nhesho(elem) = lehexa
                coexhe(lehexa,cofamd) = fameel(elem)
                coexhe(lehexa,cotyel) = typele(elem)
c
                hexae = lehexa
c
              else
c
                hexae = nhesho(elem)
c
              endif
c
              quahex(hexae,floc) = lequad
c
c 2.3.2.4.3. ==> pour un pentaedre
c
            elseif ( typhom.eq.tyhpe1 .or. typhom.eq.tyhpe2 ) then
c
              if ( npesho(elem).eq.0 ) then
c
                lepent = lepent + 1
                npesca(lepent) = elem
                npesho(elem) = lepent
                coexpe(lepent,cofamd) = fameel(elem)
                coexpe(lepent,cotyel) = typele(elem)
c
                penta = lepent
c
              else
c
                penta = npesho(elem)
c
              endif
c
              if ( nbarfa.eq.3 ) then
c
                facpen(penta,floc) = letria
c
              else
c
                facpen(penta,floc) = lequad
c
              endif
c
c 2.3.2.4.4. ==> pour une pyramide
c
            elseif ( typhom.eq.tyhpy1 .or. typhom.eq.tyhpy2 ) then
c
              if ( npysho(elem).eq.0 ) then
c
                lapyra = lapyra + 1
                npysca(lapyra) = elem
                npysho(elem) = lapyra
                coexpy(lapyra,cofamd) = fameel(elem)
                coexpy(lapyra,cotyel) = typele(elem)
c
                pyram = lapyra
c
              else
c
                pyram = npysho(elem)
c
              endif
c
              if ( nbarfa.eq.3 ) then
c
                facpyr(pyram,floc) = letria
c
              else
c
                facpyr(pyram,floc) = lequad
c
              endif
c
            endif
c
c========= fin de if ( larete.lt.aglmin ) then ===========
          endif
c========= fin de if ( larete.lt.aglmin ) then ===========
c
c========= fin de if ( codret.eq.0 ) debut 223 ===========
          endif
c========= fin de if ( codret.eq.0 ) debut 223 ===========
c
  223   continue
c
        endif
c
        endif
c
   22 continue
c
      endif
c
cc      if (larete.eq.1) stop
   21 continue
c
c====
c 3. consequences
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. consequences ; codret = ', codret
#endif
c     . on suppose que l'on part d'un macro-maillage
c     . la premiere caracteristique des faces a deja ete initialisee
c       on initialise les autres a 0
c       les autres prennent la valeur 0
c     . l'etat vaut 0
c     . il n'y a aucune parente
c     . le niveau vaut 0
c
      nivinf = 0
      nivsup = 0
      niincf = 0
      nisucf = 0
      nancno = nbnoto
      nancar = nbarto
c
c 3.1. ==> pour les triangles
c
      nbtrac = nbtrto
      nbtrma = nbtrto
      nbtrpe = nbtrto
      nbtrde = 0
      nbtrt2 = 0
      nbtrq3 = 0
      nbtrhc = 0
      nbtrpc = 0
      nbtrtc = 0
      nanctr = nbtrto
c
      do 31 , letria = 1 , nbtrto
        hettri(letria) = 0
        filtri(letria) = 0
        pertri(letria) = 0
        nivtri(letria) = 0
   31 continue
c
c 3.2. ==> pour les quadrangles
c
      nbquac = nbquto
      nbquma = nbquto
      nbqupe = nbquto
      nbquq2 = 0
      nbquq5 = 0
      nbqude = 0
      nancqu = nbquto
c
      do 32 , lequad = 1 , nbquto
        hetqua(lequad) = 0
        filqua(lequad) = 0
        perqua(lequad) = 0
        nivqua(lequad) = 0
   32 continue
c
c 3.3. ==> pour les tetraedres
c
      nbteac = nbteto
      nbtema = nbteto
      nbtepe = nbteto
      nbtecf = nbteto
      nbteca = 0
      nbtea2 = 0
      nbtea4 = 0
      nbtede = 0
      nbtef4 = 0
      nbteh1 = 0
      nbteh2 = 0
      nbteh3 = 0
      nbteh4 = 0
      nbtep0 = 0
      nbtep1 = 0
      nbtep2 = 0
      nbtep3 = 0
      nbtep4 = 0
      nbtep5 = 0
      nbtedh = 0
      nbtedp = 0
      nancte = nbteto
      nanctf = nbtecf
      nancta = nbteca
c
      do 33 , letetr = 1 , nbteto
        hettet(letetr) = 0
        filtet(letetr) = 0
        pertet(letetr) = 0
   33 continue
c
c 3.4. ==> pour les hexaedres
c
      nbheac = nbheto
      nbhema = nbheto
      nbhepe = nbheto
      nbhecf = nbheto
      nbheca = 0
      nbhede = 0
      nbhedh = 0
      nanche = nbheto
      nanchf = nbhecf
      nancha = nbheca
c
      do 34 , lehexa = 1 , nbheto
        hethex(lehexa) = 0
        filhex(lehexa) = 0
        perhex(lehexa) = 0
   34 continue
c
c 3.5. ==> pour les pentaedres
c
      nbpeac = nbpeto
      nbpema = nbpeto
      nbpepe = nbpeto
      nbpecf = nbpeto
      nbpeca = 0
      nbpede = 0
      nbpedp = 0
      nancpe = nbpeto
      nancpf = nbpecf
      nancpa = nbpeca
c
      do 35 , lepent = 1 , nbpeto
        hetpen(lepent) = 0
        filpen(lepent) = 0
        perpen(lepent) = 0
 35   continue
c
c 3.6. ==> pour les pyramides
c
      nbpyac = nbpyto
      nbpyma = nbpyto
      nbpype = nbpyto
      nbpycf = nbpyto
      nbpyca = 0
      nbpyde = 0
      nbpyh1 = 0
      nbpyh2 = 0
      nbpyh3 = 0
      nbpyh4 = 0
      nbpyp0 = 0
      nbpyp1 = 0
      nbpyp2 = 0
      nbpyp3 = 0
      nbpyp4 = 0
      nbpyp5 = 0
      nbpydh = 0
      nbpydp = 0
      nancpy = nbpyto
      nancyf = nbpycf
      nancya = nbpyca
c
      do 36 , lapyra = 1 , nbpyto
        hetpyr(lapyra) = 0
        filpyr(lapyra) = 0
        perpyr(lapyra) = 0
 36   continue
c
c 3.7. ==> nombres propres a la renumerotation
c
      if ( rbtr00.ne.0 ) then
        rstrto = nbtrto
      else
        rstrto = 0
      endif
c
      if ( rbqu00.ne.0 ) then
        rsquto = nbquto
      else
        rsquto = 0
      endif
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
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
