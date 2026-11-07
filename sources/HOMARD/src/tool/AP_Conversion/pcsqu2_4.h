c           .................         .................
c           .      . .      .         ..             ..
c           .     .   .     .         . .           . .
c           .    .     .    .         .  .         .  .
c           .   .       .   .  ===>   .   .       .   .
c           .  .         .  .         .    .     .    .
c           . .           . .         .     .   .     .
c           ..             ..         .      . .      .
c           .................         .................
c
            f1hp = -filqua(quhnp1)
            f1cp = ntrsca(f1hp)
            f2cp = ntrsca(f1hp+1)
            f3cp = ntrsca(f1hp+2)
            prftrp(f1cp) = 1
            prftrp(f2cp) = 1
            prftrp(f3cp) = 1
c
            q1tp = 1
            q2tp = 2
            q3tp = 3
            q4tp = 4
            q5tp = 5
            q6tp = 6
c
c   decoupage en 3 par l'arete a2 d'un triangle predecoupe en a1
c
            if ((etan.eq.31).and.( etanp1.eq.32)) then
c
            do 23311 , nrofon = 1 , nbfonc

c   dans le triangle NT1

          vatrtt(nrofon,q1tp,f1cp) = vatren(nrofon,q2t,prf3cn)
c
          vatrtt(nrofon,q2tp,f1cp) = vatren(nrofon,q6t,prf2cn)
c
          vatrtt(nrofon,q3tp,f1cp) = unsde*(vatren(nrofon,q1t,prf1cn)+
     >                              vatren(nrofon,q1t,prf3cn))
c
          vatrtt(nrofon,q4tp,f1cp) = trshu*(vatren(nrofon,q2t,prf1cn)+
     >                              vatren(nrofon,q4t,prf1cn)+
     >                              vatren(nrofon,q5t,prf1cn))-
     >                    trstr2*(vatren(nrofon,q1t,prf1cn)+
     >                              vatren(nrofon,q3t,prf1cn))+
     >                    unssz*vatren(nrofon,q6t,prf1cn)
c
          vatrtt(nrofon,q5tp,f1cp) = -unshu*vatren(nrofon,q2t,prf1cn)-
     >                     trstr2*(vatren(nrofon,q3t,prf1cn)+
     >                              vatren(nrofon,q1t,prf1cn))+
     >                         trshu*(vatren(nrofon,q4t,prf1cn)+
     >                              vatren(nrofon,q5t,prf1cn))+
     >                     nessz*vatren(nrofon,q6t,prf1cn)
c
          vatrtt(nrofon,q6tp,f1cp) =vatren(nrofon,q4t,prf3cn)
c
c   dans le triangle NT2
c
          vatrtt(nrofon,q1tp,f2cp) = vatren(nrofon,q1t,prf1cn)
c
          vatrtt(nrofon,q2tp,f2cp) = vatren(nrofon,q6t,prf2cn)
c
          vatrtt(nrofon,q3tp,f2cp) = unsde*(vatren(nrofon,q3t,prf1cn)+
     >                              vatren(nrofon,q1t,prf2cn))
c
          vatrtt(nrofon,q4tp,f2cp) = vatrtt(nrofon,q5t,f1cp)
c
          vatrtt(nrofon,q5tp,f2cp) = -unshu*vatren(nrofon,q3t,prf2cn)+
     >                          trshu*vatren(nrofon,q1t,prf2cn)+
     >                          trsqu*vatren(nrofon,q6t,prf2cn)
c
          vatrtt(nrofon,q6tp,f2cp) =vatren(nrofon,q6t,prf1cn)
c
c   dans le triangle NT3
c
          vatrtt(nrofon,q1tp,f3cp) = vatren(nrofon,q2t,prf3cn)
c
          vatrtt(nrofon,q2tp,f3cp) = vatren(nrofon,q3t,prf2cn)
c
          vatrtt(nrofon,q3tp,f3cp) = vatren(nrofon,q6t,prf2cn)
c
          vatrtt(nrofon,q4tp,f3cp) = unstr*(vatren(nrofon,q2t,prf1cn)+
     >                              vatren(nrofon,q2t,prf2cn)+
     >                              vatren(nrofon,q3t,prf3cn))
c
          vatrtt(nrofon,q5tp,f3cp) = -unshu*vatren(nrofon,q1t,prf2cn)+
     >                          trshu*vatren(nrofon,q3t,prf2cn)+
     >                          trsqu*vatren(nrofon,q6t,prf2cn)
c
          vatrtt(nrofon,q6tp,f3cp) = vatrtt(nrofon,q4t,f1cp)
23311       continue
c
c   decoupage en 3 par l'arete a3 d'un triangle predecoupe en a1
c
            elseif ((etan.eq.31).and.( etanp1.eq.33)) then
c
            do 23312 , nrofon = 1 , nbfonc
c
c   dans le triangle NT1
c
           vatrtt(nrofon,q1tp,f1cp) = vatren(nrofon,q3t,prf2cn)
