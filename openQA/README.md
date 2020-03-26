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
