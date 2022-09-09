from collections import Counter
import hcuppy.utils as utils

class ElixhauserEngine:

    def __init__(self):
        # old 
        #fn = "data/elix_comformat_icd10cm_2019_1.txt"
        # NOTE: updated in 2022-09-08
        # source: https://www.hcup-us.ahrq.gov/toolssoftware/comorbidityicd10/comorbidity_icd10.jsp#indices
        fn = "data/CMR_Format_Program_v2022-1.sas" 
        self.dx2elix = utils.read_elixhauser(fn)

        # OLD NOTE: weights are adopted from the following link
        # https://www.hcup-us.ahrq.gov/toolssoftware/comorbidity/comindex2012-2015.txt
        # Weights from CMR_Index_Program_v2022-1.sas 
        self.weights = {
            "rdmsn": {
                "AIDS":5,
                "ALCOHOL":3,
                "ANEMDEF":5,
                "AUTOIMMUNE":2,
                "BLDLOSS":2,
                "CANCER_LEUK":10,
                "CANCER_LYMPH":7,
                "CANCER_METS":11,
                "CANCER_NSITU":0,
                "CANCER_SOLID":7,
                "CBVD":0,
                "HF":7,
                "COAG":3,
                "DEMENTIA":1,
                "DEPRESS":2,
                "DIAB_CX":4,
                "DIAB_UNCX":0,
                "DRUG_ABUSE":6,
                "HTN_CX":0,
                "HTN_UNCX":0,
                "LIVER_MLD":3,
                "LIVER_SEV":10,
                "LUNG_CHRONIC":4,
                "NEURO_MOVT":1,
                "NEURO_OTH":2,
                "NEURO_SEIZ":5,
                "OBESE":-2,
                "PARALYSIS":3,
                "PERIVASC":1,
                "PSYCHOSES":6,
                "PULMCIRC":3,
                "RENLFL_MOD":4,
                "RENLFL_SEV":8,
                "THYROID_HYPO":0,
                "THYROID_OTH":0,
                "ULCER_PEPTIC":2,
                "VALVE":0,
                "WGHTLOSS":6},
            "mrtlt": {
                "AIDS":-4,
                "ALCOHOL":-1,
                "ANEMDEF":-3,
                "AUTOIMMUNE":-1,
                "BLDLOSS":-4,
                "CANCER_LEUK":9,
                "CANCER_LYMPH":6,
                "CANCER_METS":23,
                "CANCER_NSITU":0,
                "CANCER_SOLID":10,
                "CBVD":5,
                "HF":15,
                "COAG":15,
                "DEMENTIA":5,
                "DEPRESS":-9,
                "DIAB_CX":-2,
                "DIAB_UNCX":0,
                "DRUG_ABUSE":-7,
                "HTN_CX":1,
                "HTN_UNCX":0,
                "LIVER_MLD":2,
                "LIVER_SEV":17,
                "LUNG_CHRONIC":2,
                "NEURO_MOVT":-1,
                "NEURO_OTH":23,
                "NEURO_SEIZ":2,
                "OBESE":-7,
                "PARALYSIS":4,
                "PERIVASC":3,
                "PSYCHOSES":-9,
                "PULMCIRC":4,
                "RENLFL_MOD":3,
                "RENLFL_SEV":8,
                "THYROID_HYPO":-3,
                "THYROID_OTH":-8,
                "ULCER_PEPTIC":0,
                "VALVE":0,
                "WGHTLOSS":14
                }
            }

        # Following the logic in CMR_Mapping_Program_v2022-1.sas
        # VALANYPOA and VALPOA
        self.valanypoa = {"AIDS", "ALCOHOL", "AUTOIMMUNE", "LUNG_CHRONIC",
                        "DEMENTIA", "DEPRESS", "DIAB_UNCX", "DIAB_CX",
                        "DRUG_ABUSE", "HTN_UNCX", "HTN_CX", "THYROID_HYPO",
                        "THYROID_OTH", "CANCER_LYMPH", "CANCER_LEUK",
                        "CANCER_METS", "OBESE", "PERIVASC", "CANCER_SOLID",
                        "CANCER_NSITU"}
        self.valpoa = {"ANEMDEF", "BLDLOSS", "HF", "COAG", "LIVER_MLD", 
                "LIVER_SEV", "NEURO_MOVT", "NEURO_SEIZ", "NEURO_OTH", 
                "PARALYSIS", "PSYCHOSES", "PULMCIRC", "RENLFL_MOD",
                "RENLFL_SEV", "ULCER_PEPTIC", "WGHTLOSS", "CBVD_POA",
                "CBVD_SQLA", "VALVE"}


    def get_elixhauser(self, dx_full_lst, dx_poa_lst = []):
        """
        Returns the Elixhauser Comorbidity Index for the given list of 
        diagnosis codes.
        The original software can be found at
        Parameters
        __________
        dx_full_lst: list of str
                A full list of ICD10 diagnosis codes.
        dx_poa_lst: list of str
                A list of Present On Admission (POA) ICD10 diagnosis codes.
                It is a subset of dx_full_lst.
                If empty, it is initialized with dx_full_lst.
        """

        def get_labels(dx):
            labels = []
            for i in range(4, 8):
                dx_shrt = dx[:i]
                if dx_shrt in self.dx2elix:
                    labels = self.dx2elix[dx_shrt]      
                    break
            return labels

        def apply_hierarchy(cmrbdt_cnt):
            # neutral to POA 
            if cmrbdt_cnt["DIAB_CX"] > 0:
                cmrbdt_cnt["DIAB_UNCX"] = 0
            if cmrbdt_cnt["HTN_CX"] > 0:
                cmrbdt_cnt["HTN_UNCX"] = 0
            if cmrbdt_cnt["CANCER_METS"] > 0:
                cmrbdt_cnt["CANCER_SOLID"] = 0
                cmrbdt_cnt["CANCER_NSITU"] = 0
            if cmrbdt_cnt["CANCER_SOLID"] > 0:
                cmrbdt_cnt["CANCER_NSITU"] = 0
            
            # POA info required; 
            # in this package, we assume POA info is available
            if cmrbdt_cnt["LIVER_SEV"] > 0:
                cmrbdt_cnt["LIVER_MLD"] = 0
            if cmrbdt_cnt["RENLFL_SEV"] > 0:
                cmrbdt_cnt["RENLFL_MOD"] = 0
            if (cmrbdt_cnt["CBVD_POA"] > 0 or
                (cmrbdt_cnt["CBVD_POA"]==0 and 
                 cmrbdt_cnt["CBVD_NPOA"]==0 and 
                 cmrbdt_cnt["CBVD_SQLA"] > 0)):
                cmrbdt_cnt["CBVD"] = 1 # note tha this is "1", not "0"
            cmrbdt_lst = [cmrbdt for cmrbdt, cnt in cmrbdt_cnt.items() 
                        if cnt > 0]
            return cmrbdt_lst

        def apply_score(cmrbdt_lst, model="rdmsn"):
            score = 0
            for cmrbdt in cmrbdt_lst:
                if cmrbdt in {"HTNCX", "HTN"}:
                    score += self.weights[model]["HTN_C"]
                else:
                    score += self.weights[model][cmrbdt]
            return score

        if not isinstance(dx_full_lst, list):
            dx_lst = [dx_lst]
      
        # cleanup
        dx_full_lst = [dx.strip().upper().replace(".","") 
                        for dx in dx_full_lst]
        dx_poa_lst = [dx.strip().upper().replace(".","") 
                        for dx in dx_poa_lst]
        if len(dx_poa_lst) == 0:
            dx_poa_lst = dx_full_lst
        for dx in dx_poa_lst:
            if dx not in dx_full_lst:
                dx_full_lst.append(dx)

        cmrbdt_cnt = Counter()
        for dx in dx_full_lst:
            labels = get_labels(dx)
            for label in labels:
                if label in self.valanypoa:
                    cmrbdt_cnt[label] += 1
            if "DRUG_ABUSEPSYCHOSES" in labels:
                cmrbdt_cnt["DRUG_ABUSE"] += 1
            if "HFHTN_CX" in labels:
                cmrbdt_cnt["HTN_CX"] += 1
            if "HTN_CXRENLFL_SEV" in labels:
                cmrbdt_cnt["HTN_CX"] += 1
            if "HFHTN_CXRENLFL_SEV" in labels:
                cmrbdt_cnt["HTN_CX"] += 1
            if "ALCOHOLLIVER_MLD" in labels:
                cmrbdt_cnt["ALCOHOL"] += 1
            if "VALVE_AUTOIMMUNE" in labels:
                cmrbdt_cnt["AUTOIMMUNE"] += 1
            if ("POAXMPT" in labels or 
                dx in dx_poa_lst): 
                for label in labels:
                    if label in self.valpoa:
                        cmrbdt_cnt[label] += 1
                if "DRUG_ABUSEPSYCHOSES" in labels:
                    cmrbdt_cnt["PSYCHOSES"] += 1
                if "HFHTN_CX" in labels:
                    cmrbdt_cnt["HF"] += 1
                if "HTN_CXRENLFL_SEV" in labels:
                    cmrbdt_cnt["RENLFL_SEV"] += 1
                if "HFHTN_CXRENLFL_SEV" in labels:
                    cmrbdt_cnt["HF"] += 1
                    cmrbdt_cnt["RENLFL_SEV"] += 1
                if "CBVD_SQLAPARALYSIS" in labels:
                    cmrbdt_cnt["PARALYSIS"] += 1
                    cmrbdt_cnt["CBVD_SQLA"] += 1
                if "ALCOHOLLIVER_MLD" in labels:
                    cmrbdt_cnt["LIVER_MLD"] += 1
                if "VALVE_AUTOIMMUNE" in labels:
                    cmrbdt_cnt["VALVE"] += 1
            if ("POAXMPT" not in labels and
                dx not in dx_poa_lst): 
                if "CBVD_POA" in labels:
                    cmrbdt_cnt["CBVD_NPOA"] += 1

        cmrbdt_lst = apply_hierarchy(cmrbdt_cnt) 

        rdmsn_scr = apply_score(cmrbdt_lst, "rdmsn")
        mrtlt_scr = apply_score(cmrbdt_lst, "mrtlt")

        out = {"cmrbdt_lst": cmrbdt_lst,
                "rdmsn_scr": rdmsn_scr,
                "mrtlt_scr": mrtlt_scr}

        return out



