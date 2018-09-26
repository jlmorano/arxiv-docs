import os

SECRET_KEY = os.environ.get('SECRET_KEY', 'asdf1234')
INDEX_NAME = os.environ.get('INDEX_NAME', 'idx')
SITE_NAME = os.environ.get('SITE_NAME', 'site')
SITE_PATH = os.path.join(
    os.environ.get('BUILD_PATH', ''),
    SITE_NAME
)
SERVER_NAME = os.environ.get('DOCS_SERVER_NAME')

EXTERNAL_URL_SCHEME = os.environ.get('EXTERNAL_URL_SCHEME', 'https')
BASE_SERVER = os.environ.get('BASE_SERVER', 'arxiv.org')
URLS = [
    ("login", "/login", BASE_SERVER),
    ("logout", "/logout", BASE_SERVER),
]

LOGLEVEL = os.environ.get('LOGLEVEL', 10)


VERSION = os.environ.get('VERSION')
SOURCE = os.environ.get('SOURCE')
BUILD_TIME = os.environ.get('BUILD_TIME')
