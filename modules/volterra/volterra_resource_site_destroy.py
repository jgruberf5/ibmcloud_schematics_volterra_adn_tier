#!/usr/bin/env python3

import os
import sys
import json
import argparse
import urllib.request

from urllib.error import HTTPError


def remove_site_token(tenant, token, site_name):
    site_token_file = "%s/%s_site_token.txt" % (
        os.path.dirname(os.path.realpath(__file__)), site_name)
    if os.path.exists(site_token_file):
        os.unlink(site_token_file)
    headers = {
        "Authorization": "APIToken %s" % token
    }
    # Does the site token exist
    try:
        url = "https://%s.console.ves.volterra.io/api/register/namespaces/system/tokens/%s" % (
            tenant, site_name)
        headers['volterra-apigw-tenant'] = tenant
        headers['content-type'] = 'application/json'
        data = {
            'fail_if_referred': False,
            'name': site_name,
            'namespace': 'system'
        }
        data = json.dumps(data)
        request = urllib.request.Request(
            url=url, headers=headers, data=bytes(data.encode('utf-8')), method='DELETE')
        urllib.request.urlopen(request)
        return True
    except HTTPError as her:
        if her.code != 404:
            sys.stderr.write(
                "Error deleting site tokens resources %s: %s\n" % (url, her))
            sys.exit(1)
    except Exception as er:
        sys.stderr.write(
            "Error deleting site token resources %s - %s\n" % (url, er))
        sys.exit(1)


def remove_virutal_network(tenant, token, site_name):
    headers = {
        "Authorization": "APIToken %s" % token
    }
    # Does the site token exist
    try:
        url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/virtual_networks/%s" % (
            tenant, site_name)
        headers['volterra-apigw-tenant'] = tenant
        headers['content-type'] = 'application/json'
        data = {
            'fail_if_referred': False,
            'name': site_name,
            'namespace': 'system'
        }
        data = json.dumps(data)
        request = urllib.request.Request(
            url=url, headers=headers, data=bytes(data.encode('utf-8')), method='DELETE')
        urllib.request.urlopen(request)
        return True
    except HTTPError as her:
        if her.code != 404:
            sys.stderr.write(
                "Error deleting virtual_networks resources %s: %s\n" % (url, her))
            sys.exit(1)
    except Exception as er:
        sys.stderr.write(
            "Error deleting virtual_networks resources %s: %s\n" % (url, er))
        sys.exit(1)


def remove_network_connector(tenant, token, site_name):
    headers = {
        "Authorization": "APIToken %s" % token
    }
    try:
        url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/network_connectors/%s" % (
            tenant, site_name)
        headers['volterra-apigw-tenant'] = tenant
        headers['content-type'] = 'application/json'
        data = {
            'fail_if_referred': False,
            'name': site_name,
            'namespace': 'system'
        }
        data = json.dumps(data)
        request = urllib.request.Request(
            url=url, headers=headers, data=bytes(data.encode('utf-8')), method='DELETE')
        urllib.request.urlopen(request)
        return True
    except HTTPError as her:
        if her.code != 404:
            sys.stderr.write(
                "Error deleting network_connectors resources %s: %s\n" % (url, her))
            sys.exit(1)
    except Exception as er:
        sys.stderr.write(
            "Error deleting network_connectors resources %s: %s\n" % (url, er))
        sys.exit(1)


def remove_fleet(tenant, token, site_name):
    headers = {
        "Authorization": "APIToken %s" % token
    }
    # Does the site token exist
    try:
        url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/fleets/%s" % (
            tenant, site_name)
        headers['volterra-apigw-tenant'] = tenant
        headers['content-type'] = 'application/json'
        data = {
            'fail_if_referred': False,
            'name': site_name,
            'namespace': 'system'
        }
        data = json.dumps(data)
        request = urllib.request.Request(
            url=url, headers=headers, data=bytes(data.encode('utf-8')), method='DELETE')
        urllib.request.urlopen(request)
        return True
    except HTTPError as her:
        if her.code != 404:
            sys.stderr.write(
                "Error deleting fleets resources %s: %s\n" % (url, her))
            sys.exit(1)
    except Exception as er:
        sys.stderr.write(
            "Error deleting fleets resources %s: %s\n" % (url, er))
        sys.exit(1)


