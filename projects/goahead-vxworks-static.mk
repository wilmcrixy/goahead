#
#   goahead-vxworks-static.mk -- Makefile to build Embedthis GoAhead for vxworks
#

NAME                  := goahead
VERSION               := 3.4.3
PROFILE               ?= static
ARCH                  ?= $(shell echo $(WIND_HOST_TYPE) | sed 's/-.*$(ME_ROOT_PREFIX)/')
CPU                   ?= $(subst X86,PENTIUM,$(shell echo $(ARCH) | tr a-z A-Z))
OS                    ?= vxworks
CC                    ?= cc$(subst x86,pentium,$(ARCH))
LD                    ?= ld
CONFIG                ?= $(OS)-$(ARCH)-$(PROFILE)
BUILD                 ?= build/$(CONFIG)
LBIN                  ?= $(BUILD)/bin
PATH                  := $(LBIN):$(PATH)

ME_COM_COMPILER       ?= 1
ME_COM_EST            ?= 0
ME_COM_LIB            ?= 1
ME_COM_LINK           ?= 1
ME_COM_OPENSSL        ?= 1
ME_COM_OSDEP          ?= 1
ME_COM_SSL            ?= 1
ME_COM_VXWORKS        ?= 1
ME_COM_WINSDK         ?= 1

ME_COM_OPENSSL_PATH   ?= "/usr"

ifeq ($(ME_COM_EST),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_LIB),1)
    ME_COM_COMPILER := 1
endif
ifeq ($(ME_COM_LINK),1)
    ME_COM_COMPILER := 1
endif
ifeq ($(ME_COM_OPENSSL),1)
    ME_COM_SSL := 1
endif

export WIND_HOME      ?= $(WIND_BASE)/..
export PATH           := $(WIND_GNU_PATH)/$(WIND_HOST_TYPE)/bin:$(PATH)

CFLAGS                += -fno-builtin -fno-defer-pop -fvolatile -w
DFLAGS                += -DVXWORKS -DRW_MULTI_THREAD -D_GNU_TOOL -DCPU=PENTIUM $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) -DME_COM_COMPILER=$(ME_COM_COMPILER) -DME_COM_EST=$(ME_COM_EST) -DME_COM_LIB=$(ME_COM_LIB) -DME_COM_LINK=$(ME_COM_LINK) -DME_COM_OPENSSL=$(ME_COM_OPENSSL) -DME_COM_OSDEP=$(ME_COM_OSDEP) -DME_COM_SSL=$(ME_COM_SSL) -DME_COM_VXWORKS=$(ME_COM_VXWORKS) -DME_COM_WINSDK=$(ME_COM_WINSDK) 
IFLAGS                += "-I$(BUILD)/inc -I$(WIND_BASE)/target/h -I$(WIND_BASE)/target/h/wrn/coreip"
LDFLAGS               += '-Wl,-r'
LIBPATHS              += -L$(BUILD)/bin
LIBS                  += -lgcc

DEBUG                 ?= debug
CFLAGS-debug          ?= -g
DFLAGS-debug          ?= -DME_DEBUG
LDFLAGS-debug         ?= -g
DFLAGS-release        ?= 
CFLAGS-release        ?= -O2
LDFLAGS-release       ?= 
CFLAGS                += $(CFLAGS-$(DEBUG))
DFLAGS                += $(DFLAGS-$(DEBUG))
LDFLAGS               += $(LDFLAGS-$(DEBUG))

ME_ROOT_PREFIX        ?= deploy
ME_BASE_PREFIX        ?= $(ME_ROOT_PREFIX)
ME_DATA_PREFIX        ?= $(ME_VAPP_PREFIX)
ME_STATE_PREFIX       ?= $(ME_VAPP_PREFIX)
ME_BIN_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_INC_PREFIX         ?= $(ME_VAPP_PREFIX)/inc
ME_LIB_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_MAN_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_SBIN_PREFIX        ?= $(ME_VAPP_PREFIX)
ME_ETC_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_WEB_PREFIX         ?= $(ME_VAPP_PREFIX)/web
ME_LOG_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_SPOOL_PREFIX       ?= $(ME_VAPP_PREFIX)
ME_CACHE_PREFIX       ?= $(ME_VAPP_PREFIX)
ME_APP_PREFIX         ?= $(ME_BASE_PREFIX)
ME_VAPP_PREFIX        ?= $(ME_APP_PREFIX)
ME_SRC_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/src/$(NAME)-$(VERSION)


