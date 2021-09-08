#!/usr/bin/env python3

import os
import sys
import json
import argparse
import urllib.request

from urllib.error import HTTPError


def get_tenant_id(tenant, token):
    headers = {
        "Authorization": "APIToken %s" % token
    }
    try:
        url = "https://%s.console.ves.volterra.io/api/web/namespaces/system" % tenant
        request = urllib.request.Request(
            url, headers=headers, method='GET')
        response = urllib.request.urlopen(request)
        return json.load(response)['system_metadata']['tenant']
    except HTTPError as her:
        sys.stderr.write(
            "Error retrieving tenant ID - %s\n" % her)
        sys.exit(1)


def assure_site_token(tenant, token, site_token_name):
    site_token_name = site_token_name.encode('utf-8').decode('utf-8')
    headers = {
        "Authorization": "APIToken %s" % token
    }
    # Does the site token exist
    try:
        url = "https://%s.console.ves.volterra.io/api/register/namespaces/system/tokens/%s" % (
            tenant, site_token_name)
        request = urllib.request.Request(
            url, headers=headers, method='GET')
        response = urllib.request.urlopen(request)
        return json.load(response)['system_metadata']['uid']
    except HTTPError as her:
        if her.code == 404:
            try:
                url = "https://%s.console.ves.volterra.io/api/register/namespaces/system/tokens" % tenant
                headers['volterra-apigw-tenant'] = tenant
                headers['content-type'] = 'application/json'
                data = {
                    "metadata": {
                        "annotations": {},
                        "description": "Site Authorization Token for %s" % site_token_name,
                        "disable": False,
                        "labels": {},
                        "name": site_token_name,
                        "namespace": "system"
                    },
                    "spec": {}
                }
                data = json.dumps(data)
                request = urllib.request.Request(
                    url=url, headers=headers, data=bytes(data.encode('utf-8')), method='POST')
                response = urllib.request.urlopen(request)
                site_token = json.load(response)
                return site_token['system_metadata']['uid']
            except HTTPError as err:
                sys.stderr.write(
                    "Error creating site token resources %s: %s\n" % (url, err))
                sys.exit(1)
        else:
            sys.stderr.write(
                "Error retrieving site token resources %s: %s\n" % (url, her))
            sys.exit(1)
    except Exception as er:
        sys.stderr.write(
            "Error retrieving site token resources %s\n" % er)
        sys.exit(1)


def assure_k8s_cluster(tenant, token, site_name, k8sdomain):
    headers = {
        "Authorization": "APIToken %s" % token
    }
    # create K8s cluster object
    try:
        url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/k8s_clusters/%s" % (
            tenant, site_name)
        request = urllib.request.Request(
            url, headers=headers, method='GET')
        urllib.request.urlopen(request)
    except HTTPError as her:
        if her.code == 404:
            try:
                url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/k8s_clusters" % tenant
                headers['volterra-apigw-tenant'] = tenant
                headers['content-type'] = 'application/json'
                data = {
                    "namespace": "system",
                    "metadata": {
                        "name": site_name,
                        "namespace": None,
                        "labels": {},
                        "annotations": {},
                        "description": None,
                        "disable": None
                    },
                    "spec": {
                        "local_access_config": {
                            "local_domain": k8sdomain,
                            "default_port": {}
                        },
                        "global_access_enable": {},
                        "use_default_psp": {},
                        "use_default_cluster_roles": {},
                        "use_default_cluster_role_bindings": {},
                        "no_insecure_registries": {}
                    }
                }
                data = json.dumps(data)
                request = urllib.request.Request(
                    url=url, headers=headers, data=bytes(data.encode('utf-8')), method='POST')
                urllib.request.urlopen(request)
            except HTTPError as err:
                sys.stderr.write(
                    "Error creating k8s_clusters resources %s: %s\n" % (url, err))
                sys.exit(1)


