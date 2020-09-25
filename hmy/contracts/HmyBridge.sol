pragma solidity ^0.5.0;

import "@chainlink/contracts/src/v0.5/interfaces/AggregatorInterface.sol";

// import "./AggregatorInterface.sol";

contract HmyManager {
    mapping(bytes32 => bool) public usedEvents_;

    event LockedONE(
        address indexed addrTokenERC,
        address indexed sender,
        uint256 amount,
        uint256 price,
        uint256 result,
        address recipient
    );

    event Unlocked(
        uint256 amount,
        uint256 price,
        uint256 result,
        address recipient,
        bytes32 receiptId
    );

    event WithdrawONE(address indexed _owner, uint256 amount, string msg);

    mapping(address => uint256) public wards;

    function rely(address guy) external auth {
        wards[guy] = 1;
    }

    function deny(address guy) external auth {
        require(guy != owner, "HmyManager/cannot deny the owner");
        wards[guy] = 0;
    }

    modifier auth {
        require(wards[msg.sender] == 1, "HmyManager/not-authorized");
        _;
    }

    address public owner;

    mapping(address => address) public mappings;

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
            "HmyManager/only owner can change threshold"
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
     * @dev lock ONE to be transfer ERC to recipient on ETH chain
     * @param addrTokenERC is the ethereum token contract address
     * @param oracleAddr is address of oracle token in harmony
     * @param amount amount of tokens to lock
     * @param recipient recipient address on the ethereum chain
     */
    function lockOne(
        address addrTokenERC,
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
        emit LockedONE(
            addrTokenERC,
            msg.sender,
            msg.value,
            _price,
            _result,
            recipient
        );
    }

    /**
     * @dev unlock ONE after locktoken them on ethereum chain
     * @param amount amount of unlock tokens
     * @param recipient recipient of the unlock tokens
     * @param receiptId transaction hash of the locktoken event on harmony chain
     */
    function unlockOne(
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
        emit Unlocked(amount, price, _result, recipient, receiptId);
        // delete confirmations entry for receiptId
        delete confirmations[receiptId];
    }

    /**
     * get balance ONE
     */
    function getBalanceOne() public view returns (uint256) {
        return address(this).balance;
    }

    /** Function withdraw ONE to account Manager
     */
    function withdraw(address payable _owner) public auth {
        uint256 balanceBefore = address(this).balance;
        _owner.transfer(address(this).balance);
        emit WithdrawONE(_owner, balanceBefore, "Withdraw ETH");
    }
}
