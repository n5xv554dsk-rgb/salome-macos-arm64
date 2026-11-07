      subroutine pcsqu0 ( nbfonc, typint, deraff,
     >                    prfcan, prfcap,
     >                    coonoe,
     >                    somare,
     >                    arequa, hetqua, ancqua, filqua,
     >                    nbanqu, anfiqu,
     >                    nqueca, nqusca,
     >                    aretri,
     >                    ntreca, ntrsca,
     >                    vafoen, vafott,
     >                    vatren, vatrtt,
     >                    prftrn, prftrp,
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
c    aPres adaptation - Conversion de Solution -
c     -                 -             -
c                       QUadrangles - solution P0
c                       --                      -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfonc . e   .    1   . nombre de fonctions elements de volume     .
c . typint . e   .   1    . type d'interpolation                       .
c .        .     .        .  0, si automatique                         .
c .        .     .        .  elements : 0 si intensif, sans orientation.
c .        .     .        .             1 si extensif, sans orientation.
c .        .     .        .             2 si intensif, avec orientation.
c .        .     .        .             3 si extensif, avec orientation.
c .        .     .        .  noeuds : 1 si degre 1                     .
c .        .     .        .           2 si degre 2                     .
c .        .     .        .           3 si iso-P2                      .
c . deraff . e   .    1   . vrai, s'il y a eu du deraffinement en      .
c .        .     .        . passant de l'iteration n a n+1 ; faux sinon.
c . prfcan . e   .   *    . En numero du calcul a l'iteration n :      .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . i : l'entite est au rang i dans le profil  .
c . prfcap . es  .   *    . En numero du calcul a l'iteration n+1 :    .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . nbanqu . e   .   1    . nombre de quadrangles decoupes par         .
c .        .     .        . conformite sur le maillage avant adaptation.
c . anfiqu . e   . nbanqu . tableau filqua du maillage de l'iteration n.
c . nqueca . e   .   *    . nro des quadrangles dans le calcul en ent. .
c . nqusca . e   . rsquto . numero des quadrangles du calcul           .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . ntreca . e   .   *    . nro des triangles dans le calcul en entree .
c . ntrsca . e   . rstrto . numero des triangles du calcul             .
c . vafoen . e   . nbfonc*. variables en entree de l'adaptation        .
c .        .     .    *   .                                            .
c . vafott .   a . nbfonc*. tableau temporaire de la solution          .
c .        .     .    *   .                                            .
c . vatren . e   . nbfonc*. variables en entree de l'adaptation        .
c .        .     .    *   .                                            .
c . vatrtt .   a . nbfonc*. tableau temporaire de la solution pour     .
c .        .     .    *   . les triangles de conformite                .
c . prftrn . es  .   *    . En numero du calcul a l'iteration n   :    .
c .        .     .        . 0 : le triangle est absent du profil       .
c .        .     .        . 1 : le triangle est present dans le profil .
c . prftrp . es  .   *    . En numero du calcul a l'iteration n+1 :    .
c .        .     .        . 0 : le triangle est absent du profil       .
c .        .     .        . 1 : le triangle est present dans le profil .
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
      parameter ( nompro = 'PCSQU0' )
c
#include "nblang.h"
#include "fractb.h"
#include "fractc.h"
#include "fractf.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombsr.h"
#include "nomber.h"
c
c 0.3. ==> arguments
c
      integer nbfonc
      integer typint
      integer prfcan(*), prfcap(*)
      integer somare(2,nbarto)
      integer arequa(nbquto,4), hetqua(nbquto), ancqua(*)
      integer filqua(nbquto)
      integer nbanqu, anfiqu(nbanqu)
      integer nqueca(requto), nqusca(rsquto)
      integer aretri(nbtrto,3)
      integer ntreca(retrto), ntrsca(rstrto)
      integer prftrn(*), prftrp(*)
c
      double precision coonoe(nbnoto,sdim)
      double precision vafoen(nbfonc,*)
      double precision vafott(nbfonc,*)
      double precision vatren(nbfonc,*)
      double precision vatrtt(nbfonc,*)
c
      logical deraff
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
c     qucn   = QUadrangle courant en numerotation Calcul a l'it. N
c     qucnp1 = QUadrangle courant en numerotation Calcul a l'it. N+1
c     quhn   = QUadrangle courant en numerotation Homard a l'it. N
c     quhnp1 = QUadrangle courant en numerotation Homard a l'it. N+1
c
      integer qucn, qucnp1, quhn, quhnp1
c
c     etan   = ETAt du quadrangle a l'iteration N
c     etanp1 = ETAt du quadrangle a l'iteration N+1
c
      integer etan, etanp1
c
      integer nrofon
      integer iaux
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
#include "pcimp0.h"
#include "impr01.h"
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Elements hierarchiques :'',i2)'
c
      texte(2,4) = '(''Hierarchical elements :'',i2)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbfonc', nbfonc
      write (ulsort,90002) 'nbquto', nbquto
      write (ulsort,90002) 'requto, rsquto', requto, rsquto
