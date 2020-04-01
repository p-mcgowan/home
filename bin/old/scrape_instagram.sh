#!/bin/bash

first_page="1132212827095171510"

data='
q: ig_user(9762431) {
 media.after(970415360189006678, 12) {
 }
},
ref: users::show
'
   # count,
   # nodes { caption, code, comments { count }, comments_disabled, date, dimensions { height, width }, display_src, id, is_video, likes { count }, owner { id }, thumbnail_src, video_views },
   # page_info
# query="q=ig_user(9762431)%7Bmedia.after($first_page%2C12)%7B%0Acount%2C%0A"\
# "nodes%7B%0Acaption%2C%0Acode%2C%0Acomments%7B%0Acount%0A"\
# "%7D%2C%0Acomments_disabled%2C%0Adate%2C%0Adimensions%7B%0Ah"\
# "eight%2C%0Awidth%0A%7D%2C%0Adisplay_src%2C%0Aid%2C%0Ais_vi"\
# "deo%2C%0Alikes%7B%0Acount%0A%7D%2C%0Aowner%7B%0Aid%0A"\
# "%7D%2C%0Athumbnail_src%2C%0Avideo_views%0A%7D%2C%0Apage_info%0A%7"\
# "D%0A%7D&ref=users%3A%3Ashow"

for i in $(curl -X GET -d "$data" https://www.instagram.com/hockeycommunity/?__a=1 |grep -o '{"code": "[^"]*"' |cut -d ':' -f2); do
  echo ${i//\"/}
done
 # >tmpResponse.txt
# grep -o 'window\._sharedData = '

# this is the href of the load more button - max_id is id of the first image in the next page
# /hockeycommunity/?max_id=1132212827095171510

