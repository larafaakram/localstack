import subprocess

from aws_cdk import Duration, Stack
from aws_cdk import aws_apigateway as apigateway
from aws_cdk import aws_iam as iam
from aws_cdk import aws_lambda as lambda_
from constructs import Construct
from pipfile import Pipfile


def lambda_layer_helper():
    """
    This function is used to install the packages from the Pipfile into the
    lambda layer. It runs the command: pip3 install --target
    ./lambda_layer_packages/python/ fastapi==0.95.2 mangum==0.17.0
    """
    print("Installing packages for lambda layer....")
    packages_to_install = []
    pipfile = Pipfile.load("../Pipfile")
    for package, version in pipfile.data["default"].items():
        packages_to_install.append(f"{package}{version}")

    subprocess.run(
        [
            "pip3",
            "install",
            "--target",
            "./lambda_layer_packages/python/",
            *packages_to_install,
        ]
    )

    # Pydantic-code needs a specific Linux wheel to run on Lambda
    subprocess.run(
        [
            "pip3",
            "install",
            "--upgrade",
            "--platform=manylinux_2_17_x86_64",
            "--only-binary=:all:",
            "--target",
            "./lambda_layer_packages/python/",
            "pydantic-core==2.20.1",
        ]
    )

    print("Packages installed for lambda layer.")


class APIStack(Stack):
    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        organization_name = kwargs.pop("organization_name")
        super().__init__(scope, construct_id, **kwargs)

        # Create Lambda Layer, Lambda Function & grant dynamodb permissions
        lambda_layer_helper()

        lambda_layer = lambda_.LayerVersion(
            self,
            f"{organization_name.capitalize()}LambdaLayer",
            code=lambda_.Code.from_asset("./lambda_layer_packages"),
            compatible_runtimes=[lambda_.Runtime.PYTHON_3_12],
            compatible_architectures=[lambda_.Architecture.X86_64],
            description="A layer for common dependencies",
            layer_version_name=f"{organization_name}-lambda-layer",
        )

        function = lambda_.Function(
            self,
            f"{organization_name.capitalize()}Lambda",
            function_name=f"{organization_name}-lambda",
            runtime=lambda_.Runtime.PYTHON_3_12,
            handler="app.main.handler",
            code=lambda_.Code.from_asset(
                path="..",
                exclude=[
                    ".*",
                    "tests",
                    "infra",
                    "Pipfile",
                    "Pipfile.lock",
                    "README.md",
                ],
            ),
            timeout=Duration.seconds(30),
            architecture=lambda_.Architecture.X86_64,
            memory_size=1024,
            layers=[lambda_layer],
        )

    
        # Create API Gateway, API Key, Usage Plan and grant permissions
        api = apigateway.LambdaRestApi(
            self,
            f"{organization_name.capitalize()}Api",
            rest_api_name=f"{organization_name}-api",
            handler=function,
            proxy=True,
            integration_options=apigateway.LambdaIntegrationOptions(
                allow_test_invoke=False,
            ),
            default_method_options=apigateway.MethodOptions(
                api_key_required=True,
            ),
        )

        key = api.add_api_key(
            f"{organization_name}-api-key", api_key_name=f"{organization_name}-api-key"
        )

        plan = api.add_usage_plan(
            f"{organization_name}-usage-plan",
            name=f"{organization_name}-usage-plan",
            quota=apigateway.QuotaSettings(
                limit=1000,
                period=apigateway.Period.DAY,
            ),
        )

        plan.add_api_key(key)
        plan.add_api_stage(
            stage=api.deployment_stage,
        )

