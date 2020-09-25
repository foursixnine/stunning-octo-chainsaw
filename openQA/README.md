### Generate changelog
`git shortlog hash1..hash2 | grep Merge | sed 's=^.*#\(.*\) from.*=https://github.com/os-autoinst/openQA/pull/\1=g' | xargs -I {} nokogiri -e 'puts " * {} - " + $_.xpath("//title").text.split("·")[0]' {}`

If you want to make your life even easier: `bash deltaforce.sh 58d02775 24ee0a3e` where first parameter is [os-autoinst](https://github.com/os-autoinst/os-autoinst) hash and second one would be [openQA](https://github.com/os-autoinst/openQA) git hash

### Deleting or cancelling jobs that were created by clonejob: (in bulk)

cat to_delete:
`Created job #2277850: sle-15-SP1-Installer-DVD-s390x-Build101.2-create_hdd_minimal_base+sdk@zkvm -> http://openqa.suse.de/t2277850`

Simply pass the file to this regexp
`cat to_delete | sed -r 's/.*#([0-9]*):.*/\1/g' | xargs -I '{}' ./script/client --host openqa.suse.de jobs/{} delete`

In case what you have is json:
`cat jobs.json | jq '.results.sle[][][].x86_64.jobid' |xargs -I '{}' $OPENQA_SRC/script/client  --host https://openqa.suse.de jobs/{} delete`

In case what you have, it's just the json from an url:
```
curl "https://openqa.suse.de/tests/overview.json?arch=&machine=\
&modules=user_defined_snapshot&distri=sle&groupid=96&version=15-SP2\
&build=foursixnine_163.11#" \
| jq '.results[][][][][] | .jobid?' \
| xargs -I {} openqa-client --host openqa.suse.de jobs/{} delete
```

### Best case scenario, you have the output of an isos post

Long story short, you take the values shown in ids => and use them as parameters for a for loop, i.e `3947203 .. 3947427` becomes for job in `$(seq 3947152  3947199); do ./script/client --host openqa.suse.de jobs/$job delete; done;`

### Say your worst nightmare is true and you didn't save the output or you don't have it

Today since I didn't have the output from the isos post command, I went on https://openqa.suse.de/admin/productlog looked for your product, copied the list of sucessful_job_ids, put them on a file and bam

`cat ~/to_delete.list | xargs -I {} openqa-client --host openqa.suse.de jobs/{} delete`

### Even easier! (Just with few more pick & axe stuff)

Say that you know a bit of html, and can `left click on your product row, and get the value of data-url` that looks like this: `data-url="/api/v1/isos/547157"`

Call the client, and save the output to a file: `./script/client --host openqa.suse.de isos/547157 | tee ~/data.log`

Use the following file and save it as `scheduled_product_load` (I might improve this later, if this happens enough times)

```perl scheduled_product_load
use strict; 
use warnings;
use feature qw(say); 
use Mojo::JSON qw(encode_json);

my $stored_hash = 'my %this_hash =';
$stored_hash = do { local $/; <STDIN> } . "; " ;
my $restored_hash = eval $stored_hash;

print encode_json($restored_hash);
```

Put it all together:

`cat ~/to_delete.list | scheduled_product_load | xargs -I {} openqa-client --host openqa.suse.de jobs/{} delete`

### Even easier v2, no pick & axe needed!

Go to your product log and pick the ones you want to wipe out of existence: https://openqa.suse.de/admin/productlog

```
PRODUCT_POSTS="597644 597643 597642 597641 597640 597639 597638"
for i in $PRODUCT_POSTS; do
  openqa-cli api -X GET -host openqa.suse.de isos/$i | \
  jq -r '.results.successful_job_ids[] , .results.failed_job_info[].job_id | if type=="array" then .[] else . end' | sort | uniq | \
  xargs -I {} openqa-cli api --host openqa.suse.de -X DELETE jobs/{}
done
```

Now go for a `$DRINK`, you deserve it *sips coffee*

## In case you want to trigger N jobs, I tend to use this trick:

```
for job in {1..100}; do 
    openqa-clone-job --dir $OPENQA_SHARE/factory \
    --within-instance openqa.suse.de  --skip-chained-deps 4037949 \
    TEST="foursixnine_BSC_1166955_1.5GB_$job" \
    BUILD="foursixnine_163.11" \
    INCLUDE_MODULES=boot_to_desktop,user_defined_snapshot \ 
    CASEDIR=https://github.com/foursixnine/os-autoinst-distri-opensuse.git#oopsitsbrokenagain \
    _GROUP_ID=96 QEMURAM=1536; 
done

```

But also take a look at [trigger-multiple-jobs](trigger-multiple-jobs)
