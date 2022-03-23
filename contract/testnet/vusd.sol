// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Exchange 1:1 VUSD:USDC
contract VUSD is ERC20 {
    constructor () ERC20("ViRef USD", "VUSD") {
    }

    bool status = true; 
    address owner = msg.sender;
    address withdrawAddress = msg.sender;
    uint moneyWithdrawed = 0;

    address vrefAddress = address(0);
    address USDC = 0xd4579eC441f296B3795B16eb3D47A0537E9E44D9;

    event buy(address _address, uint _amount);
    event sell(address _address, uint _amount);
    event changestatus(bool _status);
    event changeowner(address _address);

    function buyToken(uint _amount) public {
        require(status, "Contract is maintaining");
        require(_amount > 0);
        require(IERC20(USDC).transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        _mint(msg.sender, _amount);
        emit buy(msg.sender, _amount);
    }

    function sellToken(uint _amount, address _address) public {
        require(status, "Contract is maintaining");
        require(_amount > 0);
        _burn(msg.sender, _amount);
        if ( _address == address(0) ) {
            _address = msg.sender;
        }
        require(IERC20(USDC).transfer(_address, _amount),"Transfer failed");
        emit sell(_address, _amount);
    }

    function withdraw() public {
        require(msg.sender == withdrawAddress, "permission denied");
        require(vrefAddress != address(0), "invalid vrefAddress");
        uint moneyCanWithdraw = VREF(vrefAddress).moneyCanWithdraw();
        require(moneyCanWithdraw > moneyWithdrawed, "no money can withdraw");
        require(IERC20(USDC).transfer(msg.sender, moneyCanWithdraw - moneyWithdrawed),"Transfer failed");
        moneyWithdrawed += moneyCanWithdraw - moneyWithdrawed;
    }
    
    function changeWithdrawAddress(address _address) public {
        require(_address != address(0), "invalid address");
        require(msg.sender == owner,"permission denied");
        withdrawAddress = _address;
    }
    
    function changeStatus(bool _status) public {
        require(msg.sender == owner, "permission denied");
        status = _status;
        emit changestatus(_status);
    }

    function changeOwner(address _address) public {
        require(msg.sender == owner, "permission denied");
        require(_address != address(0), "invalid address");
        owner = _address;
        emit changeowner(_address);
    }

    function updateVREFAddress(address _address) public {
        require(msg.sender == owner, "permission denied");
        require(_address != address(0), "invalid address");
        vrefAddress = _address;
    }
} 

abstract contract VREF {
    function moneyCanWithdraw() public virtual returns(uint);
}
