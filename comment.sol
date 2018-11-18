/*
purchaseCD這個函數可執行購買定存，首先以require規定msg.sender之定存帳戶為零，表示此人
原本沒有定存帳戶。然後再以require要求其輸入的定存期數要大於零。接著把msg.sender的存款
金額和設定定存期數存到cd裡，再以emit告知外界定存購買完成
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
                                 msg.value, periods,
                                 now);
}


/*
terminateCD這個函數用來執行提前終止定存合約。首先以require規定msg.sender的帳戶餘額不為零，否則會警告該定存帳戶不存在。
之後以require要求提前解約的期數要小於等於之前買的期數，避免其實msg.sender宣稱是提前解約，其實已超過時間。
之後用delete清空msg.sender購買定存的紀錄。之後的msg.sender.transfer便是把定存本金轉到msg.sender的帳戶中。
最後再以emit告知外界提前終止定存
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
completeCD用以執行定存期滿的結算。同樣以require要求定存帳戶餘額不為零，然後分別將該定存戶的
本金、期數、本金加利息存到value、periods、withProfit裡。再以emit告知外界定存期滿。
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
calcCD利用value(本金)和periods(期數)計算總共的本金加利息為多少
*/

// 計算回饋定存金額
function calcCD(uint256 value, uint256 periods) private pure returns (uint256) {
    return value + value * periods / 100;
}

/*
getCD用以了解msg.sender之本金和定存期數
*/

// 取得定存狀態
function getCD() public view returns (uint256, uint256) {
    return (cd[msg.sender].value,
            cd[msg.sender].periods);
}
