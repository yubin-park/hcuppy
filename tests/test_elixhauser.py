import unittest
from hcuppy.elixhauser_v19 import ElixhauserEngineV19
from hcuppy.elixhauser import ElixhauserEngine

class TestElixhauserEngine(unittest.TestCase):

    def test_elixhauser_v19(self):
        ee = ElixhauserEngineV19()
        out = ee.get_elixhauser(["E119", "E108", "I10", "I110", "Z944"])
        self.assertTrue("HTNCX" in out["cmrbdt_lst"])
        self.assertEqual(out["rdmsn_scr"], 31)
        self.assertEqual(out["mrtlt_scr"], 9)

        out = ee.get_elixhauser(["M545"])
        self.assertTrue(len(out["cmrbdt_lst"]) == 0)

        out = ee.get_elixhauser(["D473"])
        self.assertTrue(len(out["cmrbdt_lst"]) == 0)

    def test_elixhauser(self):
        ee = ElixhauserEngine()
        out = ee.get_elixhauser(["E119", "E108", "I10", "I110", "Z944"])
        self.assertTrue("DIAB_CX" in out["cmrbdt_lst"])
        self.assertEqual(out["rdmsn_scr"], 21)
        self.assertEqual(out["mrtlt_scr"], 31)
       
        out = ee.get_elixhauser(["E640", "E119"], ["E119"])
        self.assertTrue("WGHTLOSS" in out["cmrbdt_lst"])
        
        out = ee.get_elixhauser(["E640", "E119", "B190"], 
                                ["E119", "B190"])
        self.assertTrue("LIVER_SEV" in out["cmrbdt_lst"])

        out = ee.get_elixhauser(["E640", "E119", "B190"], 
                                ["E119"])
        self.assertTrue("LIVER_SEV" not in out["cmrbdt_lst"])


if __name__ == "__main__":
    unittest.main()