#endif
c
cgn      write(ulsort,*) 'nqueca'
cgn      write(ulsort,91020) nqueca
cgn      write(ulsort,*) 'prfcan'
cgn      write(ulsort,91020) (prfcan(iaux),iaux=1,74)
cgn      print *,'vafoen :'
cgn      print 1790,(vafoen(1,iaux),iaux=1,min(nbquto,10))
cgn      print *,'prftrn = ',(prftrn(iaux),iaux=1,6)
cgn      print *,'vatren :'
cgn      print 1790,(vatren(1,iaux),iaux=1,6)
cgn      write(ulsort,91020) (nqusca(iaux),iaux=1,rsquto)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) hierar
#endif
      codret = 0
c
c====
c 2. on boucle sur tous les quadrangles du maillage HOMARD n+1
c    on trie en fonction de l'etat du quadrangle dans le maillage n
c    on numerote les paragraphes en fonction de la documentation, a
c    savoir : le paragraphe doc.n.p traite de la mise a jour de solution
c    pour un quadrangle dont l'etat est passe de n a p.
c    les autres paragraphes sont numerotes classiquement
c====
c
      if ( nbfonc.ne.0 ) then
c
      do 20 , quhnp1 = 1 , nbquto
      if ( codret.ne.0 ) goto 20
c
c 2.1. ==> caracteristiques du quadrangle :
c 2.1.1. ==> son numero homard dans le maillage precedent
c
        if ( deraff ) then
          quhn = ancqua(quhnp1)
        else
          quhn = quhnp1
        endif
c
c 2.1.2. ==> l'historique de son etat
c          On rappelle que l'etat vaut :
c          etan = 0 : le quadrangle etait actif
c          etan = 4 : le quadrangle etait coupe en 4 ; il y a eu
c                     deraffinement.
c          etan = 55 : le quadrangle n'existait pas ; il a ete produit
c                      par un decoupage.
c          etan = 31, 32, 33, 34 : le quadrangle etait coupe en 3
c                                  triangles ; il y a eu deraffinement.
c
        etanp1 = mod(hetqua(quhnp1),100)
        etan   = (hetqua(quhnp1)-etanp1) / 100
