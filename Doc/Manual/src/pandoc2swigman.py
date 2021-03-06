# -*- coding: utf-8 -*-
"""Convert Pandoc-generated HTML to SWIG html

Requires Python 3.x"""
#-----------------------------------------------------------------------------#
from html.entities import codepoint2name
import os
import re
from exnihiloenv.rewriter import ReWriter
from string import printable
###############################################################################

RE_HEADER = re.compile(r'^<h(\d) id="([^"]+)">(.*)</h(\d)>$')
RE_PRE    = re.compile(r'^<pre class="([^"]+)">')
RE_ENDPRE = re.compile(r'</pre>')
RE_LINK   = re.compile(r'<a href="#([^"]+)">')

NEW_HEADER = '<H{lev:d}><a name="{link}">{title}</a></H{lev:d}>\n'

SELECTOR = {
        'fortran': "targetlang",
        'swig':    "code",
        'cpp':     "code",
        'c++':     "code",
        'c':       "code",
        'sh':      "shell",
        }

NONASCII_TO_HTML = {}
for k in set(codepoint2name) - set(ord(x) for x in printable):
    NONASCII_TO_HTML[k] = "&" + codepoint2name[k] + ";"

def convert_link(link):
    return "Fortran_" + link.replace("-","_")

def repl_link_match(match):
    return r'<a href="#{}">'.format(convert_link(match.group(1)))

def swiggify(path):
    with ReWriter(path) as rewriter:
        (oldf, newf) = rewriter.files
        rewriter.dirty = True

        in_code = False
        for line in oldf:
            # Convert special characters to HTML &foo; characters
            line = line.translate(NONASCII_TO_HTML)

            if not in_code:
                match = RE_PRE.match(line)
                if match:
                    code = SELECTOR[match.group(1)]
                    line = '\n<div class="{}"><pre>{}'.format(
                        code, line[match.end():])
                    in_code = True

            if not in_code:
                match = RE_HEADER.match(line)
                if match:
                    (lev, link, title, lev2) = match.groups()
                    lev = int(lev) + 1 # lower the heading level
                    link = convert_link(link)
                    line = NEW_HEADER.format(lev=lev, link=link, title=title)

                line = RE_LINK.sub(repl_link_match, line)
                line = line.replace("<p>", "\n<p>\n")
                line = line.replace("</p>", "\n</p>\n")

            if in_code and line.endswith("</pre>\n"):
                line = line[:-1] + "</div>\n\n"
                in_code = False

            newf.write(line)

def main():
    extensions = (".html",)

    from exnihiloenv.filemodify import _common
    _common.run(swiggify, default_extensions=",".join(extensions))

#-----------------------------------------------------------------------------#
if __name__ == '__main__':
    #main()
    swiggify("../Fortran.html")
