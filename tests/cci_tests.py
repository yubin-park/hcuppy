import unittest
from hcuppy.cci import CCIEngine

class TestCCIEngine(unittest.TestCase):

    def test_ccimapping(self):
        ce = CCIEngine()
        cci_lst = ce.get_cci(["E119", "I10"])
        self.assertTrue(True in {cci["is_chronic"] for cci in cci_lst})

if __name__=="__main__":
    unittest.main()

