import threading
import time
from typing import Any

import cbor2
import zenoh
from nicegui import Client, ui

channels: dict[str, tuple[Any, Any]] = {}


def subscribe_in_background():
    config = zenoh.Config.from_file("zenoh_config.json5")
    print(config)
    zenoh.init_log_from_env_or("error")
    print("Opening session...")
    with zenoh.open(config) as session:
        with session.declare_subscriber("**") as sub:
            samples: int = 0
            last_print_time = time.perf_counter_ns()
            print(f"last print time: {last_print_time}")
            for sample in sub:
                if sample.encoding != zenoh.Encoding.APPLICATION_CBOR:
                    print(f"wrong encoding: {sample.encoding}")
                    continue
                if sample.kind == zenoh.SampleKind.DELETE:
                    channels.pop(str(sample.key_expr), None)
                elif sample.kind == zenoh.SampleKind.PUT:
                    channels[str(sample.key_expr)] = (cbor2.loads(sample.payload.to_bytes()), sample.timestamp.get_time() if sample.timestamp else None)
                samples += 1
                if (time.perf_counter_ns() - last_print_time) > 10e9:
                    print(f"samples/s: {samples/10}")
                    last_print_time = time.perf_counter_ns()
                    samples = 0


def query_channels():
    try:
        config = zenoh.Config.from_file("zenoh_config.json5")
        zenoh.init_log_from_env_or("error")
        print("Opening session...")
        with zenoh.open(config) as session:
            replies = session.liveliness().get("**/@adv/**", timeout=10.0, handler=zenoh.handlers.RingChannel(100))
            print(replies)
            for reply in replies:
                try:
                    print(str(reply.ok.key_expr))
                except Exception as e:
                    print(e)
    except Exception as e:
        print(e)


@ui.page("/")
async def main_page(client: Client):

    filter = ui.input('Filter')
    columns = [{"name": "channel", "label": "channel", "field": "channel", "align": "left", "style": "width: 700px"},
               {"name": "value", "label": "value", "field": "value", "align": "right", "style": "width: 100px"},
               {"name": "timestamp", "label": "timestamp", "field": "timestamp", "align": "right", "style": "width: 200px"},

               ]
    channels_table = ui.table(columns=columns, rows=[], pagination=25).props("dense")
    filter.bind_value(channels_table, 'filter')
    async def update_table():
        channels_table.rows = [{"channel": channel, "value": value[0], "timestamp": value[1]} for channel,value in channels.items()]
    ui.timer(0.1, update_table)

    ui.button("query liveliness", on_click=lambda: query_channels())
    # channel_list = 


if __name__ in {"__main__", "__mp_main__"}:
    print("starting")
    subscribe_thread = threading.Thread(target=subscribe_in_background)
    subscribe_thread.start()
    ui.run()
