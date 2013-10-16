# Lingr notification step

before using gem, need to make bot of Lingr. [Lingr/developer](http://lingr.com/developer)

## Options

* ``bot-id`` (required)
* ``secret`` (required)
* ``room-id`` (required)
* ``on``
* ``message``

## Example

```
build:
  after-steps:
    - 1syo/lingr-notify@0.0.3:
        bot-id: YOUR_BOT_ID
        secret: YOUR_SECRET
        room-id: YOUR_ROOM_ID
```

## License

The MIT License (MIT)
