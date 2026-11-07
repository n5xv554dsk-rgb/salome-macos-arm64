c   ATTENTION : les formules meriteraient d'etre verifiees ...
c
c           .................         .................
c           .      . .      .         .       .       .
c           .     .   .     .         .       .       .
c           .    .     .    .         .       .       .
c           .   .       .   .  ===>   .................
c           .  .         .  .         .       .       .
c           . .           . .         .       .       .
c           ..             ..         .       .       .
c           .................         .................
c
            f1hp = filqua(quhnp1)
cgn            print *,'f1hp =',f1hp
            f1cp = nqusca(f1hp)
            f2cp = nqusca(f1hp+1)
            f3cp = nqusca(f1hp+2)
            f4cp = nqusca(f1hp+3)
cgn            print *,'ficp =',f1cp,f2cp,f3cp,f4cp
c
            f1hn = -anfiqu(quhn)
cgn            print *,'f1hn =',f1hn
            f1cn = ntreca(f1hn)
            f2cn = ntreca(f1hn+1)
            f3cn = ntreca(f1hn+2)
cgn            print *,'ficn =',f1cn,f2cn,f3cn
            prf1cn = prftrn(f1cn)
            prf2cn = prftrn(f2cn)
            prf3cn = prftrn(f3cn)
cgn            print *,'prf1cn =',prf1cn
cgn            print *,'prf2cn =',prf2cn
cgn            print *,'prf3cn =',prf3cn
c
            q1t = 1
            q2t = 2
            q3t = 3
            q4t = 4
            q5t = 5
            q6t = 6
cgn            print *,'qit =',q1t,q2t,q3t,q4t,q5t,q6t
c
c           decoupage en 4 quadrangles d'un quadrangle
c           predecoupe en 3 triangles par l arete a1

            if ( etan.eq.31 ) then
c
            do 2341 , nrofon = 1 , nbfonc
c
c        pour le quadrangle Q1 (eventuellement redecoupe en 3 triangles)
c
            if ( mod(hetqua(f1hp),100).eq.0 ) then
c
            prfcap(f1cp) = 1
c
cgn        print *,'vatren(nrofon,q1t,prf1cn)',vatren(nrofon,q1t,prf1cn)
cgn        print *,'vatren(nrofon,q2t,prf1cn)',vatren(nrofon,q2t,prf1cn)
cgn        print *,'vatren(nrofon,q3t,prf1cn)',vatren(nrofon,q3t,prf1cn)
cgn        print *,'vatren(nrofon,q4t,prf1cn)',vatren(nrofon,q4t,prf1cn)
cgn        print *,'vatren(nrofon,q5t,prf1cn)',vatren(nrofon,q5t,prf1cn)
cgn        print *,'vatren(nrofon,q6t,prf1cn)',vatren(nrofon,q6t,prf1cn)
c
cgn        print *,'vatren(nrofon,q1t,prf2cn)',vatren(nrofon,q1t,prf2cn)
cgn        print *,'vatren(nrofon,q2t,prf2cn)',vatren(nrofon,q2t,prf2cn)
cgn        print *,'vatren(nrofon,q3t,prf2cn)',vatren(nrofon,q3t,prf2cn)
cgn        print *,'vatren(nrofon,q4t,prf2cn)',vatren(nrofon,q4t,prf2cn)
cgn        print *,'vatren(nrofon,q5t,prf2cn)',vatren(nrofon,q5t,prf2cn)
cgn        print *,'vatren(nrofon,q6t,prf2cn)',vatren(nrofon,q6t,prf2cn)
c
cgn        print *,'vatren(nrofon,q1t,prf3cn)',vatren(nrofon,q1t,prf3cn)
cgn        print *,'vatren(nrofon,q2t,prf3cn)',vatren(nrofon,q2t,prf3cn)
cgn        print *,'vatren(nrofon,q3t,prf3cn)',vatren(nrofon,q3t,prf3cn)
cgn        print *,'vatren(nrofon,q4t,prf3cn)',vatren(nrofon,q4t,prf3cn)
cgn        print *,'vatren(nrofon,q5t,prf3cn)',vatren(nrofon,q5t,prf3cn)
cgn        print *,'vatren(nrofon,q6t,prf3cn)',vatren(nrofon,q6t,prf3cn)
c
            vafott(nrofon,q1,f1cp) = vatren(nrofon,q2t,prf3cn)
c
            vafott(nrofon,q2,f1cp) =
     >                 unstr *( vatren(nrofon,q2t,prf1cn)+
     >                          vatren(nrofon,q2t,prf2cn)+
     >                          vatren(nrofon,q3t,prf3cn))
c
            vafott(nrofon,q3,f1cp) =
     >    -unshu*(vatren(nrofon,q1t,prf1cn)+vatren(nrofon,q3t,prf1cn))+
     >     unsde*(vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))+
     >     unsqu*vatren(nrofon,q6t,prf1cn)
c
            vafott(nrofon,q4,f1cp) = vatren(nrofon,q4t,prf3cn)
c
            vafott(nrofon,q5,f1cp) = vatren(nrofon,q5t,prf3cn)
c
            vafott(nrofon,q6,f1cp) =trshu*(vatren(nrofon,q2t,prf1cn)+
     >                                     vatren(nrofon,q4t,prf1cn)+
     >                                     vatren(nrofon,q5t,prf1cn))-
     >                      trstr2*(vatren(nrofon,q1t,prf1cn)+
     >                              vatren(nrofon,q3t,prf1cn))+
     >                       unssz*vatren(nrofon,q6t,prf1cn)
c
            vafott(nrofon,q7,f1cp) = unsde*(vatren(nrofon,q4t,prf1cn)+
     >                                vatren(nrofon,q6t,prf3cn))
c
            vafott(nrofon,q8,f1cp) =
     >     -unshu*vatren(nrofon,q1t,prf3cn)+
     >      trshu*vatren(nrofon,q2t,prf3cn)+
     >      trsqu*vatren(nrofon,q4t,prf3cn)
c
            elseif ( mod(hetqua(f1hp+1),100).ge.31 .and.
     >               mod(hetqua(f1hp+1),100).le.34 ) then
c

                f1fhp = -filqua(f1hp)
                f1fcp = ntrsca(f1fhp)
                f2fcp = ntrsca(f1fhp+1)
                f3fcp = ntrsca(f1fhp+2)
c
                prftrp(f3fcp) = 1
                prftrp(f1fcp) = 1
                prftrp(f2fcp) = 1
c
c           Pour le fils f3fcp
c
c    qi --> qit
                vatrtt(nrofon,q1t,f3fcp) = vatren(nrofon,q4t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q2t,f3fcp) = vatren(nrofon,q2t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q3t,f3fcp) = vatren(nrofon,q5t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q4t,f3fcp) =
     >           trshu*vatren(nrofon,q2t,prf3cn)
     >          -unshu*vatren(nrofon,q1t,prf3cn)
     >          +trsqu*vatren(nrofon,q4t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q5t,f3fcp) =
     >           trshu*vatren(nrofon,q2t,prf3cn)
     >          -unshu*vatren(nrofon,q3t,prf3cn)
     >          +trsqu*vatren(nrofon,q5t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q6t,f3fcp) =
     >      -unshu*(vatren(nrofon,q1t,prf3cn)+vatren(nrofon,q3t,prf3cn))
     >      +unsde*(vatren(nrofon,q4t,prf3cn)+vatren(nrofon,q5t,prf3cn))
     >      +unsqu*vatren(nrofon,q6t,prf3cn)
c
c           Pour le fils f1fcp
c
c    qi --> qit
                vatrtt(nrofon,q1t,f1fcp) = vatren(nrofon,q4t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q2t,f1fcp) = vatren(nrofon,q5t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q3t,f1fcp) =
     >      -unshu*(vatren(nrofon,q1t,prf1cn)+vatren(nrofon,q3t,prf1cn))
     >      +unsde*(vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))
     >      +unsqu*vatren(nrofon,q6t,prf1cn)
c
c    qi --> qit
                vatrtt(nrofon,q4t,f1fcp) =
     >      -unshu*(vatren(nrofon,q1t,prf3cn)+vatren(nrofon,q3t,prf3cn))
     >      +unsde*(vatren(nrofon,q4t,prf3cn)+vatren(nrofon,q5t,prf3cn))
     >      +unsqu*vatren(nrofon,q6t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q5t,f1fcp) =
     >        -unshu*unsde*(vatren(nrofon,q1t,prf3cn)+
     >                      vatren(nrofon,q1t,prf1cn))
     >        +trshu*unsde*(vatren(nrofon,q3t,prf3cn)+
     >                      vatren(nrofon,q2t,prf1cn))
     >        +trsqu*unsde*(vatren(nrofon,q4t,prf1cn)+
     >                      vatren(nrofon,q6t,prf3cn))
