#!/usr/bin/env python
# -*- coding: utf-8 -*- #

SITENAME = u'Sanpi\u2019s blog'
SITEURL = 'http://sanpi.homecomputing.fr'

TIMEZONE = 'Europe/Paris'

DEFAULT_LANG = u'fr'

STATIC_PATHS = (['images', 'documents'])

THEME = 'iris'

DEFAULT_PAGINATION = 10

DISPLAY_PAGES_ON_MENU = False

ARTICLE_URL = "content/{slug}"
ARTICLE_SAVE_AS = "content/{slug}/index.html"

PATH = 'src'

# Social widget
LINKS =  ()

SOCIAL = (
    ('comment-alt', 'http://status.homecomputing.fr/sanpi'),
    ('github', 'http://status.homecomputing.fr/sanpi'),
)

EMAIL = 'mailto:sanpi@homecomputing.fr'

# Feed
FEED_DOMAIN = 'http://sanpi.homecomputing.fr'
FEED_RSS = 'all.rss.xml'
TAG_FEED_RSS = 'feeds/tags/%s.rss.xml'
