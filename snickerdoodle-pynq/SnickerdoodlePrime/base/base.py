import pynq
import pynq.lib
from .constants import *


__author__ = "James Cotton"


class BaseOverlay(pynq.Overlay):
    """ The Base overlay for the Snickerdoodle 
        This bitstream has no PL so this doesn't expose anything"
    """

    def __init__(self, bitfile, **kwargs):
        super().__init__(bitfile, **kwargs)
