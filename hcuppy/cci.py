import csv
import hcuppy.utils as utils

class CCIEngine:

    def __init__(self):
        fn = "data/cci_icd10cm_2019_1.csv"
        self.dx2cci = utils.read_cci(fn)

    def get_cci(self, dx_lst):
        dx_set = {dx.strip().upper().replace(".","") for dx in dx_lst} 
        cci_lst = []
        for dx in dx_set:
            if dx not in self.dx2cci:
                continue
            cci_lst.append(self.dx2cci[dx])
        return cci_lst