def assure_voltstack_site(tenant, token, site_name, tenant_id, cluster_size, latitude, longitude, inside_networks, inside_gateway):
    headers = {
        "Authorization": "APIToken %s" % token
    }
    # create Voltstack site
    try:
        url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/sites/%s" % (
            tenant, site_name)
        request = urllib.request.Request(
            url, headers=headers, method='GET')
        response = urllib.request.urlopen(request)
        return json.load(response)['system_metadata']['uid']
    except HTTPError as her:
        if her.code == 404:
            try:
                v_static_routes = [
                    {
                        "ip_prefixes": inside_networks,
                        "ip_address": inside_gateway,
                        "attrs": ['ROUTE_ATTR_INSTALL_HOST', 'ROUTE_ATTR_INSTALL_FORWARDING']
                    }
                ]
                url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/voltstack_sites" % tenant
                headers['volterra-apigw-tenant'] = tenant
                headers['content-type'] = 'application/json'
                data = {
                    "metadata": {
                        "name": site_name,
                        "namespace": None,
                        "labels": {},
                        "annotations": {},
                        "description": None,
                        "disable": None
                    },
                    "spec": {
                        "volterra_certified_hw": "kvm-volstack-combo",
                        "master_nodes": [],
                        "worker_nodes": [],
                        "no_bond_devices": {},
                        "custom_network_config": {
                            "slo_config": {
                                "labels": {},
                                "static_routes": {
                                    "static_routes": v_static_routes
                                },
                                "no_dc_cluster_group": {}
                            },
                            "default_interface_config": {},
                            "no_network_policy": {},
                            "no_forward_proxy": {},
                            "global_network_list": {
                                "global_network_connections": [
                                    {
                                        "slo_to_global_dr": {
                                            "global_vn": {
                                                "tenant": "ves-io",
                                                "namespace": "shared",
                                                "name": "public"
                                            }
                                        }
                                    }
                                ]
                            },
                        },
                        "default_storage_config": {},
                        "disable_gpu": {},
                        "address": None,
                        "coordinates": {
                            "latitude": latitude,
                            "longitude": longitude
                        },
                        "k8s_cluster": {
                            "tenant": tenant_id,
                            "namespace": "system",
                            "name": site_name
                        },
                        "logs_streaming_disabled": {},
                        "deny_all_usb": {}
                    },
                    "resource_version": None
                }
                masters = []
                for indx in range(min(cluster_size, 3)):
                    masters.append("%s-vce-%d" % (site_name, indx))
                data['spec']['master_nodes'] = masters
                workers = []
                for indx in range(cluster_size - 3):
                    workers.append("%s-vce-%d" % (site_name, indx + 3))
                data['spec']['worker_nodes'] = workers
                data = json.dumps(data)
                request = urllib.request.Request(
                    url=url, headers=headers, data=bytes(data.encode('utf-8')), method='POST')
                response = urllib.request.urlopen(request)
                site = json.load(response)
                return site['system_metadata']['uid']
            except HTTPError as err:
                sys.stderr.write(
                    "Error creating volstack site resources %s: %s\n" % (url, err))
                sys.exit(1)
        else:
            sys.stderr.write(
                "Error retrieving voltstack site resources %s: %s\n" % (url, her))
            sys.exit(1)
    except Exception as er:
        sys.stderr.write(
            "Error retrieving voltstack site resources %s\n" % er)
        sys.exit(1)


def assure_virtual_network(tenant, token, site_name, fleet_label, tenant_id, inside_networks, inside_gateway):
    headers = {
        "Authorization": "APIToken %s" % token
    }
    if inside_networks:
        # Does virtual network exist
        try:
            url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/virtual_networks/%s" % (
                tenant, fleet_label)
            request = urllib.request.Request(
                url, headers=headers, method='GET')
            response = urllib.request.urlopen(request)
        except HTTPError as her:
            if her.code == 404:
                try:
                    v_static_routes = [
                        {
                            "ip_prefixes": inside_networks,
                            "ip_address": inside_gateway,
                            "attrs": ['ROUTE_ATTR_INSTALL_HOST', 'ROUTE_ATTR_INSTALL_FORWARDING']
                        }
                    ]
                    url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/virtual_networks" % tenant
                    headers['volterra-apigw-tenant'] = tenant
                    headers['content-type'] = 'application/json'
                    data = {
                        "namespace": "system",
                        "metadata": {
                            "name": site_name,
                            "namespace": "system",
                            "labels": {
                                "ves.io/fleet": fleet_label
                            },
                            "annotations": {},
                            "description": "Routes inside %s" % site_name,
                            "disable": False
                        },
                        "spec": {
                            "site_local_inside_network": {},
                            "static_routes": v_static_routes
                        }
                    }
                    data = json.dumps(data)
                    request = urllib.request.Request(
                        url=url, headers=headers, data=bytes(data.encode('utf-8')), method='POST')
                    urllib.request.urlopen(request)
                except HTTPError as her:
                    sys.stderr.write(
                        "Error creating virtual_networks resources %s: %s - %s\n" % (url, data, her))
                    sys.exit(1)
            else:
                sys.stderr.write(
                    "Error retrieving virtual_networks resources %s: %s\n" % (url, her))
                sys.exit(1)


