

npm install aws-cdk-local

cdk --version

cdklocal bootstrap aws://000000000000/us-east-1 --profile localstack

mkdir infra
cd infra

cdk init app --language python

source .venv/Scripts/activate

pip install -r requirements.txt
