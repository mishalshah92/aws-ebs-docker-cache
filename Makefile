.PHONY: fmt test tflint
CUR_DIR = $(CURDIR)

init:
	tfenv install

fmt:
	terraform fmt -check=true -diff=true -write=false -list=true terraform/
	terraform fmt -check=true -diff=true -write=false -list=true examples/

tflint:
	docker run --rm -v $(CUR_DIR):/data -t wata727/tflint --no-color --enable-rule=terraform_documented_variables --enable-rule=terraform_dash_in_resource_name --enable-rule=terraform_documented_outputs --module terraform

test:
	$(MAKE) -C test test