c
           vatrtt(nrofon,q2tp,f1cp) = vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q3tp,f1cp) = vatren(nrofon,q2t,prf3cn)
c
           vatrtt(nrofon,q4tp,f1cp) = unsde*(vatren(nrofon,q5t,prf1cn)+
     >                                vatren(nrofon,q4t,prf2cn))
c
           vatrtt(nrofon,q5tp,f1cp) = unsde*(vatren(nrofon,q4t,prf1cn)+
     >                                vatren(nrofon,q6t,prf3cn))
c
           vatrtt(nrofon,q6tp,f1cp) = unstr*(vatren(nrofon,q2t,prf1cn)+
     >                                vatren(nrofon,q2t,prf2cn)+
     >                                vatren(nrofon,q3t,prf3cn))

c   dans le triangle NT2
c
           vatrtt(nrofon,q1tp,f2cp) = vatren(nrofon,q2t,prf3cn)
c
           vatrtt(nrofon,q2tp,f2cp) = vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q3tp,f2cp) = unsde*(vatren(nrofon,q1t,prf1cn)+
     >                                vatren(nrofon,q1t,prf3cn))
c
           vatrtt(nrofon,q4tp,f2cp) = vatrtt(nrofon,q5t,f1cp)
c
           vatrtt(nrofon,q5tp,f2cp) = -unshu*vatren(nrofon,q3t,prf1cn)+
     >                            trshu*vatren(nrofon,q1t,prf1cn)+
     >                            trsqu*vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q6tp,f2cp) =vatren(nrofon,q4t,prf3cn)
c
c   dans le triangle NT3
c
           vatrtt(nrofon,q1tp,f3cp) = vatren(nrofon,q3t,prf2cn)
c
           vatrtt(nrofon,q2tp,f3cp) = unsde*(vatren(nrofon,q1t,prf2cn)+
     >                                vatren(nrofon,q3t,prf1cn))
c
           vatrtt(nrofon,q3tp,f3cp) = vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q4tp,f3cp) = vatren(nrofon,q6t,prf2cn)
c
           vatrtt(nrofon,q5tp,f3cp) = -unshu*vatren(nrofon,q1t,prf1cn)+
     >                            trshu*vatren(nrofon,q3t,prf1cn)+
     >                            trsqu*vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q6tp,f3cp) = vatrtt(nrofon,q4t,f1cp)
c
23312       continue
c
c   decoupage en 3 par l'arete a4 d'un triangle predecoupe en a1
c
            elseif ((etan.eq.31).and.( etanp1.eq.34)) then
c
            do 23313 , nrofon = 1 , nbfonc
c
c   dans le triangle NT1
c
           vatrtt(nrofon,q1tp,f1cp) = unsde*(vatren(nrofon,q1t,prf2cn)+
     >                                vatren(nrofon,q3t,prf1cn))
c
           vatrtt(nrofon,q2tp,f1cp) = vatren(nrofon,q4t,prf3cn)
c
           vatrtt(nrofon,q3tp,f1cp) = vatren(nrofon,q3t,prf2cn)
c
           vatrtt(nrofon,q4tp,f1cp) = -unshu*vatren(nrofon,q2t,prf1cn)-
     >                       trstr2*(vatren(nrofon,q3t,prf1cn)+
     >                                vatren(nrofon,q1t,prf1cn))+
     >                           trshu*(vatren(nrofon,q4t,prf1cn)+
     >                                vatren(nrofon,q5t,prf1cn))+
     >                       nessz*vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q5tp,f1cp) = trshu*(vatren(nrofon,q2t,prf1cn)+
     >                                vatren(nrofon,q4t,prf1cn)+
     >                                vatren(nrofon,q5t,prf1cn))-
     >                      trstr2*(vatren(nrofon,q1t,prf1cn)+
     >                                vatren(nrofon,q3t,prf1cn))+
     >                      unssz*vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q6tp,f1cp) = vatren(nrofon,q6t,prf2cn)
c
c   dans le triangle NT2
c
           vatrtt(nrofon,q1tp,f2cp) = vatren(nrofon,q3t,prf2cn)
c
           vatrtt(nrofon,q2tp,f2cp) = vatren(nrofon,q4t,prf3cn)
c
           vatrtt(nrofon,q3tp,f2cp) = vatren(nrofon,q2t,prf3cn)
c
           vatrtt(nrofon,q4tp,f2cp) = vatrtt(nrofon,q5t,f1cp)
c
           vatrtt(nrofon,q5tp,f2cp) = -unshu*vatren(nrofon,q1t,prf3cn)+
     >                            trshu*vatren(nrofon,q2t,prf3cn)+
     >                            trsqu*vatren(nrofon,q4t,prf3cn)
c
           vatrtt(nrofon,q6tp,f2cp) = unstr*(vatren(nrofon,q2t,prf1cn)+
     >                                vatren(nrofon,q2t,prf2cn)+
     >                                vatren(nrofon,q3t,prf3cn))
c
c   dans le triangle NT3
c
           vatrtt(nrofon,q1tp,f3cp) = vatren(nrofon,q3t,prf1cn)
