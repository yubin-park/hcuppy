import hcuppy.utils as utils

class PrClsEngine:

    def __init__(self):
        fn = "data/pc_icd10pcs_2018.csv"
        self.pr2cls = utils.read_prcls(fn)

    def get_prcls(self, pr_lst):

        output_type = "list"
        if not isinstance(pr_lst, list):
            output_type = "value"
            pr_lst = [pr_lst]
        
        pr_lst = [pr.strip().upper().replace(".","") for pr in pr_lst]
        cls_lst = []
        for pr in pr_lst:
            if pr not in self.pr2cls:
                cls_lst.append(None)
            else:
                cls_lst.append(self.pr2cls[pr])

        out = cls_lst
        if output_type == "value":
            out = cls_lst[0]
        return out





