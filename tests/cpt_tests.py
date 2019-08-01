import unittest
from hcuppy.cpt import CPT

class TestLicense(unittest.TestCase):

    def test_license(self):
        cpt = CPT()
        cpt.download_data()

if __name__=="__main__":
    unittest.main()

