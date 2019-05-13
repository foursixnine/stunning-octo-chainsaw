# stunning-octo-chainsaw
Repository with random stuff

# build_helper.pl 
* meant to be used with openqa: 
    ```
        perl script/build_helper.pl -w aarch64_dualsocket3 -b 0453 -s 0247 -name _CAVIUM3_0453B -a aarch64\ 
        -e QEMUMACHINE=virt,usb=off,gic-version=3,its=off
     ```
# trigger-multiple-jobs
* Triggers N jobs to be used to gather data or statistics when it comes to test execution or to check the behaviour of a SUT under certain conditions
    ```
    ./script/trigger-multiple-jobs  https://openqa.suse.de/tests/2874077 rogue_workqueue_bsc1126782 1 EXTRABOOTPARAMS=kernel.softlockup_panic=1\ softlockup_panic=1
    ```
