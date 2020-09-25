pragma solidity 0.5.17;

import "@openzeppelin/contracts/math/SafeMath.sol";
// import "./SafeMath.sol";

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
// import "./AggregatorInterface.sol";

contract HmyBridge {
    
     using SafeMath for uint256;
    
    mapping(bytes32 => bool) public usedEvents_;
    
    mapping(address => uint256) public wards;
    
    address public owner;
    address public oracleONE;

    uint16 public threshold;
    mapping(bytes32 => uint16) confirmations;
    
    event Locked(
        string  symbolTo,
        address indexed sender,
        uint256 amountONE,
        uint256 priceONE,
        uint256 amountUSD,
        address recipient
    );

    event Unlocked(
        string  symbolFrom,
        uint256 amountUSD,
        uint256 priceONE,
        uint256 amountONE,
        address recipient,
        bytes32 receiptId
    );
    
    event WithdrawONE(
        address indexed _owner,
        uint256 amount,
        string  msg
    );

    modifier auth {
        require(wards[msg.sender] == 1, "HmyManager/not-authorized");
        _;
    }

    /**
     * @dev constructor
     */
    constructor() public {
        owner = msg.sender;
        wards[owner] = 1;
        threshold = 1;
        oracleONE = address(0x05d511aAfc16c7c12E60a2Ec4DbaF267eA72D420);
    }
    
    function rely(address guy) external auth {
        wards[guy] = 1;
    }

    function deny(address guy) external auth {
        require(guy != owner, "HmyManager/cannot deny the owner");
        wards[guy] = 0;
    }
    
    function changeOracleONE(address _oracleONE) external auth {
        require( _oracleONE != address(0), "hmyBrigde/oracleONE is a zero address");
         oracleONE = _oracleONE;
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
    function getLatestPrice(address _addrOracle) public view returns (int) {
        AggregatorInterface priceFeed = AggregatorInterface(_addrOracle);
        int price = priceFeed.latestAnswer();
        return price;
    }
    
    
    /**
     * @dev lock ONE to be transfer ERC to recipient on ETH chain
     * @param symbolTo is the symbol of the contract on Ethereum
     * @param amountONE amount of ONE to lock
     * @param recipient recipient address on the ethereum chain
     */
    function lockOne(
        string memory symbolTo,
        uint256 amountONE,
        address recipient
    ) public payable {
        require(
            recipient != address(0),
            "hmyBrigde/recipient is a zero address"
        );
        require(amountONE > 0, "amount token locked is zero");
        require(amountONE == msg.value, "amount ONE and msg.value different");
        uint256 _priceONE = uint256(getLatestPrice(oracleONE));
        uint256 _amountUSD = _priceONE * msg.value;
        emit Locked(symbolTo, msg.sender, msg.value, _priceONE, _amountUSD , recipient);
    }
    
    /**
     * @dev unlock ONE after locktoken them on ethereum chain
     * @param symbolFrom is the symbol of the contract on Ethereum
     * @param amountUSD amount USD of unlock on Harmony
     * @param recipient recipient of the unlock tokens
     * @param receiptId transaction hash of the locktoken event on harmony chain
     */
    function unlockOne(
        string memory symbolFrom,
        uint256 amountUSD,
        address payable recipient,
        bytes32 receiptId
    ) public auth {
        require(
            !usedEvents_[receiptId],
            "hmyBrigde/zero token unlocked"
        );
        confirmations[receiptId] = confirmations[receiptId] + 1;
        if (confirmations[receiptId] < threshold) {
            return;
        }
        usedEvents_[receiptId] = true;
        uint256 _priceONE = uint256(getLatestPrice(oracleONE));
        uint256 _amountONE = amountUSD.div(_priceONE);
        recipient.transfer(_amountONE);
        emit Unlocked(symbolFrom , amountUSD, _priceONE, _amountONE, recipient, receiptId);
        // delete confirmations entry for receiptId
        delete confirmations[receiptId];
    }
    
    
    /**
     * get balance ONE
    */
    function getBalanceOne() public view returns(uint256) {
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
