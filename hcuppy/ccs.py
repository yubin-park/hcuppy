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

        output_type = "list"
        if not isinstance(icd_lst, list):
            output_type = "value"
            icd_lst = [icd_lst]

        icd_lst = [icd.strip().upper().replace(".","") for icd in icd_lst]
        ccs_lst = []
        for icd in icd_lst:
            if icd not in self.icd2ccs:
                ccs_lst.append(None)
            else:
                ccs_lst.append(self.icd2ccs[icd])

        out = ccs_lst
        if output_type == "value":
            out = ccs_lst[0]
        return out






