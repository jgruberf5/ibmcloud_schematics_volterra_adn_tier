#!/usr/bin/env python3

import sys
import json
import urllib.request
import difflib

PUBLIC_REGIONS = ['us-south', 'us-east', 'eu-gb', 'eu-de', 'jp-tok', 'au-syd']


def get_public_images(region):
    if not region:
        region = 'us-south'
    catalog_url = "https://volterra-ce-%s.s3.%s.cloud-object-storage.appdomain.cloud/volterra-image-catalog.json" % (
        region, region)
    try:
        response = urllib.request.urlopen(catalog_url)
        return json.load(response)
    except Exception as ex:
        sys.stderr.write(
            'Can not fetch Volterra image catalog at %s: %s' % (catalog_url, ex))
        sys.exit(1)


def longest_substr(catalog_image_name, version_prefix):
    if catalog_image_name.find(version_prefix) < 0:
        return 0
    seqMatch = difflib.SequenceMatcher(
        None, catalog_image_name, version_prefix)
    match = seqMatch.find_longest_match(
        0, len(catalog_image_name), 0, len(version_prefix))
    return match.size


def main():
    jsondata = json.loads(sys.stdin.read())
    if 'download_region' not in jsondata:
        sys.stderr.write(
            'type, download_region, verion_prefix inputs require to query public volterra images')
        sys.exit(1)
    if 'version_prefix' not in jsondata:
        sys.stderr.write(
            'type, download_region, verion_prefix inputs require to query public volterra images')
        sys.exit(1)
    ce_version_match = jsondata['version_prefix'].lower().replace('.', '-')
    region = jsondata['download_region'].lower()
    if region not in PUBLIC_REGIONS:
        region = 'us-south'
    image_catalog = get_public_images(region)
    max_match = 0
    image_url = None
    image_name = None
    for image in image_catalog[region]:
        match_length = longest_substr(image['image_name'], ce_version_match)
        if match_length >= max_match:
            max_match = match_length
            image_url = image['image_sql_url']
            image_name = image['image_name']
    if not image_url:
        sys.stderr.write(
            'No image in the public image catalog matched version %s' % ce_version_match)
        sys.exit(1)
    jsondata['image_sql_url'] = image_url
    jsondata['image_name'] = image_name
    sys.stdout.write(json.dumps(jsondata))


if __name__ == '__main__':
    main()
