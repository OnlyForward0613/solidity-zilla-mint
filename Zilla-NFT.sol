// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Zillas is ERC721Enumerable, Ownable {
    // Claim Basic Variables
    string _baseTokenURI;
    address PREMINT = 0xFc44b51003041bf8010646C07f2b31E757747359;
    address dev = 0x3D27f909606c97b13973c52b0752c06C5cAd9240;
    address admin;
    uint256 private constant MAX_ENTRIES = 3333;
    uint256 private constant PREMINT_ENTRIES = 100;
    uint256 private constant PRESALE_ENTRIES = 1700;

    // Set Prices following Tokenomics
    uint256 private PRE_PRICE = 0.06 ether;
    uint256 private PUB_PRICE = 0.07 ether;
    uint256[] private MAX_BUYABLE = [2, 4];
    uint256 public price;

    // Set about the WhiteListed person
    mapping(address => bool) whitelisted;
    uint256 public whitelistAccessCount = 0;
    uint16 public LIMIT_WL = 800;

    // Set Variables to start
    bool public start;
    uint256 public startTime;

    // STAGES Contains PRESALE and PUBLICSALE
    enum STAGES {
        PRESALE,
        PUBLICSALE
    }

    // Amount of Tokens which are Minted
    uint256 public totalMinted;

    // When it starts, 100 NFTs go to the Admin's Wallet
    constructor(string memory baseURI) ERC721("Bored Zilla", "Zilla") {
        setBaseURI(baseURI);
        start = false;
    }

    function preMint() public {
        for (uint8 i = 1; i <= PREMINT_ENTRIES; i++) _mint(PREMINT, i);
        totalMinted = 100;
    }

    function mint(uint256 amount) public payable {
        require(start == true, "SALE has not Started!");
        require(totalMinted + amount <= MAX_ENTRIES, "Amount Exceed!");

        if ((block.timestamp - startTime) <= 10800) {
            require(
                totalMinted + amount <= PRESALE_ENTRIES,
                "Presale Amount Exceed"
            );
            require(
                whitelisted[msg.sender] == true,
                "You are not a WhiteListed Person!"
            );
            require(
                balanceOf(msg.sender) + amount <= MAX_BUYABLE[0],
                "In PRESALE Stage, you can buy ONLY 2 Zillas!"
            );
        } else {
            require(
                balanceOf(msg.sender) + amount <= MAX_BUYABLE[1],
                "In PUBLIC Stage, you can buy ONLY 4 Zillas!"
            );
        }

        // GET the PRICE in the case of PRESALE and PUBLICSALE
        price = 0;
        if (totalMinted + amount <= PRESALE_ENTRIES) price = PRE_PRICE * amount;
        else price = PUB_PRICE * amount;

        // Payment value is larger than the 'price'
        require(msg.value >= price, "Zilla : INCORRECT PRICE!");
        payable(admin).transfer(((address(this).balance) * 98) / 100);
        payable(dev).transfer(((address(this).balance) * 2) / 100);
        for (uint8 i = 1; i <= _amount; i++)
            _safeMint(msg.sender, (totalMinted + i));

        totalMinted += amount;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    function startSale() external onlyOwner {
        // require(start == false, "PRESALE is not Started!");
        startTime = block.timestamp;
        start = true;
    }

    function setWhitelistAddresses(address[] calldata addresses)
        external
        onlyOwner
    {
        for (uint16 i = 0; i < addresses.length; i++) {
            require(whitelistAccessCount + i < LIMIT_WL, "WhiteList Member Exceed!");
            whitelisted[addresses[i]] = true;
        }
        whitelistAccessCount += addresses.length;
    }

    function getWhitelistState(address user) public view returns (bool) {
        return whitelisted[user];
    }
}
