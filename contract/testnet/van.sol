// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract VAN is ERC20 {
    constructor() ERC20("Virtual Affiliate Network", "VAN") {
    }

    address VUSD = 0xCD38FD5EdDe2E0009BF7eC41c256985B820ea1C8;
    bool public status = true; 
    address owner = msg.sender;
    uint public _tokenInPool;
    uint public _moneyInPool;
    enum statusEnum { ICO, IDO, subIDO }
    statusEnum public state = statusEnum.ICO;
    uint public currentStep = 0;
    uint subIDOSold = 0;
    uint[29] icoPrice =[10,20,40,80,160,320,640,1280,2560,5120,10240,20480,40960,81920,163840,
    327680,655360,1310720,2621440,5242880,10485760,20971520,41943040,83886080,167772160,335544320,671088640,1342177280,2684354560];
    uint[29] tokenBeforeICO = [0,353553390593273762200422,603553390593273762200422,780330085889910643300633,905330085889910643300633,
    993718433538229083850739,1056218433538229083850739,1100412607362388304125792,1131662607362388304125792,1153759694274467914263318,
    1169384694274467914263318,1180433237730507719332081,1188245737730507719332081,1193770009458527621866463,1197676259458527621866463,
    1200438395322537573133654,1202391520322537573133654,1203772588254542548767249,1204749150754542548767249,1205439684720545036584047,
    1205927965970545036584047,1206273232953546280492445,1206517373578546280492445,1206690007070046902446645,1206812077382546902446645,
    1206898394128297213423745,1206959429284547213423745,1207002587657422368912294,1207033105235547368912294];
    
    event buy(address _address, uint _amount);
    event sell(address _address, uint _amount);
    event changestatus(bool _status);
    event changeowner(address _address);

    function checkVUSD() public view returns(uint) {
        return IERC20(VUSD).balanceOf(address(this)) * 10**12;
    }

    function buyToken(uint amount, uint expected) public {
        require(status, "Contract is maintaining");
        require(amount > 0, "Please input amount greater than 0");

        uint nextBreak;
        uint assumingToken;
        uint buyNowCost = 0;
        uint buyNowToken;

        amount = amount * 10**12; // VUSD uses 6 decimal places of precision, convert to 18
        uint tokenMint = 0;
        uint tokenTransferForUser = 0;
        uint currentMoney = _moneyInPool;
        uint moneyLeft = amount;

        while (moneyLeft  >  0) {
            if (state == statusEnum.ICO) {
                nextBreak = (tokenBeforeICO[currentStep] + 5 * 10**5 * 10 **18) - _tokenInPool;
                assumingToken = moneyLeft * 100/icoPrice[currentStep];
            } else {
                if (currentStep==28 && state==statusEnum.IDO) { // nomore ICO
                    nextBreak = 2**256 - 1; // MAX_INT
                } else {
                    nextBreak = state == statusEnum.subIDO ? subIDOSold : (_tokenInPool - tokenBeforeICO[currentStep + 1]);
                }
                assumingToken = _tokenInPool - (_tokenInPool * _moneyInPool / (_moneyInPool + moneyLeft));
            }

            buyNowToken = nextBreak<assumingToken ? nextBreak : assumingToken;
            buyNowCost = moneyLeft;

            if (assumingToken>nextBreak) {
                buyNowCost = state == statusEnum.ICO ?
                                    buyNowToken * icoPrice[currentStep]/100 :
                                    ((_tokenInPool * _moneyInPool)/(_tokenInPool - buyNowToken) - _moneyInPool);
            }
            _moneyInPool += buyNowCost;

            if (state == statusEnum.ICO) {
                tokenMint += buyNowToken;
                _tokenInPool += buyNowToken;
            } else {
                tokenTransferForUser += buyNowToken;
                _tokenInPool -= buyNowToken;
            }

            if (assumingToken >= nextBreak) {
                if (state == statusEnum.ICO) {
                    state = statusEnum.IDO;
                } else {
                    if (state == statusEnum.IDO) {
                        currentStep += 1;
                    }
                    state = statusEnum.ICO;
                    subIDOSold = 0;
                }
            }
            moneyLeft = moneyLeft - buyNowCost;
        }
        require(tokenTransferForUser+tokenMint >= expected, "price slippage detected");
        require(_moneyInPool-currentMoney == amount, "something wrong with money");

        require(IERC20(VUSD).transferFrom(msg.sender, address(this), amount), "transfer VUSD failed");
        if (tokenMint > 0)  {
            _mint(address(this), tokenMint*2);
        }
        _transfer(address(this), msg.sender, tokenMint + tokenTransferForUser);

        require(_moneyInPool<=checkVUSD(), "something wrong with _moneyInPool");
        require(_tokenInPool<=balanceOf(address(this)), "something wrong with _tokenInPool");
        emit buy(msg.sender, amount);
    }

    function sellToken(uint amount, uint expected) public {
        require(status, "Contract is maintaining");
        require(amount > 0, "invalid amount");
        uint currentMoney = _moneyInPool;
        uint moneyInpool = (_tokenInPool * _moneyInPool) / (_tokenInPool + amount);
        uint receivedMoney = currentMoney - moneyInpool;
        require(receivedMoney >= expected, "price slippage detected");
        require(transfer(address(this), amount), "transfer VAN failed");
        require(IERC20(VUSD).transfer(msg.sender, receivedMoney/10**12), "transfer VUSD failed");
        _moneyInPool -= receivedMoney;
        _tokenInPool += amount;
        if (state == statusEnum.ICO) {
            state = statusEnum.subIDO;
        }
        if (state == statusEnum.subIDO) {
            subIDOSold +=amount;
        }
        require(_moneyInPool<=checkVUSD(), "something wrong with _moneyInPool");
        require(_tokenInPool<=balanceOf(address(this)), "something wrong with _tokenInPool");

        emit sell(msg.sender, amount);
    }

    function changeOwner(address _address) public {
        require(msg.sender == owner, "permission denied");
        require(_address != address(0), "invalid address");
        owner = _address;
        emit changeowner(_address);
    }

    function changeStatus(bool _status) public {
        require(msg.sender == owner, "permission denied");
        status = _status;
        emit changestatus(_status);
    }

    function burnToken() public {
        require(msg.sender == owner, "permission denied");
        require(balanceOf(address(this))>_tokenInPool, "no token need to burn");
        _burn(address(this), balanceOf(address(this))-_tokenInPool);
    }

    function moneyCanWithdraw() public view returns(uint){
        return _tokenInPool * _moneyInPool / totalSupply();
    }
}