c
c    qi --> qit
                vatrtt(nrofon,q6t,f1fcp) =
     >      unsde*(vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q6t,prf3cn))
c
c           Pour le fils f2fcp
c
c    qi --> qit
                vatrtt(nrofon,q1t,f2fcp) = vatrtt(nrofon,q3t,f1fcp)
c
c    qi --> qit
                vatrtt(nrofon,q2t,f2fcp) = vatrtt(nrofon,q2t,f1fcp)
c
c    qi --> qit
                vatrtt(nrofon,q3t,f2fcp) =
     >                 unstr *( vatren(nrofon,q2t,prf1cn)+
     >                          vatren(nrofon,q2t,prf2cn)+
     >                          vatren(nrofon,q3t,prf3cn))
c
c    qi --> qit
                vatrtt(nrofon,q4t,f2fcp) =
     >        -unshu*unsde*(vatren(nrofon,q1t,prf3cn)+
     >                      vatren(nrofon,q1t,prf1cn))
     >        +trshu*unsde*(vatren(nrofon,q3t,prf3cn)+
     >                      vatren(nrofon,q2t,prf1cn))
     >        +trsqu*unsde*(vatren(nrofon,q4t,prf1cn)+
     >                      vatren(nrofon,q6t,prf3cn))
c
c    qi --> qit
                vatrtt(nrofon,q5t,f2fcp) =
     >         trshu*vatren(nrofon,q3t,prf3cn)-
     >         unshu*vatren(nrofon,q2t,prf3cn)+
     >         trsqu*vatren(nrofon,q5t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q6t,f2fcp) =
     >       trshu*(vatren(nrofon,q2t,prf1cn)+
     >              vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))
     >        -trstr2*(vatren(nrofon,q1t,prf1cn)+
     >                 vatren(nrofon,q3t,prf1cn))
     >        +unssz*vatren(nrofon,q6t,prf1cn)
c
c
            else
c
                codret = codret + 1
c
            endif
c
c        pour le quadrangle Q2 (eventuellement redecoupe en 3 triangles)
c
            if ( mod(hetqua(f1hp+1),100).eq.0 ) then

            prfcap(f2cp) = 1

            vafott(nrofon,q1,f2cp) = vatren(nrofon,q3t,prf2cn)
c
            vafott(nrofon,q2,f2cp) = vatren(nrofon,q6t,prf2cn)
c
            vafott(nrofon,q3,f2cp) =
     >    -unshu*(vatren(nrofon,q1t,prf1cn)+vatren(nrofon,q3t,prf1cn))+
     >     unsde*(vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))+
     >     unsqu*vatren(nrofon,q6t,prf1cn)
c
            vafott(nrofon,q4,f2cp) =
     >                 unstr *( vatren(nrofon,q2t,prf1cn)+
     >                          vatren(nrofon,q2t,prf2cn)+
     >                          vatren(nrofon,q3t,prf3cn))
c
            vafott(nrofon,q5,f2cp) =
     >     -unshu*vatren(nrofon,q1t,prf2cn)+
     >      trshu*vatren(nrofon,q3t,prf2cn)+
     >      trsqu*vatren(nrofon,q6t,prf2cn)
c
            vafott(nrofon,q6,f2cp) = unsde*(vatren(nrofon,q4t,prf2cn)+
     >                                vatren(nrofon,q5t,prf1cn))
c
            vafott(nrofon,q7,f2cp) = trshu*(vatren(nrofon,q2t,prf1cn)+
     >                               vatren(nrofon,q4t,prf1cn)+
     >                               vatren(nrofon,q5t,prf1cn))-
     >                      trstr2*(vatren(nrofon,q1t,prf1cn)+
     >                               vatren(nrofon,q3t,prf1cn))+
     >                      unssz*vatren(nrofon,q6t,prf1cn)
c
            vafott(nrofon,q8,f2cp) = vatren(nrofon,q5t,prf2cn)
c
            elseif ( mod(hetqua(f1hp+1),100).ge.31 .and.
     >               mod(hetqua(f1hp+1),100).le.34 ) then
c
                f1fhp = -filqua(f1hp+1)
                f1fcp = ntrsca(f1fhp)
                f2fcp = ntrsca(f1fhp+1)
                f3fcp = ntrsca(f1fhp+2)
c
                prftrp(f1fcp) = 1
                prftrp(f3fcp) = 1
                prftrp(f2fcp) = 1
c
c           Pour le fils f3fcp
c
c    qi --> qit
            vatrtt(nrofon,q1t,f3fcp) =
     >      -unshu*(vatren(nrofon,q1t,prf1cn)+vatren(nrofon,q3t,prf1cn))
     >      +unsde*(vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))
     >      +unsqu*vatren(nrofon,q6t,prf1cn)

c
c    qi --> qit
            vatrtt(nrofon,q2t,f3fcp) =
     >                 unstr *( vatren(nrofon,q2t,prf1cn)+
     >                          vatren(nrofon,q2t,prf2cn)+
     >                          vatren(nrofon,q3t,prf3cn))
c
c    qi --> qit
            vatrtt(nrofon,q3t,f3fcp) = vatren(nrofon,q5t,prf2cn)
c
c    qi --> qit
            vatrtt(nrofon,q4t,f3fcp) =
     >       trshu*(vatren(nrofon,q2t,prf1cn)+
     >              vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))
     >        -trstr2*(vatren(nrofon,q1t,prf1cn)+
     >                 vatren(nrofon,q3t,prf1cn))
     >        +unssz*vatren(nrofon,q6t,prf1cn)

c
            vatrtt(nrofon,q5t,f3fcp) =
     >     -unshu*vatren(nrofon,q3t,prf2cn)+
     >      trshu*vatren(nrofon,q2t,prf2cn)+
     >      trsqu*vatren(nrofon,q5t,prf2cn)
c
            vatrtt(nrofon,q6t,f3fcp) =
     >     -unshu*unsde*(vatren(nrofon,q1t,prf2cn)+
     >                   vatren(nrofon,q3t,prf1cn))+
     >      trshu*unsde*(vatren(nrofon,q2t,prf2cn)+
     >                   vatren(nrofon,q2t,prf1cn))+
     >      trsqu*unsde*(vatren(nrofon,q5t,prf1cn)+
     >                   vatren(nrofon,q4t,prf2cn))
c
c           Pour le fils f1fcp
c
            vatrtt(nrofon,q1t,f1fcp) = vatrtt(nrofon,q1t,f3fcp)

c
            vatrtt(nrofon,q2t,f1fcp) = vatren(nrofon,q5t,prf2cn)
c
            vatrtt(nrofon,q3t,f1fcp) = vatren(nrofon,q6t,prf2cn)
c
            vatrtt(nrofon,q4t,f1fcp) = vatrtt(nrofon,q6t,f3fcp)
c
            vatrtt(nrofon,q5t,f1fcp) =
     >     -unshu*(vatren(nrofon,q2t,prf2cn)+vatren(nrofon,q1t,prf2cn))
     >     +unsde*(vatren(nrofon,q5t,prf2cn)+vatren(nrofon,q6t,prf2cn))
     >     +unsqu*vatren(nrofon,q4t,prf2cn)
c
            vatrtt(nrofon,q6t,f1fcp) =
     >     unsde*(vatren(nrofon,q4t,prf2cn)+
     >            vatren(nrofon,q5t,prf1cn))
c
c           Pour le fils f2fcp
c
            vatrtt(nrofon,q1t,f2fcp) = vatren(nrofon,q6t,prf2cn)

c
            vatrtt(nrofon,q2t,f2fcp) = vatren(nrofon,q5t,prf2cn)
c
            vatrtt(nrofon,q3t,f2fcp) = vatren(nrofon,q3t,prf2cn)
c
            vatrtt(nrofon,q4t,f2fcp) =
     >     -unshu*(vatren(nrofon,q2t,prf2cn)+vatren(nrofon,q1t,prf2cn))
     >     +unsde*(vatren(nrofon,q5t,prf2cn)+vatren(nrofon,q6t,prf2cn))
     >     +unsqu*vatren(nrofon,q4t,prf2cn)
c
            vatrtt(nrofon,q5t,f2fcp) =
     >      trshu*vatren(nrofon,q3t,prf2cn)-
     >      unshu*vatren(nrofon,q2t,prf2cn)+
     >      trsqu*vatren(nrofon,q5t,prf2cn)
c
            vatrtt(nrofon,q6t,f2fcp) =
     >      trshu*vatren(nrofon,q3t,prf2cn)-
     >      unshu*vatren(nrofon,q1t,prf2cn)+
     >      trsqu*vatren(nrofon,q6t,prf2cn)
