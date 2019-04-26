import csv
import hcuppy.utils as utils

class CCIEngine:

    def __init__(self):
        fn = "data/cci_icd10cm_2019_1.csv"
        self.dx2cci = utils.read_cci(fn)

    def get_cci(self, dx_lst):

        output_type = "list"
        if not isinstance(dx_lst, list):
            output_type = "value"
            dx_lst = [dx_lst]
        
        dx_lst = [dx.strip().upper().replace(".","") for dx in dx_lst]
        cci_lst = []
        for dx in dx_lst:
            if dx not in self.dx2cci:
                cci_lst.append(None)
            else:
                cci_lst.append(self.dx2cci[dx])

        out = cci_lst
        if output_type == "value":
            out = cci_lst[0]
 
        return out

    def has_chronic(self, dx_lst):
        cci_lst = [cci for cci in self.get_cci(dx_lst) if cci is not None]
        return any(cci["is_chronic"] for cci in cci_lst)

    def is_chronic(self, dx):
        cci = self.get_cci(dx)
        if cci is not None:
            return cci["is_chronic"] 
        else:
            return False


