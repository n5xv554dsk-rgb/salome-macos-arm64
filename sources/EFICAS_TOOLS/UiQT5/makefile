PYUIC = pyuic5
QTRELEASE = lrelease
.PHONY : all
.SUFFIXES : .ui .py .ts .qm


PY_FILES = myMain.py desBaseWidget.py desChoixCata.py desChoixCode.py desChoixCommandes.py \
        desChoixLangue.py desRecherche.py  desRechercheCatalogue.py\
	desSelectVal.py desViewTexte.py desViewRegles.py desVisu.py desWidgetCreeParam.py desWidgetCommande.py \
	desWidgetOptionnel.py Tuple2.py Tuple3.py  Tuple4.py Tuple5.py Tuple6.py Tuple7.py Tuple8.py Tuple9.py\
	Tuple10.py desWidgetBloc.py desWidgetCB.py desWidgetCBIntoSug.py desWidgetCommentaire.py desWidgetDate.py \
	desWidgetFact.py desWidgetFactPlie.py desWidgetFactTableau.py desWidgetFormule.py desGroupeOptionnel.py \
	desWidgetHeure.py  desWidgetInformation.py desWidgetIntoSug.py desWidgetInactif.py \
	desWidgetMatrice.py desWidgetParam.py desWidgetPlusieursBase.py desWidgetPlusieursInto.py \
	desWidgetPlusieursIntoOrdonne.py desWidgetPlusieursTuple.py desWidgetRadioButton.py \
	desWidget4a6RadioButton.py desWidgetSimpBase.py desWidgetSDCOInto.py desWidgetSimpBool.py \
        desWidgetSimpSalome.py  desPBOptionnelMT.py desWidgetTableau.py\
	desWidgetSimpComplexe.py desWidgetSimpFichier.py desWidgetSimpTxt.py desWidgetTuple2.py \
        desWidgetTuple3.py desWidgetTuple4.py desWidgetTuple5.py desWidgetTuple6.py desWidgetTuple7.py \
        desWidgetTuple8.py desWidgetTuple9.py desWidgetTuple10.py desWidgetVide.py desWidgetUniqueSDCO.py \
        desWidgetPlusieursPlie.py desWidgetNiveauFact.py dateEtHeure.py 



QM_FILES=eficas_en.qm eficas_fr.qm

%.py:%.ui
	${PYUIC} -x -o $@ $<

%.qm:%.ts
	${QTRELEASE}  -qm $@ $<

all : $(PY_FILES) $(QM_FILES)
clean :
	-rm -rf $(PY_FILES) *.pyc

