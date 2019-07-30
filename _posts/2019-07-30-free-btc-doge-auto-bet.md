---
layout: post
title: "脚本实现FreeBitcoin高胜率地自动下注"
date: 2019-07-30 14:00:00 +0800
category: 技术
tags: [Bitcoin]
---

几年前玩过一个免费领DOGE币的网站叫[FreeDogecoin](link: http://freedoge.co.in/?r=1049768) ，除了领免费币，还能玩下注猜大小的游戏“赢”币，之前玩过，毫不意外地领到的币全输光了。

今天突发奇想：如果一直猜小，输了就把下注翻倍，直到赢为止，然后重新开始。按概率论说，只要本金足够，最终不会输才对。

决定实践一下自己的想法，第一步是实现自动下注，分析了一下网站页面元素，自动下注的的代码是这样的：

```js
var startValue = '0.038000001', // Don't lower the decimal point more than 4x of current balance
  stopPercentage = 0.001, // In %. I wouldn't recommend going past 0.08
  maxWait = 500, // In milliseconds
  stopped = false,
  stopBefore = 3; // In minutes

var $loButton = $('#double_your_doge_bet_lo_button'),
  $hiButton = $('#double_your_doge_bet_hi_button');

function multiply() {
  var current = $('#double_your_doge_stake').val();
  var multiply = (current * 2).toFixed(8);
  $('#double_your_doge_stake').val(multiply);
}

function getRandomWait() {
  var wait = Math.floor(Math.random() * maxWait) + 100;
  console.log('Waiting for ' + wait + 'ms before next bet.');
  return wait;
}

function startGame() {
  console.log('Game started!');
  reset();
  $loButton.trigger('click');
}

function stopGame() {
  console.log('Game will stop soon! Let me finish.');
  stopped = true;
}

function reset() {
  $('#double_your_doge_stake').val(startValue);
}

// quick and dirty hack if you have very little bitcoins like 0.0380001
function deexponentize(number) {
  return number * 1000000;
}

function iHaveEnoughMoni() {
  var balance = deexponentize(parseFloat($('#balance').text()));
  var current = deexponentize($('#double_your_doge_stake').val());

  return ((balance * 2) / 100) * (current * 2) > stopPercentage / 100;
}


function stopBeforeRedirect() {
  var minutes = parseInt($('title').text());

  if (minutes < stopBefore) {
    console.log('Approaching redirect! Stop the game so we don\'t get redirected while loosing.');
    stopGame();

    return true;
  }

  return false;
}

// Unbind old shit
$('#double_your_doge_bet_lose').unbind();
$('#double_your_doge_bet_win').unbind();


// Loser
$('#double_your_doge_bet_lose').bind("DOMSubtreeModified", function (event) {
  if ($(event.currentTarget).is(':contains("lose")')) {
    console.log('You LOST! Multiplying your bet and betting again.');

    multiply();

    setTimeout(function () {
      $loButton.trigger('click');
    }, getRandomWait());

    //$loButton.trigger('click');
  }
});


// Winner
$('#double_your_doge_bet_win').bind("DOMSubtreeModified", function (event) {
  if ($(event.currentTarget).is(':contains("win")')) {
    if (stopBeforeRedirect()) {
      return;
    }

    if (iHaveEnoughMoni()) {
      console.log('You WON! But don\'t be greedy. Restarting!');
      reset();

      if (stopped) {
        stopped = false;
        return false;
      }
    }
    else {
      console.log('You WON! Betting again');
    }

    setTimeout(function () {
      $loButton.trigger('click');
    }, getRandomWait());
  }
});
```

然后打开浏览器控制台，把上面的代码粘贴进去，再输入`startGame()`就可以开始自动下注了。如果要停止，则输入`stopGame()`。

经过几天的实践证明，我的想法基本上可行的，但要注意两点：**起始投注额要足够小（0.038），本金要足够大（500以上）**，毕竟2的n次幂还是很可怕的。

FreeDogecoin还有个孪生网站叫FreeBitcoin，其实这才是人家的主营业务，这个方法也是通用的，只需要把脚本的页面元素ID改一下即可：

```js
var startValue = '0.00000002', // Don't lower the decimal point more than 4x of current balance
  stopPercentage = 0.001, // In %. I wouldn't recommend going past 0.08
  maxWait = 500, // In milliseconds
  stopped = false,
  stopBefore = 1; // In minutes for timer before stopping redirect on webpage

var $loButton = $('#double_your_btc_bet_lo_button'),
  $hiButton = $('#double_your_btc_bet_hi_button');

function multiply() {
  var current = $('#double_your_btc_stake').val();
  var multiply = (current * 2).toFixed(8);
  $('#double_your_btc_stake').val(multiply);
}

function getRandomWait() {
  var wait = Math.floor(Math.random() * maxWait) + 100;
  console.log('Waiting for ' + wait + 'ms before next bet.');
  return wait;
}

function startGame() {
  console.log('Game started!');
  reset();
  $loButton.trigger('click');
}

function stopGame() {
  console.log('Game will stop soon! Let me finish.');
  stopped = true;
}

function reset() {
  $('#double_your_btc_stake').val(startValue);
}

// quick and dirty hack if you have very little bitcoins like 0.0380001
function deexponentize(number) {
  return number * 1000000;
}

function iHaveEnoughMoni() {
  var balance = deexponentize(parseFloat($('#balance').text()));
  var current = deexponentize($('#double_your_btc_stake').val());

  return ((balance * 2) / 100) * (current * 2) > stopPercentage / 100;
}


function stopBeforeRedirect() {
  var minutes = parseInt($('title').text());

  if (minutes < stopBefore) {
    console.log('Approaching redirect! Stop the game so we don\'t get redirected while loosing.');
    stopGame();

    return true;
  }

  return false;
}

// Unbind old shit
$('#double_your_btc_bet_lose').unbind();
$('#double_your_btc_bet_win').unbind();


// Loser
$('#double_your_btc_bet_lose').bind("DOMSubtreeModified", function (event) {
  if ($(event.currentTarget).is(':contains("lose")')) {
    console.log('You LOST! Multiplying your bet and betting again.');

    multiply();

    setTimeout(function () {
      $loButton.trigger('click');
    }, getRandomWait());

    //$loButton.trigger('click');
  }
});


// Winner
$('#double_your_btc_bet_win').bind("DOMSubtreeModified", function (event) {
  if ($(event.currentTarget).is(':contains("win")')) {
    if (stopBeforeRedirect()) {
      return;
    }

    if (iHaveEnoughMoni()) {
      console.log('You WON! But don\'t be greedy. Restarting!');
      reset();

      if (stopped) {
        stopped = false;
        return false;
      }
    }
    else {
      console.log('You WON! Betting again');
    }

    setTimeout(function () {
      $loButton.trigger('click');
    }, getRandomWait());
  }
});
```

**最后，本文仅为技术探讨，千万不要真的拿着这个去“赚钱”。**