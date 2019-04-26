import unittest
from hcuppy.uflag import UFlagEngine

class TestUFlagEngine(unittest.TestCase):

    def test_uflagmapping(self):
        ufe = UFlagEngine()
        self.assertTrue("Blood" in ufe.get_uflag(rev_lst=["0380"]))
        self.assertTrue("Chest X-Ray" in 
                        ufe.get_uflag(pr_lst=["BB0DZZZ"]))
        self.assertTrue("Computed Tomography Scan" in 
                        ufe.get_uflag(pr_lst=["B02000Z"]))

        uflag_lst = ufe.get_uflag(rev_lst=["0380"], pr_lst=["BB0DZZZ"])
        self.assertTrue("Blood" in uflag_lst)
        self.assertTrue("Chest X-Ray" in uflag_lst)

if __name__=="__main__":
    unittest.main()