TARGETS               += $(BUILD)/bin/ca.crt
TARGETS               += $(BUILD)/bin/goahead.out
TARGETS               += $(BUILD)/bin/goahead-test.out
TARGETS               += $(BUILD)/bin/gopass.out

unexport CDPATH

ifndef SHOW
.SILENT:
endif

all build compile: prep $(TARGETS)

.PHONY: prep

prep:
	@echo "      [Info] Use "make SHOW=1" to trace executed commands."
	@if [ "$(CONFIG)" = "" ] ; then echo WARNING: CONFIG not set ; exit 255 ; fi
	@if [ "$(ME_APP_PREFIX)" = "" ] ; then echo WARNING: ME_APP_PREFIX not set ; exit 255 ; fi
	@if [ "$(WIND_BASE)" = "" ] ; then echo WARNING: WIND_BASE not set. Run wrenv.sh. ; exit 255 ; fi
	@if [ "$(WIND_HOST_TYPE)" = "" ] ; then echo WARNING: WIND_HOST_TYPE not set. Run wrenv.sh. ; exit 255 ; fi
	@if [ "$(WIND_GNU_PATH)" = "" ] ; then echo WARNING: WIND_GNU_PATH not set. Run wrenv.sh. ; exit 255 ; fi
	@[ ! -x $(BUILD)/bin ] && mkdir -p $(BUILD)/bin; true
	@[ ! -x $(BUILD)/inc ] && mkdir -p $(BUILD)/inc; true
	@[ ! -x $(BUILD)/obj ] && mkdir -p $(BUILD)/obj; true
	@[ ! -f $(BUILD)/inc/me.h ] && cp projects/goahead-vxworks-static-me.h $(BUILD)/inc/me.h ; true
	@if ! diff $(BUILD)/inc/me.h projects/goahead-vxworks-static-me.h >/dev/null ; then\
		cp projects/goahead-vxworks-static-me.h $(BUILD)/inc/me.h  ; \
	fi; true
	@if [ -f "$(BUILD)/.makeflags" ] ; then \
		if [ "$(MAKEFLAGS)" != "`cat $(BUILD)/.makeflags`" ] ; then \
			echo "   [Warning] Make flags have changed since the last build: "`cat $(BUILD)/.makeflags`"" ; \
		fi ; \
	fi
	@echo "$(MAKEFLAGS)" >$(BUILD)/.makeflags

clean:
	rm -f "$(BUILD)/obj/action.o"
	rm -f "$(BUILD)/obj/alloc.o"
	rm -f "$(BUILD)/obj/auth.o"
	rm -f "$(BUILD)/obj/cgi.o"
	rm -f "$(BUILD)/obj/cgitest.o"
	rm -f "$(BUILD)/obj/crypt.o"
	rm -f "$(BUILD)/obj/est.o"
	rm -f "$(BUILD)/obj/file.o"
	rm -f "$(BUILD)/obj/fs.o"
	rm -f "$(BUILD)/obj/goahead.o"
	rm -f "$(BUILD)/obj/gopass.o"
	rm -f "$(BUILD)/obj/http.o"
	rm -f "$(BUILD)/obj/js.o"
	rm -f "$(BUILD)/obj/jst.o"
	rm -f "$(BUILD)/obj/matrixssl.o"
	rm -f "$(BUILD)/obj/nanossl.o"
	rm -f "$(BUILD)/obj/openssl.o"
	rm -f "$(BUILD)/obj/options.o"
	rm -f "$(BUILD)/obj/osdep.o"
	rm -f "$(BUILD)/obj/rom-documents.o"
	rm -f "$(BUILD)/obj/route.o"
	rm -f "$(BUILD)/obj/runtime.o"
	rm -f "$(BUILD)/obj/socket.o"
	rm -f "$(BUILD)/obj/test.o"
	rm -f "$(BUILD)/obj/upload.o"
	rm -f "$(BUILD)/bin/ca.crt"
	rm -f "$(BUILD)/bin/goahead.out"
	rm -f "$(BUILD)/bin/goahead-test.out"
	rm -f "$(BUILD)/bin/gopass.out"
	rm -f "$(BUILD)/bin/libgo.out"

clobber: clean
	rm -fr ./$(BUILD)

#
#   est.h
#

$(BUILD)/inc/est.h: $(DEPS_1)

#
#   me.h
#

