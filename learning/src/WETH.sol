pragma solidity ^0.8.13;

// SPDX-License-Identifier: MIT

/**
 虽然有成熟的ERC20合约在openzeppelin库中可以直接继承
 为了更好的理解ERC20，尝试自己实现一个符合ERC20标准的合约
 参考：  https://eips.ethereum.org/EIPS/eip-20
 */
contract WETH {

    // ERC 20 中的基本上属性
    string public name;
    string public symbol;
    uint8 public decimals;

    // WETH的总供应量，对应ERC20中的 totalSupply
    uint256 public totalSupply;

    // 用来记录每个地址的WETH余额
    mapping(address => uint256) public balanceOf;
    // 授权地址记录， 前者地址是主动授权地址， 后者mapping是被授权的地址, 并且被授权多少金额
    mapping(address => mapping(address => uint256)) private _allowances;

    // ERC-20 标准的 Transfer 事件
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // 存款事件，用户存入ETH并获取等量的WETH, WETH扩展的功能
    event Deposit(address indexed account, uint256 amount);
    
    // 取款事件，用户销毁WETH并提取等量的ETH，WETH扩展的功能
    event Withdrawal(address indexed account, uint256 amount);


    // 实例化合约， 并提供名字，精度，总量等
    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply){
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
    }

    // transfer to an other address
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "balance is not enough");
        require(_to != address(0), "can not trander to no exist address");

        balanceOf[msg.sender] = balanceOf[msg.sender] - _value;
        balanceOf[_to] = balanceOf[_to] + _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }


    // transfer value from one address to another address
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] > _value, "balance is not enough");
        require(_to != address(0), "transfer to a no exist address");
        // 检查是否达到了最大的授权额度
        require(_allowances[_from][msg.sender] > _value, "it is reached the limitation");

        balanceOf[_from] = balanceOf[_from] - _value;
        balanceOf[_to] = balanceOf[_to] + _value;
        // 计算剩余额度
        _allowances[_from][msg.sender] = _allowances[_from][msg.sender] - _value;

        emit Transfer(_from, _to, _value);

        return true;
    }


    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0), "can not auth to a unexist address");

        _allowances[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // 返回剩余的额度
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return _allowances[_owner][_spender];
    }


    // 存款功能，用户将ETH转换为WETH, 类似于增加总量，并将sender的信息增加到 balanceOf
    function deposit() public payable {
        // 将发送的ETH数量视为WETH
        uint256 amount = msg.value;
        
        // 增加用户的WETH余额
        balanceOf[msg.sender] += amount;
        
        // 增加总供应量
        totalSupply += amount;

        // 触发存款事件
        emit Deposit(msg.sender, amount);
        
        // 触发 Transfer 事件，from 地址为 0 表示铸币,  用新发代币来表示存款
        emit Transfer(address(0), msg.sender, amount);
    }

    // 取款功能，用户将WETH转换回ETH
    function withdraw(uint256 amount) public {
        require(balanceOf[msg.sender] >= amount, "Insufficient WETH balance");

        // 减少用户的WETH余额
        balanceOf[msg.sender] -= amount;
        
        // 减少总供应量
        totalSupply -= amount;

        // 将等量的ETH发送给用户， 调用transfer函数， 该函数不等于前面定义的transfer函数
        payable(msg.sender).transfer(amount);

        // 触发取款事件
        emit Withdrawal(msg.sender, amount);
        
        // 触发 Transfer 事件，to 地址为 0 表示销毁， 这一步是需要特别注意的需要提醒
        emit Transfer(msg.sender, address(0), amount);
    }
}