c
c
            else
c
                codret = codret + 1
c
            endif

c         pour le quadrangle Q3
c
            prfcap(f3cp) = 1
c
            vafott(nrofon,q1,f3cp) = unsde*(vatren(nrofon,q1t,prf2cn)+
     >                                vatren(nrofon,q3t,prf1cn))
c
            vafott(nrofon,q2,f3cp) = vatren(nrofon,q6t,prf1cn)
c
            vafott(nrofon,q3,f3cp) =
     >    -unshu*(vatren(nrofon,q1t,prf1cn)+vatren(nrofon,q3t,prf1cn))+
     >     unsde*(vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))+
     >     unsqu*vatren(nrofon,q6t,prf1cn)
c
            vafott(nrofon,q4,f3cp) = vatren(nrofon,q6t,prf2cn)
c
            vafott(nrofon,q5,f3cp) =
     >     -unshu*vatren(nrofon,q1t,prf1cn)+
     >      trshu*vatren(nrofon,q3t,prf1cn)+
     >      trsqu*vatren(nrofon,q6t,prf1cn)
c
            vafott(nrofon,q6,f3cp) = -unshu*vatren(nrofon,q2t,prf1cn)-
     >                       trstr2*(vatren(nrofon,q3t,prf1cn)+
     >                                vatren(nrofon,q1t,prf1cn))+
     >                           trshu*(vatren(nrofon,q4t,prf1cn)+
     >                                vatren(nrofon,q5t,prf1cn))+
     >                      nessz*vatren(nrofon,q6t,prf1cn)
c
            vafott(nrofon,q7,f3cp) =unsde*(vatren(nrofon,q4t,prf2cn)+
     >                                vatren(nrofon,q5t,prf1cn))
c
            vafott(nrofon,q8,f3cp) =
     >     -unshu*vatren(nrofon,q3t,prf2cn)+
     >      trshu*vatren(nrofon,q1t,prf2cn)+
     >      trsqu*vatren(nrofon,q6t,prf2cn)
c
c         pour le quadrangle Q4
c
            prfcap(f4cp) = 1
c
            vafott(nrofon,q1,f4cp) = unsde*(vatren(nrofon,q1t,prf1cn)+
     >                                vatren(nrofon,q1t,prf3cn))
c
            vafott(nrofon,q2,f4cp) = vatren(nrofon,q4t,prf3cn)
c
            vafott(nrofon,q3,f4cp) =
     >    -unshu*(vatren(nrofon,q1t,prf1cn)+vatren(nrofon,q3t,prf1cn))+
     >     unsde*(vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))+
     >     unsqu*vatren(nrofon,q6t,prf1cn)
c
            vafott(nrofon,q4,f4cp) = vatren(nrofon,q6t,prf1cn)
c
            vafott(nrofon,q5,f4cp) =
     >     -unshu*vatren(nrofon,q2t,prf3cn)+
     >      trshu*vatren(nrofon,q1t,prf3cn)+
     >      trsqu*vatren(nrofon,q4t,prf3cn)
c
            vafott(nrofon,q6,f4cp) = unsde*(vatren(nrofon,q4t,prf1cn)+
     >                                vatren(nrofon,q6t,prf3cn))
c
            vafott(nrofon,q7,f4cp) = -unshu*vatren(nrofon,q2t,prf1cn)-
     >                       trstr2*(vatren(nrofon,q3t,prf1cn)+
     >                                vatren(nrofon,q1t,prf1cn))+
     >                           trshu*(vatren(nrofon,q4t,prf1cn)+
     >                                vatren(nrofon,q5t,prf1cn))+
     >                      nessz*vatren(nrofon,q6t,prf1cn)
c
            vafott(nrofon,q8,f4cp) =
     >     -unshu*vatren(nrofon,q3t,prf1cn)+
     >      trshu*vatren(nrofon,q1t,prf1cn)+
     >      trsqu*vatren(nrofon,q6t,prf1cn)
c
 2341     continue
c
c           decoupage en 4 quadrangles d'un quadrangle
c           predecoupe en 3 triangles par l arete a2
c
         elseif (etan .eq. 32) then
c
         do 2342 , nrofon = 1 , nbfonc

c        pour le quadrangle Q1
c
           prfcap(f1cp) = 1
c
           vafott(nrofon,q1,f1cp) = unsde*(vatren(nrofon,q1t,prf3cn)+
     >                              vatren(nrofon,q1t,prf1cn))
c
           vafott(nrofon,q2,f1cp) = vatren(nrofon,q4t,prf3cn)
c
           vafott(nrofon,q3,f1cp) =
     >   -unshu*(vatren(nrofon,q1t,prf1cn)+vatren(nrofon,q3t,prf1cn))+
     >    unsde*(vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))+
     >    unsqu*vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q4,f1cp) = vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q5,f1cp) =
     >    -unshu*vatren(nrofon,q2t,prf3cn)+
     >     trshu*vatren(nrofon,q1t,prf3cn)+
     >     trsqu*vatren(nrofon,q4t,prf3cn)
c
           vafott(nrofon,q6,f1cp) = unsde*(vatren(nrofon,q4t,prf1cn)+
     >                              vatren(nrofon,q6t,prf3cn))
c
           vafott(nrofon,q7,f1cp) = -unshu*vatren(nrofon,q2t,prf1cn)-
     >                     trstr2*(vatren(nrofon,q3t,prf1cn)+
     >                              vatren(nrofon,q1t,prf1cn))+
     >                         trshu*(vatren(nrofon,q4t,prf1cn)+
     >                              vatren(nrofon,q5t,prf1cn))+
     >                      nessz*vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q8,f1cp) =
     >    -unshu*vatren(nrofon,q3t,prf1cn)+
     >     trshu*vatren(nrofon,q1t,prf1cn)+
     >     trsqu*vatren(nrofon,q6t,prf1cn)
c
c        pour le quadrangle Q2
c
            if ( mod(hetqua(f1hp+1),100).eq.0 ) then

            prfcap(f2cp) = 1

           vafott(nrofon,q1,f2cp) = vatren(nrofon,q2t,prf3cn)
c
           vafott(nrofon,q2,f2cp) =
     >                 unstr *( vatren(nrofon,q2t,prf1cn)+
     >                          vatren(nrofon,q2t,prf2cn)+
     >                          vatren(nrofon,q3t,prf3cn))
c
           vafott(nrofon,q3,f2cp) =
     >   -unshu*(vatren(nrofon,q1t,prf1cn)+vatren(nrofon,q3t,prf1cn))+
     >    unsde*(vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))+
     >    unsqu*vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q4,f2cp) = vatren(nrofon,q4t,prf3cn)
c
           vafott(nrofon,q5,f2cp) = vatren(nrofon,q5t,prf3cn)
c
           vafott(nrofon,q6,f2cp) = trshu*(vatren(nrofon,q2t,prf1cn)+
     >                              vatren(nrofon,q4t,prf1cn)+
     >                              vatren(nrofon,q5t,prf1cn))-
     >                     trstr2*(vatren(nrofon,q1t,prf1cn)+
     >                              vatren(nrofon,q3t,prf1cn))+
     >                     unssz*vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q7,f2cp) = unsde*(vatren(nrofon,q4t,prf1cn)+
     >                              vatren(nrofon,q6t,prf3cn))
c
           vafott(nrofon,q8,f2cp) =
     >    -unshu*vatren(nrofon,q1t,prf3cn)+
     >     trshu*vatren(nrofon,q2t,prf3cn)+
     >     trsqu*vatren(nrofon,q4t,prf3cn)
c
            elseif ( mod(hetqua(f1hp+1),100).ge.31 .and.
     >               mod(hetqua(f1hp+1),100).le.34 ) then
c
                f1fhp = -filqua(f1hp+1)
                f1fcp = ntrsca(f1fhp)
                f2fcp = ntrsca(f1fhp+1)
                f3fcp = ntrsca(f1fhp+2)

                prftrp(f3fcp) = 1
                prftrp(f1fcp) = 1
                prftrp(f2fcp) = 1
c
c
c           Pour le fils f3fcp
c
c    qi --> qit
                vatrtt(nrofon,q1t,f3fcp) = vatren(nrofon,q4t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q2t,f3fcp) = vatren(nrofon,q2t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q3t,f3fcp) = vatren(nrofon,q5t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q4t,f3fcp) =
     >           trshu*vatren(nrofon,q2t,prf3cn)
     >          -unshu*vatren(nrofon,q1t,prf3cn)
     >          +trsqu*vatren(nrofon,q4t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q5t,f3fcp) =
     >           trshu*vatren(nrofon,q2t,prf3cn)
     >          -unshu*vatren(nrofon,q3t,prf3cn)
     >          +trsqu*vatren(nrofon,q5t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q6t,f3fcp) =
     >      -unshu*(vatren(nrofon,q1t,prf3cn)+vatren(nrofon,q3t,prf3cn))
     >      +unsde*(vatren(nrofon,q4t,prf3cn)+vatren(nrofon,q5t,prf3cn))
     >      +unsqu*vatren(nrofon,q6t,prf3cn)
