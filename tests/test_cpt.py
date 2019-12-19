import unittest
from hcuppy.cpt import CPT


class TestLicense(unittest.TestCase):

    def test_license(self):
        cpt = CPT()
        cpt.download_data()

    def test_section(self):
        cpt = CPT()
        out = cpt.get_cpt_section("E0100")
        self.assertTrue(out["sect"] == "HCPCS2-E")