def assure_network_connector(tenant, token, site_name, fleet_label):
    headers = {
        "Authorization": "APIToken %s" % token
    }
    # Does Global Network connector exist?
    try:
        url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/network_connectors/%s" % (
            tenant, site_name)
        request = urllib.request.Request(
            url, headers=headers, method='GET')
        urllib.request.urlopen(request)
    except HTTPError as her:
        if her.code == 404:
            try:
                url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/network_connectors" % tenant
                headers['volterra-apigw-tenant'] = tenant
                headers['content-type'] = 'application/json'
                data = {
                    "namespace": "system",
                    "metadata": {
                        "name": site_name,
                        "namespace": None,
                        "labels": {
                            "ves.io/fleet": fleet_label
                        },
                        "annotations": {},
                        "description": "connecting %s to the global shared network" % site_name,
                        "disable": False
                    },
                    "spec": {
                        "sli_to_global_dr": {
                            "global_vn": {
                                "tenant": "ves-io",
                                "namespace": "shared",
                                "name": "public"
                            }
                        },
                        "disable_forward_proxy": {}
                    }
                }
                data = json.dumps(data)
                request = urllib.request.Request(
                    url=url, headers=headers, data=bytes(data.encode('utf-8')), method='POST')
                urllib.request.urlopen(request)
            except HTTPError as her:
                sys.stderr.write(
                    "Error creating network_connectors resources %s: %s - %s\n" % (url, data, her))
                sys.exit(1)
        else:
            sys.stderr.write(
                "Error retrieving network_connectors resources %s: %s\n" % (url, her))
            sys.exit(1)


def assure_fleet(tenant, token, site_name, fleet_label, tenant_id):
    headers = {
        "Authorization": "APIToken %s" % token
    }
    # Does the fleet exist
    try:
        url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/fleets/%s" % (
            tenant, site_name)
        request = urllib.request.Request(
            url, headers=headers, method='GET')
        response = urllib.request.urlopen(request)
        return json.load(response)['spec']['fleet_label']
    except HTTPError as her:
        if her.code == 404:
            try:
                url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/fleets" % tenant
                headers['volterra-apigw-tenant'] = tenant
                headers['content-type'] = 'application/json'
                data = {
                    "namespace": "system",
                    "metadata": {
                        "name": site_name,
                        "namespace": None,
                        "labels": {},
                        "annotations": {},
                        "description": "Fleet provisioning object for %s" % site_name,
                        "disable": None
                    },
                    "spec": {
                        "fleet_label": fleet_label,
                        "volterra_software_version": None,
                        "network_connectors": [
                            {
                                "kind": "network_connector",
                                "uuid": None,
                                "tenant": tenant_id,
                                "namespace": "system",
                                "name": site_name
                            }
                        ],
                        "network_firewall": None,
                        "operating_system_version": None,
                        "outside_virtual_network": None,
                        "inside_virtual_network": [
                            {
                                "kind": "virtual_network",
                                "uid": None,
                                "tenant": tenant_id,
                                "namespace": "system",
                                "name": site_name
                            }
                        ],
                        "default_config": {},
                        "no_bond_devices": {},
                        "no_storage_interfaces": {},
                        "no_storage_device": {},
                        "default_storage_class": {},
                        "no_dc_cluster_group": {},
                        "disable_gpu": {},
                        "no_storage_static_routes": {},
                        "enable_default_fleet_config_download": None,
                        "logs_streaming_disabled": {},
                        "deny_all_usb": {}
                    }
                }
                data = json.dumps(data)
                request = urllib.request.Request(
                    url=url, headers=headers, data=bytes(data.encode('utf-8')), method='POST')
                response = urllib.request.urlopen(request)
                return json.load(response)['spec']['fleet_label']
            except HTTPError as her:
                sys.stderr.write(
                    "Error creating fleets resources %s: %s - %s\n" % (url, data, her))
                sys.exit(1)
        else:
            sys.stderr.write(
                "Error retrieving feet resources %s: %s\n" % (url, her))
            sys.exit(1)
    except Exception as er:
        sys.stderr.write(
            "Error retrieving fleet resources %s\n" % er)
        sys.exit(1)


