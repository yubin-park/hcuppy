# hcuppy 

A Python package for [H-CUP Tools and Software](https://www.hcup-us.ahrq.gov/tools_software.jsp).
The modules implemented in this package are as follows:
- "[CCS (Clinical Classification Software)](https://www.hcup-us.ahrq.gov/toolssoftware/ccs10/ccs10.jsp)" converts ICD-10 diagnosis and procedure codes to clinically meaningful groups
- "[CCI (Chronic Condition Indicator)](https://www.hcup-us.ahrq.gov/toolssoftware/chronic_icd10/chronic_icd10.jsp)" identifies chronic conditions from ICD-10 diagnosis codes
- "[Elixhauser Comordibity Index](https://www.hcup-us.ahrq.gov/toolssoftware/comorbidityicd10/comorbidity_icd10.jsp)" calculates both readmission and mortality risks using a set of ICD-10 diagnosis codes
- "[Procedure Classes](https://www.hcup-us.ahrq.gov/toolssoftware/procedureicd10/procedure_icd10.jsp)" identify if a given ICD-10 procedure code is Minor/Major Diagnosis/Therapeutic
- "[Utilization Flags](https://www.hcup-us.ahrq.gov/toolssoftware/utilflagsicd10/utilflag_icd10.jsp)" identify if a combination of UB40 revenue codes and ICD-10 procedure codes indicates (or implies) a certain resource utilization e.g. Intensive Care Unit, Ultrasound, X-Ray, etc.
- "[Surgery Flags](https://www.hcup-us.ahrq.gov/toolssoftware/surgflags/surgeryflags.jsp)" identify if a CPT code is a surgery related or not. *NOTE that, to use this module, users must agree to an additional license agreement with the AMA for using CPT codes [here](https://www.hcup-us.ahrq.gov/toolssoftware/surgflags/surgeryflags_license.jsp)*.

NOTE that this package does not support for ICD-9.

## Installing

Installing from the source:
```
$ git clone git@github.com:yubin-park/hcuppy.git
$ cd hcuppy
$ python setup.py develop
```

Or, simply using `pip`:
```
$ pip install hcuppy
```

## File Structure
- `hcuppy/`: The package source code is located here.
  - `data/`: The raw data files downloaded from the H-CUP website.
  - `ccs.py`: a module for CCS
  - `cci.py`: a module for CCI
  - `elixhauser.py`: a module for Elixhauser Comorbidity Index
  - `prcls.py`: a module for Procedure Class
  - `uflag.py`: a module for Utilization Flags
  - `sflag.py`: a module for Surgery Flags
  - `utils.py`: utility functions for reading data files.
- `tests/`: test scripts to check the validity of the outputs.
- `LICENSE.txt`: Apache 2.0.
- `README.md`: This README file.
- `setup.py`: a set-up script.

## Code Examples
`hcuppy` is really simple to use. 
Please see some examples below.
NOTE that all functions used below have docstrings. 
If you want to see the input parameter specifications,
please type `print(<instance>.<function>.__doc__)`.

### Using CCS
```python
>>> import json
>>> from hcuppy.ccs import CCSEngine
>>> ce = CCSEngine(mode="dx")
>>> out = ce.get_ccs(["E119", "I10"])
>>> print(json.dumps(out, indent=2))
[
  {
    "ccs": "49",
    "ccs_desc": "Diabetes mellitus without complication",
    "ccs_lv1": "3",
    "ccs_lv1_desc": "Endocrine; nutritional; and metabolic diseases and immunity disorders",
    "ccs_lv2": "3.2",
    "ccs_lv2_desc": "Diabetes mellitus without complication [49.]"
  },
  {
    "ccs": "98",
    "ccs_desc": "Essential hypertension",
    "ccs_lv1": "7",
    "ccs_lv1_desc": "Diseases of the circulatory system",
    "ccs_lv2": "7.1",
    "ccs_lv2_desc": "Hypertension"
  }
]
>>>
```

### Using CCI
```python
>>> from hcuppy.cci import CCIEngine
>>> ce = CCIEngine()
>>> out = ce.get_cci(["E119"])
>>> print(json.dumps(out, indent=2))
[
  {
    "is_chronic": true,
    "body_system": "3",
    "body_system_desc": "Endocrine, nutritional, and metabolic diseases and immunity disorders"
  }
]
```

### Using Elixhauser Comorbidity Index
```python
>>> from hcuppy.elixhauser import ElixhauserEngine
>>> ee = ElixhauserEngine()
>>> out = ee.get_elixhauser(["E119", "E108", "I10", "I110", "Z944"])
>>> print(json.dumps(out, indent=2))
{
  "cmrbdt_lst": [
    "LIVER",
    "DMCX",
    "HTNCX",
    "CHF"
  ],
  "rdmsn_scr": 31,
  "mrtlt_scr": 9
}
>>>
```

### Using Procedure Class
```python
>>> from hcuppy.prcls import PrClsEngine
>>> pce = PrClsEngine()
>>> out = pce.get_prcls(["B231Y0Z"])
>>> print(json.dumps(out, indent=2))
[
  {
    "class": "1",
    "desc": "Minor Diagnostic"
  }
]
>>>
```

### Using Utilization Flag
```python
>>> from hcuppy.uflag import UFlagEngine
>>> ufe = UFlagEngine()
>>> out = ufe.get_uflag(rev_lst=["0380"], pr_lst=["BB0DZZZ"])
>>> print(json.dumps(out, indent=2))
[
  "Blood",
  "Chest X-Ray"
]
>>>
```

Please refer to the test scripts under the `tests/` folder if you want to see other example use cases.

## License
Apache 2.0

## Authors
Yubin Park, PhD

## References
- https://www.hcup-us.ahrq.gov/
- https://www.hcup-us.ahrq.gov/tools_software.jsp
- https://cran.r-project.org/web/packages/comorbidity/vignettes/comorbidityscores.html
- https://github.com/modusdatascience/ccs






