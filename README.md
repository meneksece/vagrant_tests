# vagrant_tests


to initialize vagrant file for hyperv

PS C:\vagrant_tests\vagrant_hyperv> vagrant init generic/centos7

A `Vagrantfile` has been placed in this directory. You are now
ready to `vagrant up` your first virtual environment! Please read
the comments in the Vagrantfile as well as documentation on
`vagrantup.com` for more information on using Vagrant.


after configuring Vagrantfile, run "vagrant up --provider=hyperv"

PS C:\vagrant_tests\vagrant_hyperv> vagrant up --provider=hyperv
Bringing machine 'centos7-jump' up with 'hyperv' provider...
Bringing machine 'centos7-first' up with 'hyperv' provider...
Bringing machine 'centos7-second' up with 'hyperv' provider...
Bringing machine 'centos7-third' up with 'hyperv' provider...
==> centos7-jump: Verifying Hyper-V is enabled...
==> centos7-jump: Verifying Hyper-V is accessible...
==> centos7-jump: Importing a Hyper-V instance
    centos7-jump: Creating and registering the VM...
    centos7-jump: Successfully imported VM
    centos7-jump: Configuring the VM...
    centos7-jump: Setting VM Enhanced session transport type to disabled/default (VMBus)
==> centos7-jump: Starting the machine...
.
.
.

#######

to initialize vagrant file for  virtualbox

PS C:\vagrant_tests\vagrant_virtualbox> vagrant init generic/centos7
A `Vagrantfile` has been placed in this directory. You are now
ready to `vagrant up` your first virtual environment! Please read
the comments in the Vagrantfile as well as documentation on
`vagrantup.com` for more information on using Vagrant.
PS C:\vagrant_tests\vagrant_virtualbox>

#######

before running "vagrant up" , you can run "vagrant status"

PS D:\Vagrant\certified-kubernetes-administrator-course\kubeadm-clusters\hyperv> vagrant status
Current machine states:

kubemaster                not_created (hyperv)
kubenode01                not_created (hyperv)
kubenode02                not_created (hyperv)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.

#######
