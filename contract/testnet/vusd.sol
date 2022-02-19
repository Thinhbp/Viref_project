// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Exchange 1:1 VUSD:USDC
contract VUSD is ERC20 {
    constructor () ERC20("ViNet USD", "VUSD") {
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }
    
    bool status = true; 
    address owner = msg.sender;
    address withdrawAddress = msg.sender;
    uint moneyWithdrawed = 0;

    address vanAddress = address(0);
    address USDC = 0x38558FB189f9fB0a6B455064477627Fdbe3d0f1c;

    event buy(address _address, uint _amount);
    event sell(address _address, uint _amount);
    event changestatus(bool _status);
    event changeowner(address _address);

    function buyToken(uint _amount) public {
        require(status, "Contract is maintaining");
        require(_amount > 0);
        IERC20(USDC).transferFrom(msg.sender, address(this), _amount);
        _mint(msg.sender, _amount);
        emit buy(msg.sender, _amount);
    }

    function sellToken(uint _amount) public {
        require(status, "Contract is maintaining");
        require(_amount > 0);
        _burn(msg.sender, _amount);
        IERC20(USDC).transfer(msg.sender, _amount);
        emit sell(msg.sender, _amount);
    }

    function withdraw() public {
        require(msg.sender == withdrawAddress, "permission denied");
        require(vanAddress != address(0), "invalid vanAddress");
        uint moneyCanWithdraw = VAN(vanAddress).moneyCanWithdraw();
        require(moneyCanWithdraw > moneyWithdrawed, "no money can withdraw");
        IERC20(USDC).transfer(msg.sender, moneyCanWithdraw - moneyWithdrawed);
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

    function updateVANAddress(address _address) public {
        require(msg.sender == owner, "permission denied");
        require(_address != address(0), "invalid address");
        vanAddress = _address;
    }
} 

abstract contract VAN {
    function moneyCanWithdraw() public virtual returns(uint);
}