c
c           Pour le fils f1fcp
c
c    qi --> qit
                vatrtt(nrofon,q1t,f1fcp) = vatren(nrofon,q4t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q2t,f1fcp) = vatren(nrofon,q5t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q3t,f1fcp) =
     >      -unshu*(vatren(nrofon,q1t,prf1cn)+vatren(nrofon,q3t,prf1cn))
     >      +unsde*(vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))
     >      +unsqu*vatren(nrofon,q6t,prf1cn)
c
c    qi --> qit
                vatrtt(nrofon,q4t,f1fcp) = vatrtt(nrofon,q6t,f3fcp)
c
c    qi --> qit
                vatrtt(nrofon,q5t,f1fcp) =
     >        -unshu*unsde*(vatren(nrofon,q1t,prf3cn)+
     >                      vatren(nrofon,q1t,prf1cn))
     >        +trshu*unsde*(vatren(nrofon,q3t,prf3cn)+
     >                      vatren(nrofon,q2t,prf1cn))
     >        +trsqu*unsde*(vatren(nrofon,q4t,prf1cn)+
     >                      vatren(nrofon,q6t,prf3cn))
c
c    qi --> qit
                vatrtt(nrofon,q6t,f1fcp) =
     >      unsde*(vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q6t,prf3cn))
c
c           Pour le fils f2fcp
c
c    qi --> qit
                vatrtt(nrofon,q1t,f2fcp) = vatrtt(nrofon,q3t,f1fcp)
c
c    qi --> qit
                vatrtt(nrofon,q2t,f2fcp) = vatrtt(nrofon,q2t,f1fcp)
c
c    qi --> qit
                vatrtt(nrofon,q3t,f2fcp) =
     >                 unstr *( vatren(nrofon,q2t,prf1cn)+
     >                          vatren(nrofon,q2t,prf2cn)+
     >                          vatren(nrofon,q3t,prf3cn))
c
c    qi --> qit
                vatrtt(nrofon,q4t,f2fcp) = vatrtt(nrofon,q5t,f1fcp)
c
c    qi --> qit
                vatrtt(nrofon,q5t,f2fcp) =
     >         trshu*vatren(nrofon,q3t,prf3cn)-
     >         unshu*vatren(nrofon,q2t,prf3cn)+
     >         trsqu*vatren(nrofon,q5t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q6t,f2fcp) =
     >       trshu*(vatren(nrofon,q2t,prf1cn)+
     >              vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))
     >        -trstr2*(vatren(nrofon,q1t,prf1cn)+
     >                 vatren(nrofon,q3t,prf1cn))
     >        +unssz*vatren(nrofon,q6t,prf1cn)
c
c
            else
c
                codret = codret + 1
c
            endif

c        pour le quadrangle Q3
c
            if ( mod(hetqua(f1hp+2),100).eq.0 ) then

            prfcap(f3cp) = 1
c
           vafott(nrofon,q1,f3cp) = vatren(nrofon,q3t,prf2cn)
c
           vafott(nrofon,q2,f3cp) = vatren(nrofon,q6t,prf2cn)
c
           vafott(nrofon,q3,f3cp) =
     >   -unshu*(vatren(nrofon,q1t,prf1cn)+vatren(nrofon,q3t,prf1cn))+
     >    unsde*(vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))+
     >    unsqu*vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q4,f3cp) =
     >                 unstr *( vatren(nrofon,q2t,prf1cn)+
     >                          vatren(nrofon,q2t,prf2cn)+
     >                          vatren(nrofon,q3t,prf3cn))
c
           vafott(nrofon,q5,f3cp) =
     >    -unshu*vatren(nrofon,q1t,prf2cn)+
     >     trshu*vatren(nrofon,q3t,prf2cn)+
     >     trsqu*vatren(nrofon,q6t,prf2cn)
c
           vafott(nrofon,q6,f3cp) = unsde*(vatren(nrofon,q5t,prf1cn)+
     >                              vatren(nrofon,q4t,prf2cn))
c
           vafott(nrofon,q7,f3cp) = trshu*(vatren(nrofon,q2t,prf1cn)+
     >                              vatren(nrofon,q4t,prf1cn)+
     >                              vatren(nrofon,q5t,prf1cn))-
     >                     trstr2*(vatren(nrofon,q1t,prf1cn)+
     >                              vatren(nrofon,q3t,prf1cn))+
     >                     unssz*vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q8,f3cp) = vatren(nrofon,q5t,prf2cn)
c
            elseif ( mod(hetqua(f1hp+2),100).ge.31 .and.
     >               mod(hetqua(f1hp+2),100).le.34 ) then
c
                f1fhp = -filqua(f1hp+2)
                f3fcp = ntrsca(f1fhp+2)
                f1fcp = ntrsca(f1fhp)
                f2fcp = ntrsca(f1fhp+1)

                prftrp(f3fcp) = 1
                prftrp(f1fcp) = 1
                prftrp(f2fcp) = 1
c
c
c           Pour le fils f3fcp
c
c   qi --> qit
            vatrtt(nrofon,q1t,f3fcp) =
     >      -unshu*(vatren(nrofon,q1t,prf1cn)+vatren(nrofon,q3t,prf1cn))
     >      +unsde*(vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))
     >      +unsqu*vatren(nrofon,q6t,prf1cn)

c
            vatrtt(nrofon,q2t,f3fcp) =
     >                 unstr *( vatren(nrofon,q2t,prf1cn)+
     >                          vatren(nrofon,q2t,prf2cn)+
     >                          vatren(nrofon,q3t,prf3cn))
c
c   qi --> qit
            vatrtt(nrofon,q3t,f3fcp) = vatren(nrofon,q5t,prf2cn)
c
c   qi --> qit
            vatrtt(nrofon,q4t,f3fcp) =
     >       trshu*(vatren(nrofon,q2t,prf1cn)+
     >              vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))
     >        -trstr2*(vatren(nrofon,q1t,prf1cn)+
     >                 vatren(nrofon,q3t,prf1cn))
     >        +unssz*vatren(nrofon,q6t,prf1cn)

c
            vatrtt(nrofon,q5t,f3fcp) =
     >     -unshu*vatren(nrofon,q3t,prf2cn)+
     >      trshu*vatren(nrofon,q2t,prf2cn)+
     >      trsqu*vatren(nrofon,q5t,prf2cn)
c
            vatrtt(nrofon,q6t,f3fcp) =
     >     -unshu*unsde*(vatren(nrofon,q1t,prf2cn)+
     >                   vatren(nrofon,q3t,prf1cn))+
     >      trshu*unsde*(vatren(nrofon,q2t,prf2cn)+
     >                   vatren(nrofon,q2t,prf1cn))+
     >      trsqu*unsde*(vatren(nrofon,q5t,prf1cn)+
     >                   vatren(nrofon,q4t,prf2cn))

c           Pour le fils f1fcp
c
            vatrtt(nrofon,q1t,f1fcp) = vatrtt(nrofon,q1t,f3fcp)

c
            vatrtt(nrofon,q2t,f1fcp) = vatren(nrofon,q5t,prf2cn)
c
            vatrtt(nrofon,q3t,f1fcp) = vatren(nrofon,q6t,prf2cn)
c
            vatrtt(nrofon,q4t,f1fcp) = vatrtt(nrofon,q6t,f3fcp)
c
            vatrtt(nrofon,q5t,f1fcp) =
     >     -unshu*(vatren(nrofon,q2t,prf2cn)+vatren(nrofon,q1t,prf2cn))
     >     +unsde*(vatren(nrofon,q5t,prf2cn)+vatren(nrofon,q6t,prf2cn))
     >     +unsqu*vatren(nrofon,q4t,prf2cn)
c
            vatrtt(nrofon,q6t,f1fcp) =
     >     unsde*(vatren(nrofon,q4t,prf2cn)+
     >            vatren(nrofon,q5t,prf1cn))

c
c           Pour le fils f2fcp
c
            vatrtt(nrofon,q1t,f2fcp) = vatren(nrofon,q6t,prf2cn)

c
            vatrtt(nrofon,q2t,f2fcp) = vatren(nrofon,q5t,prf2cn)
c
            vatrtt(nrofon,q3t,f2fcp) = vatren(nrofon,q3t,prf2cn)