$(BUILD)/inc/me.h: $(DEPS_2)

#
#   osdep.h
#
DEPS_3 += src/paks/osdep/osdep.h
DEPS_3 += $(BUILD)/inc/me.h

$(BUILD)/inc/osdep.h: $(DEPS_3)
	@echo '      [Copy] $(BUILD)/inc/osdep.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/osdep/osdep.h $(BUILD)/inc/osdep.h

#
#   goahead.h
#
DEPS_4 += src/goahead.h
DEPS_4 += $(BUILD)/inc/me.h
DEPS_4 += $(BUILD)/inc/osdep.h

$(BUILD)/inc/goahead.h: $(DEPS_4)
	@echo '      [Copy] $(BUILD)/inc/goahead.h'
	mkdir -p "$(BUILD)/inc"
	cp src/goahead.h $(BUILD)/inc/goahead.h

#
#   js.h
#
DEPS_5 += src/js.h
DEPS_5 += $(BUILD)/inc/goahead.h

$(BUILD)/inc/js.h: $(DEPS_5)
	@echo '      [Copy] $(BUILD)/inc/js.h'
	mkdir -p "$(BUILD)/inc"
	cp src/js.h $(BUILD)/inc/js.h

#
#   action.o
#
DEPS_6 += $(BUILD)/inc/goahead.h

$(BUILD)/obj/action.o: \
    src/action.c $(DEPS_6)
	@echo '   [Compile] $(BUILD)/obj/action.o'
	$(CC) -c -o $(BUILD)/obj/action.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/action.c

#
#   alloc.o
#
DEPS_7 += $(BUILD)/inc/goahead.h

$(BUILD)/obj/alloc.o: \
    src/alloc.c $(DEPS_7)
	@echo '   [Compile] $(BUILD)/obj/alloc.o'
	$(CC) -c -o $(BUILD)/obj/alloc.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/alloc.c

#
#   auth.o
#
DEPS_8 += $(BUILD)/inc/goahead.h

$(BUILD)/obj/auth.o: \
    src/auth.c $(DEPS_8)
	@echo '   [Compile] $(BUILD)/obj/auth.o'
	$(CC) -c -o $(BUILD)/obj/auth.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/auth.c

#
#   cgi.o
#
DEPS_9 += $(BUILD)/inc/goahead.h

$(BUILD)/obj/cgi.o: \
    src/cgi.c $(DEPS_9)
	@echo '   [Compile] $(BUILD)/obj/cgi.o'
	$(CC) -c -o $(BUILD)/obj/cgi.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/cgi.c

#
#   cgitest.o
#

$(BUILD)/obj/cgitest.o: \
    test/cgitest.c $(DEPS_10)
	@echo '   [Compile] $(BUILD)/obj/cgitest.o'
	$(CC) -c -o $(BUILD)/obj/cgitest.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" test/cgitest.c

#
#   crypt.o
#
DEPS_11 += $(BUILD)/inc/goahead.h

$(BUILD)/obj/crypt.o: \
    src/crypt.c $(DEPS_11)
	@echo '   [Compile] $(BUILD)/obj/crypt.o'
	$(CC) -c -o $(BUILD)/obj/crypt.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/crypt.c

#
#   est.o
#
DEPS_12 += $(BUILD)/inc/goahead.h
DEPS_12 += $(BUILD)/inc/est.h

$(BUILD)/obj/est.o: \
    src/ssl/est.c $(DEPS_12)
	@echo '   [Compile] $(BUILD)/obj/est.o'
	$(CC) -c -o $(BUILD)/obj/est.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/ssl/est.c

#
#   file.o
#
DEPS_13 += $(BUILD)/inc/goahead.h

$(BUILD)/obj/file.o: \
    src/file.c $(DEPS_13)
	@echo '   [Compile] $(BUILD)/obj/file.o'
	$(CC) -c -o $(BUILD)/obj/file.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/file.c

#
#   fs.o
#
DEPS_14 += $(BUILD)/inc/goahead.h

$(BUILD)/obj/fs.o: \
    src/fs.c $(DEPS_14)
	@echo '   [Compile] $(BUILD)/obj/fs.o'
	$(CC) -c -o $(BUILD)/obj/fs.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/fs.c

#
#   goahead.o
#
DEPS_15 += $(BUILD)/inc/goahead.h

