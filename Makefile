
all: nifs

nifs: priv/lib/nif.so

ARCH := $(shell uname -m)
ifeq ($(ARCH),arm64)
  ORTOOLS ?= /opt/homebrew
endif
ifeq ($(ARCH),x86_64)
  ORTOOLS ?= /usr/local
endif

# Don't assume where Erlang is installed. Instead find out where it is at.
ERLANG_HOME ?= $(shell erl -noshell -eval "io:format(\"~ts/erts-~ts\", [code:root_dir(), erlang:system_info(version)])." -s init stop)

INCLUDES=-I$(ERLANG_HOME)/include -I$(ORTOOLS)/include
LIBPATH=-L$(ERLANG_HOME)/lib -L$(ORTOOLS)/lib
CFLAGS=-std=c++17 -Wall
LIBS=-lortools -labsl_raw_hash_set -labsl_base
SRC=$(wildcard c_src/*.cc)

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	SOFLAGS=-fPIC -shared -Wl,-rpath=$(ORTOOLS)/lib -Wl,-rpath=$(ERLANG_HOME)/lib
endif
ifeq ($(UNAME_S),Darwin)
	SOFLAGS=-dynamiclib -undefined dynamic_lookup -fPIC
endif

priv/lib/nif.so: $(SRC)
	@mkdir -p $(@D)
	$(CC) $(INCLUDES) $(CFLAGS) $(SOFLAGS) -o priv/lib/nif.so $(SRC) $(LIBPATH) $(LIBS)

clean:
	rm -f priv/lib/*.so
