const SpiritOfAfrica = artifacts.require("SpiritOfAfrica");

var accounts;
var owner;

contract("SpiritOfAfrica", (accs) => {
  accounts = accs;
  owner = accounts[0];
  const tokenId = 1;
  // const spiritPrice = web3.toWei(1, "ether");
  const spiritPrice = 100;
  var spiritState = 0;
  const mediaUrl = "ipfs://test1";
  const metadataUrl = "ipfs://test2";
  const emptyAddress = "0x00000000000000000000000000000000000000";

  console.log("Contract Owner: accounts[0] ", accounts[0]);

  it("Testing smart contract function createSpirit() that allows a user to mint a spirit", async () => {
    let soa = await SpiritOfAfrica.deployed();

    // Declare and Initialize a variable for event
    // var eventEmitted = false;

    // Watch the emitted event Minted()
    // var event = soa.Minted();
    // await event.watch((err, res) => {
    //   eventEmitted = true;
    // });

    await soa.createSpirit(tokenId, spiritPrice, mediaUrl, metadataUrl, {
      from: accounts[0],
    });

    // Retrieve created spirit
    const fetchedSpirit = await soa.fetchSpirit.call(tokenId);

    // Verify the result set
    assert.equal(fetchedSpirit[0], tokenId, "Error: Invalid token id");
    assert.equal(fetchedSpirit[1], owner, "Error: Invalid minter address");
    assert.equal(fetchedSpirit[2], owner, "Error: Invalid owner address");
    assert.equal(fetchedSpirit[3], spiritPrice, "Error: Invalid price");
    assert.equal(fetchedSpirit[4], spiritState, "Error: Invalid spirit state");
    assert.equal(fetchedSpirit[5], mediaUrl, "Error: Invalid media url");
    assert.equal(fetchedSpirit[6], metadataUrl, "Error: Invalid metadata url");
  });
});