c
           vatrtt(nrofon,q2tp,f3cp) = unsde*(vatren(nrofon,q1t,prf1cn)+
     >                                vatren(nrofon,q1t,prf3cn))
c
           vatrtt(nrofon,q3tp,f3cp) = vatren(nrofon,q4t,prf3cn)
c
           vatrtt(nrofon,q4tp,f3cp) = vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q5tp,f3cp) = -unshu*vatren(nrofon,q2t,prf3cn)+
     >                            trshu*vatren(nrofon,q1t,prf3cn)+
     >                            trsqu*vatren(nrofon,q4t,prf3cn)
c
           vatrtt(nrofon,q6tp,f3cp) = vatrtt(nrofon,q4t,f1cp)
c
23313       continue
c
c   decoupage en 3 par l'arete a3 d'un triangle predecoupe en a2
c
            elseif ((etan.eq.32).and.( etanp1.eq.33)) then
c
            do 23321 , nrofon = 1 , nbfonc
c
c   dans le triangle NT1
c
           vatrtt(nrofon,q1tp,f1cp) = vatren(nrofon,q2t,prf3cn)
c
           vatrtt(nrofon,q2tp,f1cp) = vatren(nrofon,q6t,prf2cn)
c
           vatrtt(nrofon,q3tp,f1cp) = unsde*(vatren(nrofon,q1t,prf1cn)+
     >                                vatren(nrofon,q1t,prf3cn))
c
           vatrtt(nrofon,q4tp,f1cp) = trshu*(vatren(nrofon,q2t,prf1cn)+
     >                                vatren(nrofon,q4t,prf1cn)+
     >                                vatren(nrofon,q5t,prf1cn))-
     >                      trstr2*(vatren(nrofon,q1t,prf1cn)+
     >                                vatren(nrofon,q3t,prf1cn))+
     >                      unssz*vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q5tp,f1cp) = -unshu*vatren(nrofon,q2t,prf1cn)-
     >                       trstr2*(vatren(nrofon,q3t,prf1cn)+
     >                                vatren(nrofon,q1t,prf1cn))+
     >                           trshu*(vatren(nrofon,q4t,prf1cn)+
     >                                vatren(nrofon,q5t,prf1cn))+
     >                       nessz*vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q6tp,f1cp) = vatren(nrofon,q4t,prf3cn)
c
c   dans le triangle NT2
c
           vatrtt(nrofon,q1tp,f2cp) = vatren(nrofon,q1t,prf1cn)
c
           vatrtt(nrofon,q2tp,f2cp) = vatren(nrofon,q6t,prf2cn)
c
           vatrtt(nrofon,q3tp,f2cp) = unsde*(vatren(nrofon,q3t,prf1cn)+
     >                                vatren(nrofon,q1t,prf2cn))
c
           vatrtt(nrofon,q4tp,f2cp) = vatrtt(nrofon,q5t,f1cp)
c
           vatrtt(nrofon,q5tp,f2cp) = -unshu*vatren(nrofon,q3t,prf2cn)+
     >                            trshu*vatren(nrofon,q1t,prf2cn)+
     >                            trsqu*vatren(nrofon,q6t,prf2cn)
c
           vatrtt(nrofon,q6tp,f2cp) = vatren(nrofon,q4t,prf3cn)
c
c   dans le triangle NT3
c
           vatrtt(nrofon,q1tp,f3cp) = vatren(nrofon,q2t,prf3cn)
c
           vatrtt(nrofon,q2tp,f3cp) = vatren(nrofon,q3t,prf2cn)
c
           vatrtt(nrofon,q3tp,f3cp) = vatren(nrofon,q6t,prf2cn)
c
           vatrtt(nrofon,q4tp,f3cp) = unstr*(vatren(nrofon,q2t,prf1cn)+
     >                                vatren(nrofon,q2t,prf2cn)+
     >                                vatren(nrofon,q3t,prf3cn))
c
           vatrtt(nrofon,q5tp,f3cp) = -unshu*vatren(nrofon,q1t,prf2cn)+
     >                            trshu*vatren(nrofon,q3t,prf2cn)+
     >                            trsqu*vatren(nrofon,q6t,prf2cn)
c
           vatrtt(nrofon,q6tp,f3cp) = vatrtt(nrofon,q4t,f1cp)
23321       continue
c
c   decoupage en 3 par l'arete a4 d'un triangle predecoupe en a2
c
            elseif ((etan.eq.32).and.( etanp1.eq.34)) then
c
            do 23322 , nrofon = 1 , nbfonc
c
c   dans le triangle NT1
c
           vatrtt(nrofon,q1tp,f1cp) = vatren(nrofon,q3t,prf2cn)
c
           vatrtt(nrofon,q2tp,f1cp) = vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q3tp,f1cp) = vatren(nrofon,q2t,prf3cn)
c
           vatrtt(nrofon,q4tp,f1cp) = unsde*(vatren(nrofon,q5t,prf1cn)+
     >                                vatren(nrofon,q4t,prf2cn))
