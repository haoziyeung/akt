CC=gcc
CXX=g++

OMP=-fopenmp

CXXFLAGS =  -std=c++11

all: akt

HTSDIR=htslib-1.6
include $(HTSDIR)/htslib.mk
HTSLIB = $(HTSDIR)/libhts.a
IFLAGS = -I$(HTSDIR)  -I./
LFLAGS = -lz -lm  -lpthread

no_omp: CXXFLAGS += -O2 
no_omp: CFLAGS = -O2 
no_omp: all

default: CXXFLAGS += -O2  $(OMP) -mpopcnt
default: CFLAGS = -O2  $(OMP) -mpopcnt
default: all

release: CXXFLAGS += -O2  $(OMP) -mpopcnt
release: CFLAGS = -O2  $(OMP) -mpopcnt
release: LFLAGS +=  -static
release: all

debug: CXXFLAGS += -g -O1 -Wall
debug: CFLAGS = -g -O1  -lz -lm -lpthread
debug: all

profile: CXXFLAGS = -pg -O2 $(OMP)
profile: CFLAGS =  -pg -O2 $(OMP)
profile: all

##generates a version
GIT_HASH := $(shell git describe --abbrev=4 --always )
BCFTOOLS_VERSION=1.6
VERSION = x.x.x
ifneq "$(wildcard .git)" ""
VERSION = $(shell git describe --always)
endif
version.h:
	echo '#define AKT_VERSION "$(VERSION)"' > $@
	echo '#define BCFTOOLS_VERSION "$(BCFTOOLS_VERSION)"' >> $@

OBJS= utils.o pedphase.o family.o reader.o vcfpca.o relatives.o kin.o pedigree.o unrelated.o cluster.o HaplotypeBuffer.o
.cpp.o:
	$(CXX) $(CXXFLAGS) $(IFLAGS) -c -o $@ $<
.c.o:
	$(CC) $(CXXFLAGS) -c -o $@ $<

##akt code
cluster.o: cluster.cpp cluster.hpp
family.o: family.cpp family.hpp
relatives.o: relatives.cpp 
unrelated.o: unrelated.cpp 
vcfpca.o: vcfpca.cpp RandomSVD.hpp
kin.o: kin.cpp 
pedigree.o: pedigree.cpp pedigree.h
reader.o: reader.cpp 
pedphase.o: pedphase.cpp pedphase.h utils.h HaplotypeBuffer.o
utils.o: utils.cpp utils.h
HaplotypeBuffer.o: HaplotypeBuffer.cpp HaplotypeBuffer.h
akt: akt.cpp version.h $(OBJS) $(HTSLIB)
	$(CXX) $(CXXFLAGS)   -o akt akt.cpp $(OBJS) $(IFLAGS) $(HTSLIB) $(LFLAGS) $(CXXFLAGS)
clean:
	rm *.o akt version.h
test: akt
	cd test/;bash -e test.sh