c
            vatrtt(nrofon,q4t,f2fcp) =
     >     -unshu*(vatren(nrofon,q2t,prf2cn)+vatren(nrofon,q1t,prf2cn))
     >     +unsde*(vatren(nrofon,q5t,prf2cn)+vatren(nrofon,q6t,prf2cn))
     >     +unsqu*vatren(nrofon,q4t,prf2cn)

            vatrtt(nrofon,q5t,f2fcp) =
     >      trshu*vatren(nrofon,q3t,prf2cn)-
     >      unshu*vatren(nrofon,q2t,prf2cn)+
     >      trsqu*vatren(nrofon,q5t,prf2cn)
c
            vatrtt(nrofon,q6t,f2fcp) =
     >      trshu*vatren(nrofon,q3t,prf2cn)-
     >      unshu*vatren(nrofon,q1t,prf2cn)+
     >      trsqu*vatren(nrofon,q6t,prf2cn)
c
            else
c
                codret = codret + 1
c
            endif
c        pour le quadrangle Q4
c
           prfcap(f4cp) = 1
c
           vafott(nrofon,q1,f4cp) = unsde*(vatren(nrofon,q3t,prf1cn)+
     >                              vatren(nrofon,q1t,prf2cn))
c
           vafott(nrofon,q2,f4cp) = vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q3,f4cp) =
     >   -unshu*(vatren(nrofon,q1t,prf1cn)+vatren(nrofon,q3t,prf1cn))+
     >    unsde*(vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))+
     >    unsqu*vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q4,f4cp) = vatren(nrofon,q6t,prf2cn)
c
           vafott(nrofon,q5,f4cp) =
     >    -unshu*vatren(nrofon,q1t,prf1cn)+
     >     trshu*vatren(nrofon,q3t,prf1cn)+
     >     trsqu*vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q6,f4cp) = -unshu*vatren(nrofon,q2t,prf1cn)-
     >                     trstr2*(vatren(nrofon,q3t,prf1cn)+
     >                              vatren(nrofon,q1t,prf1cn))+
     >                         trshu*(vatren(nrofon,q4t,prf1cn)+
     >                              vatren(nrofon,q5t,prf1cn))+
     >                      nessz*vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q7,f4cp) = unsde*(vatren(nrofon,q5t,prf1cn)+
     >                              vatren(nrofon,q4t,prf2cn))
c
           vafott(nrofon,q8,f4cp) =
     >    -unshu*vatren(nrofon,q3t,prf2cn)+
     >     trshu*vatren(nrofon,q1t,prf2cn)+
     >     trsqu*vatren(nrofon,q6t,prf2cn)
c
 2342    continue
c
c           decoupage en 4 quadrangles d'un quadrangle
c           predecoupe en 3 triangles par l arete a3
c
         elseif (etan .eq. 33) then
         do 2343 , nrofon = 1 , nbfonc
c
c        pour le quadrangle Q1
c
           prfcap(f1cp) = 1
c
           vafott(nrofon,q1,f1cp) = unsde*(vatren(nrofon,q3t,prf1cn)+
     >                             vatren(nrofon,q1t,prf2cn))
c
           vafott(nrofon,q2,f1cp) = vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q3,f1cp) =
     >    -unshu*(vatren(nrofon,q1t,prf1cn)+vatren(nrofon,q3t,prf1cn))+
     >     unsde*(vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))+
     >     unsqu*vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q4,f1cp) = vatren(nrofon,q6t,prf2cn)
c
           vafott(nrofon,q5,f1cp) =
     >    -unshu*vatren(nrofon,q1t,prf1cn)+
     >     trshu*vatren(nrofon,q3t,prf1cn)+
     >     trsqu*vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q6,f1cp) = -unshu*vatren(nrofon,q2t,prf1cn)-
     >                    trstr2*(vatren(nrofon,q3t,prf1cn)+
     >                             vatren(nrofon,q1t,prf1cn))+
     >                        trshu*(vatren(nrofon,q4t,prf1cn)+
     >                             vatren(nrofon,q5t,prf1cn))+
     >                     nessz*vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q7,f1cp) = unsde*(vatren(nrofon,q5t,prf1cn)+
     >                             vatren(nrofon,q4t,prf2cn))
c
           vafott(nrofon,q8,f1cp) =
     >    -unshu*vatren(nrofon,q3t,prf2cn)+
     >     trshu*vatren(nrofon,q1t,prf2cn)+
     >     trsqu*vatren(nrofon,q6t,prf2cn)
c
c        pour le quadrangle Q2
c
           prfcap(f2cp) = 1
c
           vafott(nrofon,q1,f2cp) = unsde*(vatren(nrofon,q1t,prf3cn)+
     >                             vatren(nrofon,q1t,prf1cn))
c
           vafott(nrofon,q2,f2cp) = vatren(nrofon,q4t,prf3cn)
c
           vafott(nrofon,q3,f2cp) =
     >    -unshu*(vatren(nrofon,q1t,prf1cn)+vatren(nrofon,q3t,prf1cn))+
     >     unsde*(vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))+
     >     unsqu*vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q4,f2cp) = vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q5,f2cp) =
     >    -unshu*vatren(nrofon,q2t,prf3cn)+
     >     trshu*vatren(nrofon,q1t,prf3cn)+
     >     trsqu*vatren(nrofon,q4t,prf3cn)
c
           vafott(nrofon,q6,f2cp) =  unsde*(vatren(nrofon,q4t,prf1cn)+
     >                             vatren(nrofon,q6t,prf3cn))
c
           vafott(nrofon,q7,f2cp) = -unshu*vatren(nrofon,q2t,prf1cn)-
     >                    trstr2*(vatren(nrofon,q3t,prf1cn)+
     >                             vatren(nrofon,q1t,prf1cn))+
     >                        trshu*(vatren(nrofon,q4t,prf1cn)+
     >                             vatren(nrofon,q5t,prf1cn))+
     >                     nessz*vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q8,f2cp) =
     >    -unshu*vatren(nrofon,q3t,prf1cn)+
     >     trshu*vatren(nrofon,q1t,prf1cn)+
     >     trsqu*vatren(nrofon,q6t,prf1cn)
c
c        pour le quadrangle Q3
c
            if ( mod(hetqua(f1hp+2),100).eq.0 ) then

            prfcap(f3cp) = 1
c
           vafott(nrofon,q1,f3cp) = vatren(nrofon,q2t,prf3cn)
c
           vafott(nrofon,q2,f3cp) =
     >                 unstr *( vatren(nrofon,q2t,prf1cn)+
     >                          vatren(nrofon,q2t,prf2cn)+
     >                          vatren(nrofon,q3t,prf3cn))
c
           vafott(nrofon,q3,f3cp) =
     >    -unshu*(vatren(nrofon,q1t,prf1cn)+vatren(nrofon,q3t,prf1cn))+
     >     unsde*(vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))+
     >     unsqu*vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q4,f3cp) = vatren(nrofon,q4t,prf3cn)
c
           vafott(nrofon,q5,f3cp) = vatren(nrofon,q5t,prf3cn)
c
           vafott(nrofon,q6,f3cp) = trshu*(vatren(nrofon,q2t,prf1cn)+
     >                             vatren(nrofon,q4t,prf1cn)+
     >                             vatren(nrofon,q5t,prf1cn))-
     >                    trstr2*(vatren(nrofon,q1t,prf1cn)+
     >                             vatren(nrofon,q3t,prf1cn))+
     >                    unssz*vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q7,f3cp) = unsde*(vatren(nrofon,q4t,prf1cn)+
     >                             vatren(nrofon,q6t,prf3cn))
c
           vafott(nrofon,q8,f3cp) =
     >    -unshu*vatren(nrofon,q1t,prf3cn)+
     >     trshu*vatren(nrofon,q2t,prf3cn)+
     >     trsqu*vatren(nrofon,q4t,prf3cn)
c
            elseif ( mod(hetqua(f1hp+2),100).ge.31 .and.
     >               mod(hetqua(f1hp+2),100).le.34 ) then
c
                f1fhp = -filqua(f1hp+2)
                f3fcp = ntrsca(f1fhp+2)
                f1fcp = ntrsca(f1fhp)
                f2fcp = ntrsca(f1fhp+1)

                prftrp(f3fcp) = 1
                prftrp(f1fcp) = 1
                prftrp(f2fcp) = 1
