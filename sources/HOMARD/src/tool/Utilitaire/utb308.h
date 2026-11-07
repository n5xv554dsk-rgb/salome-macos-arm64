c
c 2.2.1. ==> Elimination des situations ou il est inutile
c           de controler car l'arete a deja ete ramenee
c
            larete = arefro(nuarfr)
c
            if ( larete.le.0 ) then
              goto 22
            endif
c
c 2.2.2. ==> Reperage des situations a examiner :
c          . le noeud milieu de l'arete decoupee ou
c          . les noeuds P2 courbes
c
            if ( codret.eq.0 ) then
c
            if ( typsfr.le.2 ) then
              nbexam = 1
              examar(1) = larete
              examno(1) = somare(2,filare(examar(1)))
            else
              nbexam = 2
              examar(1) = filare(larete)
              examno(1) = np2are(examar(1))
              examar(2) = examar(1) + 1
              examno(2) = np2are(examar(2))
            endif
c
            endif
