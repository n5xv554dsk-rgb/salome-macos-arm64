      subroutine sfbatt ( nn, sn, tridec,
     >                    inloc, iploc, iqloc,
     >                    somare, facare, posifa,
     >                    filtri, aretri, hettri )
c
c  Attention : ce decoupage ne permet plus de respecter la regle
c              de placement du fils aine d'un triangle au centre
c              du dit triangle. Cela peut affecter les interpolations
c              de solutions aux points de Gauss.
c
c  GN 23.01.98
c
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
c   Suivi de Frontiere - BAscule d'aretes pour Triangle - Traitement
c   -        -           --                    -          -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nn     . e   . 1      . noeud projete                              .
c . sn     . e   . 1      . noeud oppose                               .
c . tridec . e   . 1      . triangle decoupe dont on va modifier les   .
c .        .     .        . fils                                       .
c . inloc  . e   . 1      . position locale de l'arete dont le noeud   .
c .        .     .        . est projete (i.e. arete frontiere de )     .
c . iploc  . e   . 1      . position locale d'arete                    .
c . iqloc  . e   . 1      . position locale d'arete                    .
c . somare . es  .2*nbarto. numeros des extremites d'arete             .
c . facare . es  . nbfaar . liste des faces contenant une arete        .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . filtri . e   . nbtrto . premier fils des triangles                 .
c . aretri . es  .nbtrto*3. numeros des 3 aretes des triangles         .
c . hettri . es  . nbtrto . historique de l'etat des triangles         .
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
c 0.2. ==> communs
c
#include "nombar.h"
#include "nombtr.h"
c
c 0.3. ==> arguments
c
      integer nn,sn
      integer tridec
      integer inloc, iploc, iqloc
      integer somare(2,nbarto), posifa(0:nbarto), facare(nbfaar)
      integer aretri(nbtrto,3), hettri(nbtrto), filtri(nbtrto)
c
c 0.4. ==> variables locales
c
      integer nf, nfn
      integer arebas, arnqnn, arnqsn, arnpnn
      integer iaux, ideb, ifin
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 2. traitement
c====
c
c 2.1. ==> situation initiale
c
c
c                             inloc
c       sp                       nn                      sq
c        .-----------------------.-----------------------.
c         .                     . .                     .
c          .                   .   .                   .
c           .   nfp           .     .     nfq         .
c            .               .i     i.               .
c             .             .p       q.             .
c              .     arnqnn.l         l.arnpnn     .
c               .         .o           o.         .
c       iqloc    .       .c     nf      c.       .    iploc
c                 .     .                 .     .
c                  .   .                   .   . 
c                   . .        inloc        . . 
c                    .---------arebas--------.
c                 nq  .        inloc        . np
c                      .                   .
c                       .                 .
c                        .i     nfn     i.
c                         .q           p.
c                   arnqsn .l         l. arnpsn
c                           .o       o.
c                            .c     c.
c                             .     .
c                              .   .
c                               . .
c                                .
c                               sn
c
      nf  = filtri(tridec)
c
      nfn = nf + inloc
c
c       on ne peut basculer que si le triangle de coin qui partage
c       l'arete a basculer avec le triangle central n'est pas decoupe
c       pour la conformite.
c
      if ( mod(hettri(nfn),10).eq.0 ) then
c
      arebas = aretri(nf,inloc)
c
      arnqnn = aretri(nf,iploc)
      arnpnn = aretri(nf,iqloc)
c
      arnqsn = aretri(nfn,iqloc)
c
c 2.2. ==> apres basculement
c
c  Attention : on ne peut pas conserver le numero local inloc a
c              l'arete basculee, car alors l'orientation des deux
c              triangles nf et nfn changerait. il faut donc permuter
c              les numeros locaux de deux des trois aretes des triangles
c              nf et nfn pour respecter cette orientation.
c              on choisit de garder le numero local des aretes issues
c              d'un decoupage en 2 des aretes du triangle pere.
c
c                             inloc
c       sp                       nn                      sq
c        .-----------------------.-----------------------.
c         .                     ...                     .
c          .                   . . .                   .
c           .   nfp           .  .  .     nfq         .
c            .               .i  a  i.               .
c             .             .n   r   n.             .
c              .     arnqnn.l . e   . l.arnpnn     .
c               .         .o     b     o.         .
c       iqloc    .       .c      a      c.       .    iploc
c                 .     .      .  s  .    .     .
c                  .   .         .         .   .
c                   . .          .          . .
c                    .    nf    i.i    nfn   .
c                 nq  .         p.q         . np
c                      .i       l.l       i.
c                       .q      o.o      p.
c                        .l     c.c     l.
c                         .o     .     o.
c                   arnqsn .c    .    c. arnpsn
c                           .    .    .
c                            .   .   .
c                             .  .  .
c                              . . .
c                               ...
c                                .
c                               sn
c
c 2.2.1. ==> description de l'arete basculee
c            Rq : par construction, nn>sn, donc ok pour somare
c
      somare(1,arebas) = sn
      somare(2,arebas) = nn
c
c 2.2.2. ==> nouveau triangle "central"
c            attention a l'orientation : la meme que tridec
c
      aretri(nf,inloc) = arnqnn
      aretri(nf,iploc) = arebas
      aretri(nf,iqloc) = arnqsn
c
c 2.2.3. ==> nouveau triangle "oppose"
c            attention a l'orientation : la meme que tridec
c            l'arete iploc est inchangee : arnpsn
c
      aretri(nfn,inloc) = arnpnn
      aretri(nfn,iqloc) = arebas
c
c 2.2.4. ==> traingles voisins des aretes
c            on doit examiner les 5 aretes impliquees
c            . arete basculee : il n'y a pas de changement car elle
c                               borde toujours nf et nfn
c            . arete arnqnn : il n'y a pas de changement car elle
c                             borde toujours nf, nfp et eventuellement
c                             une fille de nfp si nfp est coupee en 2
c                             par l'arete sp-nq.
c            . arete arnpsn : il n'y a pas de changement car elle
c                             borde toujours nfn, une voisine et
c                             eventuellement une fille de cette voisine
c                             si cette voisine est coupee en 2
c                             par l'arete sn-np.
c            . arete arnpnn : elle bordait nf, nfq et eventuellement
c                             une fille de nfq si nfq est coupee en 2
c                             par l'arete sq-np. Pas de changement du
c                             cote de nfq, il faut remplacer nf par nfn.
c            . arete arnqsn : elle bordait nfn, nfp et eventuellement
c                             une fille de nfp si nfp est coupee en 2
c                             par l'arete sn-nq. Pas de changement du
c                             cote de nfp, il faut remplacer nfn par nf.
c
      ideb = posifa(arnpnn-1) + 1
      ifin = posifa(arnpnn)
      do 2241 , iaux = ideb , ifin
        if ( facare(iaux).eq.nf ) then
          facare(iaux) = nfn
        endif
 2241 continue
c
      ideb = posifa(arnqsn-1) + 1
      ifin = posifa(arnqsn) 
      do 2242 , iaux = ideb , ifin
        if ( facare(iaux).eq.nfn ) then
          facare(iaux) = nf
        endif
 2242 continue
c
c 2.2.5. ==> modification de l'etat du triangle pere
c
      hettri(tridec) = hettri(tridec) + 1 + inloc
c
      endif
c
      end
