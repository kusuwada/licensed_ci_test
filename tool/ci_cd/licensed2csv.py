#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import csv

OUTPUT_CSV_FILE = 'libraries.csv'


class Licensed:
    BLOCK_SEPARATOR = '---'
    INFO_SEPARATOR = ': '
    TYPE = 'type'
    NAME = 'name'
    VERSION = 'version'
    HOMEPAGE = 'homepage'
    LICENSE = 'license'


class LibInfo:
    def __init__(self, type=None, name=None, version=None, homepage=None, license=None):
        self.type = type
        self.name = name
        self.version = version
        self.homepage = homepage
        self.license = license


def parse_directory(path):
    items = os.listdir(path)
    for i in items:
        item_path = path + os.sep + i
        if os.path.isfile(item_path):
            parse_license_file(item_path)
        elif os.path.isdir(item_path):
            parse_directory(item_path)
        else:
            continue
    return


def parse_license_file(path):
    lib = {}
    separator_count = 0
    with open(path) as f:
        line = f.readline()
        while line or separator_count < 2:
            if line.startswith(Licensed.BLOCK_SEPARATOR):
                separator_count += 1
            elif len(line.split(Licensed.INFO_SEPARATOR)) >= 2:
                lib[line.split(Licensed.INFO_SEPARATOR)[0]] = \
                    line.split(Licensed.INFO_SEPARATOR)[1].strip()
            line = f.readline()
        libinfo = LibInfo(lib[Licensed.TYPE], lib[Licensed.NAME], lib[Licensed.VERSION],
                          lib[Licensed.HOMEPAGE], lib[Licensed.LICENSE])
        libinfo_list.append(libinfo)


if __name__ == '__main__':
    libinfo_list = []
    path = os.getcwd() 
    directories = [f for f in os.listdir(path) if os.path.isdir(os.path.join(path, f))]
    for d in directories:
        child_dir = path + os.sep + d
        parse_directory(child_dir)
    csv_array = [[Licensed.TYPE.upper(), Licensed.NAME.upper(), Licensed.VERSION.upper(),
                  Licensed.HOMEPAGE.upper(), Licensed.LICENSE.upper()]]
    for l in libinfo_list:
        csv_array.append([l.type, l.name, l.version, l.homepage, l.license])
    with open(OUTPUT_CSV_FILE, 'w') as f:
        writer = csv.writer(f, lineterminator='\n')
        writer.writerows(csv_array)
