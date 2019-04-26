import unittest
from hcuppy.ccs import CCSEngine

class TestCCSEngine(unittest.TestCase):

    def test_ccsmapping(self):
        cedx = CCSEngine(mode="dx")
        ccs_lst = cedx.get_ccs(["E119", "I10"])
        self.assertTrue("98" in {ccs["ccs"] for ccs in ccs_lst})
        self.assertTrue("49" in {ccs["ccs"] for ccs in ccs_lst})

        cepr = CCSEngine(mode="pr")
        ccs_lst = cepr.get_ccs(["00800ZZ"])
        self.assertTrue("1" in {ccs["ccs"] for ccs in ccs_lst})


if __name__=="__main__":
    unittest.main()