c
           vatrtt(nrofon,q5tp,f1cp) = unsde*(vatren(nrofon,q4t,prf1cn)+
     >                                vatren(nrofon,q6t,prf3cn))
c
           vatrtt(nrofon,q6tp,f1cp) = unstr*(vatren(nrofon,q2t,prf1cn)+
     >                                vatren(nrofon,q2t,prf2cn)+
     >                                vatren(nrofon,q3t,prf3cn))
c
c   dans le triangle NT2
c
           vatrtt(nrofon,q1tp,f2cp) = vatren(nrofon,q2t,prf3cn)
c
           vatrtt(nrofon,q2tp,f2cp) = vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q3tp,f2cp) = unsde*(vatren(nrofon,q1t,prf1cn)+
     >                                vatren(nrofon,q1t,prf3cn))
c
           vatrtt(nrofon,q4tp,f2cp) = unsde*(vatren(nrofon,q4t,prf1cn)+
     >                                vatren(nrofon,q6t,prf3cn))
c
           vatrtt(nrofon,q5tp,f2cp) = -unshu*vatren(nrofon,q3t,prf1cn)+
     >                            trshu*vatren(nrofon,q1t,prf1cn)+
     >                            trsqu*vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q6tp,f2cp) = vatren(nrofon,q4t,prf3cn)
c
c   dans le triangle NT3
c
           vatrtt(nrofon,q1tp,f3cp) = vatren(nrofon,q3t,prf2cn)
c
           vatrtt(nrofon,q2tp,f3cp) = unsde*(vatren(nrofon,q3t,prf1cn)+
     >                                vatren(nrofon,q1t,prf2cn))
c
           vatrtt(nrofon,q3tp,f3cp) = vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q4tp,f3cp) = vatren(nrofon,q6t,prf2cn)
c
           vatrtt(nrofon,q5tp,f3cp) = -unshu*vatren(nrofon,q1t,prf1cn)+
     >                            trshu*vatren(nrofon,q3t,prf1cn)+
     >                            trsqu*vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q6tp,f3cp) = unsde*(vatren(nrofon,q5t,prf1cn)+
     >                                vatren(nrofon,q4t,prf2cn))
23322       continue
c
c   decoupage en 3 par l'arete a1 d'un triangle predecoupe en a2
c
            elseif ((etan.eq.32).and.( etanp1.eq.31)) then
c
            do 23323 , nrofon = 1 , nbfonc
c
c   dans le triangle NT1
c
           vatrtt(nrofon,q1tp,f1cp) = unsde*(vatren(nrofon,q3t,prf1cn)+
     >                                vatren(nrofon,q1t,prf2cn))
c
           vatrtt(nrofon,q2tp,f1cp) = vatren(nrofon,q4t,prf3cn)
c
           vatrtt(nrofon,q3tp,f1cp) = vatren(nrofon,q3t,prf2cn)
c
           vatrtt(nrofon,q4tp,f1cp) = -unshu*vatren(nrofon,q2t,prf1cn)-
     >                       trstr2*(vatren(nrofon,q3t,prf1cn)+
     >                                vatren(nrofon,q1t,prf1cn))+
     >                           trshu*(vatren(nrofon,q4t,prf1cn)+
     >                                vatren(nrofon,q5t,prf1cn))+
     >                       nessz*vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q5tp,f1cp) = trshu*(vatren(nrofon,q2t,prf1cn)+
     >                                vatren(nrofon,q4t,prf1cn)+
     >                                vatren(nrofon,q5t,prf1cn))-
     >                      trstr2*(vatren(nrofon,q1t,prf1cn)+
     >                                vatren(nrofon,q3t,prf1cn))+
     >                      unssz*vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q6tp,f1cp) = vatren(nrofon,q6t,prf2cn)
c
c   dans le triangle NT2
c
           vatrtt(nrofon,q1tp,f2cp) = vatren(nrofon,q3t,prf2cn)
c
           vatrtt(nrofon,q2tp,f2cp) = vatren(nrofon,q4t,prf3cn)
c
           vatrtt(nrofon,q3tp,f2cp) = vatren(nrofon,q2t,prf3cn)
c
           vatrtt(nrofon,q4tp,f2cp) = vatrtt(nrofon,q5t,f1cp)
c
           vatrtt(nrofon,q5tp,f2cp) = -unshu*vatren(nrofon,q1t,prf3cn)+
     >                            trshu*vatren(nrofon,q2t,prf3cn)+
     >                            trsqu*vatren(nrofon,q4t,prf3cn)
c
           vatrtt(nrofon,q6tp,f2cp) = unstr*(vatren(nrofon,q2t,prf1cn)+
     >                                vatren(nrofon,q2t,prf2cn)+
     >                                vatren(nrofon,q3t,prf3cn))
c
c   dans le triangle NT3
c
           vatrtt(nrofon,q1tp,f3cp) = vatren(nrofon,q3t,prf1cn)
c
           vatrtt(nrofon,q2tp,f3cp) = unsde*(vatren(nrofon,q1t,prf1cn)+
     >                                vatren(nrofon,q1t,prf3cn))
