pragma solidity 0.5.17;

import "@openzeppelin/contracts/math/SafeMath.sol";
// import "./SafeMath.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "./IERC20.sol";

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
// import "./SafeERC20.sol";

import "@chainlink/contracts/src/v0.5/interfaces/AggregatorInterface.sol";
// import "./AggregatorInterface.sol";

contract EthBridge {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    mapping(bytes32 => bool) public usedEvents_;
    
    struct ObjERC {
        address addrERC;
        address addrOracle;
    }
    mapping(string => ObjERC) public listERC;
    
    
    mapping(address => uint256) public wards;
    address public owner;
    uint16 public threshold;
    mapping(bytes32 => uint16) confirmations;

    event Locked(
        string  symbol,
        address indexed sender,
        uint256 amount,
        uint256 price,
        uint256 amountUSD,
        address recipient
    );

    event Unlocked(
        string  symbol,
        uint256 amountUSD,
        uint256 amountToken,
        uint256 priceToken,
        address recipient,
        bytes32 receiptId
    );
    
    event WithdrawETH(
        address indexed _owner,
        uint256 amount,
        string  msg
    );
    
    event WithdrawToken(
        address addrTokenERC,
        address indexed _owner,
        uint256 amount,
        string  msg
    );
    
    //MODIFIER
    modifier auth {
        require(wards[msg.sender] == 1, "EthManager/not-authorized");
        _;
    }

    /**
     * @dev constructor
     */
    constructor() public {
        owner = msg.sender;
        wards[owner] = 1;
        threshold = 1;
        listERC["ETH"] =  ObjERC({ addrERC: address(0x0000000000000000000000000000000000000001), addrOracle: address(0x30B5068156688f818cEa0874B580206dFe081a03)});
        listERC["DAI"] =  ObjERC({ addrERC: address(0xaD6D458402F60fD3Bd25163575031ACDce07538D), addrOracle: address(0xaF540Ca83c7da3181778e3D1E11A6137e7e0085B)});
        listERC["LINK"] = ObjERC({ addrERC: address(0xb4f7332ed719Eb4839f091EDDB2A3bA309739521), addrOracle:address(0x40c9885aa8213B40e3E8a0a9aaE69d4fb5915a3A)});
        listERC["KNC"] =  ObjERC({ addrERC: address(0x4E470dc7321E84CA96FcAEDD0C8aBCebbAEB68C6), addrOracle: address(0x6701C0057DAB793F88a30b8d40dD31f3a7bC6B87)});
    }
    
    function rely(address guy) external auth {
        wards[guy] = 1;
    }

    function deny(address guy) external auth {
        require(guy != owner, "EthManager/cannot deny the owner");
        wards[guy] = 0;
    }
    
    /**
     * @dev change oracle in listERC
     * @param _symbol symbol of token
     * @param _addrERC address of contract ERC in Ethereum
     * @param _oracleAddr oracle address of token in chainlink
    */
    function changeOracle(string memory _symbol, address _addrERC, address _oracleAddr) public auth {
        require(keccak256(abi.encodePacked(_symbol)) != keccak256(abi.encodePacked("")),"symbol cannot be left blank");
        require(_oracleAddr != address(0),"address of oracle is a zero address");
        listERC[_symbol] = ObjERC({ addrERC: _addrERC, addrOracle: _oracleAddr });
    }
    
    
    /**
     * @dev change threshold requirement
     * @param newTheshold new threshold requirement
    */
    function changeThreshold(uint16 newTheshold) public {
        require(
            msg.sender == owner,
            "EthManager/only owner can change threshold"
        );
        threshold = newTheshold;
    }
    
    /**
    * Returns the latest price
    */
    function getLatestPrice(address _tokenERC) public view returns (int) {
        AggregatorInterface priceFeed = AggregatorInterface(_tokenERC);
        int price = priceFeed.latestAnswer();
        return price;
    }
    
    /**
     * @dev lock ETH to be transfer ONE to recipient on Harmony chain
     * @param amount amount of tokens to lock
     * @param recipient recipient address on the Ethereum chain
     */
    function lockEth(
        uint256 amount,
        address recipient
    ) public payable {
        require(
            recipient != address(0),
            "EthManager/recipient is a zero address"
        );
        require(amount > 0, "EthManager/zero token locked");
        require(amount == msg.value, "amount and msg.value different");
        uint256 _price = uint256(getLatestPrice(listERC["ETH"].addrOracle));
        uint256 _amountUSD = _price * msg.value;
        emit Locked("ETH", msg.sender,  msg.value, _price, _amountUSD , recipient);
    }
    
    /**
     * @dev lock tokens to be transfer ONE to recipient on harmony chain
     * @param symbol is the symbol of the contract on Ethereum
     * @param amount amount of tokens to lock
     * @param recipient recipient address on the harmony chain
     */
    function lockToken(
        string memory symbol,
        uint256 amount,
        address recipient
    ) public {
        require(listERC[symbol].addrERC != address(0), "symbol ERC are not currently supported");
        require(keccak256(abi.encodePacked(symbol)) != keccak256(abi.encodePacked("ETH")) , "This function is not used for ETH");
        require(
            recipient != address(0),
            "EthManager/recipient is a zero address"
        );
        require(amount > 0, "EthManager/zero token locked");
        
        IERC20 ethToken = IERC20(listERC[symbol].addrERC);
        uint256 _balanceBefore = ethToken.balanceOf(msg.sender);
        ethToken.transferFrom(msg.sender, address(this), amount);
        uint256 _balanceAfter = ethToken.balanceOf(msg.sender);
        uint256 _actualAmount = _balanceBefore.sub(_balanceAfter);
        uint256 _price = uint256(getLatestPrice(listERC[symbol].addrOracle));
        uint256 _amountUSD = _price * _actualAmount;
        emit Locked(symbol, msg.sender, _actualAmount, _price, _amountUSD , recipient);
    }


    /**
     * @dev lock tokens for a user address to be minted on harmony chain
     * @param symbol is the symbol of the contract on Ethereum
     * @param userAddr is token holder address
     * @param amount amount of tokens to lock
     * @param recipient recipient address on the harmony chain
     */
    function lockTokenFor(
        string memory symbol,
        address userAddr,
        uint256 amount,
        address recipient
    ) public auth {
        require(listERC[symbol].addrERC != address(0), "symbol ERC are not currently supported");
        require(keccak256(abi.encodePacked(symbol)) != keccak256(abi.encodePacked("ETH")) , "This function is not used for ETH");
        require(
            recipient != address(0),
            "EthManager/recipient is a zero address"
        );
        require(amount > 0, "EthManager/zero token locked");

        IERC20 ethToken = IERC20(listERC[symbol].addrERC);
        uint256 _balanceBefore = ethToken.balanceOf(userAddr);
        ethToken.transferFrom(userAddr, address(this), amount);
        uint256 _balanceAfter = ethToken.balanceOf(userAddr);
        uint256 _actualAmount = _balanceBefore.sub(_balanceAfter);
        uint256 _price = uint256(getLatestPrice(listERC[symbol].addrOracle));
        uint256 _amountUSD = _price * _actualAmount;
        emit Locked(symbol, msg.sender, _actualAmount, _price, _amountUSD , recipient);
    }
    
    
    /**
     * @dev unlock tokens after burning them on harmony chain
     * @param symbol is the symbol of the contract on Ethereum
     * @param amountUSD amount USD will be unlocked to token ERC
     * @param recipient recipient of the unlock tokens
     * @param receiptId transaction hash of the locktoken event on harmony chain
     */
    function unlockToken(
        string memory symbol,
        uint256 amountUSD,
        address recipient,
        bytes32 receiptId
    ) public auth {
        require(
            !usedEvents_[receiptId],
            "EthManager/zero token unlocked"
        );
        confirmations[receiptId] = confirmations[receiptId] + 1;
        if (confirmations[receiptId] < threshold) {
            return;
        }
        IERC20 ethToken = IERC20(listERC[symbol].addrERC);
        usedEvents_[receiptId] = true;
        uint256 _priceToken = uint256(getLatestPrice(listERC[symbol].addrOracle));
        uint256 _amountToken = amountUSD.div(_priceToken);
        ethToken.transfer(recipient, _amountToken);
        emit Unlocked(symbol, amountUSD , _amountToken, _priceToken, recipient, receiptId);
        // delete confirmations entry for receiptId
        delete confirmations[receiptId];
    }
    
    
    /**
     * @dev unlock ETH after lockOne them on Harmony chain
     * @param amountUSD amount USD will be unlocked to ETH
     * @param recipient recipient of the unlock tokens
     * @param receiptId transaction hash of the locktoken event on harmony chain
     */
    function unlockEth(
        uint256 amountUSD,
        address payable recipient,
        bytes32 receiptId
    ) public auth {
        require(
            !usedEvents_[receiptId],
            "EthManager/zero token unlocked"
        );
        confirmations[receiptId] = confirmations[receiptId] + 1;
        if (confirmations[receiptId] < threshold) {
            return;
        }
        usedEvents_[receiptId] = true;
        uint256 _priceETH = uint256(getLatestPrice(listERC["ETH"].addrOracle));
        uint256 _amountETH = amountUSD.div(_priceETH);
        recipient.transfer(_amountETH);
        emit Unlocked("ETH", amountUSD , _amountETH , _priceETH, recipient, receiptId);
        // delete confirmations entry for receiptId
        delete confirmations[receiptId];
    }
    
    
    /**
    * Returns the balance token of msg.sender 
    */
    function checkMyBalanceOfToken( address _addrToken ) public view returns(uint256) {
        IERC20 ethToken = IERC20(_addrToken);
        uint256 balance = ethToken.balanceOf(msg.sender);
        return balance;
    }
    
    /**
    * Returns the balance token of contract 
    */
    function checkContractBalanceOfToken( address _addrToken ) public view returns(uint256) {
        IERC20 ethToken = IERC20(_addrToken);
        uint256 balance = ethToken.balanceOf(address(this));
        return balance;
    }
    
    /**
     * get balance ETH
    */
    function getBalanceETH() public view returns(uint256) {
        return address(this).balance;
    }
    
    
    
    /** Function withdraw ETH to account Manager
    */
    function withdraw(address payable _owner) public auth {
        uint256 balanceBefore = address(this).balance;
        _owner.transfer(address(this).balance);
        emit WithdrawETH(_owner, balanceBefore, "Withdraw ETH");
    }
    
    
    /** Function withdraw Token to account Manager
     * @param addrTokenERC is the Ethereum token contract address
    */
    function withdrawToken(address addrTokenERC,address _owner, uint256 amount) public auth {
        require(amount > 0, "EthManager/zero token locked");
        IERC20 ethToken = IERC20(addrTokenERC);
        ethToken.transfer(_owner, amount);
        emit WithdrawToken(addrTokenERC ,_owner, amount, "withdraw Token");
    }
}