def assure_service_discovery(tenant, token, site_name, tenant_id, consul_servers, ca_cert_encoded):
    headers = {
        "Authorization": "APIToken %s" % token
    }
    for indx, consul_server in enumerate(consul_servers):
        name = "%s-consul-%d" % (site_name, indx)
        # Does service discovery exist
        try:
            url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/discoverys/%s" % (
                tenant, name)
            request = urllib.request.Request(
                url, headers=headers, method='GET')
            urllib.request.urlopen(request)
        except HTTPError as her:
            if her.code == 404:
                try:
                    url = "https://%s.console.ves.volterra.io/api/config/namespaces/system/discoverys" % tenant
                    data = {
                        "namespace": "system",
                        "metadata": {
                            "name": name,
                            "namespace": None,
                            "labels": {},
                            "annotations": {},
                            "description": None,
                            "disable": False
                        },
                        "spec": {
                            "where": {
                                "site": {
                                    "ref": [{
                                        "kind": "site",
                                        "uid": None,
                                        "tenant": tenant_id,
                                        "namespace": "system",
                                        "name": site_name
                                    }],
                                    "network_type": "VIRTUAL_NETWORK_SITE_LOCAL_INSIDE"
                                }
                            },
                            "discovery_consul": {
                                "access_info": {
                                    "connection_info": {
                                        "api_server": consul_server,
                                        "tls_info": {
                                            "server_name": None,
                                            "certificate_url": None,
                                            "certificate": None,
                                            "key_url": None,
                                            "ca_certificah signal has different support and stability in OTLP, described through its own maturity level, which in turn applies to all the OTLP Transports listed below.te_url": None,
                                            "trusted_ca_url": "string:///%s" % ca_cert_encoded
                                        }
                                    },
                                    "scheme": None,
                                    "http_basic_auth_info": None
                                },
                                "publish_info": {
                                    "disable": {}
                                }
                            }
                        }
                    }
                    data = json.dumps(data)
                    request = urllib.request.Request(
                        url=url, headers=headers, data=bytes(data.encode('utf-8')), method='POST')
                    urllib.request.urlopen(request)
                except HTTPError as her:
                    sys.stderr.write(
                        "Error creating discoverys resources %s: %s - %s\n" % (url, data, her))
                    sys.exit(1)
            else:
                sys.stderr.write(
                    "Error retrieving discoverys resources %s: %s\n" % (url, her))
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
        required=False,
        default='false'
    )
    ap.add_argument(
        '--k8sdomain',
        help='Voltstack domain for K8s config',
        required=False,
        default='local'
    )
    ap.add_argument(
        '--cluster_size',
        help='Volterra Cluster size',
        required=False,
        default='3'
    ),
    ap.add_argument(
        '--latitude',
        help='Volterra Cluster latitude',
        required=False,
        default='33.1032'
    ),
    ap.add_argument(
        '--longitude',
        help='Volterra Cluster longitude',
        required=False,
        default='-96.6706'
    )
    ap.add_argument(
        '--inside_networks',
        help='Network CIDRs reachable inside the Volterra Cluster',
        required=False,
        default='[]'
    )
    ap.add_argument(
        '--inside_gateway',
        help='Network inside the Volterra Cluster next hop IPv4 address',
        required=False,
        default=''
    )
    ap.add_argument(
        '--consul_servers',
        help='Consul server IPv4 addresses to add as service discovery',
        required=False,
        default='[]'
    )
    ap.add_argument(
        '--ca_cert_encoded',
        help='Base64 encoded Consul CA certificate to add as service discovery',
        required=False,
        default='[]'
    )
    args = ap.parse_args()

    tenant_id = get_tenant_id(
        args.tenant,
        args.token
    )

    if args.voltstack == "true":
        assure_k8s_cluster(
            args.tenant,
            args.token,
            args.site,
            args.k8sdomain
        )
        assure_voltstack_site(
            args.tenant,
            args.token,
            args.site,
            tenant_id,
            int(args.cluster_size),
            args.latitude,
            args.longitude,
            json.loads(args.inside_networks),
            args.inside_gateway
        )
    else:
        assure_virtual_network(
            args.tenant,
            args.token,
            args.site,
            args.fleet,
            tenant_id,
            json.loads(args.inside_networks),
            args.inside_gateway
        )
        assure_network_connector(
            args.tenant,
            args.token,
            args.site,
            args.fleet
        )
        assure_fleet(
            args.tenant,
            args.token,
            args.site,
            args.fleet,
            tenant_id
        )
        consul_servers = json.loads(args.consul_servers)
        if consul_servers:
            assure_service_discovery(
                args.tenant,
                args.token,
                args.site,
                tenant_id,
                consul_servers,
                args.ca_cert_encoded
            )
    site_token = assure_site_token(
        args.tenant,
        args.token,
        args.site
    )
    site_token_file = "%s/%s_site_token.txt" % (
        os.path.dirname(os.path.realpath(__file__)), args.site)
    if os.path.exists(site_token_file):
        os.unlink(site_token_file)
    with open(site_token_file, "w") as site_token_file:
        site_token_file.write(site_token)
    sys.exit(0)


if __name__ == '__main__':
    main()
