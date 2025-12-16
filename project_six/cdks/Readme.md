

npm install aws-cdk-local

cdk --version
# PowerShell:
$env:AWS_DEFAULT_PROFILE='localstack'

# GitBash:
export AWS_DEFAULT_PROFILE='localstack'

cdklocal bootstrap aws://000000000000/us-east-1 --profile localstack

mkdir infra
cd infra

cdk init app --language python

# Install pipenv
pip install --user pipenv

pipenv --version

# Create a Pipfile
pipenv --python 3.12

# Activate the virtual environment
pipenv shell
exit

# Convert from requirements.txt 
pipenv install -r requirements.txt --prod



source .venv/Scripts/activate

pip install -r requirements.txt


cdklocal diff "APIStack" --profile localstack
cdklocal deploy "APIStack" --profile localstack
cdklocal destroy "APIStack" --profile localstack


# If you have a problem with the size of packages where the max size is 250Mb
find python/ -type d -name "__pycache__" -exec rm -rf {} +
find python/ -type d -name "tests" -exec rm -rf {} +
find python/ -type d -name "*.dist-info" -exec rm -rf {} +



curl -X GET \
  http://localhost:4566/restapis/40kh40mubg/prod/_user_request_/coffee \
  -H "x-api-key: x7f9A1BcDeFgHiJkLmNoP"