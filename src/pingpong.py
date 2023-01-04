import json

class PingPong:

  SUCCESS_TOPIC = 'dev.pingpong.succeeded'
  FAILURE_TOPIC = 'dev.pingpong.failed'

  @staticmethod
  def process_message(data):
    try:
      data = json.loads(data)

      transaction_id = data['transaction-id']
      payload = data['payload']
      message = payload['message']

      if message == 'ping':
        response_message = json.dumps({ "transaction-id": transaction_id, "payload": { "message": "pong" } })
        return [PingPong.SUCCESS_TOPIC, response_message]
      else:
        response_message = json.dumps({ "transaction-id": transaction_id, "payload": { "message": "Error the message doesn't contain 'ping'" } })
        return [PingPong.FAILURE_TOPIC, response_message]
    except:
      response_message = json.dumps({ "message": "Error in the format of the Kafka event" })
      return [PingPong.FAILURE_TOPIC, response_message ]
k
