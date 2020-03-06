package test

import (
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformTest(t *testing.T) {
	timestamp := time.Now().Format("060102150405.999")
	env := "test" + "-" + timestamp
	env = strings.ReplaceAll(env, ".", "")
	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples",

		Vars: map[string]interface{}{
			"env": env,
		},

		// Disable colors in Terraform commands so its easier to parse stdout/stderr
		NoColor: true,
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the values of output variables
	lambdaArn := terraform.Output(t, terraformOptions, "lambda_arn")
	cwRuleArn := terraform.Output(t, terraformOptions, "cw_rule_arn")
	launchTemplate := terraform.Output(t, terraformOptions, "launch_template")

	// Verify we're getting back the outputs we expect
	assert.Regexp(t, "arn:aws:lambda:us-west-2:[0-9A-Za-z]+:function:docker-cache-main-"+env, lambdaArn)
	assert.Regexp(t, "arn:aws:events:us-west-2:[0-9A-Za-z]+:rule/docker-cache-main-"+env, cwRuleArn)
	assert.Regexp(t, "arn:aws:ec2:us-west-2:[0-9A-Za-z]+:launch-template/lt-*", launchTemplate)
}
