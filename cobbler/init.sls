{% from "cobbler/map.jinja" import cobbler with context %}

{% set cfg_cobbler = pillar.get('cobbler', {}) -%}
{%- macro get_config(configname, default_value) -%}
{%- if configname in cfg_cobbler -%}
{{ cfg_cobbler[configname] }}
{%- else -%}
{{ default_value }}
{%- endif -%}
{%- endmacro -%}

include:
  - apache

cobbler-deps:
  pkg.installed:
    - pkgs: {{ cobbler['pkgs']|json }}

{% if grains['os_family'] == 'Debian' %}
cobbler-repo:
  pkgrepo.managed:
    - humanname: Cobbler Repo
    {% if grains['os'] == 'Ubuntu' %}
    - name: "deb http://download.opensuse.org/repositories/home:/libertas-ict:/cobbler26/x{{ grains['os'] }}_{{ grains['osrelease'] }} ./"
    {% else %}
    - name: "deb http://download.opensuse.org/repositories/home:/libertas-ict:/cobbler26/{{ grains['os'] }}_{{ grains['osrelease'] }} ./"
    {% endif %}
    - dist: ./
    - file: /etc/apt/sources.list.d/cobbler.list
    - key_url: salt://cobbler/files/Release.key
{% endif %}

cobbler:
  pkg.latest:
    - refresh: True
    - watch_in:
      - service: apache
  require:
    - name: cobbler-repo
  service.running:
    - name: cobblerd
    - enable: True

cobbler-apache-mods:
  cmd.run:
    - name: a2enmod proxy && a2enmod proxy_http && a2enmod version && touch /etc/cobbler/apache_mods_enabled
    - creates: /etc/cobbler/apache_mods_enabled
    - watch_in:
      - service: apache

cobbler-settings-config:
  augeas.change:
    - context: /files/etc/cobbler/settings
    - changes:
      - set bind_master {{ get_config('bind_master', '127.0.0.1') }}
      - set next_server {{ get_config('next_server', '127.0.0.1') }}
      - set server {{ get_config('server', '127.0.0.1') }}
      - set manage_dhcp {{ get_config('manage_dhcp', '0') }}
      - set restart_dhcp {{ get_config('restart_dhcp', '0') }}
      - set manage_tftpd {{ get_config('manage_tftpd', 1) }}
      - set pxe_just_once {{ get_config('pxe_just_once', 0) }}
      - set default_virt_bridge {{ get_config('default_virt_bridge', 'xenbr0') }}
      - set default_virt_type {{ get_config('default_virt_type', 'xenpv') }}
    - watch_in:
      - service: cobblerd

cobbler-modules-config:
  augeas.change:
    - context: /files/etc/cobbler/modules.conf
    - changes:
      - set dns/module {{ get_config('dns_module', 'manage_isc') }}
      - set dhcp/module {{ get_config('dhcp_module', 'manage_isc') }}
      - set tftpd/module {{ get_config('tftpd_module', 'manage_in_tftpd') }}
    - watch_in:
      - service: cobblerd

cobbler-dnsmasq-config:
  file.managed:
    - source: salt://cobbler/files/dnsmasq.template
    - name: /etc/cobbler/dnsmasq.template
    - template: jinja

cobbler-tftpd-config:
  file.managed:
    - source: salt://cobbler/files/tftpd.template
    - name: /etc/cobbler/tftpd.template
    - template: jinja

/var/lib/cobbler/webui_sessions:
  file.directory:
    - user: www-data

/tftpboot:
  file.directory

{%  if grains['os'] == 'Ubuntu' %}
/usr/share/cobbler/web/cobbler_web/urls.py:
  file.replace:
    - pattern: "from django.conf.urls import patterns"
    - repl: "from django.conf.urls.defaults import *"
{% endif %}
