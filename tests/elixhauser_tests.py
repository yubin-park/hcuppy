import unittest
from hcuppy.elixhauser import ElixhauserEngine

class TestElixhauserEngine(unittest.TestCase):

    def test_elixhauser(self):
        ee = ElixhauserEngine()
        out = ee.get_elixhauser(["E119", "E108", "I10", "I110", "Z944"])
        self.assertTrue("HTNCX" in out["cmrbdt_lst"])
        self.assertEqual(out["rdmsn_scr"], 31)
        self.assertEqual(out["mrtlt_scr"], 9)

if __name__=="__main__":
    unittest.main()