c
           vatrtt(nrofon,q3tp,f3cp) = vatren(nrofon,q4t,prf3cn)
c
           vatrtt(nrofon,q4tp,f3cp) = vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q5tp,f3cp) = -unshu*vatren(nrofon,q2t,prf3cn)+
     >                            trshu*vatren(nrofon,q1t,prf3cn)+
     >                            trsqu*vatren(nrofon,q4t,prf3cn)
c
           vatrtt(nrofon,q6tp,f3cp) = vatrtt(nrofon,q4t,f1cp)
23323       continue
c
c   decoupage en 3 par l'arete a4 d'un triangle predecoupe en a3
c
            elseif ((etan.eq.33).and.( etanp1.eq.34)) then
c
            do 23331 , nrofon = 1 , nbfonc
c
c   dans le triangle NT1
c
           vatrtt(nrofon,q1tp,f1cp) = vatren(nrofon,q2t,prf3cn)
c
           vatrtt(nrofon,q2tp,f1cp) = vatren(nrofon,q6t,prf2cn)
c
           vatrtt(nrofon,q3tp,f1cp) = unsde*(vatren(nrofon,q1t,prf3cn)+
     >                                vatren(nrofon,q1t,prf1cn))
c
           vatrtt(nrofon,q4tp,f1cp) = trshu*(vatren(nrofon,q2t,prf1cn)+
     >                                vatren(nrofon,q4t,prf1cn)+
     >                                vatren(nrofon,q5t,prf1cn))-
     >                      trstr2*(vatren(nrofon,q1t,prf1cn)+
     >                                vatren(nrofon,q3t,prf1cn))+
     >                      unssz*vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q5tp,f1cp) = -unshu*vatren(nrofon,q2t,prf1cn)-
     >                       trstr2*(vatren(nrofon,q3t,prf1cn)+
     >                                vatren(nrofon,q1t,prf1cn))+
     >                           trshu*(vatren(nrofon,q4t,prf1cn)+
     >                                vatren(nrofon,q5t,prf1cn))+
     >                       nessz*vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q6tp,f1cp) = vatren(nrofon,q4t,prf3cn)
c
c   dans le triangle NT2
c
           vatrtt(nrofon,q1tp,f2cp) = vatren(nrofon,q1t,prf1cn)
c
           vatrtt(nrofon,q2tp,f2cp) = vatren(nrofon,q6t,prf2cn)
c
           vatrtt(nrofon,q3tp,f2cp) = unsde*(vatren(nrofon,q3t,prf1cn)+
     >                                vatren(nrofon,q1t,prf2cn))
c
           vatrtt(nrofon,q4tp,f2cp) = vatrtt(nrofon,q5t,f1cp)
c
           vatrtt(nrofon,q5tp,f2cp) = -unshu*vatren(nrofon,q3t,prf2cn)+
     >                            trshu*vatren(nrofon,q1t,prf2cn)+
     >                            trsqu*vatren(nrofon,q6t,prf2cn)
c
           vatrtt(nrofon,q6tp,f2cp) = vatren(nrofon,q6t,prf1cn)
c
c   dans le triangle NT3
c
           vatrtt(nrofon,q1tp,f3cp) = vatren(nrofon,q2t,prf3cn)
c
           vatrtt(nrofon,q2tp,f3cp) = vatren(nrofon,q3t,prf2cn)
c
           vatrtt(nrofon,q3tp,f3cp) = vatren(nrofon,q6t,prf2cn)
c
           vatrtt(nrofon,q4tp,f3cp) = unstr*(vatren(nrofon,q2t,prf1cn)+
     >                                vatren(nrofon,q2t,prf2cn)+
     >                                vatren(nrofon,q3t,prf3cn))
c
           vatrtt(nrofon,q5tp,f3cp) = -unshu*vatren(nrofon,q1t,prf2cn)+
     >                            trshu*vatren(nrofon,q3t,prf2cn)+
     >                            trsqu*vatren(nrofon,q6t,prf2cn)
c
           vatrtt(nrofon,q6tp,f3cp) = vatrtt(nrofon,q4t,f1cp)
23331       continue
c
c   decoupage en 3 par l'arete a1 d'un triangle predecoupe en a3
c
            elseif ((etan.eq.33).and.( etanp1.eq.31)) then
c
            do 23332 , nrofon = 1 , nbfonc
c
c   dans le triangle NT1
c
           vatrtt(nrofon,q1tp,f1cp) = vatren(nrofon,q3t,prf2cn)
c
           vatrtt(nrofon,q2tp,f1cp) = vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q3tp,f1cp) = vatren(nrofon,q2t,prf3cn)
c
           vatrtt(nrofon,q4tp,f1cp) = unsde*(vatren(nrofon,q5t,prf1cn)+
     >                                vatren(nrofon,q4t,prf2cn))
c
           vatrtt(nrofon,q5tp,f1cp) = unsde*(vatren(nrofon,q4t,prf1cn)+
     >                                vatren(nrofon,q6t,prf3cn))
