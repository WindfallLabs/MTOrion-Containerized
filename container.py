#!/usr/bin/env python
"""
Author: Garin Wally, 3/25/2019
Copyright...

Version: 0.0.1
"""

import os
import zipfile
from subprocess import Popen


NUL = open(os.devnull, "w")

# TODO: move
pwd = "my$uperStr0ngPwd5!"

# Counties
with open("./counties.txt", "r") as f:
    counties = f.readlines()
# Lowercase
counties = [cnty.lower().strip() for cnty in counties]
# TODO: Validation


# URL (base)
url_base = "http://ftp.geoinfo.msl.mt.gov/Data/Spatial/MSDI/Cadastral"

# URL to DOR databases
url_dor = url_base + "/ORION_SQLDatabases/{cnty_num}.ZIP"


# Dictionary of County name : County number
# All lowercase
# TODO: all counties
county_dict = {
    "missoula": "county4",
    "ravalli": "county13"
    }


def download(cnty_name):
    """Downloads zipped DOR database for input COUNTY#."""
    cnty_num = county_dict[cnty_name].upper()
    Popen([
        # Linux command 'wget' to download data
        "wget",
        # Format the URL to COUNTY#.ZIP
        url_dor.format(cnty_num),
        # Output flag
        "-O",
        # Output name to lowercase "county#.zip"
        cnty_name.title() + ".zip"
        ], stdout=NUL)
    return


def unzip(cnty_zip):
    """Unzips an input file."""
    cnty_name = cnty_zip.replace(".zip", "").title()
    zip_ref = zipfile.ZipFile(cnty_zip, 'r')
    zip_ref.extractall(".")
    zip_ref.close()
    os.rename("Output.mdf", "{}.mdf".format(cnty_name.title()))
    return


def attach(cnty):
    sql = "USE [master]; CREATE DATABASE {cnty} ON (FILENAME = '/home/{cnty}.mdf') FOR ATTACH;"
    cmds = [
        "/opt/mssql-tools/bin/sqlcmd",
        "-S", "localhost",
        "-U", "SA",
        "-P", pwd,
        "-Q", sql.format(cnty=cnty)]
    Popen(cmds).communicate()
    return


'''
# Python pseudo-code
import pandas as pd
import pymssql
import db

YEAR = 2019

ms = pymssql.connect("localhost:1433", "SA", "my$uperStr0ngPwd5!", "County4")
table_names = pd.read_sql("SELECT * FROM County4.INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE'", ms)["TABLE_NAME"].tolist()

lite = db.DB(filename="county4.sqlite", dbtype="sqlite")
#for tbl in table_names:
for tbl in ["Com", "Res", "Property"]:
    print("Loading {}...".format(tbl))
    df = pd.DataFrame()
    
    pd.read_sql("SELECT * FROM {};".format(tbl), ms).to_sql(tbl, lite.con, index=False)
'''


if __name__ == "__main__":
    # For each county listed by the client
    # Download, unzip, rename, and attach to MSSQL server

    # Queue a multi-process download
    processes = []
    for cnty in counties:
        if cnty not in [os.path.splitext(f)[0].lower() for f in os.listdir("/home")]:
            cnty_num = county_dict[cnty].upper()
            p = Popen([
                # Linux command 'wget' to download data
                "wget",
                # Format the URL to COUNTY#.ZIP
                url_dor.format(cnty_num=cnty_num),
                # Output flag
                "-O",
                # Output name to lowercase "county#.zip"
                cnty.title() + ".zip"
                ], stdout=NUL)
            processes.append(p)
    # Run processes
    [proc.communicate() for proc in processes if proc]

    # Unzip the downloaded zips
    [unzip(z) for z in os.listdir(".") if z.endswith(".zip")]
    
    # Connect and attach
    [attach(mdf.replace(".mdf", "")) for mdf in os.listdir("/home")
     if mdf.endswith(".mdf")]
