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
按下執行購買定存後，先檢查Bank Address、定存金額、期數是否符合規定。
接著會unlock本地賬戶並呼叫purchaseCD函數購買定存。交易結束後會更新賬戶資料並顯示交易成功或失敗。
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
按下執行合約期滿後，會檢查Bank Address並unlock本地賬戶。
接著呼叫completeCD函數執行定存期滿的結算，更新界面顯示定存返還成功或失敗。
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
按下執行提前解約後，會檢查Bank Address並unlock本地賬戶。
接著呼叫terminateCD函數執行提前終止定存合約，更新界面顯示定存返還成功或失敗。
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

