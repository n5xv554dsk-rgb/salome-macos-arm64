# -*- coding: iso-8859-1 -*-
import re

BLANKLINE_MARKER = '<BLANKLINE>'
ELLIPSIS_MARKER = '...'
True=1
False=0

def check(want,got):
    if got == want: return True

    # Replace <BLANKLINE> in want with a blank line.
    want = re.sub('(?m)^%s\s*?$' % re.escape(BLANKLINE_MARKER),
                  '', want)
    # If a line in got contains only spaces, then remove the
    # spaces.
    got = re.sub('(?m)^\s*?$', '', got)
    if got == want:
       return True

    if _ellipsis_match(want, got): 
       return True

    return False

def _ellipsis_match(want, got):
    if ELLIPSIS_MARKER not in want:
        return want == got

    # Find "the real" strings.
    ws = want.split(ELLIPSIS_MARKER)
    assert len(ws) >= 2

    # Deal with exact matches possibly needed at one or both ends.
    startpos, endpos = 0, len(got)
    w = ws[0]
    if w:   # starts with exact match
        if got.startswith(w):
            startpos = len(w)
            del ws[0]
        else:
            return False
    w = ws[-1]
    if w:   # ends with exact match
        if got.endswith(w):
            endpos -= len(w)
            del ws[-1]
        else:
            return False

    if startpos > endpos:
        # Exact end matches required more characters than we have, as in
        # _ellipsis_match('aa...aa', 'aaa')
        return False

    # For the rest, we only need to find the leftmost non-overlapping
    # match for each piece.  If there's no overall match that way alone,
    # there's no overall match period.
    for w in ws:
        # w may be '' at times, if there are consecutive ellipses, or
        # due to an ellipsis at the start or end of `want`.  That's OK.
        # Search for an empty string succeeds, and doesn't change startpos.
        startp = got.find(w, startpos, endpos)
        if startp < 0:
            return False
        startpos = startp + len(w)

    return True
