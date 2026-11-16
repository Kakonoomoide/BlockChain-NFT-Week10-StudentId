const { ethers } = require('ethers');
const fs = require('node:fs');
const path = require('node:path');

// ===== Parameter koin (satuan KOIN, bukan satuan terkecil) =====
const NAME = 'MahasiswaCoin';     // ganti nama dengan coint yang di inginkan
const SYMBOL = 'MHS';             // ganti dengan symnbol yang di inginkan
const INITIAL_SUPPLY = 1000000;   // dicetak ke deployer saat deploy
const CAP = 10000000;             // batas maksimal supply (tidak bisa dilewati mint)

async function main() {
  // Disuntik oleh `cmu deploy` sesuai network di cmu.config.js
  const rpcUrl = process.env.CMU_RPC_URL;
  const chainId = Number(process.env.CMU_CHAIN_ID);
  const privateKey = process.env.PRIVATE_KEY;
  if (!rpcUrl || !chainId || !privateKey) {
    throw new Error('CMU_RPC_URL / CMU_CHAIN_ID / PRIVATE_KEY tidak ada. Jalankan lewat `cmu deploy`.');
  }

  const provider = new ethers.JsonRpcProvider(rpcUrl, chainId, {
    cacheTimeout: -1,
    staticNetwork: true,
  });
  const wallet = new ethers.Wallet(privateKey, provider);

  const artifact = JSON.parse(
    fs.readFileSync(path.resolve('artifacts', 'Coin.json'), 'utf8'),
  );
  const factory = new ethers.ContractFactory(artifact.abi, artifact.evm.bytecode.object, wallet);

  console.log('Network  :', rpcUrl, `(chain ${chainId})`);
  console.log('Owner    :', wallet.address);
  console.log(`Deploying ${NAME} (${SYMBOL})...`);

  const coin = await factory.deploy(NAME, SYMBOL, INITIAL_SUPPLY, CAP);
  await coin.waitForDeployment();

  console.log('Coin deployed to:', await coin.getAddress());
  console.log('Salin alamat di atas ke dalam aplikasi CointMU');
  console.log('Gunakan wallet yang di gunakan untuk deploy dan pilih menu Tokens');
  console.log('Tekan button Add Token dan input contract addressnya');
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
