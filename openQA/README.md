### Generate changelog
git shortlog  92e52b69..HEAD | grep Merge | sed 's=^.*#\(.*\) from.*=https://github.com/os-autoinst/os-autoinst/pull/\1=g' | xargs -I {} nokogiri -e 'puts " * {} - " + $_.xpath("//title").text.split(")'·")[0]' {}'
