#!/bin/bash

if [ $# -ne 1 ]
then
    echo "Usage: $SELF addon"
    exit 1
fi


mkdir $1
cd $1


for DIR in models controllers wizard
do
    mkdir $DIR
    touch $DIR/__init__.py
done

mkdir views
touch views/view.xml

for DIR in security report data demo i18n
do
    mkdir $DIR
done

mkdir -p static/description
mkdir -p static/src/js
mkdir static/src/scss
mkdir static/src/css
mkdir static/src/xml

echo "from . import models
from . import controllers
from . import wizard
" > __init__.py


echo "# -*- coding: utf-8 -*-
{
    'name': '',
    'summary': '', 
    'description': '',
    'author': 'Michael Piko',
    'license': 'OPL-1',
    'sequence': '-100',
    'website': 'https://www.cyder.com.au',
    'category': 'Uncategorize',
    'version': '15.0.1.0',
    'depends': ['base'],
    'data': [
        # 'security/ir.model.access.csv',
        # 'views/views.xml',
    ],
    'demo': [],
    'application': True,
    'installable': True,

}" > __manifest__.py
