pragma solidity ^0.5.0;

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

    event LockedETH(
        address indexed sender,
        uint256 amount,
        uint256 price,
        uint256 result,
        address recipient
    );

    event UnlockedETH(
        uint256 amount,
        uint256 price,
        uint256 result,
        address recipient,
        bytes32 receiptId
    );

    event Locked(
        address indexed addrTokenERC,
        address indexed sender,
        uint256 amount,
        uint256 price,
        uint256 result,
        address recipient
    );

    event Unlocked(
        address indexed addrTokenERC,
        uint256 amount,
        uint256 price,
        uint256 result,
        address recipient,
        bytes32 receiptId
    );

    event WithdrawETH(address indexed _owner, uint256 amount, string msg);

    event WithdrawToken(
        address addrTokenERC,
        address indexed _owner,
        uint256 amount,
        string msg
    );

    mapping(address => uint256) public wards;

    function rely(address guy) external auth {
        wards[guy] = 1;
    }

    function deny(address guy) external auth {
        require(guy != owner, "EthManager/cannot deny the owner");
        wards[guy] = 0;
    }

    //MODIFIER
    modifier auth {
        require(wards[msg.sender] == 1, "EthManager/not-authorized");
        _;
    }

    address public owner;

    uint16 public threshold;
    mapping(bytes32 => uint16) confirmations;

    /**
     * @dev constructor
     */
    constructor() public {
        owner = msg.sender;
        wards[owner] = 1;
        threshold = 1;
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
    function getLatestPrice(address _tokenERC) public view returns (int256) {
        AggregatorInterface priceFeed = AggregatorInterface(_tokenERC);
        int256 price = priceFeed.latestAnswer();
        return price;
    }

    /**
     * @dev lock ETH to be transfer ONE to recipient on Harmony chain
     * @param oracleAddr is address of oracle token in harmony
     * @param amount amount of tokens to lock
     * @param recipient recipient address on the ethereum chain
     */
    function lockEth(
        address oracleAddr,
        uint256 amount,
        address recipient
    ) public payable {
        require(
            recipient != address(0),
            "EthManager/recipient is a zero address"
        );
        require(amount > 0, "EthManager/zero token locked");
        require(amount == msg.value, "amount and msg.value different");
        uint256 _price = uint256(getLatestPrice(oracleAddr));
        uint256 _result = _price * msg.value;
        emit LockedETH(msg.sender, msg.value, _price, _result, recipient);
    }

    /**
     * @dev lock tokens to be transfer ONE to recipient on harmony chain
     * @param addrTokenERC is the ethereum token contract address
     * @param oracleAddr is address of oracle token in ethereum
     * @param amount amount of tokens to lock
     * @param recipient recipient address on the harmony chain
     */
    function lockToken(
        address addrTokenERC,
        address oracleAddr,
        uint256 amount,
        address recipient
    ) public {
        require(
            recipient != address(0),
            "EthManager/recipient is a zero address"
        );
        require(amount > 0, "EthManager/zero token locked");
        IERC20 ethToken = IERC20(addrTokenERC);
        uint256 _balanceBefore = ethToken.balanceOf(msg.sender);
        ethToken.transferFrom(msg.sender, address(this), amount);
        uint256 _balanceAfter = ethToken.balanceOf(msg.sender);
        uint256 _actualAmount = _balanceBefore.sub(_balanceAfter);
        uint256 _price = uint256(getLatestPrice(oracleAddr));
        uint256 _result = _price * _actualAmount;
        emit Locked(
            addrTokenERC,
            msg.sender,
            _actualAmount,
            _price,
            _result,
            recipient
        );
    }

    /**
     * @dev lock tokens for a user address to be minted on harmony chain
     * @param addrTokenERC is the ethereum token contract address
     * @param oracleAddr is address of oracle token in ethereum
     * @param userAddr is token holder address
     * @param amount amount of tokens to lock
     * @param recipient recipient address on the harmony chain
     */
    function lockTokenFor(
        address addrTokenERC,
        address oracleAddr,
        address userAddr,
        uint256 amount,
        address recipient
    ) public auth {
        require(
            recipient != address(0),
            "EthManager/recipient is a zero address"
        );
        require(amount > 0, "EthManager/zero token locked");
        IERC20 ethToken = IERC20(addrTokenERC);
        uint256 _balanceBefore = ethToken.balanceOf(userAddr);
        ethToken.transferFrom(userAddr, address(this), amount);
        uint256 _balanceAfter = ethToken.balanceOf(userAddr);
        uint256 _actualAmount = _balanceBefore.sub(_balanceAfter);
        uint256 _price = uint256(getLatestPrice(oracleAddr));
        uint256 _result = _price * _actualAmount;
        emit Locked(
            addrTokenERC,
            userAddr,
            _actualAmount,
            _price,
            _result,
            recipient
        );
    }

    /**
     * @dev unlock tokens after burning them on harmony chain
     * @param addrTokenERC is the ethereum token contract address
     * @param amount amount of unlock tokens
     * @param recipient recipient of the unlock tokens
     * @param receiptId transaction hash of the locktoken event on harmony chain
     */
    function unlockToken(
        address addrTokenERC,
        uint256 amount,
        uint256 price,
        address recipient,
        bytes32 receiptId
    ) public auth {
        require(!usedEvents_[receiptId], "EthManager/zero token unlocked");
        confirmations[receiptId] = confirmations[receiptId] + 1;
        if (confirmations[receiptId] < threshold) {
            return;
        }
        IERC20 ethToken = IERC20(addrTokenERC);
        usedEvents_[receiptId] = true;
        ethToken.transfer(recipient, amount);
        uint256 _result = price * amount;
        emit Unlocked(
            addrTokenERC,
            amount,
            price,
            _result,
            recipient,
            receiptId
        );
        // delete confirmations entry for receiptId
        delete confirmations[receiptId];
    }

    /**
     * @dev unlock ETH after lockOne them on Harmony chain
     * @param amount amount of unlock tokens
     * @param recipient recipient of the unlock tokens
     * @param receiptId transaction hash of the locktoken event on harmony chain
     */
    function unlockEth(
        uint256 amount,
        uint256 price,
        address payable recipient,
        bytes32 receiptId
    ) public auth {
        require(!usedEvents_[receiptId], "EthManager/zero token unlocked");
        confirmations[receiptId] = confirmations[receiptId] + 1;
        if (confirmations[receiptId] < threshold) {
            return;
        }
        usedEvents_[receiptId] = true;
        recipient.transfer(amount);
        uint256 _result = price * amount;
        emit UnlockedETH(amount, price, _result, recipient, receiptId);
        // delete confirmations entry for receiptId
        delete confirmations[receiptId];
    }

    /**
     * Returns the balance token of msg.sender
     */
    function checkMyBalanceOfToken(address _addrToken)
        public
        view
        returns (uint256)
    {
        IERC20 ethToken = IERC20(_addrToken);
        uint256 balance = ethToken.balanceOf(msg.sender);
        return balance;
    }

    /**
     * Returns the balance token of contract
     */
    function checkContractBalanceOfToken(address _addrToken)
        public
        view
        returns (uint256)
    {
        IERC20 ethToken = IERC20(_addrToken);
        uint256 balance = ethToken.balanceOf(address(this));
        return balance;
    }

    /**
     * get balance ETH
     */
    function getBalanceETH() public view returns (uint256) {
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
     * @param addrTokenERC is the ethereum token contract address
     */
    function withdrawToken(
        address addrTokenERC,
        address _owner,
        uint256 amount
    ) public auth {
        require(amount > 0, "EthManager/zero token locked");
        IERC20 ethToken = IERC20(addrTokenERC);
        ethToken.transfer(_owner, amount);
        emit WithdrawToken(addrTokenERC, _owner, amount, "withdraw Token");
    }
}
