# RAGFLOW with Supabase Schema

There are several files to update to support Supabase Schema.

## 1. ragflow/db_models.py
Create ragflow folder by copying the `docker` folder and rename it to `ragflow`.
Copy `api/db/db_models.py` to `ragflow/db_models.py`

The `BaseDataBase` class is used to initialize the database connection.
We need to add the schema support for PostgreSQL.

```python
@singleton
class BaseDataBase:
    def __init__(self):
        database_config = settings.DATABASE.copy()
        db_name = database_config.pop("name")
        
        # Add schema support for PostgreSQL
        if settings.DATABASE_TYPE.upper() == 'POSTGRES':
            schema = os.getenv('POSTGRES_SCHEMA', 'public')
            database_config['options'] = f'-c search_path={schema}'
            
        self.database_connection = PooledDatabase[settings.DATABASE_TYPE.upper()].value(
            db_name, 
            **database_config
        )
        logging.info(f'init database on cluster mode successfully with type {settings.DATABASE_TYPE}')
```

## 2. ragflow/constants.py
Copy `api/constants.py` to `ragflow/constants.py`

The `SERVICE_CONF` is the path to the service configuration file. Use the updated path.

```python
NAME_LENGTH_LIMIT = 2 ** 10

IMG_BASE64_PREFIX = 'data:image/png;base64,'

SERVICE_CONF = "../ragflow/service_conf.dev.yaml"

API_VERSION = "v1"
RAG_FLOW_SERVICE_NAME = "ragflow"
REQUEST_WAIT_SEC = 2
REQUEST_MAX_WAIT_SEC = 300

DATASET_NAME_LIMIT = 128
```

## 3. ragflow/service_conf.dev.yaml

Create a new file `ragflow/service_conf.dev.yaml` and add the following content:

Disable the `mysql` section, and add the `postgres` section.

```yaml
ragflow:
  host: ${RAGFLOW_HOST:-0.0.0.0}
  http_port: ${RAGFLOW_HTTP_PORT:-9380}
# mysql:
#   name: '${MYSQL_DBNAME:-rag_flow}'
#   user: '${MYSQL_USER:-root}'
#   password: '${MYSQL_PASSWORD:-infini_rag_flow}'
#   host: '${MYSQL_HOST:-mysql}'
#   port: ${MYSQL_PORT:-3306}
#   max_connections: 100
#   stale_timeout: 30
minio:
  user: '${MINIO_USER:-rag_flow}'
  password: '${MINIO_PASSWORD:-infini_rag_flow}'
  host: '${MINIO_HOST:-minio}:${MINIO_PORT:-9000}'
es:
  hosts: 'http://${ES_HOST:-es01}:${ES_PORT:-9200}'
  username: '${ES_USER:-elastic}'
  password: '${ELASTIC_PASSWORD:-infini_rag_flow}'
infinity:
  uri: '${INFINITY_HOST:-infinity}:${INFINITY_THRIFT_PORT:-23817}'
  db_name: 'default_db'
redis:
  db: 1
  password: '${REDIS_PASSWORD:-infini_rag_flow}'
  host: '${REDIS_HOST:-redis}:${REDIS_PORT:-6379}'
postgres:
  name: '${POSTGRES_DBNAME:-rag_flow}'
  user: '${POSTGRES_USER:-rag_flow}'
  password: '${POSTGRES_PASSWORD:-infini_rag_flow}'
  host: '${POSTGRES_HOST:-postgres}'
  port: ${POSTGRES_PORT:-5432}
  max_connections: 100
#   stale_timeout: 30
# s3:
#   access_key: 'access_key'
#   secret_key: 'secret_key'
#   region: 'region'
# azure:
#   auth_type: 'sas'
#   container_url: 'container_url'
#   sas_token: 'sas_token'
# azure:
#   auth_type: 'spn'
#   account_url: 'account_url'
#   client_id: 'client_id'
#   secret: 'secret'
#   tenant_id: 'tenant_id'
#   container_name: 'container_name'
# user_default_llm:
#   factory: 'Tongyi-Qianwen'
#   api_key: 'sk-xxxxxxxxxxxxx'
#   base_url: ''
# oauth:
#   github:
#     client_id: xxxxxxxxxxxxxxxxxxxxxxxxx
#     secret_key: xxxxxxxxxxxxxxxxxxxxxxxxxxxx
#     url: https://github.com/login/oauth/access_token
#   feishu:
#     app_id: cli_xxxxxxxxxxxxxxxxxxx
#     app_secret: xxxxxxxxxxxxxxxxxxxxxxxxxxxx
#     app_access_token_url: https://open.feishu.cn/open-apis/auth/v3/app_access_token/internal
#     user_access_token_url: https://open.feishu.cn/open-apis/authen/v1/oidc/access_token
#     grant_type: 'authorization_code'
# authentication:
#   client:
#     switch: false
#     http_app_key:
#     http_secret_key:
#   site:
#     switch: false
# permission:
#   switch: false
#   component: false
#   dataset: false
```

