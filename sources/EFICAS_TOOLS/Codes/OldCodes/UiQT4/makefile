PYUIC = pyuic4
QTRELEASE = lrelease-qt4
.PHONY : all
.SUFFIXES : .ui .py .ts .qm


PY_FILES = myMain.py desBaseWidget.py desChoixCata.py desChoixCode.py desChoixLangue.py desChoixCommandes.py \
        desRecherche.py desRechercheCatalogue.py \
	desSelectVal.py desViewTexte.py desViewRegles.py desVisu.py desWidgetCreeParam.py desWidgetCommande.py \
	desWidgetOptionnel.py desWidgetOptionnelMC.py Tuple2.py Tuple3.py  \
	desWidgetBloc.py desWidgetCB.py desWidgetCommentaire.py desWidgetDate.py \
	desWidgetFact.py desWidgetFactPlie.py desWidgetFormule.py desGroupeOptionnel.py \
	desWidgetHeure.py  desWidgetInformation.py desWidgetInactif.py \
	desWidgetMatrice.py desWidgetParam.py desWidgetPlusieursBase.py desWidgetPlusieursInto.py \
	desWidgetPlusieursIntoOrdonne.py desWidgetPlusieursTuple.py desWidgetRadioButton.py \
	desWidget4a6RadioButton.py desWidgetSimpBase.py desWidgetSDCOInto.py desWidgetSimpBool.py \
        desWidgetSimpSalome.py \
	desWidgetSimpComplexe.py desWidgetSimpFichier.py desWidgetSimpTxt.py desWidgetTuple2.py \
	desWidgetTuple3.py desWidgetVide.py desWidgetUniqueSDCO.py desWidgetPlusieursPlie.py



QM_FILES=eficas_en.qm eficas_fr.qm

%.py:%.ui
	${PYUIC} -x -o $@ $<

%.qm:%.ts
	${QTRELEASE}  -qm $@ $<

all : $(PY_FILES) $(QM_FILES)
clean :
	-rm -rf $(PY_FILES) *.pyc

