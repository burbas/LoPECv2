APPNAME = config
DEBUG_FLAGS= -Ddebug
DOC_OPTS =
ERLC_FLAGS = -I include +debug_info
SOURCES = $(wildcard src/*.erl)
TESTFILES = $(wildcard test/*_tests.erl)
HEADERS = $(wildcard include/*.hrl)
OBJECTS = $(SOURCES:src/%.erl=ebin/%.beam)
TESTOBJECTS = $(TESTFILES:test/%.erl=test/%.beam)

all: build test docs

build: $(OBJECTS)

test: $(TESTOBJECTS)
	erl -sname test -noshell -pa ebin -eval 'eunit:test("test",[verbose])' -s init stop

ebin/%.beam : src/%.erl $(HEADERS) Makefile
	erlc $(ERLC_FLAGS) $(DEBUG_FLAGS) -o ebin/ $<

test/%.beam : test/%.erl $(HEADERS) Makefile
	erlc $(ERLC_FLAGS) $(DEBUG_FLAGS) -o test/ $<

clean:
	-rm -f ebin/*.beam test/*.beam test/*.html

docs: 
	erl -noshell -eval "edoc:application($(APPNAME), \".\", [$(DOC_OPTS)])" \
	    -s init stop

