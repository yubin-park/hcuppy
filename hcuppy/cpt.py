import hcuppy.utils as utils
import string

class CPT:
    def __init__(self):
        fn = "data/cpt_sections.csv"
        self.cpt2sect = utils.read_cpt_sect(fn)

    def download_data(self):
        utils.download_cpt() 

    def get_cpt_section(self, x_lst):

        output_type = "list"
        if not isinstance(x_lst, list):
            output_type = "value"
            x_lst = [x_lst]
        
        sect_lst = []
        out_default = {"sect": "na",
                        "desc": "na"}
        for x in x_lst:
            if x not in self.cpt2sect:
                sect_lst.append(out_default)
            else:
                sect_lst.append(self.cpt2sect[x])

        out = sect_lst
        if output_type == "value":
            out = sect_lst[0]
        return out






