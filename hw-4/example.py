import os
import re
import logging
import time
import unicodedata
import graphyte

from requests import get as get_url
from bs4 import BeautifulSoup

logging.getLogger().setLevel(logging.INFO)

BASE_URL = 'https://yandex.ru/pogoda/moscow'

GRAPHITE_HOST = os.environ['GRAPHITE_HOST']


def get_int_temp(s):
    match = re.search(r'[+-]\d+', s)
    if match is None:
        return None
    return int(match.group(0))

def parse_yandex_page(page):
    current_whether_block = page.findAll('div', {'class': 'fact__temp'})

    if len(current_whether_block) == 0:
        return None

    current_temperature = current_whether_block[0].find('span', {'class': 'temp__value'}).text
    current_temperature = get_int_temp(current_temperature)
    temperatures = [('current', current_temperature)]

    whether_blocks = page.findAll('div', {'class': 'fact__hour'})

    for offset, block in zip([1, 2], whether_blocks[1:3]):
        value = get_int_temp(block.find('div', {'class': 'fact__hour-temp'}).text)
        temperatures.append(('%dh' % offset, value))
    return temperatures


def send_metrics(temperatures):
    sender = graphyte.Sender(GRAPHITE_HOST, prefix='temperatures')
    for metric in temperatures:
        sender.send(metric[0], metric[1])


def whether_example():
    page = get_url(BASE_URL).content.decode('utf-8')
    soup = BeautifulSoup(page, 'html.parser')
    ts = parse_yandex_page(soup)
    send_metrics(ts)


if __name__ == '__main__':
    whether_example()
