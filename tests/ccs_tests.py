import unittest
from hcuppy.ccs import CCSEngine

class TestCCSEngine(unittest.TestCase):

    def test_ccsmapping(self):
        cedx = CCSEngine(mode="dx")
        ccs_lst = cedx.get_ccs(["E119", "I10"])
        self.assertTrue("98" in {ccs["ccs"] for ccs in ccs_lst})
        self.assertTrue("49" in {ccs["ccs"] for ccs in ccs_lst})

        ccs_lst = cedx.get_ccs(["randomstring", "E119"])
        self.assertEqual(len(ccs_lst), 2)
        self.assertEqual(ccs_lst[0], None)
        self.assertEqual(ccs_lst[1]["ccs"], "49")

        ccs = cedx.get_ccs("E119")
        self.assertEqual(ccs["ccs"], "49")

        cepr = CCSEngine(mode="pr")
        ccs_lst = cepr.get_ccs(["00800ZZ"])
        self.assertTrue("1" in {ccs["ccs"] for ccs in ccs_lst})


if __name__=="__main__":
    unittest.main()