def remove_service_discovery(tenant, token, site_name):
    headers = {
        "Authorization": "APIToken %s" % token
    }
    try:
        url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/discoverys" % tenant
        headers['volterra-apigw-tenant'] = tenant
        headers['content-type'] = 'application/json'
        request = urllib.request.Request(
            url=url, headers=headers, method='GET')
        response = urllib.request.urlopen(request)
        for discovery in json.load(response)['items']:
            if discovery['name'].startswith(site_name):
                url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/discoverys/%s" % (
                    tenant, discovery['name'])
                data = {
                    'fail_if_referred': False,
                    'name': discovery['name'],
                    'namespace': 'system'
                }
                data = json.dumps(data)
                del_req = urllib.request.Request(
                    url=url, headers=headers, data=bytes(data.encode('utf-8')), method='DELETE')
                urllib.request.urlopen(del_req)
        return True
    except HTTPError as her:
        if her.code != 404:
            sys.stderr.write(
                "Error deleting discovery resources %s: %s\n" % (url, her))
            sys.exit(1)
    except Exception as er:
        sys.stderr.write(
            "Error deleting discovery resources %s: %s\n" % (url, er))
        sys.exit(1)


def remove_k8s_cluster(tenant, token, site_name):
    headers = {
        "Authorization": "APIToken %s" % token
    }
    try:
        url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/k8s_clusters" % tenant
        headers['volterra-apigw-tenant'] = tenant
        headers['content-type'] = 'application/json'
        request = urllib.request.Request(
            url=url, headers=headers, method='GET')
        response = urllib.request.urlopen(request)
        for k8sc in json.load(response)['items']:
            if k8sc['name'].startswith(site_name):
                url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/k8s_clusters/%s" % (
                    tenant, k8sc['name'])
                data = {
                    'fail_if_referred': False,
                    'name': k8sc['name'],
                    'namespace': 'system'
                }
                data = json.dumps(data)
                del_req = urllib.request.Request(
                    url=url, headers=headers, data=bytes(data.encode('utf-8')), method='DELETE')
                urllib.request.urlopen(del_req)
        return True
    except HTTPError as her:
        if her.code != 404:
            sys.stderr.write(
                "Error deleting k8s_clusters resources %s: %s\n" % (url, her))
            sys.exit(1)
    except Exception as er:
        sys.stderr.write(
            "Error deleting k8s_clusters resources %s: %s\n" % (url, er))
        sys.exit(1)


def remove_voltstack_site(tenant, token, site_name):
    # remove all Voltstack sites with this name
    url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/voltstack_sites/%s" % (
        tenant, site_name)
    headers = {
        "Authorization": "APIToken %s" % token
    }
    try:
        request = urllib.request.Request(
            url=url, headers=headers, method='DELETE')
        urllib.request.urlopen(request)
    except HTTPError as her:
        if her.code != 404:
            sys.stderr.write(
                "Error deleting voltstack site %s: %s\n" % (url, her))
            sys.exit(1)
    except Exception as ex:
        sys.stderr.write(
            "Can not delete voltstack site %s: %s\n" % (url, ex))
        sys.exit(1)


def decomission_site(tenant, token, site_name):
    # remove all Voltmesh sites with this name
    url = "https://%s.console.ves.volterra.io/api/register/namespaces/system/site/%s/state" % (
        tenant, site_name)
    headers = {
        "Authorization": "APIToken %s" % token
    }
    data = {
        "namespace": "system",
        "name": site_name,
        "state": "DECOMMISSIONING"
    }
    data = json.dumps(data)
    try:
        request = urllib.request.Request(
            url=url, headers=headers, data=bytes(data.encode('utf-8')), method='POST')
        urllib.request.urlopen(request)
    except HTTPError as her:
        if her.code != 404:
            sys.stderr.write(
                "Can not delete site %s: %s\n" % (url, her))
            sys.exit(1)
    except Exception as ex:
        sys.stderr.write(
            "Can not delete site %s: %s\n" % (url, ex))
        sys.exit(1)


def main():
    ap = argparse.ArgumentParser(
        prog='volterra_resource_site_destroy',
        usage='%(prog)s.py [options]',
        description='clean up site tokens and fleets on destroy'
    )
    ap.add_argument(
        '--site',
        help='Volterra site name',
        required=True
    )
    ap.add_argument(
        '--fleet',
        help='Volterra fleet label',
        required=True
    )
    ap.add_argument(
        '--tenant',
        help='Volterra site tenant',
        required=True
    )
    ap.add_argument(
        '--token',
        help='Volterra API token',
        required=True
    )
    ap.add_argument(
        '--voltstack',
        help='Create Voltstack site',
        required=False
    )
    args = ap.parse_args()

    remove_service_discovery(args.tenant, args.token, args.site)
    remove_site_token(args.tenant, args.token, args.site)

    if args.voltstack == "true":
        remove_voltstack_site(args.tenant, args.token, args.site)
        remove_k8s_cluster(args.tenant, args.token, args.site)
    else:
        decomission_site(args.tenant, args.token, args.site)
        remove_virutal_network(args.tenant, args.token, args.site)
        remove_network_connector(args.tenant, args.token, args.site)
        remove_fleet(args.tenant, args.token, args.site)
    sys.exit(0)


if __name__ == '__main__':
    main()
