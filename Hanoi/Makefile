TOPFILE = Hanoi
SOURCES = Hanoi.ml2mk.ml HanoiD.ml

REWRITER_EXES = rewriter.native
PXFLAGS = -pp ./rewriter.native
include ../Makefile.common.mk
NOCFLAGS = -w -8

clean::
	@$(RM) $(REWRITER_EXES)
