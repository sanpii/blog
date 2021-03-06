#!/usr/bin/env python
# -*- coding: utf-8 -*- #

SITENAME = u'Le dernier blog\navant la fin du monde'
RELATIVE_URLS = True
PATH = 'src/'

TIMEZONE = 'Europe/Paris'

STATIC_PATHS = (['images', 'files'])

DEFAULT_PAGINATION = 10
DEFAULT_CATEGORY = 'Humeur'
DEFAULT_DATE = 'fs'
DEFAULT_AUTHOR = 'Sanpi'

DISPLAY_PAGES_ON_MENU = False

ARTICLE_URL = "{category}/{slug}"
ARTICLE_SAVE_AS = "{category}/{slug}/index.html"

PLUGINS = [
    'code-paste',
]

LICENSE = 'Blog dans le domaine public vivant <a href="https://creativecommons.org/publicdomain/zero/1.0/">cc0</a>.'

# Social widget
SOCIAL = (
    ('flask', 'https://github.com/sanpii'),
    ('euro', 'https://liberapay.com/sanpi/'),
    ('bitcoin', 'bitcoin:15WyuHEMqtugjPLsJoXiBiAL7jtLmwLsJH'),
    ('envelope', 'mailto:sanpi+blog@homecomputing.fr'),
)

# Feed
FEED_DOMAIN = 'https://sanpi.homecomputing.fr'
FEED_RSS = 'all.rss.xml'
TAG_FEED_RSS = 'feeds/tags/%s.rss.xml'
CATEGORY_FEED_RSS = 'feeds/categories/%s.rss.xml'
