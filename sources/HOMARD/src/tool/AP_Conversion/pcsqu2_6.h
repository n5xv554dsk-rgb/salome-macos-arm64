c           .................         .................
c           .       .       .         .      . .      .
c           .       .       .         .     .   .     .
c           .       .       .         .    .     .    .
c           .................  ===>   .   .       .   .
c           .       .       .         .  .         .  .
c           .       .       .         . .           . .
c           .       .       .         ..             ..
c           .................         .................
c
c
            f1hp = -filqua(quhnp1)
            f1cp = ntrsca(f1hp)
            f2cp = ntrsca(f1hp+1)
            f3cp = ntrsca(f1hp+2)
            prftrp(f1cp) = 1
            prftrp(f2cp) = 1
            prftrp(f3cp) = 1
c
            q1t = 1
            q2t = 2
            q3t = 3
            q4t = 4
            q5t = 5
            q6t = 6
c
c    quadrangle predecoupe en 4 quad et decoupe en trois triangles
c    a l'arete a1

            if ( etanp1.eq.31 ) then

            do 2511 , nrofon = 1 , nbfonc
c
c    dans le triangle NT1
c
              vatrtt(nrofon,q1t,f1cp) = vafoen(nrofon,q1,prf4cn)
c
              vatrtt(nrofon,q2t,f1cp) = unsde*(vafoen(nrofon,q2,prf1cn)+
     >                                        vafoen(nrofon,q4,prf2cn))
c
              vatrtt(nrofon,q3t,f1cp) = vafoen(nrofon,q1,prf3cn)
c
              vatrtt(nrofon,q4t,f1cp) = unsde*(vafoen(nrofon,q7,prf1cn)+
     >                                        vafoen(nrofon,q6,prf4cn))
c
              vatrtt(nrofon,q5t,f1cp) = unsde*(vafoen(nrofon,q6,prf2cn)+
     >                                        vafoen(nrofon,q7,prf3cn))
c
              vatrtt(nrofon,q6t,f1cp) = unsde*(vafoen(nrofon,q2,prf3cn)+
     >                                        vafoen(nrofon,q4,prf4cn))
c
c    dans le triangle NT2
c
              vatrtt(nrofon,q1t,f2cp) = vafoen(nrofon,q1,prf3cn)
c
              vatrtt(nrofon,q2t,f2cp) = vafoen(nrofon,q4,prf2cn)
c
              vatrtt(nrofon,q3t,f2cp) = vafoen(nrofon,q1,prf2cn)
c
              vatrtt(nrofon,q4t,f2cp) = unsde*(vafoen(nrofon,q6,prf2cn)+
     >                                        vafoen(nrofon,q7,prf3cn))
c
              vatrtt(nrofon,q5t,f2cp) = vafoen(nrofon,q8,prf2cn)
c
              vatrtt(nrofon,q6t,f2cp) = unsde*(vafoen(nrofon,q2,prf2cn)+
     >                                        vafoen(nrofon,q4,prf3cn))
c
c    dans le triangle NT3
c
              vatrtt(nrofon,q1t,f3cp) = vafoen(nrofon,q1,prf4cn)
c
              vatrtt(nrofon,q2t,f3cp) = vafoen(nrofon,q1,prf1cn)
c
              vatrtt(nrofon,q3t,f3cp) = vafoen(nrofon,q2,prf1cn)
c
              vatrtt(nrofon,q4t,f3cp) = unsde*(vafoen(nrofon,q4,prf1cn)+
     >                                        vafoen(nrofon,q2,prf4cn))
c
              vatrtt(nrofon,q5t,f3cp) = vafoen(nrofon,q5,prf1cn)
c
              vatrtt(nrofon,q6t,f3cp) = unsde*(vafoen(nrofon,q7,prf1cn)+
     >                                        vafoen(nrofon,q6,prf4cn))
c
 2511       continue
c
c    quadrangle predecoupe en 4 quad et decoupe en trois triangles
c    a l'arete a2
c
            elseif ( etanp1.eq.32 ) then
c
            do 2512 , nrofon = 1 , nbfonc
c    dans le triangle NT1
c
              vatrtt(nrofon,q1t,f1cp) = vafoen(nrofon,q1,prf1cn)
