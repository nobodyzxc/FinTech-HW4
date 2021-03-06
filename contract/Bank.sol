pragma solidity ^0.4.23;

contract Bank {
	// 此合約的擁有者
    address private owner;

	// 儲存所有會員的餘額
    mapping (address => uint256) private balance;

    struct certificate_deposit{
        uint256 value;
        uint256 periods;
    }

    mapping (address => certificate_deposit) cd;

	// 事件們，用於通知前端 web3.js
    event DepositEvent(address indexed from, uint256 value, uint256 timestamp);
    event WithdrawEvent(address indexed from, uint256 value, uint256 timestamp);
    event TransferEvent(address indexed from, address indexed to, uint256 value, uint256 timestamp);

    event PurchaseCDEvent(address indexed from, uint256 value, uint256 periods, uint256 timestamp);
    event TerminateCDEvent(address indexed from, uint256 value, uint256 periods, uint256 timestamp);
    event CompleteCDEvent(address indexed from, uint256 value, uint256 periods, uint256 timestamp);

    event DuplicateCD(address indexed from, uint256 timestamp);

    modifier isOwner() {
        require(owner == msg.sender, "you are not owner");
        _;
    }

	// 建構子
    constructor() public payable {
        owner = msg.sender;
    }

	// 存錢
    function deposit() public payable {
        balance[msg.sender] += msg.value;

        emit DepositEvent(msg.sender, msg.value, now);
    }

	// 提錢
    function withdraw(uint256 etherValue) public {
        uint256 weiValue = etherValue * 1 ether;

        require(balance[msg.sender] >= weiValue, "your balances are not enough");

        msg.sender.transfer(weiValue);

        balance[msg.sender] -= weiValue;

        emit WithdrawEvent(msg.sender, etherValue, now);
    }

	// 轉帳
    function transfer(address to, uint256 etherValue) public {
        uint256 weiValue = etherValue * 1 ether;

        require(balance[msg.sender] >= weiValue, "your balances are not enough");

        balance[msg.sender] -= weiValue;
        balance[to] += weiValue;

        emit TransferEvent(msg.sender, to, etherValue, now);
    }

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

    function calcCD(uint256 value, uint256 periods) private pure returns (uint256) {
        return value + value * periods / 100;
    }

    function getCD() public view returns (uint256, uint256) {
        return (cd[msg.sender].value,
                cd[msg.sender].periods);
    }

	// 檢查銀行帳戶餘額
    function getBankBalance() public view returns (uint256) {
        return balance[msg.sender];
    }

    function kill() public isOwner {
        selfdestruct(owner);
    }
}
