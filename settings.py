#!/usr/bin/env python
# -*- coding: utf-8 -*- #

SITENAME = u'Le dernier blog\navant la fin du monde'
SITEURL = '//sanpi.homecomputing.fr'

TIMEZONE = 'Europe/Paris'

STATIC_PATHS = (['images', 'files'])

DEFAULT_PAGINATION = 10
DEFAULT_CATEGORY = 'Humeur'

DISPLAY_PAGES_ON_MENU = False

ARTICLE_URL = "{category}/{slug}"
ARTICLE_SAVE_AS = "{category}/{slug}/index.html"

PLUGINS = [
    'code-paste',
]

# Social widget
LINKS =  ()

SOCIAL = (
    ('comment-alt', 'https://status.homecomputing.fr/sanpi'),
    ('beaker', 'https://git.homecomputing.fr'),
)

EMAIL = 'sanpi@homecomputing.fr'

# Feed
FEED_DOMAIN = 'http://sanpi.homecomputing.fr'
FEED_RSS = 'all.rss.xml'
TAG_FEED_RSS = 'feeds/tags/%s.rss.xml'
