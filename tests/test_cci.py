import unittest
from hcuppy.cci import CCIEngine


class TestCCIEngine(unittest.TestCase):

    def test_ccimapping(self):
        ce = CCIEngine()
        cci_lst = ce.get_cci(["E119", "I10"])
        self.assertTrue(True in {cci["is_chronic"] for cci in cci_lst})
        self.assertTrue(ce.has_chronic(["E119"]))

        cci_lst = ce.get_cci(["E119", "randomstring"])
        self.assertEqual(cci_lst[1]["is_chronic"], False)
        self.assertTrue(ce.has_chronic(["E119", "randomstring"]))

        self.assertTrue(ce.get_cci("E119")["is_chronic"])
        self.assertTrue(ce.is_chronic("E119"))

if __name__ == '__main__':
    unittest.main()