c
           vatrtt(nrofon,q6tp,f1cp) = unstr*(vatren(nrofon,q2t,prf1cn)+
     >                                vatren(nrofon,q2t,prf2cn)+
     >                                vatren(nrofon,q3t,prf3cn))
c
c   dans le triangle NT2
c
           vatrtt(nrofon,q1tp,f2cp) = vatren(nrofon,q2t,prf3cn)
c
           vatrtt(nrofon,q2tp,f2cp) = vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q3tp,f2cp) = unsde*(vatren(nrofon,q1t,prf1cn)+
     >                                vatren(nrofon,q1t,prf3cn))
c
           vatrtt(nrofon,q4tp,f2cp) = vatrtt(nrofon,q5t,f1cp)
c
           vatrtt(nrofon,q5tp,f2cp) = -unshu*vatren(nrofon,q3t,prf1cn)+
     >                            trshu*vatren(nrofon,q1t,prf1cn)+
     >                            trsqu*vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q6tp,f2cp) = vatren(nrofon,q4t,prf3cn)
c
c   dans le triangle NT3
c
           vatrtt(nrofon,q1tp,f3cp) = vatren(nrofon,q3t,prf2cn)
c
           vatrtt(nrofon,q2tp,f3cp) = unsde*(vatren(nrofon,q3t,prf1cn)+
     >                                vatren(nrofon,q1t,prf2cn))
c
           vatrtt(nrofon,q3tp,f3cp) = vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q4tp,f3cp) = vatren(nrofon,q6t,prf2cn)
c
           vatrtt(nrofon,q5tp,f3cp) = -unshu*vatren(nrofon,q1t,prf1cn)+
     >                            trshu*vatren(nrofon,q3t,prf1cn)+
     >                            trsqu*vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q6tp,f3cp) = vatrtt(nrofon,q4t,f1cp)
23332       continue
c
c   decoupage en 3 par l'arete a2 d'un triangle predecoupe en a3
c
            elseif ((etan.eq.33).and.( etanp1.eq.32)) then
c
            do 23333 , nrofon = 1 , nbfonc
c
c   dans le triangle NT1
c
           vatrtt(nrofon,q1tp,f1cp) = unsde*(vatren(nrofon,q1t,prf2cn)+
     >                                vatren(nrofon,q3t,prf1cn))
c
           vatrtt(nrofon,q2tp,f1cp) = vatren(nrofon,q4t,prf3cn)
c
           vatrtt(nrofon,q3tp,f1cp) = vatren(nrofon,q3t,prf2cn)
c
           vatrtt(nrofon,q4tp,f1cp) = -unshu*vatren(nrofon,q2t,prf1cn)-
     >                       trstr2*(vatren(nrofon,q3t,prf1cn)+
     >                                vatren(nrofon,q1t,prf1cn))+
     >                           trshu*(vatren(nrofon,q4t,prf1cn)+
     >                                vatren(nrofon,q5t,prf1cn))+
     >                       nessz*vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q5tp,f1cp) = trshu*(vatren(nrofon,q2t,prf1cn)+
     >                                vatren(nrofon,q4t,prf1cn)+
     >                                vatren(nrofon,q5t,prf1cn))-
     >                      trstr2*(vatren(nrofon,q1t,prf1cn)+
     >                                vatren(nrofon,q3t,prf1cn))+
     >                      unssz*vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q6tp,f1cp) = vatren(nrofon,q6t,prf2cn)
c
c   dans le triangle NT2
c
           vatrtt(nrofon,q1tp,f2cp) = vatren(nrofon,q3t,prf2cn)
c
           vatrtt(nrofon,q2tp,f2cp) = vatren(nrofon,q4t,prf3cn)
c
           vatrtt(nrofon,q3tp,f2cp) = vatren(nrofon,q2t,prf3cn)
c
           vatrtt(nrofon,q4tp,f2cp) = vatrtt(nrofon,q5t,f1cp)
c
           vatrtt(nrofon,q5tp,f2cp) = -unshu*vatren(nrofon,q1t,prf3cn)+
     >                            trshu*vatren(nrofon,q2t,prf3cn)+
     >                            trsqu*vatren(nrofon,q4t,prf3cn)
c
           vatrtt(nrofon,q6tp,f2cp) = unstr*(vatren(nrofon,q2t,prf1cn)+
     >                                vatren(nrofon,q2t,prf2cn)+
     >                                vatren(nrofon,q3t,prf3cn))
c
c   dans le triangle NT3
c
           vatrtt(nrofon,q1tp,f3cp) = vatren(nrofon,q3t,prf1cn)
c
           vatrtt(nrofon,q2tp,f3cp) = unsde*(vatren(nrofon,q1t,prf1cn)+
     >                                vatren(nrofon,q1t,prf3cn))
c
           vatrtt(nrofon,q3tp,f3cp) = vatren(nrofon,q4t,prf3cn)
c
           vatrtt(nrofon,q4tp,f3cp) = vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q5tp,f3cp) = -unshu*vatren(nrofon,q2t,prf3cn)+
     >                            trshu*vatren(nrofon,q1t,prf3cn)+
     >                            trsqu*vatren(nrofon,q4t,prf3cn)
