.PHONY: all

ifneq ($(TEST_VAR), )
    TEST_VAR := "--rsync-user $(TEST_VAR)"
endif

all:
	@echo $(origin $(TEST_VAR))
	@echo "TEST_VAR='$(TEST_VAR)'"
