#!/usr/bin/env python
# -*- coding: utf-8 -*- #

SITENAME = u'Sanpi\u2019s blog'
SITEURL = 'http://sanpi.homecomputing.fr'

TIMEZONE = 'Europe/Paris'

STATIC_PATHS = (['images', 'documents'])

DEFAULT_PAGINATION = 10

DISPLAY_PAGES_ON_MENU = False

ARTICLE_URL = "{category.slug}/{slug}"
ARTICLE_SAVE_AS = "{category.slug}/{slug}/index.html"

# Social widget
LINKS =  ()

SOCIAL = (
    ('comment-alt', 'http://status.homecomputing.fr/sanpi'),
    ('github', 'https://github.com/sanpii'),
)

EMAIL = 'sanpi@homecomputing.fr'

# Feed
FEED_DOMAIN = 'http://sanpi.homecomputing.fr'
FEED_RSS = 'all.rss.xml'
TAG_FEED_RSS = 'feeds/tags/%s.rss.xml'
