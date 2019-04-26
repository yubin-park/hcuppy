import hcuppy.utils as utils

class SFlagEngine:

    def __init__(self):
        fn = "data/surgery_flags_cpt_2017.csv"
        self.cpt2flag = utils.read_surgeryflag(fn)

    def get_sflag(self, cpt_lst):

        output_type = "list"
        if not isinstance(cpt_lst, list):
            output_type = "value"
            cpt_lst = [cpt_lst]

        sflag_lst = []
        for cpt in cpt_lst:
            if cpt not in self.cpt2flag:
                sflag_lst.append(None)
            else:
                sflag_lst.append(self.cpt2flag[cpt])

        out = sflag_lst
        if output_type == "value":
            out = sflag_lst[0]
        return out







