#.SUFFIX: .byte .native

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
PXFLAGS = -syntax camlp5o -package GT-p5,OCanren.syntax,GT.syntax.all
# byte flags
BFLAGS += -rectypes -g -package GT,OCanren
# opt flags
OFLAGS += $(BFLAGS) -inline 10
NOCANREN = noCanren
NOCFLAGS +=

all: .depend $(TOPFILE).native $(TOPFILE).byte

rewriter.exe:
	mkcamlp5.opt -package camlp5.pr_dump,GT-p5,GT.syntax,OCanren.syntax,GT.syntax.all -o $@

.depend: rewriter.exe

.depend: $(SOURCES)
	$(OCAMLDEP) $(PXFLAGS) *.ml > .depend

$(TOPFILE).native: $(MKSOURCES:.ml2mk.ml=.cmx) $(MLSOURCES:.ml=.cmx)
	$(OCAMLOPT) -o $@ $(OFLAGS) $(LIBS:.cma=.cmxa) -linkpkg $^

$(TOPFILE).byte:  $(MKSOURCES:.ml2mk.ml=.cmo) $(MLSOURCES:.ml=.cmo)
	$(OCAMLC) -o $@ $(BFLAGS) $(LIBS) -linkpkg $^

clean:
	$(RM) *.cm[iox] *.annot *.o *.opt *.byte *~ .depend $(TOPFILE).native $(TOPFILE).byte rewriter.exe

-include .depend

# generic rules

###############
%.ml: %.ml2mk.ml
	$(NOCANREN) $(NOCFLAGS) -o $@ $<

%.cmi: %.mli
	$(OCAMLC)   -c $(BFLAGS) $(PXFLAGS) $<

# Note: cmi <- mli should go first
%.cmi: %.ml
	$(OCAMLC)   -c $(BFLAGS) $(PXFLAGS) $<

%.cmo: %.ml
	$(OCAMLC)   -c $(BFLAGS) $(PXFLAGS) $<

%.o: %.ml
	$(OCAMLOPT) -c $(OFLAGS) $(STATIC) $(BFLAGS) $(PXFLAGS) $<

%.cmx: %.ml
	$(OCAMLOPT) -c $(OFLAGS) $(STATIC) $(BFLAGS) $(PXFLAGS) $<
