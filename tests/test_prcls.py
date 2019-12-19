import unittest
from hcuppy.prcls import PrClsEngine


class TestPrClsEngine(unittest.TestCase):

    def test_prclsmapping(self):
        pce = PrClsEngine()
        prcls_lst = pce.get_prcls(["B231Y0Z", "randomstring"])
        self.assertEqual(prcls_lst[0]["desc"], "Minor Diagnostic")
        self.assertEqual(pce.get_prcls("B231Y0Z")["desc"],
                         "Minor Diagnostic")
