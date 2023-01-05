import os
import logging
from confluent_kafka import Consumer, Producer

from pingpong import PingPong


BROKER_ADDRESS = os.environ['BROKER_ADDRESS']
CONSUMER_GROUP_ID = os.environ['CONSUMER_GROUP_ID']
CONSUMER_BEHAVIOUR = os.environ['CONSUMER_BEHAVIOUR']
TOPIC = os.environ['TOPIC']

logging.basicConfig(level=logging.DEBUG)

c = Consumer({
  'bootstrap.servers': BROKER_ADDRESS,
  'group.id': CONSUMER_GROUP_ID,
  'auto.offset.reset': CONSUMER_BEHAVIOUR
})

p = Producer({
  'bootstrap.servers': BROKER_ADDRESS,
  'socket.timeout.ms': 100,
})

c.subscribe([TOPIC])

while True:
  msg = c.poll(1.0)

  if msg is None:
    continue

  if msg.error():
    logging.error('Consumer error: {}'.format(msg.error()))
    continue

  logging.debug('Received message: {}'.format(msg.value()))

  response = PingPong.process_message(msg.value())
  response_topic = response[0]
  response_message = response[1]

  logging.debug('Response: {}, Topic: {}'.format(
      response_message, response_topic))

  p.produce(response_topic, response_message)
  p.flush()
