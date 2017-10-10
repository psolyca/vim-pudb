"""
Usage: clear_breakpoints.py

Clear all breakpoints

"""

import sys

from pudb.settings import save_breakpoints
from pudb import NUM_VERSION

save_breakpoints([])
