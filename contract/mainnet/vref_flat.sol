
// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// File: contracts/vref.v2.sol


pragma solidity ^0.8.10;

abstract contract usdc {
    function decimals() external virtual returns (uint256) ;
}

contract VREF is ERC20 {
    constructor() ERC20("Virtual Referral Network", "VREF") {
    }

    address USDC = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d; // 0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48 at ETH
    uint decimalUSDC = 18 - usdc(USDC).decimals() ; // 0 at BSC and 12 at ETH
    bool public status = true; 
    address owner = msg.sender;
    address withdrawAddress = msg.sender;
    uint public _tokenInPool;
    uint public _moneyInPool;
    enum statusEnum { ICO, IDO, subIDO }
    statusEnum public state = statusEnum.ICO;
    uint public currentStep = 0;
    uint public subIDOSold = 0;
    uint[30] icoPrice =[10,20,40,80,160,320,640,1280,2560,5120,10240,20480,40960,81920,163840,327680,655360,1310720,
    2621440,5242880,10485760,20971520,41943040,83886080,167772160,335544320,671088640,1342177280,2684354560,5368709120]; // * 100 already
    uint[30] tokenBeforeICO = [0,353553390593273762200422,603553390593273762200422,780330085889910643300633,905330085889910643300633,
    993718433538229083850739,1056218433538229083850739,1100412607362388304125792,1131662607362388304125792,1153759694274467914263318,
    1169384694274467914263318,1180433237730507719332081,1188245737730507719332081,1193770009458527621866463,1197676259458527621866463,
    1200438395322537573133654,1202391520322537573133654,1203772588254542548767249,1204749150754542548767249,1205439684720545036584047,
    1205927965970545036584047,1206273232953546280492445,1206517373578546280492445,1206690007070046902446645,1206812077382546902446645,
    1206898394128297213423745,1206959429284547213423745,1207002587657422368912294,1207033105235547368912294,1207054684421984946656569];
    uint moneyWithdrawed = 0;
    
    event buy(address _address, uint _amount);
    event sell(address _address, uint _amount);
    event changestatus(bool _status);
    event withdraw(uint _amount);

    function buyToken(uint amount, uint expected) public {
        require(status, "Contract is maintaining");
        require(amount > 0, "Please input amount greater than 0");
        require(IERC20(USDC).transferFrom(msg.sender, address(this), amount), "transfer USDC failed");

        uint nextBreak;
        uint assumingToken;
        uint buyNowCost = 0;
        uint buyNowToken;

        amount = amount * 10**decimalUSDC; // Base on USDC's decimal, convert to 18
        uint tokenMint = 0;
        uint tokenTransferForUser = 0;
        uint currentMoney = _moneyInPool;
        uint moneyLeft = amount;

        while (moneyLeft > 0) {
            if (state == statusEnum.ICO) {
                nextBreak = (tokenBeforeICO[currentStep] + 5 * 10**5 * 10 **18) - _tokenInPool;
                assumingToken = moneyLeft * 100/icoPrice[currentStep];
            } else {
                if (currentStep==29 && state==statusEnum.IDO) { // nomore ICO
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

            if (assumingToken>=nextBreak) {
                if (state == statusEnum.ICO) {
                    state = statusEnum.IDO;
                } else {
                    if (state == statusEnum.IDO) {
                        currentStep += 1;
                    }
                    state = statusEnum.ICO;
                    subIDOSold = 0;
                }
            } else if ( state==statusEnum.subIDO ) {
                subIDOSold -= buyNowToken;
            }
            moneyLeft = moneyLeft - buyNowCost;
        }
        require(tokenTransferForUser+tokenMint >= expected, "price slippage detected");
        require(_moneyInPool-currentMoney == amount, "something wrong with money");

        if (tokenMint > 0)  {
            _mint(address(this), tokenMint*2);
        }
        _transfer(address(this), msg.sender, tokenMint + tokenTransferForUser);

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
        require(transfer(address(this), amount), "transfer VREF failed");
        require(IERC20(USDC).transfer(msg.sender, receivedMoney/10**decimalUSDC), "transfer USDC failed");
        _moneyInPool -= receivedMoney;
        _tokenInPool += amount;
        if (state == statusEnum.ICO) {
            state = statusEnum.subIDO;
        }
        if (state == statusEnum.subIDO) {
            subIDOSold +=amount;
        }
        require(_tokenInPool<=balanceOf(address(this)), "something wrong with _tokenInPool");

        emit sell(msg.sender, amount);
    }

    function changeOwner(address _address) public {
        require(_address != address(0), "invalid address");
        require(msg.sender == owner, "permission denied");
        owner = _address;
    }
    
    function changeWithdrawAddress(address _address) public {
        require(_address != address(0), "invalid address");
        require(msg.sender == owner, "permission denied");
        withdrawAddress = _address;
    }

    function changeStatus(bool _status) public {
        require(msg.sender == owner, "permission denied");
        status = _status;
        emit changestatus(_status);
    }

    function collectWastedToken() public {
        require(msg.sender == withdrawAddress, "permission denied");
        uint wastedToken = balanceOf(address(this)) - _tokenInPool;
        require(wastedToken>0, "no token wasted");
        _transfer(address(this), withdrawAddress, wastedToken);
    }

    function withdrawMoney() public {
        require(msg.sender == withdrawAddress, "permission denied");

        uint realMoneyInPool = IERC20(USDC).balanceOf(address(this)) * 10**decimalUSDC; // USDC uses 6 decimal places of precision, convert to 18
        uint moneyCanWithdraw = _tokenInPool*_moneyInPool/totalSupply() + realMoneyInPool+moneyWithdrawed-_moneyInPool;
        // _tokenInPool*_moneyInPool/totalSupply() : money unused base on AMM algorithm
        // most of time, realMoneyInPool = _moneyInPool-moneyWithdrawed , sometime, someone may send USDC to this address without any further action

        uint withdrawThisTime = (moneyCanWithdraw - moneyWithdrawed) / 10**decimalUSDC;
        require(withdrawThisTime > 0, "no money can withdraw");
        require(IERC20(USDC).transfer(withdrawAddress, withdrawThisTime), "Transfer failed");
        moneyWithdrawed += withdrawThisTime * 10**decimalUSDC;
        emit withdraw(withdrawThisTime);
    }
}