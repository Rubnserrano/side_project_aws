import pandas as pd
import boto3

def handler(event, context):
    print("Evento recibido:", event)

    try:
        s3 = boto3.client("s3")

        record = event["Records"][0]
        bucket_name = record["s3"]["bucket"]["name"]
        object_key = record["s3"]["object"]["key"]

        if object_key.endswith(".csv"):
            print(f"csv localizado: {object_key}")

            # Descargamos el archivo directamente como objeto en memoria
            response = s3.get_object(Bucket=bucket_name, Key=object_key)
            df = pd.read_csv(response["Body"])

            print("Primeras filas del CSV:")
            print(df.head())  # Aquí ves las primeras 5 filas

    except Exception as e:
        print(f"Error procesando el archivo: {e}")

    return {
        "statusCode": 200,
        "body": "Procesado con éxito"
    }
