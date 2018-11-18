/*
comment here
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
comment here
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
comment here
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
comment here
*/

// 計算回饋定存金額
function calcCD(uint256 value, uint256 periods) private pure returns (uint256) {
    return value + value * periods / 100;
}

/*
comment here
*/

// 取得定存狀態
function getCD() public view returns (uint256, uint256) {
    return (cd[msg.sender].value,
            cd[msg.sender].periods);
}
