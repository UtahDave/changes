===============================================================================
Salt Vagrant Demo showing Salt State "changes" and "comments" field differences
===============================================================================

A Salt Demo using Vagrant.


Instructions
============

Run the following commands in a terminal. Git, VirtualBox and Vagrant must
already be installed.

.. code-block:: bash

    git clone https://github.com/UtahDave/changes.git
    cd changes
    vagrant plugin install vagrant-vbguest
    vagrant up


This will download an Ubuntu  VirtualBox image and create two virtual machines
for you. One will be a Salt Master named `master` and the other will be named
`minion1`.  The Salt Minion will point to the Salt Master and the Minion's keys
will already be accepted. Because the keys are pre-generated and reside in the
repo, please be sure to regenerate new keys if you use this for production
purposes.

You can then run the following commands to log into the Salt Master and begin
using Salt.

.. code-block:: bash

    vagrant ssh master
    sudo salt \* test.ping


You can see the difference between the output of a successful orchestration
state and a failure with the following commands:


.. code-block:: bash

    sudo salt-run state.orch changes.succeed --out json
    sudo salt-run state.orch changes.fail --out json 2> /dev/null



You should see something like the following:


.. code-block:: bash

    sudo salt minion1 pkg.remove nano
    sudo salt-run state.orch changes.succeed --out json
    {
        "outputter": "highstate",
        "data": {
            "saltmaster.local_master": {
                "salt_|-Step01_|-Step01_|-state": {
                    "comment": "States ran successfully. Updating minion1.",
                    "name": "Step01",
                    "start_time": "01:47:59.026329",
                    "result": true,
                    "duration": 8006.557,
                    "__run_num__": 0,
                    "__jid__": "20171109014759087105",
                    "__sls__": "changes.succeed",
                    "changes": {
                        "ret": {
                            "minion1": {
                                "pkg_|-install_good_package_|-nano_|-installed": {
                                    "comment": "The following packages were installed/updated: nano",
                                    "name": "nano",
                                    "start_time": "01:47:59.077133",
                                    "result": true,
                                    "duration": 7202.901,
                                    "__run_num__": 0,
                                    "__sls__": "changes.pkg_succeed",
                                    "changes": {
                                        "nano": {
                                            "new": "2.5.3-2ubuntu2",
                                            "old": ""
                                        }
                                    },
                                    "__id__": "install_good_package"
                                }
                            }
                        },
                        "out": "highstate"
                    },
                    "__id__": "Step01"
                }
            }
        },
        "retcode": 0
    }


And like this on failure:


.. code-block:: bash

    sudo salt-run state.orch changes.fail --out json 2> /dev/null
    {
        "outputter": "highstate",
        "data": {
            "saltmaster.local_master": {
                "salt_|-Step01_|-Step01_|-state": {
                    "comment": "Run failed on minions: minion1\nFailures:\n    {\n        \"minion1\": {\n            \"pkg_|-install_fake_package_|-asdfasdf_|-installed\": {\n                \"comment\": \"Problem encountered installing package(s). Additional info follows:\\n\\nerrors:\\n    - Running scope as unit run-r9c32e46083d64e3785334798d98071e9.scope.\\n      E: Unable to locate package asdfasdf\", \n                \"name\": \"asdfasdf\", \n                \"start_time\": \"01:41:40.142147\", \n                \"result\": false, \n                \"duration\": 4373.974, \n                \"__run_num__\": 0, \n                \"__sls__\": \"changes.pkg_fail\", \n                \"changes\": {}, \n                \"__id__\": \"install_fake_package\"\n            }\n        }\n    }\n",
                    "name": "Step01",
                    "start_time": "01:41:40.036106",
                    "result": false,
                    "duration": 5130.725,
                    "__run_num__": 0,
                    "__jid__": "20171109014140096711",
                    "__sls__": "changes.fail",
                    "changes": {},
                    "__id__": "Step01"
                }
            }
        },
        "retcode": 1
    }


You can see from the above results that when there's a success the `changes`
field is populated with a dictionary cleanly describing the changes that
happened. But when there's a failure the info about the failure is added to the
`comments` field as a string with spaces and hard returns. This makes it
difficult to parse reliably when used programatically.
