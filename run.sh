if [ "$WERCKER_LINGR_NOTIFY_ON" = "failed" ]; then
  if [ "$WERCKER_RESULT" = "passed" ]; then
    info "Skipping..."
    return 0
  fi
fi

if [ ! -n "$WERCKER_LINGR_NOTIFY_BOT_ID" ]; then
  fail 'Please specify bot-id property.'
fi
info "bot_id: $WERCKER_LINGR_NOTIFY_BOT_ID"

if [ ! -n "$WERCKER_LINGR_NOTIFY_SECRET" ]; then
  fail 'Please specify secret property.'
fi

if [ ! -n "$WERCKER_LINGR_NOTIFY_ROOM_ID" ]; then
  fail 'Please specify room-id property.'
fi
info "room_id: $WERCKER_LINGR_NOTIFY_ROOM_ID"

openssl=`which openssl`
if [ ! -n "$openssl" ]; then
  fail 'OpenSSL command not found.'
fi

bot_verifier=`echo -n $WERCKER_LINGR_NOTIFY_BOT_ID$WERCKER_LINGR_NOTIFY_SECRET | $openssl sha1 | awk '{print $2}'`

if [ "$WERCKER_RESULT" = "passed" ]; then
  status="SUCCESS"
else
  status="FAILURE"
fi
info "status: $status"

if [ "$CI" = "true" ]; then
  step="build"
  id=$WERCKER_BUILD_ID
  url=$WERCKER_BUILD_URL
elif [ "$DEPLOY" = "true" ]; then
  step="deploy"
  id=$WERCKER_DEPLOY_ID
  url=$WERCKER_DEPLOY_URL
else
  step="build"
  id=$WERCKER_BUILD_ID
  url=$WERCKER_BUILD_URL
fi

info "step: $step"
info "id: $id"
info "url: $url"

curl -G -s \
  --data-urlencode "bot=$WERCKER_LINGR_NOTIFY_BOT_ID" \
  --data-urlencode "bot_verifier=$bot_verifier" \
  --data-urlencode "room=$WERCKER_LINGR_NOTIFY_ROOM_ID" \
  --data-urlencode "text=Project $WERCKER_APPLICATION_NAME $step $number, $url: $status" \
  http://lingr.com/api/room/say
