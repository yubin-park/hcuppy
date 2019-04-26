import csv
import hcuppy.utils as utils

class ElixhauserEngine:

    def __init__(self):
        fn = "data/elix_comformat_icd10cm_2019_1.txt"
        self.dx2elix = utils.read_elixhauser(fn)

    def get_elixhauser(self, dx_lst):
        pass





