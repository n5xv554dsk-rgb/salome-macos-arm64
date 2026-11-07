#!/usr/bin/env python

import sys
import os

if len(sys.argv) != 4:
  print("Usage: test-script.py seta.py setb.py result.txt")

exec(compile(open(sys.argv[1]).read(), sys.argv[1], 'exec'))
exec(compile(open(sys.argv[2]).read(), sys.argv[2], 'exec'))

c = a * b

with open(sys.argv[3], "w") as f:
  f.write('MYENVVAR = "%s"\n' % os.getenv("MYENVVAR"))
  f.write("c = %d\n" % c)
