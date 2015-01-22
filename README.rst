===============
cobbler-formula
===============

A saltstack formula that installs cobbler 2.6 on Ubuntu 12.04 and possibly
Debian Wheezy.

This formula requires the apache-formula and the python-augeas package.

The dnsmasq template also assumes that there is a working DHCP server
somewhere else on the network, dnsmasq is configured for PXE booting
hosts that cobbler knows about.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:

``cobbler.init``
----------------

Installs the cobbler package, and starts the associated cobbler service.