c
              vatrtt(nrofon,q2t,f1cp) = unsde*(vafoen(nrofon,q2,prf2cn)+
     >                                        vafoen(nrofon,q4,prf3cn))
c
              vatrtt(nrofon,q3t,f1cp) = vafoen(nrofon,q1,prf4cn)
c
              vatrtt(nrofon,q4t,f1cp) = unsde*(vafoen(nrofon,q6,prf1cn)+
     >                                        vafoen(nrofon,q7,prf2cn))
c
              vatrtt(nrofon,q5t,f1cp) = unsde*(vafoen(nrofon,q6,prf3cn)+
     >                                        vafoen(nrofon,q7,prf4cn))
c
              vatrtt(nrofon,q6t,f1cp) = unsde*(vafoen(nrofon,q4,prf1cn)+
     >                                        vafoen(nrofon,q2,prf4cn))
c
c    dans le triangle NT2
c
              vatrtt(nrofon,q1t,f2cp) = vafoen(nrofon,q1,prf4cn)
c
              vatrtt(nrofon,q2t,f2cp) = vafoen(nrofon,q4,prf3cn)
c
              vatrtt(nrofon,q3t,f2cp) = vafoen(nrofon,q1,prf3cn)
c
              vatrtt(nrofon,q4t,f2cp) = unsde*(vafoen(nrofon,q6,prf3cn)+
     >                                        vafoen(nrofon,q7,prf4cn))
c
              vatrtt(nrofon,q5t,f2cp) = vafoen(nrofon,q8,prf3cn)
c
              vatrtt(nrofon,q6t,f2cp) = unsde*(vafoen(nrofon,q2,prf3cn)+
     >                                        vafoen(nrofon,q4,prf4cn))
c
c    dans le triangle NT3
c
              vatrtt(nrofon,q1t,f3cp) = vafoen(nrofon,q1,prf1cn)
c
              vatrtt(nrofon,q2t,f3cp) = vafoen(nrofon,q1,prf2cn)
c
              vatrtt(nrofon,q3t,f3cp) = vafoen(nrofon,q2,prf2cn)
c
              vatrtt(nrofon,q4t,f3cp) = unsde*(vafoen(nrofon,q2,prf1cn)+
     >                                        vafoen(nrofon,q4,prf2cn))
c
              vatrtt(nrofon,q5t,f3cp) = vafoen(nrofon,q5,prf2cn)
c
              vatrtt(nrofon,q6t,f3cp) = unsde*(vafoen(nrofon,q6,prf1cn)+
     >                                        vafoen(nrofon,q7,prf2cn))
c
 2512       continue
c
c    quadrangle predecoupe en 4 quad et decoupe en trois triangles
c    a l'arete a3
c
            elseif ( etanp1.eq.33 ) then
c
            do 2513 , nrofon = 1 , nbfonc
c    dans le triangle NT1
c
              vatrtt(nrofon,q1t,f1cp) = vafoen(nrofon,q1,prf2cn)
c
              vatrtt(nrofon,q2t,f1cp) = unsde*(vafoen(nrofon,q2,prf3cn)+
     >                                        vafoen(nrofon,q4,prf4cn))
c
              vatrtt(nrofon,q3t,f1cp) = vafoen(nrofon,q1,prf1cn)
c
              vatrtt(nrofon,q4t,f1cp) = unsde*(vafoen(nrofon,q6,prf2cn)+
     >                                        vafoen(nrofon,q7,prf3cn))
c
              vatrtt(nrofon,q5t,f1cp) = unsde*(vafoen(nrofon,q7,prf1cn)+
     >                                        vafoen(nrofon,q6,prf4cn))
c
              vatrtt(nrofon,q6t,f1cp) = unsde*(vafoen(nrofon,q2,prf1cn)+
     >                                        vafoen(nrofon,q4,prf2cn))
c
c    dans le triangle NT2
c
              vatrtt(nrofon,q1t,f2cp) = vafoen(nrofon,q1,prf1cn)
c
              vatrtt(nrofon,q2t,f2cp) = vafoen(nrofon,q4,prf4cn)