$(BUILD)/obj/goahead.o: \
    src/goahead.c $(DEPS_15)
	@echo '   [Compile] $(BUILD)/obj/goahead.o'
	$(CC) -c -o $(BUILD)/obj/goahead.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/goahead.c

#
#   gopass.o
#
DEPS_16 += $(BUILD)/inc/goahead.h

$(BUILD)/obj/gopass.o: \
    src/utils/gopass.c $(DEPS_16)
	@echo '   [Compile] $(BUILD)/obj/gopass.o'
	$(CC) -c -o $(BUILD)/obj/gopass.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/utils/gopass.c

#
#   http.o
#
DEPS_17 += $(BUILD)/inc/goahead.h

$(BUILD)/obj/http.o: \
    src/http.c $(DEPS_17)
	@echo '   [Compile] $(BUILD)/obj/http.o'
	$(CC) -c -o $(BUILD)/obj/http.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/http.c

#
#   js.o
#
DEPS_18 += $(BUILD)/inc/js.h

$(BUILD)/obj/js.o: \
    src/js.c $(DEPS_18)
	@echo '   [Compile] $(BUILD)/obj/js.o'
	$(CC) -c -o $(BUILD)/obj/js.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/js.c

#
#   jst.o
#
DEPS_19 += $(BUILD)/inc/goahead.h
DEPS_19 += $(BUILD)/inc/js.h

$(BUILD)/obj/jst.o: \
    src/jst.c $(DEPS_19)
	@echo '   [Compile] $(BUILD)/obj/jst.o'
	$(CC) -c -o $(BUILD)/obj/jst.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/jst.c

#
#   matrixssl.o
#
DEPS_20 += $(BUILD)/inc/me.h
DEPS_20 += $(BUILD)/inc/goahead.h

$(BUILD)/obj/matrixssl.o: \
    src/ssl/matrixssl.c $(DEPS_20)
	@echo '   [Compile] $(BUILD)/obj/matrixssl.o'
	$(CC) -c -o $(BUILD)/obj/matrixssl.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/ssl/matrixssl.c

#
#   nanossl.o
#
DEPS_21 += $(BUILD)/inc/me.h

$(BUILD)/obj/nanossl.o: \
    src/ssl/nanossl.c $(DEPS_21)
	@echo '   [Compile] $(BUILD)/obj/nanossl.o'
	$(CC) -c -o $(BUILD)/obj/nanossl.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/ssl/nanossl.c

#
#   openssl.o
#
DEPS_22 += $(BUILD)/inc/me.h
DEPS_22 += $(BUILD)/inc/osdep.h
DEPS_22 += $(BUILD)/inc/goahead.h

$(BUILD)/obj/openssl.o: \
    src/ssl/openssl.c $(DEPS_22)
	@echo '   [Compile] $(BUILD)/obj/openssl.o'
	$(CC) -c -o $(BUILD)/obj/openssl.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/ssl/openssl.c

#
#   options.o
#
DEPS_23 += $(BUILD)/inc/goahead.h

$(BUILD)/obj/options.o: \
    src/options.c $(DEPS_23)
	@echo '   [Compile] $(BUILD)/obj/options.o'
	$(CC) -c -o $(BUILD)/obj/options.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/options.c

#
#   osdep.o
#
DEPS_24 += $(BUILD)/inc/goahead.h

$(BUILD)/obj/osdep.o: \
    src/osdep.c $(DEPS_24)
	@echo '   [Compile] $(BUILD)/obj/osdep.o'
	$(CC) -c -o $(BUILD)/obj/osdep.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/osdep.c

#
#   rom-documents.o
#
DEPS_25 += $(BUILD)/inc/goahead.h

$(BUILD)/obj/rom-documents.o: \
    src/rom-documents.c $(DEPS_25)
	@echo '   [Compile] $(BUILD)/obj/rom-documents.o'
	$(CC) -c -o $(BUILD)/obj/rom-documents.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/rom-documents.c

#
#   route.o
#
DEPS_26 += $(BUILD)/inc/goahead.h

$(BUILD)/obj/route.o: \
    src/route.c $(DEPS_26)
	@echo '   [Compile] $(BUILD)/obj/route.o'
	$(CC) -c -o $(BUILD)/obj/route.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/route.c

#
#   runtime.o
#
DEPS_27 += $(BUILD)/inc/goahead.h

$(BUILD)/obj/runtime.o: \
    src/runtime.c $(DEPS_27)
	@echo '   [Compile] $(BUILD)/obj/runtime.o'
	$(CC) -c -o $(BUILD)/obj/runtime.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/runtime.c

