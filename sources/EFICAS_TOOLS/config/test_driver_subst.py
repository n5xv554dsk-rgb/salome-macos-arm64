#! /usr/bin/env python
# -*- coding:utf-8 -*-
import sys

#print(sys.argv[:])

import @module@ as mdm
import pyxb

#THESE CONFIGURATION LINES ARE FOR ADVANCED INTERNAL TEST ONLY, YOU DON'T NEED TO CONFIGURE PYXB LIKE THIS  
#mdm.pyxb.GlobalValidationConfig._setContentInfluencesGeneration(mdm.pyxb.GlobalValidationConfig.NEVER)
mdm.pyxb.GlobalValidationConfig._setContentInfluencesGeneration(mdm.pyxb.GlobalValidationConfig.ALWAYS)
mdm.pyxb.GlobalValidationConfig._setInvalidElementInContent(mdm.pyxb.GlobalValidationConfig.RAISE_EXCEPTION)
mdm.pyxb.GlobalValidationConfig._setOrphanElementInContent(mdm.pyxb.GlobalValidationConfig.RAISE_EXCEPTION)

o1 = mdm.CreateFromDocument(open('@file@').read())

filename='@file@'+'.rewrite'
with open(filename, "w") as fp:
    fp.write(o1.toDOM().toprettyxml())
    print("File ",'@file@', " has been loaded and rewrite into ",filename)

