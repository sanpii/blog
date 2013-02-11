#!/usr/bin/env python
# -*- coding: utf-8 -*- #

SITENAME = u'Sanpi\u2019s blog'
SITEURL = 'http://sanpi.homecomputing.fr'

TIMEZONE = 'Europe/Paris'

DEFAULT_LANG = u'fr'

STATIC_PATHS = (['images', 'documents'])

# Blogroll
LINKS =  (('Pelican', 'http://docs.notmyidea.org/alexis/pelican/'),
          ('Python.org', 'http://python.org'),
          ('Jinja2', 'http://jinja.pocoo.org'),
          ('You can modify those links in your config file', '#'),)

# Social widget
SOCIAL = (('You can add links in your config file', '#'),
          ('Another social link', '#'),)

DEFAULT_PAGINATION = 10

# Feed
FEED_DOMAIN = 'http://sanpi.homecomputing.fr'
TAG_FEED_ATOM = 'feeds/tags/%s.atom.xml'