#
#   socket.o
#
DEPS_28 += $(BUILD)/inc/goahead.h

$(BUILD)/obj/socket.o: \
    src/socket.c $(DEPS_28)
	@echo '   [Compile] $(BUILD)/obj/socket.o'
	$(CC) -c -o $(BUILD)/obj/socket.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/socket.c

#
#   test.o
#
DEPS_29 += $(BUILD)/inc/goahead.h
DEPS_29 += $(BUILD)/inc/js.h

$(BUILD)/obj/test.o: \
    test/test.c $(DEPS_29)
	@echo '   [Compile] $(BUILD)/obj/test.o'
	$(CC) -c -o $(BUILD)/obj/test.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" test/test.c

#
#   upload.o
#
DEPS_30 += $(BUILD)/inc/goahead.h

$(BUILD)/obj/upload.o: \
    src/upload.c $(DEPS_30)
	@echo '   [Compile] $(BUILD)/obj/upload.o'
	$(CC) -c -o $(BUILD)/obj/upload.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/upload.c

#
#   ca-crt
#
DEPS_31 += src/paks/est/ca.crt

$(BUILD)/bin/ca.crt: $(DEPS_31)
	@echo '      [Copy] $(BUILD)/bin/ca.crt'
	mkdir -p "$(BUILD)/bin"
	cp src/paks/est/ca.crt $(BUILD)/bin/ca.crt

#
#   libgo
#
DEPS_32 += $(BUILD)/inc/osdep.h
DEPS_32 += $(BUILD)/inc/goahead.h
DEPS_32 += $(BUILD)/inc/js.h
DEPS_32 += $(BUILD)/obj/action.o
DEPS_32 += $(BUILD)/obj/alloc.o
DEPS_32 += $(BUILD)/obj/auth.o
DEPS_32 += $(BUILD)/obj/cgi.o
DEPS_32 += $(BUILD)/obj/crypt.o
DEPS_32 += $(BUILD)/obj/file.o
DEPS_32 += $(BUILD)/obj/fs.o
DEPS_32 += $(BUILD)/obj/http.o
DEPS_32 += $(BUILD)/obj/js.o
DEPS_32 += $(BUILD)/obj/jst.o
DEPS_32 += $(BUILD)/obj/options.o
DEPS_32 += $(BUILD)/obj/osdep.o
DEPS_32 += $(BUILD)/obj/rom-documents.o
DEPS_32 += $(BUILD)/obj/route.o
DEPS_32 += $(BUILD)/obj/runtime.o
DEPS_32 += $(BUILD)/obj/socket.o
DEPS_32 += $(BUILD)/obj/upload.o
DEPS_32 += $(BUILD)/obj/est.o
DEPS_32 += $(BUILD)/obj/matrixssl.o
DEPS_32 += $(BUILD)/obj/nanossl.o
DEPS_32 += $(BUILD)/obj/openssl.o

ifeq ($(ME_COM_OPENSSL),1)
    LIBS_32 += -lssl
    LIBPATHS_32 += -L"$(ME_COM_OPENSSL_PATH)/lib"
    LIBPATHS_32 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_32 += -lcrypto
    LIBPATHS_32 += -L"$(ME_COM_OPENSSL_PATH)/lib"
    LIBPATHS_32 += -L"$(ME_COM_OPENSSL_PATH)"
endif

$(BUILD)/bin/libgo.out: $(DEPS_32)
	@echo '      [Link] $(BUILD)/bin/libgo.out'
	$(CC) -r -o $(BUILD)/bin/libgo.out $(LDFLAGS) $(LIBPATHS)   "$(BUILD)/obj/action.o" "$(BUILD)/obj/alloc.o" "$(BUILD)/obj/auth.o" "$(BUILD)/obj/cgi.o" "$(BUILD)/obj/crypt.o" "$(BUILD)/obj/file.o" "$(BUILD)/obj/fs.o" "$(BUILD)/obj/http.o" "$(BUILD)/obj/js.o" "$(BUILD)/obj/jst.o" "$(BUILD)/obj/options.o" "$(BUILD)/obj/osdep.o" "$(BUILD)/obj/rom-documents.o" "$(BUILD)/obj/route.o" "$(BUILD)/obj/runtime.o" "$(BUILD)/obj/socket.o" "$(BUILD)/obj/upload.o" "$(BUILD)/obj/est.o" "$(BUILD)/obj/matrixssl.o" "$(BUILD)/obj/nanossl.o" "$(BUILD)/obj/openssl.o" $(LIBPATHS_32) $(LIBS_32) $(LIBS_32) $(LIBS) -lest 

