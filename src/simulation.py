import json
import random
from time import sleep
from typing import List, Dict
from uuid import uuid4

from awscrt import mqtt
from awsiot import mqtt_connection_builder

# AWS IoT Core Configuration
ENDPOINT = "afrno95u33xaq-ats.iot.us-east-1.amazonaws.com"
PATH_TO_CERTIFICATE = "files/test.cert.pem"
PATH_TO_PRIVATE_KEY = "files/test.private.key"
PATH_TO_AMAZON_ROOT_CA_1 = "files/root-CA.crt"

class Sensor:
    def __init__(self, initial_temp, sensor_id, is_close_to_ac):
        self.ARTEFACT_PROBABILITY_PERCENTAGE = 5
        self.temperature = initial_temp
        self.sensor_id = sensor_id
        self.is_close_to_ac = is_close_to_ac

        # MQTT connection for the sensor
        self.sensor_mqtt_connection = mqtt_connection_builder.mtls_from_path(
            endpoint=ENDPOINT,
            cert_filepath=PATH_TO_CERTIFICATE,
            pri_key_filepath=PATH_TO_PRIVATE_KEY,
            ca_filepath=PATH_TO_AMAZON_ROOT_CA_1,
            client_id=f"temp_{sensor_id}",
            clean_session=True,
            keep_alive_secs=6
        )
        connect_future = self.sensor_mqtt_connection.connect()
        connect_future.result()
        print(f"Sensor {sensor_id} connected to AWS IoT Core.")

    @staticmethod
    def truncate(temp: float) -> float:
        return float(f'{temp:.2f}')

    def has_artefact_value(self) -> bool:
        return random.randint(0, int((100 / self.ARTEFACT_PROBABILITY_PERCENTAGE) - 1)) == 0

    def calculate_temperature_and_add_artefact(self, is_ac_enabled: bool, zone_id: int) -> float:
        if self.has_artefact_value():
            return self.truncate(random.randint(40, 50))  # Artefact temperature

        if is_ac_enabled:
            return self.truncate(
                max(self.temperature * 0.988, 20) if self.is_close_to_ac else max(self.temperature * 0.992, 20)
            )
        else:
            return self.truncate(min(self.temperature * 1.008, 40))

    def send_temperature_message(self, zone_id: int, is_ac_enabled: bool) -> None:
        temperature = self.calculate_temperature_and_add_artefact(is_ac_enabled, zone_id)
        message = json.dumps(self.format_temperature_message(temperature, zone_id))
        topic = f"sensor/temperature/temp_{self.sensor_id}"

        print(f"Publishing to topic {topic}: {message}")  # Debugging log
        self.sensor_mqtt_connection.publish(
            topic=topic,
            qos=mqtt.QoS.AT_LEAST_ONCE,
            payload=message
        )

    def format_temperature_message(self, temperature: float, zone_id: int) -> Dict:
        return {
            "id": str(uuid4()),
            "temperature": temperature,
            "sensor_id": self.sensor_id,
            "zone_id": zone_id
        }


class Zone:
    def __init__(self, zone_id: int, sensors: List[Sensor], is_ac_enabled: bool):
        self.zone_id = zone_id
        self.sensors = sensors
        self.is_ac_enabled = is_ac_enabled

        # MQTT connection for the AC
        self.ac_mqtt_connection = mqtt_connection_builder.mtls_from_path(
            endpoint=ENDPOINT,
            cert_filepath=PATH_TO_CERTIFICATE,
            pri_key_filepath=PATH_TO_PRIVATE_KEY,
            ca_filepath=PATH_TO_AMAZON_ROOT_CA_1,
            client_id=f"AC-{zone_id}",
            clean_session=True,
            keep_alive_secs=6
        )
        connect_future = self.ac_mqtt_connection.connect()
        connect_future.result()
        print(f"Zone {zone_id} connected to AWS IoT Core.")

        self.subscribe_future, self.packet_id = self.ac_mqtt_connection.subscribe(
            topic=f"AC/AC-{zone_id}",
            qos=mqtt.QoS.AT_LEAST_ONCE,
            callback=self.on_message_received
        )

    def on_message_received(self, topic, payload, dup, qos, retain, **kwargs) -> None:
        self.is_ac_enabled = json.loads(payload)["state"]["enabled"]
        print(f"Message received on {topic}: {payload}")
        print(f"================ ZONE {self.zone_id} : AC SWITCH TO {self.is_ac_enabled} ================")


class House:
    def __init__(self, zones: List[Zone], loop_duration: int):
        self.zones = zones
        self.loop_duration = loop_duration

    def run_simulation(self) -> None:
        while True:
            for zone in self.zones:
                for sensor in zone.sensors:
                    sensor.send_temperature_message(zone.zone_id, zone.is_ac_enabled)
            sleep(self.loop_duration)


if __name__ == '__main__':
    LOOP_DURATION = 5  # seconds

    # Initialize sensors
    temp_sensor_1 = Sensor(20, 1, True)
    temp_sensor_2 = Sensor(20, 2, False)
    temp_sensor_3 = Sensor(20, 3, True)
    temp_sensor_4 = Sensor(20, 4, False)

    # Initialize zones
    zone_1 = Zone(1, [temp_sensor_1, temp_sensor_2], False)
    zone_2 = Zone(2, [temp_sensor_3, temp_sensor_4], False)

    # Subscribe to AC topics
    zone_1.subscribe_future.result()
    zone_2.subscribe_future.result()

    # Initialize house and run simulation
    house = House([zone_1, zone_2], LOOP_DURATION)
    print("Starting simulation...")
    house.run_simulation()
