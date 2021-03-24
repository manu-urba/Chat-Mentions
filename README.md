# Chat Mentions

## Description

This plugin allows chat mentions to draw someone's attention.
The plugin allows partial nickname targeting eg. @frag, will be replaced with colored FrAgOrDiE in the chat and a sound will be reproduced to FrAgOrDiE.
Multiple targetings are also allowed such as @all, @t, @ct, @dead.

## Images

![example](https://image.prntscr.com/image/1ALWtsI9TveWMtY0Qd8roA.png)

![example](https://image.prntscr.com/image/OdjamEUKQP6BzvfW4nZ4Bg.png)

![example](https://image.prntscr.com/image/GVugrSf8QqGD17DV-7dGUw.png)

![example](https://image.prntscr.com/image/h8tns6mfQKOgBwgNVor71g.png)

![example](https://image.prntscr.com/image/o_F0PV-WSXKpvubYlD5Mdg.png)

![example](https://image.prntscr.com/image/6e_oSBVeTqeEPNBQFvFbWQ.png)

## Convars

```cpp
// Color prefix to use for mentioned name in chat
// -
// Default: "{green}"
sm_chatmentions_color "{green}"

// Enable/Disable sound for all clients
// -
// Default: "1"
// Minimum: "0.000000"
// Maximum: "1.000000"
sm_chatmentions_sound_enabled "1"

// Color prefix to use for mentioned name in chat
// -
// Default: "Chat-Mentions/mention.wav"
sm_chatmentions_sound "Chat-Mentions/mention.wav"

// Show "@" sign before player name mention
// -
// Default: "0"
// Minimum: "0.000000"
// Maximum: "1.000000"
sm_chatmentions_show_at "0"

// Show "@" sign before single player name mention
// -
// Default: "0"
// Minimum: "0.000000"
// Maximum: "1.000000"
sm_chatmentions_show_at_on_single_target "0"

// Show "@" sign before multiple targeting eg. @all, @t, @ct
// -
// Default: "1"
// Minimum: "0.000000"
// Maximum: "1.000000"
sm_chatmentions_show_at_on_multiple_target "1"
```

## APIs

```cpp
forward void Mentions_OnPlayerMentioned(int client);
```
