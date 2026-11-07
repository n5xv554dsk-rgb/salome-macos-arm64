# -*- coding: utf-8 -*-
def _exec(x,y,z):
  s = x + y
  t = "{}={}".format(z,repr(s))
  return s,t