c
c
c           Pour le fils f3fcp
c
c    qi --> qit
                vatrtt(nrofon,q1t,f3fcp) = vatren(nrofon,q4t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q2t,f3fcp) = vatren(nrofon,q2t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q3t,f3fcp) = vatren(nrofon,q5t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q4t,f3fcp) =
     >           trshu*vatren(nrofon,q2t,prf3cn)
     >          -unshu*vatren(nrofon,q1t,prf3cn)
     >          +trsqu*vatren(nrofon,q4t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q5t,f3fcp) =
     >           trshu*vatren(nrofon,q2t,prf3cn)
     >          -unshu*vatren(nrofon,q3t,prf3cn)
     >          +trsqu*vatren(nrofon,q5t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q6t,f3fcp) =
     >      -unshu*(vatren(nrofon,q1t,prf3cn)+vatren(nrofon,q3t,prf3cn))
     >      +unsde*(vatren(nrofon,q4t,prf3cn)+vatren(nrofon,q5t,prf3cn))
     >      +unsqu*vatren(nrofon,q6t,prf3cn)
c
c           Pour le fils f1fcp
c
c    qi --> qit
                vatrtt(nrofon,q1t,f1fcp) = vatren(nrofon,q4t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q2t,f1fcp) = vatren(nrofon,q5t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q3t,f1fcp) =
     >      -unshu*(vatren(nrofon,q1t,prf1cn)+vatren(nrofon,q3t,prf1cn))
     >      +unsde*(vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))
     >      +unsqu*vatren(nrofon,q6t,prf1cn)
c
c    qi --> qit
                vatrtt(nrofon,q4t,f1fcp) = vatrtt(nrofon,q6t,f3fcp)
c
c    qi --> qit
                vatrtt(nrofon,q5t,f1fcp) =
     >        -unshu*unsde*(vatren(nrofon,q1t,prf3cn)+
     >                      vatren(nrofon,q1t,prf1cn))
     >        +trshu*unsde*(vatren(nrofon,q3t,prf3cn)+
     >                      vatren(nrofon,q2t,prf1cn))
     >        +trsqu*unsde*(vatren(nrofon,q4t,prf1cn)+
     >                      vatren(nrofon,q6t,prf3cn))
c
c    qi --> qit
                vatrtt(nrofon,q6t,f1fcp) =
     >      unsde*(vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q6t,prf3cn))
c
c           Pour le fils f2fcp
c
c    qi --> qit
                vatrtt(nrofon,q1t,f2fcp) = vatrtt(nrofon,q3t,f1fcp)
c
c    qi --> qit
                vatrtt(nrofon,q2t,f2fcp) = vatrtt(nrofon,q2t,f1fcp)
c
c    qi --> qit
                vatrtt(nrofon,q3t,f2fcp) =
     >                 unstr *( vatren(nrofon,q2t,prf1cn)+
     >                          vatren(nrofon,q2t,prf2cn)+
     >                          vatren(nrofon,q3t,prf3cn))
c
c    qi --> qit
                vatrtt(nrofon,q4t,f2fcp) = vatrtt(nrofon,q5t,f1fcp)
c
c    qi --> qit
                vatrtt(nrofon,q5t,f2fcp) =
     >         trshu*vatren(nrofon,q3t,prf3cn)-
     >         unshu*vatren(nrofon,q2t,prf3cn)+
     >         trsqu*vatren(nrofon,q5t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q6t,f2fcp) =
     >       trshu*(vatren(nrofon,q2t,prf1cn)+
     >              vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))
     >        -trstr2*(vatren(nrofon,q1t,prf1cn)+
     >                 vatren(nrofon,q3t,prf1cn))
     >        +unssz*vatren(nrofon,q6t,prf1cn)
c
            else
c
                codret = codret + 1
c
            endif
c
c        pour le quadrangle Q4
c
            if ( mod(hetqua(f1hp+3),100).eq.0 ) then

           prfcap(f4cp) = 1
c
           vafott(nrofon,q1,f4cp) = vatren(nrofon,q3t,prf2cn)
c
           vafott(nrofon,q2,f4cp) = vatren(nrofon,q6t,prf2cn)
c
           vafott(nrofon,q3,f4cp) =
     >    -unshu*(vatren(nrofon,q1t,prf1cn)+vatren(nrofon,q3t,prf1cn))+
     >     unsde*(vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))+
     >     unsqu*vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q4,f4cp) =
     >                 unstr *( vatren(nrofon,q2t,prf1cn)+
     >                          vatren(nrofon,q2t,prf2cn)+
     >                          vatren(nrofon,q3t,prf3cn))
c
           vafott(nrofon,q5,f4cp) =
     >    -unshu*vatren(nrofon,q1t,prf2cn)+
     >     trshu*vatren(nrofon,q3t,prf2cn)+
     >     trsqu*vatren(nrofon,q6t,prf2cn)
c
           vafott(nrofon,q6,f4cp) = unsde*(vatren(nrofon,q5t,prf1cn)+
     >                             vatren(nrofon,q4t,prf2cn))
c
           vafott(nrofon,q7,f4cp) = trshu*(vatren(nrofon,q2t,prf1cn)+
     >                             vatren(nrofon,q4t,prf1cn)+
     >                             vatren(nrofon,q5t,prf1cn))-
     >                    trstr2*(vatren(nrofon,q1t,prf1cn)+
     >                             vatren(nrofon,q3t,prf1cn))+
     >                    unssz*vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q8,f4cp) = vatren(nrofon,q5t,prf2cn)
c
           elseif ( mod(hetqua(f1hp+3),100).ge.31 .and.
     >              mod(hetqua(f1hp+3),100).le.34 ) then
c
                f1fhp = -filqua(f1hp+3)
                f3fcp = ntrsca(f1fhp+2)
                f1fcp = ntrsca(f1fhp)
                f2fcp = ntrsca(f1fhp+1)

                prftrp(f3fcp) = 1
                prftrp(f1fcp) = 1
                prftrp(f2fcp) = 1
c
c
c           Pour le fils f3fcp
c
c    qi --> qit
            vatrtt(nrofon,q1t,f3fcp) =
     >      -unshu*(vatren(nrofon,q1t,prf1cn)+vatren(nrofon,q3t,prf1cn))
     >      +unsde*(vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))
     >      +unsqu*vatren(nrofon,q6t,prf1cn)

c
            vatrtt(nrofon,q2t,f3fcp) =
     >                 unstr *( vatren(nrofon,q2t,prf1cn)+
     >                          vatren(nrofon,q2t,prf2cn)+
     >                          vatren(nrofon,q3t,prf3cn))
c
c    qi --> qit
            vatrtt(nrofon,q3t,f3fcp) = vatren(nrofon,q5t,prf2cn)
c
c    qi --> qit
            vatrtt(nrofon,q4t,f3fcp) =
     >       trshu*(vatren(nrofon,q2t,prf1cn)+
     >              vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))
     >        -trstr2*(vatren(nrofon,q1t,prf1cn)+
     >                 vatren(nrofon,q3t,prf1cn))
     >        +unssz*vatren(nrofon,q6t,prf1cn)

c
            vatrtt(nrofon,q5t,f3fcp) =
     >     -unshu*vatren(nrofon,q3t,prf2cn)+
     >      trshu*vatren(nrofon,q2t,prf2cn)+
     >      trsqu*vatren(nrofon,q5t,prf2cn)
c
            vatrtt(nrofon,q6t,f3fcp) =
     >     -unshu*unsde*(vatren(nrofon,q1t,prf2cn)+
     >                   vatren(nrofon,q3t,prf1cn))+
     >      trshu*unsde*(vatren(nrofon,q2t,prf2cn)+
     >                   vatren(nrofon,q2t,prf1cn))+
     >      trsqu*unsde*(vatren(nrofon,q5t,prf1cn)+
     >                   vatren(nrofon,q4t,prf2cn))
c
c           Pour le fils f1fcp
c
            vatrtt(nrofon,q1t,f1fcp) = vatrtt(nrofon,q1t,f3fcp)

c
            vatrtt(nrofon,q2t,f1fcp) = vatren(nrofon,q5t,prf2cn)
c
            vatrtt(nrofon,q3t,f1fcp) = vatren(nrofon,q6t,prf2cn)
c
            vatrtt(nrofon,q4t,f1fcp) = vatrtt(nrofon,q6t,f3fcp)
c
            vatrtt(nrofon,q5t,f1fcp) =
     >     -unshu*(vatren(nrofon,q2t,prf2cn)+vatren(nrofon,q1t,prf2cn))
     >     +unsde*(vatren(nrofon,q5t,prf2cn)+vatren(nrofon,q6t,prf2cn))
     >     +unsqu*vatren(nrofon,q4t,prf2cn)
c
            vatrtt(nrofon,q6t,f1fcp) =
     >     unsde*(vatren(nrofon,q4t,prf2cn)+
     >            vatren(nrofon,q5t,prf1cn))
c
c           Pour le fils f2fcp
c
            vatrtt(nrofon,q1t,f2fcp) = vatren(nrofon,q6t,prf2cn)

c
            vatrtt(nrofon,q2t,f2fcp) = vatren(nrofon,q5t,prf2cn)
