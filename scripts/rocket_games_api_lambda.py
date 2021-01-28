import json
import snowflake.connector
import os
import boto3
import logging
import csv
import datetime
import traceback

logger = logging.getLogger()
logger.setLevel(logging.INFO)

region_name = "eu-central-1"

client = boto3.client('secretsmanager', region_name=region_name)
rg_secret_key = os.environ['secret_name']
logging.info(f"Rocket Games Secret Key name:{rg_secret_key}")
rg_sf_secret_dict = client.get_secret_value(SecretId=rg_secret_key)

rg_secret = rg_sf_secret_dict['SecretString']
rg_secret_dict = json.loads(rg_secret)

s3 = boto3.client('s3')
bucket_name = os.environ['Bucket_Name']
logging.info(f'Bucket Name:{bucket_name}')
player_ingest_key = os.environ['player_ingest_key']
logging.info(f'Bucket Name:{player_ingest_key}')
studio_ingest_key = os.environ['studio_ingest_key']
logging.info(f'Bucket Name:{studio_ingest_key}')
datapipeline_key = os.environ['datapipeline_key']
logging.info(f'Bucket Name:{datapipeline_key}')
player_s3_file_name = os.environ['player_s3_filename']
logging.info(f'Bucket Name:{player_s3_file_name}')
studio_s3_file_name = os.environ['studio_s3_filename']
logging.info(f'Bucket Name:{studio_s3_file_name}')

# extracting Snowflake DB details from secrets manager.
SF_HOST = rg_secret_dict['SF_HOST']
SF_ACCOUNT = rg_secret_dict['SF_ACCOUNT']
SF_USER = rg_secret_dict['SF_USER']
SF_WH = rg_secret_dict['SF_WH']
SF_SCHEMA = rg_secret_dict['SF_SCHEMA']
SF_PASSWORD = rg_secret_dict['SF_PWD']
SF_DB = rg_secret_dict['SF_DB']

# fire up an instance of a snowflake connection
connection = snowflake.connector.connect(
    account=SF_ACCOUNT,
    host=SF_HOST,
    schema=SF_SCHEMA,
    user=SF_USER,
    password=SF_PASSWORD,
    warehouse=SF_WH,
    database=SF_DB
)

cur = connection.cursor()


def rg_lambda_handler(event, context):
    """This method is reposible to getn the event from api gateway and invoke various the SQLs in snowflake and write the load the data to s3 bucket"""

    logging.info("API Event:%s" % event)
    logging.info("Triggered from API Gateway")

    logging.info(event)

    resource_name = event["resource"]
    resource_method = event["httpMethod"]
    query_param = event["queryStringParameters"]
    payload_body = event["body"]


    logging.info('API Gateway Resource Name:%s' % resource_name)
    logging.info('API Gateway Resource Method:%s' % resource_method)
    logging.info('API Gateway Query String Parameter:%s' % query_param)
    logging.info('API Gateway Payload Body:%s' % payload_body)
    try:

        if resource_name == "/player-ingest" and resource_method == "POST":
            logging.info("Calling method to load the player data into s3 bucket ")
            payload_body =json.loads(event["body"])
            return {
                'statusCode': 200,
                'body': json.dumps(player_ingest_s3_csv_load(payload_body))
            }
        elif resource_name == "/studio-ingest" and resource_method == "POST":
            logging.info("Calling method to load the Studio Publisher data into s3 bucket ")
            payload_body =json.loads(event["body"])
            return {
                'statusCode': 200,
                'body': json.dumps(studio_ingest_s3_csv_load(payload_body))
            }
        elif resource_name == "/stuido" and resource_method == "GET":
            logging.info(
                "Calling method to execute the publisher data-pipeline from s3 bucket to extract the report result ")
            return {
                'statusCode': 200,
                'body': json.dumps(studio_report_datapipeline(query_param))
            }
        else:
            logging.info(
                "Calling method to execute the studio-owner data-pipeline from s3 bucket to extract the report result ")
            return {
                'statusCode': 200,
                'body': json.dumps(rg_owner_report_datapipeline(query_param))
            }
    except Exception as e:
        tb = traceback.format_exc()
        logger.error(tb)
        # remove new line characters from response
        res = str(e).replace("\n", "")
        raise Exception(f"api  request failed with error , {res} ")


def player_ingest_s3_csv_load(payload_body):
    logger.info("This method converts the Json Payload data to CSV and upload the file to s3 bucket")

    player_data = payload_body["records"]
    logger.info(player_data)

    with open("/tmp/player.csv", "w") as f:
        file_header = player_data[0].keys()
        logging.info(file_header)
        writer = csv.DictWriter(f, fieldnames=file_header)
        writer.writeheader()
        for records in player_data:
            writer.writerow(records)

    player_csv_binary = open("/tmp/player.csv", "rb").read()
    try:
        suffix = datetime.datetime.now().strftime("%d%m%Y%H%M%S%f")
        s3_filename = player_s3_file_name.split(".")[-2] + "_" + suffix + ".csv"
        logging.info(f"S3 File name:{s3_filename}")
        s3.put_object(Body=player_csv_binary, Bucket=bucket_name, Key=f'{player_ingest_key}/{s3_filename}')
        logging.info(f"Player file has been loaded to S3 bucket:{bucket_name}/{player_ingest_key}/{s3_filename}")
        return "Player records sucessfully uploaded"
    except botocore.exceptions.ClientError as e:
        if e.response['Error']['Code'] == "404":
            print("The object does not exist.")
        else:
            raise


