import re
import urllib

from pelican import signals

from pygments import highlight
from pygments.lexers import get_lexer_for_filename
from pygments.formatters import HtmlFormatter

def replace_code_paste(generator):
    regex = re.compile(r'(<p>\[paste:([^\]]+)\]</p>)')
    for article in generator.articles:
        for match in regex.findall(article._content):
            try:
                code = urllib.urlopen(match[1]).read()
            except:
                code = open(match[1]).read()

            try:
                lexer = get_lexer_for_filename(match[1])
            except:
                from pygments.lexers import PythonLexer
                lexer = PythonLexer()
            replacement = highlight(code, lexer, HtmlFormatter())
            article._content = article._content.replace(match[0], replacement)

def register():
    signals.article_generator_finalized.connect(replace_code_paste)
