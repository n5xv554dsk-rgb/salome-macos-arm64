# -*- coding: utf-8 -*-
import raw.cata_map_genere as mdm
mdm.pyxb.GlobalValidationConfig._setContentInfluencesGeneration(mdm.pyxb.GlobalValidationConfig.ALWAYS)
mdm.pyxb.GlobalValidationConfig._setInvalidElementInContent(mdm.pyxb.GlobalValidationConfig.RAISE_EXCEPTION)
mdm.pyxb.GlobalValidationConfig._setOrphanElementInContent(mdm.pyxb.GlobalValidationConfig.RAISE_EXCEPTION)


print dir(mdm)
