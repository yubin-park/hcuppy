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

        # Gabriel test case 1
        dx_full_lst = [ 'I10', 'I12.9', 'I13.0', 'I25.10', 'I25.2',
                    'I35.0', 'I48.0', 'I48.91', 'I50.32', 'I50.43',
                    'I50.9', 'I51.7', 'I65.29', 'I70.0', 'I70.8',
                    'I95.1', 'J40', 'J43.9', 'J45.909', 'J90',
                    'L40.9', 'M54.5', 'N18.3', 'N18.9', 'R31.9',
                    'R55', 'R91.8', 'Z00.6', 'Z01.818', 'Z08'] 
        dx_poa_lst = [ 'I10', 'I12.9', 'I13.0', 'I25.10', 'I25.2',
                    'I35.0', 'I48.0', 'I48.91', 'I50.32', 'I50.43',
                    'I50.9', 'I51.7', 'I65.29', 'I70.0', 'I70.8',
                    'I95.1', 'J40', 'J43.9', 'J45.909', 'J90', 'L40.9', 
                    'M54.5', 'N18.3', 'N18.9', 'R31.9', 'R55',
                    'R91.8', 'Z00.6', 'Z01.818']
        out = ee.get_elixhauser(dx_full_lst, dx_poa_lst)
        cmrbdt_set = set(['HTN_CX', 'HF', 'VALVE', 'CBVD_POA', 
                        'PERIVASC', 'LUNG_CHRONIC', 'RENLFL_MOD', 'CBVD'])
          
        self.assertTrue(cmrbdt_set == set(out["cmrbdt_lst"]))

        # Gabriel test case 2
        dx_full_list = ['D72.829', 'E78.2', 'E78.4', 'E78.5', 'G89.18',
                        'I20.0', 'I21.4', 'I23.8', 'I25.10', 'I25.110',
                        'I25.2', 'I31.1', 'I31.3', 'I31.4', 'I31.9',
                        'I49.9', 'I50.20', 'I95.81', 'I95.9', 'I97.190',
                        'K21.9', 'K57.30', 'K62.5', 'K64.8', 'L03.114',
                        'L25.9', 'R00.1', 'R05', 'R06.02', 'R06.89',
                        'R07.2', 'R07.89', 'R07.9', 'R11.2', 'R42',
                        'R50.9', 'R74.8', 'R91.8', 'R94.31', 'T80.29XA',
                        'Y83.1', 'Y84.8', 'Z02.89', 'Z12.11', 'Z48.812']

        dx_poa_list= [] # if empty, it initialize with the dx_full_lst
        out = ee.get_elixhauser(dx_full_lst, dx_poa_lst)
        self.assertTrue("HTN_CX" in out["cmrbdt_lst"])
        self.assertTrue("LUNG_CHRONIC" in out["cmrbdt_lst"])

if __name__ == "__main__":
    unittest.main()
