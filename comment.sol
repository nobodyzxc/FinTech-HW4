/*
   purchaseCD 這個函數可執行購買定存，首先以 require 規定 msg.sender 之定存帳戶為零，表示此人
   原本沒有定存帳戶。然後再以 require 要求其輸入的定存期數要大於零。接著把 msg.sender 的存款
   金額和設定定存期數存到 cd 裡，再以 emit 告知外界定存購買完成
 */

// 購買定存
function purchaseCD(uint256 periods) public payable {

    require(cd[msg.sender].value == 0,
            "previous certificate deposit existed");
    require(periods > 0, "periods must more than zero");

    cd[msg.sender] = certificate_deposit({
        value: msg.value, periods: periods
    });

    emit PurchaseCDEvent(msg.sender,
                         msg.value,
                         periods,
                         now);
}


/*
   terminateCD 這個函數用來執行提前終止定存合約。首先以 require 規定 msg.sender 的帳戶餘額不為零，否則會警告該
   定存帳戶不存在。之後以 require 要求提前解約的期數要小於等於之前買的期數，避免其實 msg.sender 宣稱是提前解約，
   其實已超過時間。然後把 msg.sender 的本金和本金加利息分別存到 value 和 withProfit 中。之後用 delete 清空 msg.sender
   購買定存的紀錄。之後的 msg.sender.transfer 便是把定存本金轉到 msg.sender 的帳戶中。最後再以 emit 告知外界提前終止定存
 */

// 提前中止定存合約
function terminateCD(uint256 periods) public {

    require(cd[msg.sender].value != 0,
            "certificate deposit no exist");
    require(periods <= cd[msg.sender].periods,
            "periods over deposit's periods");

    uint256 value = cd[msg.sender].value;
    uint256 withProfit = calcCD(value, periods);

    delete cd[msg.sender];
    // delete first prevent reentry attack(?)

    msg.sender.transfer(value);
    // transfer the origin value instead of (profit + origin value)

    emit TerminateCDEvent(msg.sender,
                          withProfit,
                          periods,
                          now);
}

/*
   completeCD 用以執行定存期滿的結算。同樣以 require 要求定存帳戶餘額不為零，然後分別將該定存戶的
   本金、期數、本金加利息存到 value、periods、withProfit 裡。之後用 delete 清空 msg.sender
   購買定存的紀錄。之後的 msg.sender.transfer 便是把定存本金轉到 msg.sender 的帳戶中。再以
   emit 告知外界定存期滿。
 */

// 定存期滿
function completeCD() public {

    require(cd[msg.sender].value != 0,
            "certificate deposit no exist");

    uint256 value = cd[msg.sender].value;
    uint256 periods = cd[msg.sender].periods;
    uint256 withProfit = calcCD(value, periods);

    delete cd[msg.sender];
    // delete first prevent reentry attack(?)

    msg.sender.transfer(value);
    // transfer the origin value instead of (profit + origin value)

    emit CompleteCDEvent(msg.sender,
                         withProfit,
                         periods,
                         now);
}

/*
   calcCD 利用 value（本金）和 periods（期數）計算總共的本金加利息為多少
 */

// 計算回饋定存金額
function calcCD(uint256 value, uint256 periods) private pure returns (uint256) {
    return value + value * periods / 100;
}

/*
   getCD 用以了解 msg.sender 之本金和定存期數
 */

// 取得定存狀態
function getCD() public view returns (uint256, uint256) {
    return (cd[msg.sender].value,
            cd[msg.sender].periods);
}
