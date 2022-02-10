.SUFFIX: .byte .native
.PHONY: clean

# Put the name of the executable here
TOPFILE ?=

# Put the source files here
SOURCES ?=

OCAMLC = ocamlfind c
OCAMLOPT = ocamlfind opt
OCAMLDEP = ocamlfind dep
MLSOURCES = $(filter-out %.ml2mk.ml, $(SOURCES))
MKSOURCES = $(filter %.ml2mk.ml, $(SOURCES))
# -dsource --- dump a text *after* camlp5 extension
PXFLAGS ?= -syntax camlp5o -package GT-p5,OCanren.syntax,GT.syntax.all
REWRITER_EXES ?=
# byte flags
BFLAGS += -rectypes -g -package GT,OCanren
# opt flags
OFLAGS += -inline 10
NOCANREN = noCanren
NOCFLAGS +=

.DEFAULT: all

all: $(TOPFILE).native $(TOPFILE).byte

rewriter.native:
	mkcamlp5.opt -package camlp5.pa_o,camlp5.pr_dump,GT-p5,GT.syntax,OCanren.syntax,GT.syntax.all -o $@ #-verbose

$(TOPFILE).native: $(MKSOURCES:.ml2mk.ml=.cmx) $(MLSOURCES:.ml=.cmx)
	$(OCAMLOPT) $(BFLAGS) $(OFLAGS) $(LIBS:.cma=.cmxa) -linkpkg $^ -o $@

$(TOPFILE).byte:  $(MKSOURCES:.ml2mk.ml=.cmo) $(MLSOURCES:.ml=.cmo)
	$(OCAMLC)   $(BFLAGS) $(LIBS) -linkpkg $^ -o $@

clean::
	$(RM) *.cm[iox] *.annot *.o *.opt *.byte *~ *.d $(TOPFILE).native $(TOPFILE).byte $(REWRITER_EXES) \
		$(MKSOURCES:%.ml2mk.ml=%.ml)

# A trick with dependecies from here: http://make.mad-scientist.net/papers/advanced-auto-dependency-generation/
DEPDIR = .
DEPFILES := $(MKSOURCES:%.ml2mk.ml=$(DEPDIR)/.%.ml.d) $(MLSOURCES:%.ml=$(DEPDIR)/.%.ml.d)
include $(wildcard $(DEPFILES))
#include $(DEPFILES)
#$(info $(DEPFILES))

.%.ml.d: %.ml $(REWRITER_EXES)
	$(OCAMLDEP) $(PXFLAGS) $< > $@

# generic rules
%.ml: %.ml2mk.ml
	$(NOCANREN) $(NOCFLAGS) -o $@ $<

%.cmi: %.mli | .%.ml.d
	$(OCAMLC)   -c $(BFLAGS) $(PXFLAGS) $<

# Note: cmi <- mli should go first
%.cmi: %.ml | .%.ml.d
	$(OCAMLC)   -c $(BFLAGS) $(PXFLAGS) $<

%.cmo: %.ml | .%.ml.d
	$(OCAMLC)   -c $(BFLAGS) $(PXFLAGS) $<

%.o: %.ml | .%.ml.d
	$(OCAMLOPT) -c $(BFLAGS) $(STATIC) $(PXFLAGS) $(OFLAGS) $<

%.cmx: %.ml | .%.ml.d
	$(OCAMLOPT) -c $(BFLAGS) $(STATIC) $(PXFLAGS) $(OFLAGS) $<
