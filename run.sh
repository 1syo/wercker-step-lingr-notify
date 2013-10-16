#!/bin/sh

if [ "$WERCKER_LINGR_NOTIFY_ON" = "failed" ]; then
  if [ "$WERCKER_RESULT" = "passed" ]; then
    info "Skipping..."
    return 0
  fi
fi

if [ ! -n "$WERCKER_LINGR_NOTIFY_BOT_ID" ]; then
  fail 'Please specify bot-id property.'
fi
info $WERCKER_LINGR_NOTIFY_BOT_ID

if [ ! -n "$WERCKER_LINGR_NOTIFY_SECRET" ]; then
  fail 'Please specify secret property.'
fi


openssl=`which openssl`
if [ ! -n "$openssl" ]; then
  fail 'OpenSSL command not found.'
fi

bot_verifier=`/bin/echo -n $WERCKER_LINGR_NOTIFY_BOT_ID$WERCKER_LINGR_NOTIFY_SECRET | $openssl sha1 | awk '{print $2}'`

if [ ! -n "$WERCKER_LINGR_NOTIFY_ROOM_ID" ]; then
  fail 'Please specify room-id property.'
fi
info $WERCKER_LINGR_NOTIFY_ROOM_ID


if [ ! -n "$WERCKER_LINGR_NOTIFY_PASSED_MESSAGE" ]; then
  if [ ! -n "$DEPLOY" ]; then
    passed_message="$WERCKER_APPLICATION_OWNER_NAME/$WERCKER_APPLICATION_NAME: build of $WERCKER_GIT_BRANCH by $WERCKER_STARTED_BY passed."
  else
    passed_message="$WERCKER_APPLICATION_OWNER_NAME/$WERCKER_APPLICATION_NAME: deploy to $WERCKER_DEPLOYTARGET_NAME by $WERCKER_STARTED_BY passed."
  fi
else
  passed_message="$WERCKER_LINGR_NOTIFY_PASSED_MESSAGE"
fi

if [ ! -n "$WERCKER_LINGR_NOTIFY_FAILED_MESSAGE" ]; then
  if [ ! -n "$DEPLOY" ]; then
    failed_message="$WERCKER_APPLICATION_OWNER_NAME/$WERCKER_APPLICATION_NAME: build of $WERCKER_GIT_BRANCH by $WERCKER_STARTED_BY failed."
  else
    failed_message="$WERCKER_APPLICATION_OWNER_NAME/$WERCKER_APPLICATION_NAME: deploy to $WERCKER_DEPLOYTARGET_NAME by $WERCKER_STARTED_BY failed."
  fi
else
  failed_message="$WERCKER_LINGR_NOTIFY_FAILED_MESSAGE"
fi

if [ "$WERCKER_RESULT" = "passed" ]; then
  message="$passed_message"
else
  message="$failed_message"
fi
info "$message"


curl=`which curl`
if [ ! -n "$curl" ]; then
  fail 'Curl command not found.'
fi

$curl -G -s \
  --data-urlencode "bot=$WERCKER_LINGR_NOTIFY_BOT_ID" \
  --data-urlencode "bot_verifier=$bot_verifier" \
  --data-urlencode "room=$WERCKER_LINGR_NOTIFY_ROOM_ID" \
  --data-urlencode "text=$message" \
  http://lingr.com/api/room/say > /dev/null
