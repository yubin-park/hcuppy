import hcuppy.utils as utils

class PrClsEngine:

    def __init__(self):
        fn = "data/pc_icd10pcs_2018.csv"
        self.pr2cls = utils.read_prcls(fn)
        icd9pr_fn = 'data/icd9toicd10pcsgem.csv'
        self.icd9to10_pr = utils.read_icd9to10_procedure(icd9pr_fn)

    def _get_prcls(self, pr_lst):
        """
        Returns Procedure Class or 
            a list of Procedure Class for the given ICD procedure code(s).
        The original software can be found at 
        https://www.hcup-us.ahrq.gov/toolssoftware/procedureicd10/
            procedure_icd10.jsp

        Parameters
        __________
        pr_lst: list of str, or str
                A list of ICD10 procedure codes.
                The output is a list of corresponding Procedure Classes.
                If this parameter is a scalar (not a list), then 
                the output will be a scalar.
        """

        output_type = "list"
        if not isinstance(pr_lst, list):
            output_type = "value"
            pr_lst = [pr_lst]
        
        pr_lst = [pr.strip().upper().replace(".","") for pr in pr_lst]
        cls_lst = []
        out_default = {"class": "na", "desc": "na"}
        for pr in pr_lst:
            if pr not in self.pr2cls:
                cls_lst.append(out_default)
            else:
                cls_lst.append(self.pr2cls[pr])

        out = cls_lst
        if output_type == "value":
            out = cls_lst[0]
        return out

    def get_prcls(self, pr_lst=None, pr9_lst=None):
        """
        Returns Procedure Class or 
            a list of Procedure Class for the given ICD procedure code(s).
        The original software can be found at 
        https://www.hcup-us.ahrq.gov/toolssoftware/procedureicd10/
            procedure_icd10.jsp

        Parameters
        __________
        pr_lst: list of str, or str
                A list of ICD10 procedure codes.
                The output is a list of corresponding Procedure Classes.
                If this parameter is a scalar (not a list), then 
                the output will be a scalar.

        pr9_lst: list of str, or str
                A list of ICD9 procedure codes.
                The output is a list of corresponding Procedure Classes.
                If this parameter is a scalar (not a list), then 
                the output will be a scalar.
        """
        

        if pr_lst is not None:
            return self._get_prcls(pr_lst)

        if isinstance(pr9_lst, list):
            icd10 = [ self.icd9to10_pr.get(x, "000") for x in pr9_lst ]
        else:
            icd10 = self.icd9to10_pr.get(pr9_lst, "000")
        return self._get_prcls(icd10)