c
           vatrtt(nrofon,q6tp,f3cp) = vatrtt(nrofon,q4t,f1cp)
23333       continue
c
c   decoupage en 3 par l'arete a1 d'un triangle predecoupe en a4
c
            elseif ((etan.eq.34).and.( etanp1.eq.31)) then
c
            do 23341 , nrofon = 1 , nbfonc
c
c   dans le triangle NT1
c
           vatrtt(nrofon,q1tp,f1cp) = vatren(nrofon,q2t,prf3cn)
c
           vatrtt(nrofon,q2tp,f1cp) = vatren(nrofon,q6t,prf2cn)
c
           vatrtt(nrofon,q3tp,f1cp) = unsde*(vatren(nrofon,q1t,prf3cn)+
     >                                vatren(nrofon,q1t,prf1cn))
c
           vatrtt(nrofon,q4tp,f1cp) = trshu*(vatren(nrofon,q2t,prf1cn)+
     >                                vatren(nrofon,q4t,prf1cn)+
     >                                vatren(nrofon,q5t,prf1cn))-
     >                      trstr2*(vatren(nrofon,q1t,prf1cn)+
     >                                vatren(nrofon,q3t,prf1cn))+
     >                      unssz*vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q5tp,f1cp) = -unshu*vatren(nrofon,q2t,prf1cn)-
     >                       trstr2*(vatren(nrofon,q3t,prf1cn)+
     >                                vatren(nrofon,q1t,prf1cn))+
     >                           trshu*(vatren(nrofon,q4t,prf1cn)+
     >                                vatren(nrofon,q5t,prf1cn))+
     >                       nessz*vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q6tp,f1cp) = vatren(nrofon,q4t,prf3cn)
c
c   dans le triangle NT2
c
           vatrtt(nrofon,q1tp,f2cp) = vatren(nrofon,q1t,prf1cn)
c
           vatrtt(nrofon,q2tp,f2cp) = vatren(nrofon,q6t,prf2cn)
c
           vatrtt(nrofon,q3tp,f2cp) = unsde*(vatren(nrofon,q3t,prf1cn)+
     >                                vatren(nrofon,q1t,prf2cn))
c
           vatrtt(nrofon,q4tp,f2cp) = vatrtt(nrofon,q5t,f1cp)
c
           vatrtt(nrofon,q5tp,f2cp) = -unshu*vatren(nrofon,q3t,prf2cn)+
     >                            trshu*vatren(nrofon,q1t,prf2cn)+
     >                            trsqu*vatren(nrofon,q6t,prf2cn)
c
           vatrtt(nrofon,q6tp,f2cp) = vatrtt(nrofon,q6t,f1cp)
c
c   dans le triangle NT3
c
           vatrtt(nrofon,q1tp,f3cp) = vatren(nrofon,q2t,prf3cn)
c
           vatrtt(nrofon,q2tp,f3cp) = vatren(nrofon,q3t,prf2cn)
c
           vatrtt(nrofon,q3tp,f3cp) = vatren(nrofon,q6t,prf2cn)
c
           vatrtt(nrofon,q4tp,f3cp) =  unstr*(vatren(nrofon,q2t,prf1cn)+
     >                                vatren(nrofon,q2t,prf2cn)+
     >                                vatren(nrofon,q3t,prf3cn))
c
           vatrtt(nrofon,q5tp,f3cp) = -unshu*vatren(nrofon,q1t,prf2cn)+
     >                            trshu*vatren(nrofon,q3t,prf2cn)+
     >                            trsqu*vatren(nrofon,q6t,prf2cn)
c
           vatrtt(nrofon,q6tp,f3cp) = vatrtt(nrofon,q4t,f1cp)

23341       continue
c
c   decoupage en 3 par l'arete a2 d'un triangle predecoupe en a4
c
            elseif ((etan.eq.34).and.( etanp1.eq.32)) then
c
            do 23342 , nrofon = 1 , nbfonc
c
c   dans le triangle NT1
c
           vatrtt(nrofon,q1tp,f1cp) = vatren(nrofon,q3t,prf2cn)
c
           vatrtt(nrofon,q2tp,f1cp) = vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q3tp,f1cp) = vatren(nrofon,q2t,prf3cn)
c
           vatrtt(nrofon,q4tp,f1cp) = unsde*(vatren(nrofon,q5t,prf1cn)+
     >                                vatren(nrofon,q4t,prf2cn))
c
           vatrtt(nrofon,q5tp,f1cp) = unsde*(vatren(nrofon,q4t,prf1cn)+
     >                                vatren(nrofon,q6t,prf3cn))
c
           vatrtt(nrofon,q6tp,f1cp) = unstr*(vatren(nrofon,q2t,prf1cn)+
     >                                vatren(nrofon,q2t,prf2cn)+
     >                                vatren(nrofon,q3t,prf3cn))
c
c   dans le triangle NT2
c
           vatrtt(nrofon,q1tp,f2cp) = vatren(nrofon,q2t,prf3cn)
