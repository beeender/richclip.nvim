SPEC=

RUN=nvim --headless --noplugin -u init.vim

.PHONY: all nvim test watch prepare

prepare:
	git clone --depth=1 https://github.com/nvim-lua/plenary.nvim vendor/plenary.nvim

nvim:
	@nvim --noplugin -u spec.vim

test:
ifeq ($(strip $(SPEC)),) # a.k.a. $(SPEC) is empty
	@$(RUN) -c "PlenaryBustedDirectory spec/ { minimal_init = 'init.vim' }"
else
	@$(RUN) -c "PlenaryBustedFile $(SPEC)"
endif

watch:
	@echo -e '\nRunning tests on "spec/**/*_spec.lua" when any Lua file on "../lua/" and "spec/" changes\n'
	@find spec/ ../lua/ -name '*.lua' \
	  | entr make test SPEC=$(SPEC)

all: prepare test
