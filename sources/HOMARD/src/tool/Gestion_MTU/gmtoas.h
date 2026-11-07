c                                    copyright edf 1999
c
c  gmtoas : les Tableaux pour les Objets Alloues en String
c
c nomobj : nom des objets strutures crees
c nomobc : nom des objets attaches aux champs des objets strutures crees
c nomtbp : nom des types simples de base et des types structures crees
c
      character*8 nomobj(nobjx), nomobc(nobcx)
      character*8 nomtbp( -ntybma : nobjx )
c
      common / gmtoas / nomobj,  nomobc, nomtbp
