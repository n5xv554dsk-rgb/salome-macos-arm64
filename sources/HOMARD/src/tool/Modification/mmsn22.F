      subroutine mmsn22 ( lgtab, noeele, nounoe )
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
c    Modification de Maillage - Suppression des Noeuds P2 - phase 2
c    -               -          -               -       -         -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lgtab  . e   .    1   . longueur du tableau noeele                 .
c . noeele . es  .  lgtab . noeuds des elements (maille-points/aretes) .
c . nounoe .   e .0:nbnoto. nouveaux numeros des noeuds conserves      .
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
cc      character*6 nompro
cc      parameter ( nompro = 'MMSN22' )
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer lgtab
      integer noeele(lgtab), nounoe(0:*)
c
c 0.4. ==> variables locales
c
      integer iaux
c ______________________________________________________________________
c
c====
c 1. on passe en revue tous les noeuds dans la connectivite a modifier
c    on remplace le numero du noeud par son nouveau
c====
c
cgn      write(6,*) 'lgtab = ',lgtab
      do 11 , iaux = 1 , lgtab
c
cgn      write(6,*) 'noeele(',iaux,') = ',noeele(iaux)
        noeele(iaux) = nounoe(noeele(iaux))
c
   11 continue
c
      end
