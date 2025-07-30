// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address recipient, uint amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    // Mint function for testing or mock tokens
    function mint(address to, uint256 amount) external;
}

// 1.11.40
// 1.38.45

contract StrategyVault {
    address public simpleVault; // Authorized caller
    address public usdt;

    uint256 public ethBalance;
    uint256 public usdtBalance;

    event Deposited(address indexed vault, uint256 amount, bool isETH);
    event Withdrawn(address indexed vault, uint256 amount, bool isETH);

    modifier onlyVault() {
        require(msg.sender == simpleVault, "Not authorized");
        _;
    }

    constructor(address _usdt, address _simpleVault) payable {
        require(
            msg.value >= 0.001 ether,
            "deployer must send greater than 0.001 ether"
        ); // buffer

        usdt = _usdt;
        simpleVault = _simpleVault;

        // Mint 100,000 USDT (assuming 6 decimals like real USDT)
        IERC20(_usdt).mint(address(this), 100_000e6); // buffer
    }

    // Accept ETH deposit from SimpleVault
    function depositETH() external payable onlyVault {
        require(msg.value > 0, "Zero deposit");
        ethBalance += msg.value;
        emit Deposited(msg.sender, msg.value, true);
    }

    // Accept USDT deposit from SimpleVault
    function depositUSDT(uint256 amount) external onlyVault {
        require(amount > 0, "Zero deposit");
        IERC20(usdt).transferFrom(msg.sender, address(this), amount);
        usdtBalance += amount;
        emit Deposited(msg.sender, amount, false);
    }

    // Withdraw ETH back to SimpleVault
    function withdrawETH(uint256 amount) external onlyVault {
        require(address(this).balance >= amount, "Insufficient ETH");
        ethBalance -= amount;
        payable(simpleVault).transfer(amount);
        emit Withdrawn(msg.sender, amount, true);
    }

    // Withdraw USDT back to SimpleVault
    function withdrawUSDT(uint256 amount) external onlyVault {
        require(usdtBalance >= amount, "Insufficient USDT");
        usdtBalance -= amount;
        IERC20(usdt).transfer(simpleVault, amount);
        emit Withdrawn(msg.sender, amount, false);
    }

    receive() external payable {}
}
