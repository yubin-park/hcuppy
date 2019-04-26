import csv
import hcuppy.utils as utils

class CCSEngine:

    def __init__(self, mode="dx"):
        self.icd2ccs = {}
        self.mode = mode
        if mode == "dx":
            fn = "data/ccs_dx_icd10cm_2019_1.csv"
            self.icd2ccs = utils.read_ccs(fn)
        elif mode == "pr":
            fn = "data/ccs_pr_icd10pcs_2019_1.csv"
            self.icd2ccs = utils.read_ccs(fn)

    def get_ccs(self, icd_lst):
        icd_set = {icd.strip().upper().replace(".","") for icd in icd_lst} 
        ccs_lst = []
        for icd in icd_set:
            if icd not in self.icd2ccs:
                continue
            ccs_lst.append(self.icd2ccs[icd])
        return ccs_lst