## 4. ragflow/env.dev

Create the new `ragflow/env.dev` file for environmental variables.

```bash
# The type of doc engine to use.
# Available options:
# - `elasticsearch` (default) 
# - `infinity` (https://github.com/infiniflow/infinity)
DOC_ENGINE=${DOC_ENGINE:-elasticsearch}

# ------------------------------
# docker env var for specifying vector db type at startup
# (based on the vector db type, the corresponding docker
# compose profile will be used)
# ------------------------------
COMPOSE_PROFILES=${DOC_ENGINE}

RAGFLOW_NETWORK_HOST=10.0.0.241

# The version of Elasticsearch.
STACK_VERSION=8.11.3

# The hostname where the Elasticsearch service is exposed
ES_HOST=$RAGFLOW_NETWORK_HOST

# The port used to expose the Elasticsearch service to the host machine, 
# allowing EXTERNAL access to the service running inside the Docker container.
ES_PORT=7050

# The password for Elasticsearch. 
ELASTIC_PASSWORD=infini_rag_flow

# The port used to expose the Kibana service to the host machine, 
# allowing EXTERNAL access to the service running inside the Docker container.
KIBANA_PORT=7051
KIBANA_USER=rag_flow
KIBANA_PASSWORD=infini_rag_flow

# The maximum amount of the memory, in bytes, that a specific Docker container can use while running.
# Update it according to the available memory in the host machine.
MEM_LIMIT=8073741824

# The hostname where the Infinity service is exposed
INFINITY_HOST=$RAGFLOW_NETWORK_HOST

# Port to expose Infinity API to the host
INFINITY_THRIFT_PORT=7052
INFINITY_HTTP_PORT=7053
INFINITY_PSQL_PORT=7054

# The password for MySQL. 
MYSQL_PASSWORD=infini_rag_flow
# The hostname where the MySQL service is exposed
MYSQL_HOST=$RAGFLOW_NETWORK_HOST
# The database of the MySQL service to use
MYSQL_DBNAME=rag_flow
# The port used to expose the MySQL service to the host machine, 
# allowing EXTERNAL access to the MySQL database running inside the Docker container. 
MYSQL_PORT=5050

POSTGRES_PASSWORD=DBUser.Supa
# The database of the PostgreSQL service to use
POSTGRES_DBNAME=postgres
# The username for PostgreSQL.
POSTGRES_USER=supabase_admin
# The postgres port which will be used to connect to the PostgreSQL service
POSTGRES_PORT=5436
# The hostname where the PostgreSQL service is exposed
POSTGRES_HOST=10.0.0.241
# Postgresql schema
POSTGRES_SCHEMA=ragflow


# The hostname where the MinIO service is exposed
MINIO_HOST=$RAGFLOW_NETWORK_HOST
# The port used to expose the MinIO console interface to the host machine, 
# allowing EXTERNAL access to the web-based console running inside the Docker container. 
MINIO_CONSOLE_PORT=5052
# The port used to expose the MinIO API service to the host machine, 
# allowing EXTERNAL access to the MinIO object storage service running inside the Docker container. 
MINIO_PORT=5051
# The username for MinIO. 
# When updated, you must revise the `minio.user` entry in service_conf.yaml accordingly.
MINIO_USER=rag_flow
# The password for MinIO. 
# When updated, you must revise the `minio.password` entry in service_conf.yaml accordingly.
MINIO_PASSWORD=infini_rag_flow

# The hostname where the Redis service is exposed
REDIS_HOST=$RAGFLOW_NETWORK_HOST
# The port used to expose the Redis service to the host machine, 
# allowing EXTERNAL access to the Redis service running inside the Docker container.
REDIS_PORT=5053
# The password for Redis.
REDIS_PASSWORD=infini_rag_flow

# The port used to expose RAGFlow's HTTP API service to the host machine, 
# allowing EXTERNAL access to the service running inside the Docker container.
SVR_HTTP_PORT=8050

# The RAGFlow Docker image to download.
# Defaults to the v0.16.0-slim edition, which is the RAGFlow Docker image without embedding models.
RAGFLOW_IMAGE=infiniflow/ragflow:v0.18.0
#
# To download the RAGFlow Docker image with embedding models, uncomment the following line instead:
# RAGFLOW_IMAGE=infiniflow/ragflow:v0.16.0
# 
# The Docker image of the v0.16.0 edition includes:
# - Built-in embedding models:
#   - BAAI/bge-large-zh-v1.5
#   - BAAI/bge-reranker-v2-m3
#   - maidalun1020/bce-embedding-base_v1
#   - maidalun1020/bce-reranker-base_v1
# - Embedding models that will be downloaded once you select them in the RAGFlow UI:
#   - BAAI/bge-base-en-v1.5
#   - BAAI/bge-large-en-v1.5
#   - BAAI/bge-small-en-v1.5
#   - BAAI/bge-small-zh-v1.5
#   - jinaai/jina-embeddings-v2-base-en
#   - jinaai/jina-embeddings-v2-small-en
#   - nomic-ai/nomic-embed-text-v1.5
#   - sentence-transformers/all-MiniLM-L6-v2
#
# 


# If you cannot download the RAGFlow Docker image:
#
# - For the `nightly-slim` edition, uncomment either of the following:
# RAGFLOW_IMAGE=swr.cn-north-4.myhuaweicloud.com/infiniflow/ragflow:nightly-slim
# RAGFLOW_IMAGE=registry.cn-hangzhou.aliyuncs.com/infiniflow/ragflow:nightly-slim
#
# - For the `nightly` edition, uncomment either of the following:
# RAGFLOW_IMAGE=swr.cn-north-4.myhuaweicloud.com/infiniflow/ragflow:nightly
# RAGFLOW_IMAGE=registry.cn-hangzhou.aliyuncs.com/infiniflow/ragflow:nightly

# The local time zone.
TIMEZONE='Asia/Shanghai'

# Uncomment the following line if you have limited access to huggingface.co:
# HF_ENDPOINT=https://hf-mirror.com

# Optimizations for MacOS
# Uncomment the following line if your OS is MacOS:
# MACOS=1

# The maximum file size for each uploaded file, in bytes.
# You can uncomment this line and update the value if you wish to change the 128M file size limit
# MAX_CONTENT_LENGTH=134217728
# After making the change, ensure you update `client_max_body_size` in nginx/nginx.conf correspondingly.

# The log level for the RAGFlow's owned packages and imported packages.
# Available level:
# - `DEBUG`
# - `INFO` (default)
# - `WARNING`
# - `ERROR`
# For example, following line changes the log level of `ragflow.es_conn` to `DEBUG`:
# LOG_LEVELS=ragflow.es_conn=DEBUG
WS=1
DB_TYPE=postgres
HF_ENDPOINT=https://modelscope.cn
NPM_CONFIG_USERCONFIG=$SCRIPT_PATH/.npmrc
RAGFLOW_HTTP_PORT=$SVR_HTTP_PORT
MODEL_NETWORK_HOST=10.0.22.148
```

## 5. ragflow/entrypoint.dev.sh


```bash
#!/bin/bash

# replace env variables in the service_conf.yaml file
rm -rf /ragflow/conf/service_conf.yaml
while IFS= read -r line || [[ -n "$line" ]]; do
    # Use eval to interpret the variable with default values
    eval "echo \"$line\"" >> /ragflow/conf/service_conf.yaml
done < /ragflow/conf/service_conf.yaml.template

/usr/sbin/nginx

export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/

PY=python3
if [[ -z "$WS" || $WS -lt 1 ]]; then
  WS=1
fi

# Get number of available GPUs
NUM_GPUS=$(nvidia-smi --query-gpu=gpu_name --format=csv,noheader | wc -l)
if [[ $NUM_GPUS -lt 1 ]]; then
  NUM_GPUS=1
fi

function task_exe(){
    while [ 1 -eq 1 ];do
      $PY rag/svr/task_executor.py $1;
    done
}

for ((i=0;i<WS;i++))
do
  # Distribute workers evenly across GPUs using modulo
  gpu_id=$((i % NUM_GPUS))
  CUDA_VISIBLE_DEVICES=$gpu_id task_exe $i &
done

while [ 1 -eq 1 ];do
    $PY api/ragflow_server.py
done

wait;
```