c
           vatrtt(nrofon,q2tp,f2cp) = vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q3tp,f2cp) = unsde*(vatren(nrofon,q1t,prf1cn)+
     >                                vatren(nrofon,q1t,prf3cn))
c
           vatrtt(nrofon,q4tp,f2cp) = vatrtt(nrofon,q5t,f1cp)
c
           vatrtt(nrofon,q5tp,f2cp) = -unshu*vatren(nrofon,q3t,prf1cn)+
     >                            trshu*vatren(nrofon,q1t,prf1cn)+
     >                            trsqu*vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q6t,f2cp) = vatren(nrofon,q4t,prf3cn)
c
c   dans le triangle NT3
c
           vatrtt(nrofon,q1tp,f3cp) = vatren(nrofon,q3t,prf2cn)
c
           vatrtt(nrofon,q2tp,f3cp) = unsde*(vatren(nrofon,q3t,prf1cn)+
     >                                vatren(nrofon,q1t,prf2cn))
c
           vatrtt(nrofon,q3tp,f3cp) = vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q4tp,f3cp) = vatren(nrofon,q6t,prf2cn)
c
           vatrtt(nrofon,q5tp,f3cp) = -unshu*vatren(nrofon,q1t,prf1cn)+
     >                            trshu*vatren(nrofon,q3t,prf1cn)+
     >                            trsqu*vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q6t,f3cp) = vatrtt(nrofon,q4t,f1cp)
c
23342       continue
c
c   decoupage en 3 par l'arete a3 d'un triangle predecoupe en a4
c
            elseif ((etan.eq.34).and.( etanp1.eq.33)) then
c
            do 23343 , nrofon = 1 , nbfonc
c
c   dans le triangle NT1
c
           vatrtt(nrofon,q1tp,f1cp) = unsde*(vatren(nrofon,q1t,prf2cn)+
     >                                vatren(nrofon,q3t,prf1cn))
c
           vatrtt(nrofon,q2tp,f1cp) = vatren(nrofon,q4t,prf3cn)
c
           vatrtt(nrofon,q3tp,f1cp) = vatren(nrofon,q3t,prf2cn)
c
           vatrtt(nrofon,q4tp,f1cp) = -unshu*vatren(nrofon,q2t,prf1cn)-
     >                       trstr2*(vatren(nrofon,q3t,prf1cn)+
     >                                vatren(nrofon,q1t,prf1cn))+
     >                           trshu*(vatren(nrofon,q4t,prf1cn)+
     >                                vatren(nrofon,q5t,prf1cn))+
     >                       nessz*vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q5tp,f1cp) = trshu*(vatren(nrofon,q2t,prf1cn)+
     >                                vatren(nrofon,q4t,prf1cn)+
     >                                vatren(nrofon,q5t,prf1cn))-
     >                      trstr2*(vatren(nrofon,q1t,prf1cn)+
     >                                vatren(nrofon,q3t,prf1cn))+
     >                      unssz*vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q6tp,f1cp) = vatren(nrofon,q6t,prf2cn)
c
c   dans le triangle NT2
c
           vatrtt(nrofon,q1tp,f2cp) = vatren(nrofon,q3t,prf2cn)
c
           vatrtt(nrofon,q2tp,f2cp) = vatren(nrofon,q4t,prf3cn)
c
           vatrtt(nrofon,q3tp,f2cp) = vatren(nrofon,q2t,prf3cn)
c
           vatrtt(nrofon,q4tp,f2cp) = vatrtt(nrofon,q5t,f1cp)
c
           vatrtt(nrofon,q5tp,f2cp) = -unshu*vatren(nrofon,q1t,prf3cn)+
     >                            trshu*vatren(nrofon,q2t,prf3cn)+
     >                            trsqu*vatren(nrofon,q4t,prf3cn)
c
           vatrtt(nrofon,q6tp,f2cp) = unstr*(vatren(nrofon,q2t,prf1cn)+
     >                                vatren(nrofon,q2t,prf2cn)+
     >                                vatren(nrofon,q3t,prf3cn))
c
c   dans le triangle NT3
c
           vatrtt(nrofon,q1tp,f3cp) = vatren(nrofon,q3t,prf1cn)
c
           vatrtt(nrofon,q2tp,f3cp) = unsde*(vatren(nrofon,q1t,prf1cn)+
     >                                vatren(nrofon,q1t,prf3cn))
c
           vatrtt(nrofon,q3tp,f3cp) = vatren(nrofon,q4t,prf3cn)
c
           vatrtt(nrofon,q4tp,f3cp) = vatren(nrofon,q6t,prf1cn)
c
           vatrtt(nrofon,q5tp,f3cp) = -unshu*vatren(nrofon,q2t,prf3cn)+
     >                            trshu*vatren(nrofon,q1t,prf3cn)+
     >                            trsqu*vatren(nrofon,q4t,prf3cn)
c
           vatrtt(nrofon,q6tp,f3cp) = vatrtt(nrofon,q4t,f1cp)
c
23343       continue
            endif
