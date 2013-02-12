#!/usr/bin/env python
# -*- coding: utf-8 -*- #

SITENAME = u'Sanpi\u2019s blog'
SITEURL = 'http://sanpi.homecomputing.fr'

TIMEZONE = 'Europe/Paris'

DEFAULT_LANG = u'fr'

STATIC_PATHS = (['images', 'documents'])

THEME = 'iris'

# Blogroll
LINKS =  ()

# Social widget
SOCIAL = (
    ('comment-alt', 'http://status.homecomputing.fr/sanpi'),
    ('github', 'http://status.homecomputing.fr/sanpi'),
)
EMAIL = 'mailto:sanpi@homecomputing.fr'

DEFAULT_PAGINATION = 10

# Feed
FEED_DOMAIN = 'http://sanpi.homecomputing.fr'
TAG_FEED_ATOM = 'feeds/tags/%s.atom.xml'
