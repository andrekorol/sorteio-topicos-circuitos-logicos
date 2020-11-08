// Realiza o sorteio
const crypto = require("crypto");

const Sorteio = artifacts.require("Sorteio");

module.exports = async function (callback) {
  const sorteioContract = await Sorteio.deployed();

  const maxSafeInt = 281474976710655;

  const randomSeeds = [];

  const BN = web3.utils.BN;

  for (let i = 0; i < 6; i++) {
    const seed = new BN(crypto.randomInt(maxSafeInt));
    randomSeeds.push(seed);
  }

  await sorteioContract.sorteio(randomSeeds);

  callback();
};
