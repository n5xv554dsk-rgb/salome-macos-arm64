"""Re-render a results folder:  ./salome python pd_dynamic/render.py <results dir> [warp scale]"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pdsalome.viz import render  # noqa: E402

out = os.path.abspath(sys.argv[1])
render(os.path.join(out, "solution.med"), out, warp_scale=float(sys.argv[2]) if len(sys.argv) > 2 else 20.0)
