// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// Koin ERC-20 sederhana tanpa library: mint khusus owner, dibatasi cap, bisa burn.
contract Coin {
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;

    uint256 public totalSupply;
    uint256 public cap; // batas maksimal supply (satuan terkecil)
    address public owner;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Hanya owner");
        _;
    }

    /// _initialSupply dan _cap dalam satuan KOIN (bukan satuan terkecil).
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply,
        uint256 _cap
    ) {
        require(_cap > 0, "Cap harus > 0");
        require(_initialSupply <= _cap, "Supply awal melebihi cap");
        name = _name;
        symbol = _symbol;
        owner = msg.sender;
        cap = _cap * 10 ** decimals;
        _mint(msg.sender, _initialSupply * 10 ** decimals);
    }

    function _mint(address to, uint256 amount) internal {
        require(to != address(0), "Alamat tujuan tidak valid");
        require(totalSupply + amount <= cap, "Melebihi cap");
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    // MINT: hanya owner, tidak boleh melewati cap
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    // BURN: membakar koin milik sendiri
    function burn(uint256 amount) external {
        require(balanceOf[msg.sender] >= amount, "Saldo tidak cukup");
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 allowed = allowance[from][msg.sender];
        require(allowed >= amount, "Allowance tidak cukup");
        if (allowed != type(uint256).max) {
            allowance[from][msg.sender] = allowed - amount;
        }
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(to != address(0), "Alamat tujuan tidak valid");
        require(balanceOf[from] >= amount, "Saldo tidak cukup");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
    }
}
