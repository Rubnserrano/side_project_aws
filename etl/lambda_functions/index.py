def handler(event, context):
    print("Evento recibido:", event)
    # Aquí puedes procesar el archivo o lo que quieras
    return {
        "statusCode": 200,
        "body": "Procesado con éxito"
    }
