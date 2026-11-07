# -*- coding: utf-8 -*-

# TODO: Create a main object that point on the different subobjects and force its name

# EFICAS
from Accas import  JDC_CATA_SINGLETON
VERSION_CATALOGUE = "V_0"

from interrogeDB import cherche_code_name
from interrogeDB import cherche_test_name
from interrogeDB import cherche_version
from interrogeDB import cherche_host
from interrogeDB import cherche_max_timestamp
from interrogeDB import cherche_sha1_from_date
from interrogeDB import cherche_in_profile
from interrogeDB import cherche_name
#from interrogeDB import cherche_min_sha1, cherche_max_sha1

JdC = JDC_CATA_SINGLETON(code="GuiProfile")


# import des mots_clefs
from cata_selection import Selection
from cata_selection import PresentationLabels

# pour la partie GUI
from cata_profile import dElementsRecursifs
identifiantSelection = Selection

