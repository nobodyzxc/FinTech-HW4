/*
comment here
*/

function guard(name, val_string){
  if ($.trim(val_string) == "") {
    alert("請輸入" + name);
    return true;
  }
  if (parseInt(val_string, 10) <= 0) {
    alert(name + "必須大於零");
    return true;
  }
  return false;
}

/*
comment here
*/

// 當按下購買定存按鍵時
purchaseCDButton.on("click", async function() {
  if (bankAddress == "") {
    return;
  }
  if(guard("定存金額", purchaseCDValue.val())) {
    return;
  }
  if(guard("定存期數", purchaseCDPeriods.val())) {
    return;
  }
  // 解鎖
  let unlock = await unlockAccount();
  if (!unlock) {
    return;
  }

  // 更新介面
  waitTransactionStatus();
  // 買定存
  bank.methods
    .purchaseCD(parseInt(purchaseCDPeriods.val(), 10))
    .send({
      from: nowAccount,
      gas: 3400000,
      value: web3.utils.toWei(purchaseCDValue.val(), "ether")
    })
    .on("receipt", function(receipt) {
      log(receipt.events.PurchaseCDEvent.returnValues, "購買定存成功");

      // 觸發更新帳戶資料
      update.trigger("click");

      // 更新介面
      doneTransactionStatus();
    })
    .on("error", function(error) {
      log(error.toString() + "(先前定存已存在)");
      // 更新介面
      doneTransactionStatus();
    });
  bank.events.PurchaseCDEvent().on("data", function(event) {
    log(event, "PurchaseCDEvent");
  });
});

/*
comment here
*/

// 當按下期滿按鍵時
completeCDButton.on("click", async function() {
  if (bankAddress == "") {
    return;
  }

  // 解鎖
  let unlock = await unlockAccount();
  if (!unlock) {
    return;
  }

  // 更新介面
  waitTransactionStatus();
  // 提款
  bank.methods
    .completeCD()
    .send({
      from: nowAccount,
      gas: 3400000
    })
    .on("receipt", function(receipt) {
      log(receipt.events.CompleteCDEvent.returnValues, "定存返還成功");

      // 觸發更新帳戶資料
      update.trigger("click");

      // 更新介面
      doneTransactionStatus();
    })
    .on("error", function(error) {
      log(error.toString() + "(定存不存在)");
      // 更新介面
      doneTransactionStatus();
    });
});

/*
comment here
*/


// 當按下提前解約按鍵時
terminateCDButton.on("click", async function() {
  if (bankAddress == "") {
    return;
  }
  if(guard("完成期數", terminateCDPeriods.val())) {
    return;
  }

  // 解鎖
  let unlock = await unlockAccount();
  if (!unlock) {
    return;
  }

  // 更新介面
  waitTransactionStatus();
  // 提款
  bank.methods
    .terminateCD(parseInt(terminateCDPeriods.val()))
    .send({
      from: nowAccount,
      gas: 3400000
    })
    .on("receipt", function(receipt) {
      log(receipt.events.TerminateCDEvent.returnValues, "提前解約成功");

      // 觸發更新帳戶資料
      update.trigger("click");

      // 更新介面
      doneTransactionStatus();
    })
    .on("error", function(error) {
      log(error.toString() + "(定存不存在或期數超過)");
      // 更新介面
      doneTransactionStatus();
    });
});