c
            vatrtt(nrofon,q3t,f2fcp) = vatren(nrofon,q3t,prf2cn)
c
            vatrtt(nrofon,q4t,f2fcp) =
     >     -unshu*(vatren(nrofon,q2t,prf2cn)+vatren(nrofon,q1t,prf2cn))
     >     +unsde*(vatren(nrofon,q5t,prf2cn)+vatren(nrofon,q6t,prf2cn))
     >     +unsqu*vatren(nrofon,q4t,prf2cn)

            vatrtt(nrofon,q5t,f2fcp) =
     >      trshu*vatren(nrofon,q3t,prf2cn)-
     >      unshu*vatren(nrofon,q2t,prf2cn)+
     >      trsqu*vatren(nrofon,q5t,prf2cn)
c
            vatrtt(nrofon,q6t,f2fcp) =
     >      trshu*vatren(nrofon,q3t,prf2cn)-
     >      unshu*vatren(nrofon,q1t,prf2cn)+
     >      trsqu*vatren(nrofon,q6t,prf2cn)
c
            else
c
                codret = codret + 1
c
            endif
 2343    continue
c
c           decoupage en 4 quadrangles d'un quadrangle
c           predecoupe en 3 triangles par l arete a4
c
         elseif (etan .eq. 34) then

         do 2344 , nrofon = 1 , nbfonc
c
c        pour le quadrangle Q1
c
            if ( mod(hetqua(f1hp),100).eq.0 ) then

            prfcap(f1cp) = 1
c
           vafott(nrofon,q1,f1cp) = vatren(nrofon,q3t,prf2cn)
c
           vafott(nrofon,q2,f1cp) = vatren(nrofon,q6t,prf2cn)
c
           vafott(nrofon,q3,f1cp) =
     >    -unshu*(vatren(nrofon,q1t,prf1cn)+vatren(nrofon,q3t,prf1cn))+
     >     unsde*(vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))+
     >     unsqu*vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q4,f1cp) =
     >                 unstr *( vatren(nrofon,q2t,prf1cn)+
     >                          vatren(nrofon,q2t,prf2cn)+
     >                          vatren(nrofon,q3t,prf3cn))
c
           vafott(nrofon,q5,f1cp) =
     >    -unshu*vatren(nrofon,q1t,prf2cn)+
     >     trshu*vatren(nrofon,q3t,prf2cn)+
     >     trsqu*vatren(nrofon,q6t,prf2cn)
c
           vafott(nrofon,q6,f1cp) = unsde*(vatren(nrofon,q5t,prf1cn)+
     >                              vatren(nrofon,q4t,prf2cn))
c
           vafott(nrofon,q7,f1cp) = trshu*(vatren(nrofon,q2t,prf1cn)+
     >                              vatren(nrofon,q4t,prf1cn)+
     >                              vatren(nrofon,q5t,prf1cn))-
     >                     trstr2*(vatren(nrofon,q1t,prf1cn)+
     >                              vatren(nrofon,q3t,prf1cn))+
     >                     unssz*vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q8,f1cp) = vatren(nrofon,q5t,prf2cn)
c
           elseif ( mod(hetqua(f1hp),100).ge.31 .and.
     >              mod(hetqua(f1hp),100).le.34 ) then
c

                f1fhp = -filqua(f1hp)
                f1fcp = ntrsca(f1fhp)
                f2fcp = ntrsca(f1fhp+1)
                f3fcp = ntrsca(f1fhp+2)

                prftrp(f3fcp) = 1
                prftrp(f1fcp) = 1
                prftrp(f2fcp) = 1
c
c
c           Pour le fils f3fcp
c
c    qi --> qit
                vatrtt(nrofon,q1t,f3fcp) = vatren(nrofon,q4t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q2t,f3fcp) = vatren(nrofon,q2t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q3t,f3fcp) = vatren(nrofon,q5t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q4t,f3fcp) =
     >           trshu*vatren(nrofon,q2t,prf3cn)
     >          -unshu*vatren(nrofon,q1t,prf3cn)
     >          +trsqu*vatren(nrofon,q4t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q5t,f3fcp) =
     >           trshu*vatren(nrofon,q2t,prf3cn)
     >          -unshu*vatren(nrofon,q3t,prf3cn)
     >          +trsqu*vatren(nrofon,q5t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q6t,f3fcp) =
     >      -unshu*(vatren(nrofon,q1t,prf3cn)+vatren(nrofon,q3t,prf3cn))
     >      +unsde*(vatren(nrofon,q4t,prf3cn)+vatren(nrofon,q5t,prf3cn))
     >      +unsqu*vatren(nrofon,q6t,prf3cn)
c
c           Pour le fils f1fcp
c
c    qi --> qit
                vatrtt(nrofon,q1t,f1fcp) = vatren(nrofon,q4t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q2t,f1fcp) = vatren(nrofon,q5t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q3t,f1fcp) =
     >      -unshu*(vatren(nrofon,q1t,prf1cn)+vatren(nrofon,q3t,prf1cn))
     >      +unsde*(vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))
     >      +unsqu*vatren(nrofon,q6t,prf1cn)
c
c    qi --> qit
                vatrtt(nrofon,q4t,f1fcp) = vatrtt(nrofon,q6t,f3fcp)
c
c    qi --> qit
                vatrtt(nrofon,q5t,f1fcp) =
     >        -unshu*unsde*(vatren(nrofon,q1t,prf3cn)+
     >                      vatren(nrofon,q1t,prf1cn))
     >        +trshu*unsde*(vatren(nrofon,q3t,prf3cn)+
     >                      vatren(nrofon,q2t,prf1cn))
     >        +trsqu*unsde*(vatren(nrofon,q4t,prf1cn)+
     >                      vatren(nrofon,q6t,prf3cn))
c
c    qi --> qit
                vatrtt(nrofon,q6t,f1fcp) =
     >   unsde*(vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q6t,prf3cn))
c
c           Pour le fils f2fcp
c
c    qi --> qit
                vatrtt(nrofon,q1t,f2fcp) = vatrtt(nrofon,q3t,f1fcp)
c
c    qi --> qit
                vatrtt(nrofon,q2t,f2fcp) = vatrtt(nrofon,q2t,f1fcp)
c
c    qi --> qit
                vatrtt(nrofon,q3t,f2fcp) =
     >                 unstr *( vatren(nrofon,q2t,prf1cn)+
     >                          vatren(nrofon,q2t,prf2cn)+
     >                          vatren(nrofon,q3t,prf3cn))
c
c    qi --> qit
                vatrtt(nrofon,q4t,f2fcp) = vatrtt(nrofon,q5t,f1fcp)
c
c    qi --> qit
                vatrtt(nrofon,q5t,f2fcp) =
     >         trshu*vatren(nrofon,q3t,prf3cn)-
     >         unshu*vatren(nrofon,q2t,prf3cn)+
     >         trsqu*vatren(nrofon,q5t,prf3cn)
c
c    qi --> qit
                vatrtt(nrofon,q6t,f2fcp) =
     >       trshu*(vatren(nrofon,q2t,prf1cn)+
     >              vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))
     >        -trstr2*(vatren(nrofon,q1t,prf1cn)+
     >                 vatren(nrofon,q3t,prf1cn))
     >        +unssz*vatren(nrofon,q6t,prf1cn)
c
c
            else
c
                codret = codret + 1
c
            endif
c
c        pour le quadrangle Q2
c
           prfcap(f2cp) = 1
c
           vafott(nrofon,q1,f2cp) = unsde*(vatren(nrofon,q3t,prf1cn)+
     >                              vatren(nrofon,q1t,prf2cn))
c
           vafott(nrofon,q2,f2cp) = vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q3,f2cp) =
     >    -unshu*(vatren(nrofon,q1t,prf1cn)+vatren(nrofon,q3t,prf1cn))+
     >     unsde*(vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))+
     >     unsqu*vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q4,f2cp) = vatren(nrofon,q6t,prf2cn)
c
           vafott(nrofon,q5,f2cp) =
     >    -unshu*vatren(nrofon,q1t,prf1cn)+
     >     trshu*vatren(nrofon,q3t,prf1cn)+
     >     trsqu*vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q6,f2cp) =  -unshu*vatren(nrofon,q2t,prf1cn)-
     >                     trstr2*(vatren(nrofon,q3t,prf1cn)+
     >                              vatren(nrofon,q1t,prf1cn))+
     >                         trshu*(vatren(nrofon,q4t,prf1cn)+
     >                              vatren(nrofon,q5t,prf1cn))+
     >                      nessz*vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q7,f2cp) = unsde*(vatren(nrofon,q5t,prf1cn)+
     >                              vatren(nrofon,q4t,prf2cn))
