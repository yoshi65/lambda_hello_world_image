#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# FileName: 	app
# CreatedDate:  2021-05-12 09:45:04 +0900
# LastModified: 2021-05-12 09:45:23 +0900
#


import json


def handler(event, context):
    return {
        "statusCode": 200,
        "body": json.dumps(
            {
                "message": "hello world",
            }
        ),
    }
