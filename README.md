# Praktikum 10: Koin Sendiri + Mint (CLI + dApp Express/EJS)

Koin ERC-20 sederhana (tanpa library) dengan `mint` khusus owner, `cap`, dan `burn`,
beserta dApp web untuk mint, transfer, burn, cek saldo, dan riwayat.

## Isi
- `contracts/Coin.sol` : contract koin
- `deploy/01_deploy.js`: deploy lewat `cmu deploy` (parameter koin di bagian atas)
- `scripts/seed.js`    : mint ke beberapa alamat (konfigurasi di bagian atas)
- `app.js` + `views/`  : dApp (Express + EJS)

File `cmu.config.js` TIDAK disertakan. Salin isi folder ini ke project hasil `cmu create`
(atau folder praktikum yang sudah ada), lalu hapus contract/deploy contoh bawaan
(mis. `StandardERC20.sol` dan `deploy/01_standarderc20.*`) supaya tidak ikut dideploy.

## Langkah
```bash
npm install                  # ethers, express, ejs
cmu wallet use main          # jalankan dari folder project, bukan System32
cmu compile
cmu deploy                   # atau: cmu deploy -n local
```
1. Salin alamat dari output deploy ke `CONTRACT_ADDRESS` di `app.js` dan `scripts/seed.js`.
2. Samakan `RPC_URL` dan `CHAIN_ID` di dua file itu dengan network yang dipakai saat deploy.
3. Salin `.env.example` jadi `.env`, isi `PRIVATE_KEY` (wallet dev, HARUS wallet deployer/owner).
4. (Opsional) isi alamat penerima di `SEED_DATA`, lalu `node scripts/seed.js`.
5. `node app.js` lalu buka http://localhost:3000

## Demo lewat console (opsional)
```js
let ABI_PATH = 'artifacts/Coin.json'
let CONTRACT_ADDRESS = '0xISI_ALAMAT_CONTRACT'
let abi = JSON.parse(require('fs').readFileSync(ABI_PATH, 'utf8')).abi
let base = await getDeployed("Coin")
let coin = new ethers.Contract(CONTRACT_ADDRESS, abi, base.runner)

ethers.formatUnits(await coin.totalSupply(), 18)
let tx = await coin.mint("0xAlamat", ethers.parseUnits("100", 18)); await tx.wait()
await coin.mint.staticCall("0xAlamat", ethers.parseUnits("999999999", 18))  // revert: Melebihi cap
```

## Catatan keamanan dan keterbatasan
- Mint hanya owner; mint melewati `cap` ditolak.
- Model custodial: wallet dipegang server (`PRIVATE_KEY` di `.env`), bukan browser pengguna.
- dApp tidak punya login. Jalankan di localhost / jaringan lab, jangan di-expose ke internet.
- `.env` jangan di-commit atau dibagikan. Pakai wallet dev, bukan wallet utama.
- Transfer dan burn dari web hanya memakai koin milik wallet server.
- Riwayat membaca event `Transfer`; kalau node membatasi `getLogs`, tabel akan kosong.
- Belum diuji di jaringan CointMU (dibuat tanpa akses ke node).
