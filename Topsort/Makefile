TOPFILE = Topsort
SOURCES = Topsort.ml2mk.ml TopsortD.ml

REWRITER_EXES = rewriter.native rewriter_ppx.native
PXFLAGS = -pp './rewriter_ppx.native -pp ./rewriter.native'
include ../Makefile.common.mk
NOCFLAGS = -w -8


rewriter.native: rewriter_ppx.native
rewriter_ppx.native:
	ocamlfind opt -predicates ppx_driver -package OCanren-ppx.ppx_distrib,GT.ppx,GT.ppx_all,ppxlib.runner -linkpkg -linkall -o $@

clean::
	@$(RM) $(REWRITER_EXES)
