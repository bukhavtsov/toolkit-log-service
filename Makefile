include Makefile.vars
include Makefile.common

# to override a target from Makefile.common just redefine the target.
# you can also chain the original atlas target by adding
# -atlas to the dependency of the redefined target

.PHONY: gen
gen:
	@echo '>>' gen toolkit-log-service
	@protoc --proto_path=./pkg/pb \
	--go_out=plugins=grpc:./pkg/pb service.proto