c
           vafott(nrofon,q8,f2cp) =
     >    -unshu*vatren(nrofon,q3t,prf2cn)+
     >     trshu*vatren(nrofon,q1t,prf2cn)+
     >     trsqu*vatren(nrofon,q6t,prf2cn)
c
c        pour le quadrangle Q3
c
           prfcap(f3cp) = 1
c
           vafott(nrofon,q1,f3cp) = unsde*(vatren(nrofon,q1t,prf1cn)+
     >                              vatren(nrofon,q1t,prf3cn))
c
           vafott(nrofon,q2,f3cp) =  vatren(nrofon,q4t,prf3cn)
c
           vafott(nrofon,q3,f3cp) =
     >    -unshu*(vatren(nrofon,q1t,prf1cn)+vatren(nrofon,q3t,prf1cn))+
     >     unsde*(vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))+
     >     unsqu*vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q4,f3cp) = vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q5,f3cp) =
     >    -unshu*vatren(nrofon,q2t,prf3cn)+
     >     trshu*vatren(nrofon,q1t,prf3cn)+
     >     trsqu*vatren(nrofon,q4t,prf3cn)
c
           vafott(nrofon,q6,f3cp) = unsde*(vatren(nrofon,q4t,prf1cn)+
     >                              vatren(nrofon,q6t,prf3cn))
c
           vafott(nrofon,q7,f3cp) = -unshu*vatren(nrofon,q2t,prf1cn)-
     >                     trstr2*(vatren(nrofon,q3t,prf1cn)+
     >                              vatren(nrofon,q1t,prf1cn))+
     >                         trshu*(vatren(nrofon,q4t,prf1cn)+
     >                              vatren(nrofon,q5t,prf1cn))+
     >                      nessz*vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q8,f3cp) =
     >    -unshu*vatren(nrofon,q3t,prf1cn)+
     >     trshu*vatren(nrofon,q1t,prf1cn)+
     >     trsqu*vatren(nrofon,q6t,prf1cn)
c
c        pour le quadrangle Q4
c
            if ( mod(hetqua(f1hp+3),100).eq.0 ) then

            prfcap(f4cp) = 1
c
           vafott(nrofon,q1,f4cp) = vatren(nrofon,q3t,prf2cn)
c
           vafott(nrofon,q2,f4cp) =
     >                 unstr *( vatren(nrofon,q2t,prf1cn)+
     >                          vatren(nrofon,q2t,prf2cn)+
     >                          vatren(nrofon,q3t,prf3cn))
c
           vafott(nrofon,q3,f4cp) =
     >    -unshu*(vatren(nrofon,q1t,prf1cn)+vatren(nrofon,q3t,prf1cn))+
     >     unsde*(vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))+
     >     unsqu*vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q4,f4cp) = vatren(nrofon,q4t,prf3cn)
c
           vafott(nrofon,q5,f4cp) = vatren(nrofon,q5t,prf3cn)
c
           vafott(nrofon,q6,f4cp) = trshu*(vatren(nrofon,q2t,prf1cn)+
     >                              vatren(nrofon,q4t,prf1cn)+
     >                              vatren(nrofon,q5t,prf1cn))-
     >                     trstr2*(vatren(nrofon,q1t,prf1cn)+
     >                              vatren(nrofon,q3t,prf1cn))+
     >                     unssz*vatren(nrofon,q6t,prf1cn)
c
           vafott(nrofon,q7,f4cp) = unsde*(vatren(nrofon,q4t,prf1cn)+
     >                              vatren(nrofon,q6t,prf3cn))
c
           vafott(nrofon,q8,f4cp) =
     >    -unshu*vatren(nrofon,q1t,prf3cn)+
     >     trshu*vatren(nrofon,q2t,prf3cn)+
     >     trsqu*vatren(nrofon,q4t,prf3cn)
c
c
           elseif ( mod(hetqua(f1hp+3),100).ge.31 .and.
     >              mod(hetqua(f1hp+3),100).le.34 ) then
c
                f1fhp = -filqua(f1hp+3)
                f1fcp = ntrsca(f1fhp)
                f2fcp = ntrsca(f1fhp+1)
                f3fcp = ntrsca(f1fhp+2)
c
                prftrp(f3fcp) = 1
                prftrp(f1fcp) = 1
                prftrp(f2fcp) = 1
c
c
c           Pour le fils f3fcp
c
c    qi --> qit
            vatrtt(nrofon,q1t,f3fcp) =
     >      -unshu*(vatren(nrofon,q1t,prf1cn)+vatren(nrofon,q3t,prf1cn))
     >      +unsde*(vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))
     >      +unsqu*vatren(nrofon,q6t,prf1cn)

c
            vatrtt(nrofon,q2t,f3fcp) =
     >                 unstr *( vatren(nrofon,q2t,prf1cn)+
     >                          vatren(nrofon,q2t,prf2cn)+
     >                          vatren(nrofon,q3t,prf3cn))
c
c    qi --> qit
            vatrtt(nrofon,q3t,f3fcp) = vatrtt(nrofon,q5t,prf2cn)
c
c    qi --> qit
            vatrtt(nrofon,q4t,f3fcp) =
     >       trshu*(vatren(nrofon,q2t,prf1cn)+
     >              vatren(nrofon,q4t,prf1cn)+vatren(nrofon,q5t,prf1cn))
     >        -trstr2*(vatren(nrofon,q1t,prf1cn)+
     >                 vatren(nrofon,q3t,prf1cn))
     >        +unssz*vatren(nrofon,q6t,prf1cn)

c
            vatrtt(nrofon,q5t,f3fcp) =
     >     -unshu*vatren(nrofon,q3t,prf2cn)+
     >      trshu*vatren(nrofon,q2t,prf2cn)+
     >      trsqu*vatren(nrofon,q5t,prf2cn)
c
            vatrtt(nrofon,q6t,f3fcp) =
     >     -unshu*unsde*(vatren(nrofon,q1t,prf2cn)+
     >                   vatren(nrofon,q3t,prf1cn))+
     >      trshu*unsde*(vatren(nrofon,q2t,prf2cn)+
     >                   vatren(nrofon,q2t,prf1cn))+
     >      trsqu*unsde*(vatren(nrofon,q5t,prf1cn)+
     >                   vatren(nrofon,q4t,prf2cn))
c
c           Pour le fils f1fcp
c
            vatrtt(nrofon,q1t,f1fcp) = vatrtt(nrofon,q1t,f3fcp)

c
            vatrtt(nrofon,q2t,f1fcp) = vatren(nrofon,q5t,prf2cn)
c
            vatrtt(nrofon,q3t,f1fcp) = vatren(nrofon,q6t,prf2cn)
c
            vatrtt(nrofon,q4t,f1fcp) = vatrtt(nrofon,q6t,f3fcp)
c
            vatrtt(nrofon,q5t,f1fcp) =
     >     -unshu*(vatren(nrofon,q2t,prf2cn)+vatren(nrofon,q1t,prf2cn))
     >     +unsde*(vatren(nrofon,q5t,prf2cn)+vatren(nrofon,q6t,prf2cn))
     >     +unsqu*vatren(nrofon,q4t,prf2cn)
c
            vatrtt(nrofon,q6t,f1fcp) =
     >     unsde*(vatren(nrofon,q4t,prf2cn)+
     >            vatren(nrofon,q5t,prf1cn))
c
c           Pour le fils f2fcp
c
            vatrtt(nrofon,q1t,f2fcp) = vatren(nrofon,q6t,prf2cn)

c
            vatrtt(nrofon,q2t,f2fcp) = vatren(nrofon,q5t,prf2cn)
c
            vatrtt(nrofon,q3t,f2fcp) = vatren(nrofon,q3t,prf2cn)
c
            vatrtt(nrofon,q4t,f2fcp) =
     >     -unshu*(vatren(nrofon,q2t,prf2cn)+vatren(nrofon,q1t,prf2cn))
     >     +unsde*(vatren(nrofon,q5t,prf2cn)+vatren(nrofon,q6t,prf2cn))
     >     +unsqu*vatren(nrofon,q4t,prf2cn)
c
            vatrtt(nrofon,q5t,f2fcp) =
     >      trshu*vatren(nrofon,q3t,prf2cn)-
     >      unshu*vatren(nrofon,q2t,prf2cn)+
     >      trsqu*vatren(nrofon,q5t,prf2cn)
c
            vatrtt(nrofon,q6t,f2fcp) =
     >      trshu*vatren(nrofon,q3t,prf2cn)-
     >      unshu*vatren(nrofon,q1t,prf2cn)+
     >      trsqu*vatren(nrofon,q6t,prf2cn)
c
            else
c
                codret = codret + 1
c
            endif
 2344     continue
c
        endif