def studio_ingest_s3_csv_load(payload_body):
    logger.info("This method converts the Publisher Json Payload data to CSV and upload the file to s3 bucket")

    studio_data = payload_body["records"]
    logger.info(studio_data)

    with open("/tmp/studio.csv", "w") as f:
        file_header = studio_data[0].keys()
        logging.info(file_header)
        writer = csv.DictWriter(f, fieldnames=file_header)
        writer.writeheader()
        for records in studio_data:
            writer.writerow(records)

    studio_csv_binary = open("/tmp/studio.csv", "rb").read()
    try:

        suffix = datetime.datetime.now().strftime("%d%m%Y%H%M%S%f")
        s3_filename = studio_s3_file_name.split(".")[-2] + "_" + suffix + ".csv"
        logging.info(f"S3 File name:{s3_filename}")
        s3.put_object(Body=studio_csv_binary, Bucket=bucket_name, Key=f'{studio_ingest_key}/{s3_filename}')
        logging.info(
            f"Studio Game details file has been loaded to S3 bucket:{bucket_name}/{studio_ingest_key}/{s3_filename}")
        return "Studio records sucessfully uploaded"
    except botocore.exceptions.ClientError as e:
        if e.response['Error']['Code'] == "404":
            print("The object does not exist.")
        else:
            raise e


def studio_report_datapipeline(query_param):
    logger.info("This method queries the studio/publisher reports from snowflake and report datapipelines are available in s3 bucket")
    query_value1 = query_param['parameter1']
    query_value2 = query_param['parameter2']
    s3 = boto3.resource("s3")

    if query_value1 == "unregister":
        logging.info("As a studio owner, I want to be able to unregister a user from one or more games in our collection")
        s3_path_sql = "/report-pipelines/report4.sql"
        content_object = s3.Object(bucket_name, s3_path_sql)
        sql_query = content_object.get()['Body'].read().decode('utf-8')
        if '?' in sql_query:
            replace_sql = sql_query.replace("?", query_value2)
        cursor = cur.execute(replace_sql)
        result = cursor.fetchall()
        return result

    if query_value1 == "report-games":
        logging.info("As a studio owner, I want to query the account management system to report the popularity of all our published games")
        s3_path_sql = "/report-pipelines/report5.sql"
        content_object = s3.Object(bucket_name, s3_path_sql)
        sql_query = content_object.get()['Body'].read().decode('utf-8')
        if '?' in sql_query:
            replace_sql = sql_query.replace("?", query_value2)
        cursor = cur.execute(replace_sql)
        result = cursor.fetchall()
        return result


def rg_owner_report_datapipeline(query_param):
    logger.info(
        "This method queries the rocket games owner/publisher reports from snowflake and report datapipelines are available in s3 bucket")
    query_value1 = query_param['parameter1']
    query_value2 = query_param['parameter2']
    # query_value2 represents game name or null value
    s3 = boto3.resource("s3")
    if query_value1 == "PublishedTitles":
        logging.info("As a publisher, I want our analysts to be able to query the account management system to report the popularity of all our published title")
        s3_path_sql = "report-pipelines/report1.sql"
        content_object = s3.Object(bucket_name, s3_path_sql)
        sql_query = content_object.get()['Body'].read().decode('utf-8')
        logging.info(sql_query)
        cursor = cur.execute(sql_query)
        result = cursor.fetchall()
        return result

    if query_value1 == "StudioTitles":
        logging.info("As a publisher, I want out analysts to be able to query the account management system to report a list of all the players playing on a given studios")
        s3_path_sql = "/report-pipelines/report2.sql"
        content_object = s3.Object(bucket_name, s3_path_sql)
        sql_query = content_object.get()['Body'].read().decode('utf-8')
        if "?" in sql_query:
            replace_sql = sql_query.replace("?", query_value2)
        cursor = cur.execute(replace_sql)
        result = cursor.fetchall()
        return result

    if query_value1 == "NonPII":
        logging.info("As a publisher, I want to be able to use non Personal Identifiable Data (PII) from closed accounts in my reports")
        s3_path_sql = "/report-pipelines/report3.sql"
        content_object = s3.Object(bucket_name, s3_path_sql)
        sql_query = content_object.get()['Body'].read().decode('utf-8')
        cursor = cur.execute(sql_query)
        result = cursor.fetchall()
        return result


