#!/bin/bash

CHANGELOG=/tmp/changelog.txt
TABLE=/tmp/table.html

>$CHANGELOG
>$TABLE

source $HOME/.bash_aliases
echo '
<table class="wrapped relative-table confluenceTable" style="width: 90.1918%">
  <colgroup>
    <col style="width: 10.5167%" />
    <col style="width: 13.1915%" />
    <col style="width: 15.3191%" />
    <col style="width: 24.3769%" />
  </colgroup>
  <tbody>
    <tr>
      <th class="confluenceTh">Service</th>
      <th class="confluenceTh">Release Tag</th>
      <th colspan="1" class="confluenceTh">Release Branch</th>
      <th colspan="1" class="confluenceTh">Check List</th>
    </tr>' >>$TABLE

for proj in  \
 admin-panel \
 admin-panel-backend \
 frontend \
 user-management \
; do
  echo "generating ${proj}"
  zgoto ${proj}
  baseurl=https://$(git remote get-url --push origin |awk -F '@' '{ sub(/:/, "/"); sub(/\.git/, ""); print($2) }')
  latestTag=$(git fetch --tags && git tag --list --sort=creatordate --format="%(refname:short)" |tail -n1)

  cat >>$TABLE <<TEMPL
      <tr>
        <td class="confluenceTd">
          <a href="${baseurl}">${proj}</a>
        </td>
        <td class="confluenceTd">
          <a href="${baseurl}/-/tags/${latestTag}">${latestTag}</a>
        </td>
        <td class="confluenceTd">
          <a href="${baseurl}/-/tree/stage">stage branch</a>
          <br />
          <a href="${baseurl}/-/tree/master" >master branch</a>
        </td>
        <td class="confluenceTd">
          <ul class="inline-task-list" data-inline-tasks-content-id="102106796">
            <!-- <li class="checked" data-inline-task-id="219"><span class="placeholder-inline-tasks">Deploy to EMEA Stage</span></li> -->
            <li data-inline-task-id="219"><span class="placeholder-inline-tasks">Deploy to EMEA Stage</span></li>
            <li data-inline-task-id="220"><span class="placeholder-inline-tasks">Deploy to US Stage</span></li>
            <li data-inline-task-id="221"><span class="placeholder-inline-tasks">Deploy to EMEA Prod</span></li>
            <li data-inline-task-id="222"><span class="placeholder-inline-tasks">Deploy to US Prod</span></li>
          </ul>
        </td>
      </tr>
TEMPL

  echo -e "\n\n$proj @ $latestTag
$(diff-release stage -M)" >>$CHANGELOG

done

echo \
'  </tbody>
</table>' >>$TABLE

echo "DONE:"
echo "$TABLE"
echo "$CHANGELOG"
