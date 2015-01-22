Kernel boot options for getting serial console working...

    Kernel Options: serial console=ttyS0,115200
    Kernel Options (Post Install): console=ttyS0,115200

Example case of starting up a kvm based vm ...

On the 'server' side where you want to create a new system

    cobbler system add --name susu --profile=precise-x86_64 --virt-type=qemu --interface=eth0 --mac-address=random

Note, in the above, the random string tells cobbler to generate a random mac address

On the 'hypervisor' side where you want to kick of the VM
    
    koan --server qbsnode0.local --virt --nogfx --system=susu

To connect to the serial console of the vm, do this on the hypervisor

    virsh console DOMAIN

Or
    virsh ttyconsole DOMAIN
    screen `the device node that the previous command showed`
