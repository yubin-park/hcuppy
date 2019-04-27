from itertools import product
import hcuppy.utils as utils
from hcuppy.ccs import CCSEngine

class UFlagEngine:

    def __init__(self):
        fn = "data/ICD10PCS_utilizationflagformats_FY2019_1.csv"
        self.utilmap = utils.read_utilflag(fn)
        self.cepr = CCSEngine(mode="pr")

    def get_uflag(self, rev_lst=[], pr_lst=[]):
        """
        Returns a list of Utilization Flags for the given UB40 revenue
            and ICD-10 procedure codes.
        The original software can be found at 
        https://www.hcup-us.ahrq.gov/toolssoftware/utilflagsicd10/
            utilflag_icd10.jsp

        Parameters
        __________
        rev_lst: list of str
                A list of UB40 revenue codes.
        pr_lst: list of str
                A list of ICD-10 procedure codes.
        """

        rev_lst = [rev.strip() for rev in rev_lst]
        pr_lst = [pr.strip().upper().replace(".","") for pr in pr_lst]
        ccs_lst = [ccs["ccs"] for ccs in self.cepr.get_ccs(pr_lst)]

        keys = [(rev, "", "") for rev in rev_lst]
        keys += [("", ccs, "") for ccs in ccs_lst]
        keys += [("", "", pr) for pr in pr_lst]
        keys += [(rev, "", pr) for rev, pr in product(rev_lst, pr_lst)]

        uflag_lst = []
        for key in keys:
            if key in self.utilmap:
                uflag_lst.append(self.utilmap[key])

        return uflag_lst





