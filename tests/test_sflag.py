import unittest
from hcuppy.sflag import SFlagEngine


class TestSFlagEngine(unittest.TestCase):

    def test_sflagmapping(self):
        sfe = SFlagEngine()
        self.assertEqual(sfe.get_sflag("69970")["flag"], "2")

        out = sfe.get_sflag(["69970", "randomstring"])
        self.assertEqual(out[0]["flag"], "2")
        self.assertEqual(out[1]["flag"], "na")