c
cgn        if ( quhn.eq.498 .or. quhn.eq.1083 ) then
cgn       write (ulsort,1792) 'Quadrangle', quhn, etan, quhnp1, etanp1
cgn        endif
c
c=======================================================================
c doc.0.p. ==> etan = 0 : le quadrangle etait actif
c=======================================================================
c
        if ( etan.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'PCSEQ0', nompro
#endif
c
          call pcseq0 ( etan, etanp1, quhn, quhnp1, typint,
     >                  prfcan, prfcap,
     >                  coonoe,
     >                  somare,
     >                  arequa, filqua,
     >                  nqueca, nqusca,
     >                  aretri,
     >                          ntrsca,
     >                  nbfonc, vafoen, vafott,
     >                          vatrtt,
     >                          prftrp,
     >                  ulsort, langue, codret )
cgn          write (ulsort,*) 'retour de PCSEQ0'
c
c=======================================================================
c doc.1/2/3.p. ==> etan = 21 ou 22 : le quadrangle etait coupe
c                  en 2 quadrangles
c=======================================================================
c
        elseif ( etan.eq.21 .or. etan.eq.22 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'PCSEQ1', nompro
#endif
c
          call pcseq1 ( etan, etanp1, quhn, quhnp1, typint,
     >                  prfcan, prfcap,
     >                  coonoe,
     >                  somare,
     >                  arequa, hetqua, filqua,
     >                  nbanqu, anfiqu,
     >                  nqueca, nqusca,
     >                  aretri,
     >                          ntrsca,
     >                  nbfonc, vafoen, vafott,
     >                          vatrtt,
     >                          prftrp,
     >                  ulsort, langue, codret )
cgn          write (ulsort,*) 'retour de PCSEQ1'
c
c=======================================================================
c doc.1/2/3.p. ==> etan = 31, 32, 33 ou 34 : le quadrangle etait coupe
c                  en 3 triangles
c=======================================================================
c
        elseif ( etan.ge.31 .and. etan.le.34 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'PCSEQ2', nompro
#endif
c
          call pcseq2 ( etan, etanp1, quhn, quhnp1, typint,
     >                          prfcap,
     >                  coonoe,
     >                  somare,
     >                  arequa, hetqua, filqua,
     >                  nbanqu, anfiqu,
     >                          nqusca,
     >                  aretri,
     >                  ntreca, ntrsca,
     >                  nbfonc,         vafott,
     >                  vatren, vatrtt,
     >                  prftrn, prftrp,
     >                  ulsort, langue, codret )
cgn          write (ulsort,*) 'retour de PCSEQ2'
c
c=======================================================================
c doc.4. ==> le quadrangle etait coupe en 4 :
c=======================================================================
c
        elseif ( etan.eq.4 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'PCSEQ3', nompro
#endif
c
          call pcseq3 ( etanp1, quhn, quhnp1, typint,
     >                  prfcan, prfcap,
     >                  coonoe,
     >                  somare,
     >                  arequa, filqua,
     >                  nbanqu, anfiqu,
     >                  nqueca, nqusca,
     >                  aretri,
     >                          ntrsca,
     >                  nbfonc, vafoen, vafott,
     >                          vatrtt,
     >                          prftrp,
     >                  ulsort, langue, codret )
cgn          write (ulsort,*) 'retour de PCSEQ3'
c
c=======================================================================
c doc.1/2/3.p. ==> etan = 41, 42, 43 ou 44 : le quadrangle etait coupe
c                  en 3 quadrangles
c=======================================================================
c
        elseif ( etan.ge.41 .and. etan.le.44 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'PCSEQ4', nompro
#endif
c
          call pcseq4 ( etan, etanp1, quhn, quhnp1, typint,
     >                  prfcan, prfcap,
     >                  coonoe,
     >                  somare,
     >                  arequa, hetqua, filqua,
     >                  nbanqu, anfiqu,
     >                  nqueca, nqusca,
     >                  aretri,
     >                          ntrsca,
     >                  nbfonc, vafoen, vafott,
     >                          vatrtt,
     >                          prftrp,
     >                  ulsort, langue, codret )
cgn          write (ulsort,*) 'retour de PCSEQ4'
c
        endif
c
   20 continue
c
      endif
c
c====
c 3. cas particulier : on garde tous les quadrangles de tous les niveaux
c    on boucle sur tous les quadrangles inactifs du maillage HOMARD n+1
c    on leur met la valeur qu'ils avaient dans le maillage n
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. cas particulier ; codret = ', codret
#endif
c
      if ( nbfonc.ne.0 .and. hierar.ne.0 ) then
c
      do 30 , quhnp1 = 1 , nbquto
c
        if ( deraff ) then
          quhn = ancqua(quhnp1)
        else
          quhn = quhnp1
        endif
c
        etanp1 = mod(hetqua(quhnp1),100)
c
        if ( etanp1.ne.0 ) then
c
c         on repere son ancien numero dans le calcul
c
          qucn = nqueca(quhn)
c
          if ( prfcan(qucn).gt.0 ) then
c
            qucnp1 = nqusca(quhnp1)
            prfcap(qucnp1) = 1
c
            do 311 , nrofon = 1 , nbfonc
              vafott(nrofon,qucnp1) = vafoen(nrofon,prfcan(qucn))
cgn              write(ulsort,92010) vafoen(nrofon,prfcan(qucn))
  311       continue
cgn        write(21,91010) qucnp1
cgn        write(ulsort,91010) qucn,-1,qucnp1
c
          endif
c
        endif
c
   30 continue
c
      endif
c
cgn      write(ulsort,91020)(prfcap(iaux),iaux=1,nbquto)
cgn      print *,nompro,' ==> codret = ',codret
cgn      print *,'nbfonc = ',nbfonc
cgn      print *,'Quadrangles (prfcap/vafott) : '
cgn      etan = min(2*nbquto,11)
cgn      etan   = 1
cgn      etanp1 = nbquto
cgn      do 30001 , iaux=etan,etanp1
cgn        if ( mod(hetqua(iaux),100).eq.0 ) then
cgn          print 11790,
cgn     >    nqusca(iaux),prfcap(nqusca(iaux)),vafott(1,nqusca(iaux))
cgn        endif
cgn30001 continue
cgn      print *,'Triangles (prftrp/vatrtt) : '
cgn      etan   = 1
cgn      etanp1 = 27
cgn      do 30002 , iaux=etan,etanp1
cgnc        if ( mod(hettri(iaux),10).eq.0 ) then
cgn          print 11790,
cgn     >    ntrsca(iaux),prftrp(ntrsca(iaux)),vatrtt(1,ntrsca(iaux))
cgnc        endif
cgn30002 continue
cgn11790 format(i4,' : ',i2,' / ',g15.7)
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
