import csv
import re
from pkg_resources import resource_filename as rscfn
import requests
from io import BytesIO
from io import StringIO
from zipfile import ZipFile
from urllib.request import urlopen
import string
import json

def _clnrw(row):
    return [x.replace('"',"").replace("'","").strip() for x in row]

def license_cpt():
    fn = rscfn(__name__, "data/license.txt")
    aggreement = "reject"
    with open(fn, "r") as fp:
        for line in fp.readlines():
            if line=="\n":
                continue
            print(line)
        agreement = input("(accept/reject):")
    return agreement=="accept"

def _expand_cpt(x):
    #x = x.replace("\\","").replace("'","").replace("b","")
    start, end = x.split("-")
    if start[0] in string.ascii_uppercase:
        return [start[0]+str(x) 
                for x in range(int(start[1:]), int(end[1:])+1)]
    elif start[-1] in string.ascii_uppercase:
        return ["{0:04n}{1}".format(x, start[-1])
                for x in range(int(start[:-1]), int(end[:-1])+1)]
    else:
        return ["{0:05n}".format(x) for x in range(int(start), int(end)+1)]

def download_cpt():

    if not license_cpt():
        print("No CPT files downloaded.")
        return 1

    url = ("https://www.hcup-us.ahrq.gov/toolssoftware/"+
            "ccs_svcsproc/2019_ccs_services_procedures.zip")
    fn = "2019_ccs_services_procedures.csv"
    res = urlopen(url)
    cpt2ccs = {}
    with ZipFile(BytesIO(res.read())) as zp:
        for line in zp.open(fn).readlines():
            row = _clnrw(line.decode("utf-8").split(","))
            if len(row) != 3 or "-" not in row[0]:
                continue
            ccs = row[1]
            desc = row[2]
            for cpt in _expand_cpt(row[0]):
                cpt2ccs[cpt] = {"ccs": ccs,
                                "ccs_desc": desc}
    fn = rscfn(__name__, "data/cpt2ccs.json")
    with open(fn, "w") as fp:
        json.dump(cpt2ccs, fp=fp, indent=2, sort_keys=True)


    cpt2sflag = {}
    desc = {"1": "broad", "2": "narrow"}
    url = ("https://www.hcup-us.ahrq.gov/toolssoftware/surgflags/"+
            "surgery_flags_cpt_2017.csv")
    res = urlopen(url)
    reader = csv.reader(StringIO(res.read().decode("utf-8")))
    meta = next(reader)
    header = next(reader)
    for row in reader:
        row = _clnrw(row)
        if "-" not in row[0]:
            continue
        flag = row[1]
        for cpt in _expand_cpt(row[0]):
            cpt2sflag[cpt] = {"flag": flag,
                            "desc": desc[flag]}
    
    fn = rscfn(__name__, "data/cpt2sflag.json")
    with open(fn, "w") as fp:
        json.dump(cpt2sflag, fp=fp, indent=2, sort_keys=True)


    return 0

def read_ccs(fn):
    icd2ccs = {}
    fn = rscfn(__name__, fn)
    with open(fn, "r") as fp:
        reader = csv.reader(fp, delimiter=",")
        header = next(reader)
        for row in reader:
            row = _clnrw(row)
            icd2ccs[row[0]] = {"ccs": row[1],
                            "ccs_desc": row[3],
                            "ccs_lv1": row[4],
                            "ccs_lv1_desc": row[5],
                            "ccs_lv2": row[6],
                            "ccs_lv2_desc": row[7]}
    return icd2ccs

def read_cci(fn):
    dx2cci = {}
    fn = rscfn(__name__, fn)
    descmap = {"1": "Infectious and parasitic disease",
        "2": "Neoplasms",
        "3": ("Endocrine, nutritional, and metabolic diseases " + 
            "and immunity disorders"),
        "4": "Diseases of blood and blood-forming organs",
        "5": "Mental disorders",
        "6": "Diseases of the nervous system and sense organs",
        "7": "Diseases of the circulatory system",
        "8": "Diseases of the respiratory system",
        "9": "Diseases of the digestive system",
        "10": "Diseases of the genitourinary system",
        "11": "Complications of pregnancy, childbirth, and the puerperium",
        "12": "Diseases of the skin and subcutaneous tissue",
        "13": "Diseases of the musculoskeletal system",
        "14": "Congenital anomalies",
        "15": "Certain conditions originating in the perinatal period",
        "16": "Symptoms, signs, and ill-defined conditions",
        "17": "Injury and poisoning",
        "18": ("Factors influencing health status " + 
                "and contact with health services"),
        "None": "N/A"}
 
    with open(fn, "r") as fp:
        reader = csv.reader(fp, delimiter=",")
        header = next(reader)
        for row in reader:
            row = _clnrw(row)
            dx2cci[row[0]] = {"is_chronic": row[2]=="1",
                            "body_system": row[3],
                            "body_system_desc": descmap[row[3]]}
    return dx2cci

def read_elixhauser(fn):
    dx2elix = {}
    fn = rscfn(__name__, fn)
    with open(fn, "r") as fp:
        start = False
        end = False
        dxlst = []
        for line in fp.readlines():
            if line.strip() == "Value $RCOMFMT":
                start = True
            if start and line.strip()==";":
                end = True
                break
            if start and not end:
                if "=" in line:
                    pttr = r"\"(.*)\"=\"(.*)\""
                    matches = re.findall(pttr, line)
                    if len(matches) > 0 and len(matches[0]) == 2:
                        dx, elix = matches[0][0], matches[0][1]
                        dxlst.append(dx)
                        for dx in dxlst:
                            dx2elix[dx] = elix
                        dxlst = []
                elif "," in line:
                    pttr = r"\"(.*)\","
                    matches = re.findall(pttr, line)
                    if len(matches) > 0:
                        dx = matches[0]
                        dxlst.append(dx)
    return dx2elix

def read_prcls(fn):
    pr2cls = {}
    fn = rscfn(__name__, fn)
    with open(fn, "r") as fp:
        reader = csv.reader(fp, delimiter=",")
        meta = next(reader)
        header = next(reader)
        for row in reader:
            row = _clnrw(row)
            pr2cls[row[0]] = {"class": row[2],
                            "desc": row[3]}
    return pr2cls

def read_utilflag(fn):
    utilmap = {}
    fn = rscfn(__name__, fn)
    with open(fn, "r") as fp:
        reader = csv.reader(fp, delimiter=",")
        header = next(reader)
        for row in reader:
            row = _clnrw(row)
            key = (row[3], row[4], row[5])
            utilmap[key] = row[2]
    return utilmap

def read_surgeryflag(fn):
    fn = rscfn(__name__, fn)
    with open(fn, "r") as fp:
        return json.load(fp)

def read_cpt2ccs(fn):
    fn = rscfn(__name__, fn)
    with open(fn, "r") as fp:
        return json.load(fp)