c
              vatrtt(nrofon,q3t,f2cp) = vafoen(nrofon,q1,prf4cn)
c
              vatrtt(nrofon,q4t,f2cp) = vatrtt(nrofon,q5t,f1cp)
c
              vatrtt(nrofon,q5t,f2cp) = vafoen(nrofon,q8,prf4cn)
c
              vatrtt(nrofon,q6t,f2cp) = unsde*(vafoen(nrofon,q4,prf1cn)+
     >                                        vafoen(nrofon,q2,prf4cn))
c
c    dans le triangle NT3
c
              vatrtt(nrofon,q1t,f3cp) = vafoen(nrofon,q1,prf2cn)
c
              vatrtt(nrofon,q2t,f3cp) = vafoen(nrofon,q1,prf3cn)
c
              vatrtt(nrofon,q3t,f3cp) = vafoen(nrofon,q2,prf3cn)
c
              vatrtt(nrofon,q4t,f3cp) = unsde*(vafoen(nrofon,q2,prf2cn)+
     >                                        vafoen(nrofon,q4,prf3cn))
c
              vatrtt(nrofon,q5t,f3cp) = vafoen(nrofon,q5,prf3cn)
c
              vatrtt(nrofon,q6t,f3cp) = vatrtt(nrofon,q4t,f1cp)
c
 2513       continue
c
c    quadrangle predecoupe en 4 quad et decoupe en trois triangles
c    a l'arete a4
c
            elseif ( etanp1.eq.34 ) then
c
            do 2514 , nrofon = 1 , nbfonc
c    dans le triangle NT1
c
              vatrtt(nrofon,q1t,f1cp) = vafoen(nrofon,q1,prf3cn)
c
              vatrtt(nrofon,q2t,f1cp) = unsde*(vafoen(nrofon,q4,prf1cn)+
     >                                         vafoen(nrofon,q2,prf4cn))
c
              vatrtt(nrofon,q3t,f1cp) = vafoen(nrofon,q1,prf2cn)
c
              vatrtt(nrofon,q4t,f1cp) = unsde*(vafoen(nrofon,q6,prf3cn)+
     >                                        vafoen(nrofon,q7,prf4cn))
c
              vatrtt(nrofon,q5t,f1cp) = unsde*(vafoen(nrofon,q6,prf1cn)+
     >                                        vafoen(nrofon,q7,prf2cn))
c
              vatrtt(nrofon,q6t,f1cp) = unsde*(vafoen(nrofon,q2,prf2cn)+
     >                                        vafoen(nrofon,q4,prf3cn))
c
c    dans le triangle NT2
c
              vatrtt(nrofon,q1t,f2cp) = vafoen(nrofon,q1,prf2cn)
c
              vatrtt(nrofon,q2t,f2cp) = vafoen(nrofon,q4,prf1cn)
c
              vatrtt(nrofon,q3t,f2cp) = vafoen(nrofon,q1,prf1cn)
c
              vatrtt(nrofon,q4t,f2cp) = vatrtt(nrofon,q5t,f1cp)
c
              vatrtt(nrofon,q5t,f2cp) = vafoen(nrofon,q8,prf1cn)
c
              vatrtt(nrofon,q6t,f2cp) = unsde*(vafoen(nrofon,q2,prf1cn)+
     >                                        vafoen(nrofon,q4,prf2cn))
c
c    dans le triangle NT3
c
              vatrtt(nrofon,q1t,f3cp) = vafoen(nrofon,q1,prf3cn)
c
              vatrtt(nrofon,q2t,f3cp) = vafoen(nrofon,q1,prf4cn)
c
              vatrtt(nrofon,q3t,f3cp) = vafoen(nrofon,q2,prf4cn)
c
              vatrtt(nrofon,q4t,f3cp) = unsde*(vafoen(nrofon,q2,prf3cn)+
     >                                        vafoen(nrofon,q4,prf4cn))
c
              vatrtt(nrofon,q5t,f3cp) = vafoen(nrofon,q5,prf4cn)
c
              vatrtt(nrofon,q6t,f3cp) = vatrtt(nrofon,q4t,f1cp)
c
 2514       continue
c
            endif