#
#   goahead
#
DEPS_33 += $(BUILD)/bin/libgo.out
DEPS_33 += $(BUILD)/inc/goahead.h
DEPS_33 += $(BUILD)/inc/js.h
DEPS_33 += $(BUILD)/obj/goahead.o

ifeq ($(ME_COM_OPENSSL),1)
    LIBS_33 += -lssl
    LIBPATHS_33 += -L"$(ME_COM_OPENSSL_PATH)/lib"
    LIBPATHS_33 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_33 += -lcrypto
    LIBPATHS_33 += -L"$(ME_COM_OPENSSL_PATH)/lib"
    LIBPATHS_33 += -L"$(ME_COM_OPENSSL_PATH)"
endif

$(BUILD)/bin/goahead.out: $(DEPS_33)
	@echo '      [Link] $(BUILD)/bin/goahead.out'
	$(CC) -o $(BUILD)/bin/goahead.out $(LDFLAGS) $(LIBPATHS)   "$(BUILD)/obj/goahead.o" $(LIBPATHS_33) $(LIBS_33) $(LIBS_33) $(LIBS) -lest -Wl,-r 

#
#   goahead-test
#
DEPS_34 += $(BUILD)/bin/libgo.out
DEPS_34 += $(BUILD)/inc/goahead.h
DEPS_34 += $(BUILD)/inc/js.h
DEPS_34 += $(BUILD)/obj/test.o

ifeq ($(ME_COM_OPENSSL),1)
    LIBS_34 += -lssl
    LIBPATHS_34 += -L"$(ME_COM_OPENSSL_PATH)/lib"
    LIBPATHS_34 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_34 += -lcrypto
    LIBPATHS_34 += -L"$(ME_COM_OPENSSL_PATH)/lib"
    LIBPATHS_34 += -L"$(ME_COM_OPENSSL_PATH)"
endif

$(BUILD)/bin/goahead-test.out: $(DEPS_34)
	@echo '      [Link] $(BUILD)/bin/goahead-test.out'
	$(CC) -o $(BUILD)/bin/goahead-test.out $(LDFLAGS) $(LIBPATHS)   "$(BUILD)/obj/test.o" $(LIBPATHS_34) $(LIBS_34) $(LIBS_34) $(LIBS) -lest -Wl,-r 

#
#   gopass
#
DEPS_35 += $(BUILD)/bin/libgo.out
DEPS_35 += $(BUILD)/inc/goahead.h
DEPS_35 += $(BUILD)/inc/js.h
DEPS_35 += $(BUILD)/obj/gopass.o

ifeq ($(ME_COM_OPENSSL),1)
    LIBS_35 += -lssl
    LIBPATHS_35 += -L"$(ME_COM_OPENSSL_PATH)/lib"
    LIBPATHS_35 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_35 += -lcrypto
    LIBPATHS_35 += -L"$(ME_COM_OPENSSL_PATH)/lib"
    LIBPATHS_35 += -L"$(ME_COM_OPENSSL_PATH)"
endif

$(BUILD)/bin/gopass.out: $(DEPS_35)
	@echo '      [Link] $(BUILD)/bin/gopass.out'
	$(CC) -o $(BUILD)/bin/gopass.out $(LDFLAGS) $(LIBPATHS)   "$(BUILD)/obj/gopass.o" $(LIBPATHS_35) $(LIBS_35) $(LIBS_35) $(LIBS) -lest -Wl,-r 

#
#   stop
#

stop: $(DEPS_36)

#
#   installBinary
#

installBinary: $(DEPS_37)

#
#   start
#

start: $(DEPS_38)

#
#   install
#
DEPS_39 += stop
DEPS_39 += installBinary
DEPS_39 += start

install: $(DEPS_39)

#
#   installPrep
#

installPrep: $(DEPS_40)
	if [ "`id -u`" != 0 ] ; \
	then echo "Must run as root. Rerun with "sudo"" ; \
	exit 255 ; \
	fi

#
#   uninstall
#
DEPS_41 += stop

uninstall: $(DEPS_41)

#
#   version
#

version: $(DEPS_42)
	echo 3.4.3

