pragma solidity >=0.4.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SpiritOfAfrica is ERC721, Ownable {
    enum spiritState {Minted, ForSale, Sold}

    spiritState constant defaultState = spiritState.Minted;

    struct Spirit {
        uint256 tokenId;
        address minter;
        address owner;
        uint256 price;
        spiritState state;
        string mediaUrl;
        string metadataUrl;
    }

    constructor() public ERC721("Spirit Of Africa", "SOA") {}

    event Minted(uint256 tokenId);
    event ForSale(uint256 tokenId);
    event Sold(uint256 tokenId);

    // Mapping the Spirit with the owner address
    mapping(uint256 => Spirit) public tokens;
    // Mapping the token id and price
    mapping(uint256 => uint256) public spiritForSale;
    // Mapping the spirit token id to an array of TxHash that track his history
    mapping(uint256 => string[]) spiritHistory;

    // Modifier that verifies the Caller
    modifier verifyCaller(address _address) {
        require(_msgSender() == _address);
        _;
    }

    // Modifier that checks if the paid amount is sufficient to cover the price
    modifier paidEnough(uint256 _price) {
        require(msg.value >= _price, "You need to have enough BNB");
        _;
    }

    // Modifier that checks the price and refunds the remaining balance
    modifier checkValue(uint256 _tokenId) {
        _;
        uint256 _price = spiritForSale[_tokenId];
        uint256 amountToReturn = msg.value - _price;
        payable(_msgSender()).transfer(amountToReturn);
    }

    function createSpirit(
        uint256 _tokenId,
        uint256 _price,
        string memory _mediaUrl,
        string memory _metadataUrl
    ) public verifyCaller(_msgSender()) {
        Spirit memory newSpirit =
            Spirit({
                tokenId: _tokenId,
                price: _price,
                minter: _msgSender(),
                owner: _msgSender(),
                state: defaultState,
                mediaUrl: _mediaUrl,
                metadataUrl: _metadataUrl
            });
        tokens[_tokenId] = newSpirit;
        _mint(_msgSender(), _tokenId);
        emit Minted(_tokenId);
    }

    function putSpiritUpForSale(uint256 _tokenId, uint256 _price) public {
        require(
            ownerOf(_tokenId) == _msgSender(),
            "You can't sale the Spirit you don't own"
        );
        spiritForSale[_tokenId] = _price;
        tokens[_tokenId].state = spiritState.ForSale;
        emit ForSale(_tokenId);
    }

    function buySpirit(uint256 _tokenId)
        public
        payable
        paidEnough(spiritForSale[_tokenId])
        checkValue(_tokenId)
    {
        require(
            spiritForSale[_tokenId] > 0,
            "The Spirit should be up for sale"
        );
        uint256 spiritCost = spiritForSale[_tokenId];
        address ownerAddress = ownerOf(_tokenId);
        transferFrom(ownerAddress, _msgSender(), _tokenId);
        address payable ownerAddressPayable = payable(ownerAddress);
        ownerAddressPayable.transfer(spiritCost);
        tokens[_tokenId].state = spiritState.Sold;
        emit Sold(_tokenId);
    }

    function fetchSpirit(uint256 _tokenId)
        public
        view
        returns (
            uint256 tokenId,
            address minter,
            address owner,
            uint256 price,
            spiritState state,
            string memory mediaUrl,
            string memory metadataUrl
        )
    {
        tokenId = tokens[_tokenId].tokenId;
        minter = tokens[_tokenId].minter;
        owner = tokens[_tokenId].owner;
        price = tokens[_tokenId].price;
        state = tokens[_tokenId].state;
        mediaUrl = tokens[_tokenId].mediaUrl;
        metadataUrl = tokens[_tokenId].metadataUrl;

        return (tokenId, minter, owner, price, state, mediaUrl, metadataUrl);
    }

    function transferSpirit(address _to, uint256 _tokenId)
        public
        verifyCaller(_msgSender())
    {
        require(
            ownerOf(_tokenId) == _msgSender(),
            "You should be the owner of the spirit you want to transfer"
        );
        transferFrom(ownerOf(_tokenId), _to, _tokenId);
    }
}
