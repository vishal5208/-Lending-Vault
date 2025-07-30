// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address recipient, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    
}


interface IStrategy {
    function withdrawETH(uint256 amount) external;
    function withdrawUSDT(uint256 amount) external;
    function depositETH() external payable;
    function depositUSDT(uint256 amount) external;
}


contract SimpleVault {
    address public admin;

    address public usdt;
    address public strategyVault;

    uint256 public constant SEVEN_DAYS = 7 days;
    uint256 public constant FIXED_APY = 10; // 10% APY
    uint256 public constant APY_DENOMINATOR = 100;

    struct DepositInfo {
        uint256 amount;
        uint256 timestamp;
        bool isETH;
    }

    mapping(address => DepositInfo) public deposits;

    event Deposited(address indexed user, uint256 amount, bool isETH);
    event Withdrawn(address indexed user, uint256 amount, uint256 yield);
    event AllocatedToStrategy(address strategy, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    constructor(address _usdt, address _strategyVault) {
        admin = msg.sender;
        usdt = _usdt;
        strategyVault = _strategyVault;
    }

    // Deposit ETH
    function depositETH() external payable {
        require(msg.value > 0, "Zero deposit");
        require(deposits[msg.sender].amount == 0, "Already deposited");

        deposits[msg.sender] = DepositInfo(msg.value, block.timestamp, true);
        emit Deposited(msg.sender, msg.value, true);
    }

    // Deposit USDT
    function depositUSDT(uint256 amount) external {
        require(amount > 0, "Zero deposit");
        require(deposits[msg.sender].amount == 0, "Already deposited");

        IERC20(usdt).transferFrom(msg.sender, address(this), amount);
        deposits[msg.sender] = DepositInfo(amount, block.timestamp, false);
        emit Deposited(msg.sender, amount, false);
    }

    function withdraw() external {
        DepositInfo memory info = deposits[msg.sender];
        require(info.amount > 0, "No deposit");
        require(block.timestamp >= info.timestamp + SEVEN_DAYS, "Withdrawal locked");

        // Calculate simulated yield: (amount * APY * duration_in_seconds) / (365 days * 100)
        uint256 duration = block.timestamp - info.timestamp;
        uint256 yield = (info.amount * FIXED_APY * duration) / (365 days * APY_DENOMINATOR);
        uint256 total = info.amount + yield;

        // Clear deposit record
        delete deposits[msg.sender];

        if (info.isETH) {
            // Pull ETH from strategy if needed
            uint256 available = address(this).balance;
            if (available < total) {
                uint256 needed = total - available;
                IStrategy(strategyVault).withdrawETH(needed);
            }
            payable(msg.sender).transfer(total);
        } else {
            // Pull USDT from strategy if needed
            uint256 available = IERC20(usdt).balanceOf(address(this));
            if (available < total) {
                uint256 needed = total - available;
                IStrategy(strategyVault).withdrawUSDT(needed);
            }
            require(IERC20(usdt).transfer(msg.sender, total), "USDT transfer failed");
        }

        emit Withdrawn(msg.sender, info.amount, yield);
    }


    // Admin sets the strategy vault address
    function setStrategyVault(address _strategy) external onlyAdmin {
        strategyVault = _strategy;
    }

    function allocateToStrategy(bool isETH, uint256 amount) external onlyAdmin {
        require(strategyVault != address(0), "No strategy set");

        if (isETH) {
            require(address(this).balance >= amount, "Insufficient ETH");
            IStrategy(strategyVault).depositETH{value: amount}();
        } else {
            require(IERC20(usdt).balanceOf(address(this)) >= amount, "Insufficient USDT");

            // Approve first
            IERC20(usdt).approve(strategyVault, amount);
            IStrategy(strategyVault).depositUSDT(amount);
        }

        emit AllocatedToStrategy(strategyVault, amount);
    }

    // View function to calculate current claimable yield
    function claimableYield(address user) external view returns (uint256) {
        DepositInfo memory info = deposits[user];
        if (info.amount == 0) return 0;

        uint256 duration = block.timestamp - info.timestamp;
        return (info.amount * FIXED_APY * duration) / (365 days * APY_DENOMINATOR);
    }

    receive() external payable {} // To accept ETH
}
