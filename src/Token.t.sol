// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "ds-test/test.sol";

import "./Token.sol";

contract User {
    function doApprove(IERC20 zxx, address to, uint256 amount) external returns (bool) {
        return zxx.approve(to, amount);
    }
    function doTransfer(IERC20 zxx, address to, uint256 amount) external returns (bool) {
        return zxx.transfer(to, amount);
    }
    function doTransferFrom(IERC20 zxx, address from, address to, uint256 amount) external returns (bool) {
        return zxx.transferFrom(from, to, amount);
    }
    function doMint(IERC20 zxx, address to, uint256 amount) external returns (bool) {
        return zxx.mint(to, amount);
    }
}

contract TokenTest is DSTest {
    ZXX zxx;
    User u1;
    User u2;
    User u3;
    User u4;

    function setUp() public {
        if (true) {
            zxx = new ZXX();
        } else {
            bytes memory code = hex"336000556104f26100146000396104f26000f3fe61000934156104e0565b610011610227565b6370a082318114610068576318160ddd81146100875763a9059cbb811461009c576323b872dd81146100c55763095ea7b381146100f85763dd62ed3e8114610121576340c10f19811461014a5760006000fd61016f565b61008261007d6100786000610251565b6103d7565b6102ae565b61016f565b6100976100926103a8565b6102ae565b61016f565b6100b86100a96001610289565b6100b36000610251565b6101a9565b6100c06102bb565b61016f565b6100eb6100d26002610289565b6100dc6001610251565b6100e66000610251565b6101dd565b6100f36102bb565b61016f565b6101146101056001610289565b61010f6000610251565b6101b9565b61011c6102bb565b61016f565b6101456101406101316001610251565b61013b6000610251565b610430565b6102ae565b61016f565b6101666101576001610289565b6101616000610251565b610175565b61016e6102bb565b5b506104f1565b6101856101806104c1565b6104e0565b61018e826103b9565b61019882826103eb565b6101a4828260006102c8565b5b5050565b6101b48282336101f9565b5b5050565b6101c2816104d3565b6101cd828233610446565b6101d88282336102fc565b5b5050565b6101e8833383610458565b6101f38383836101f9565b5b505050565b610202826104d3565b61020c8382610407565b61021683836103eb565b6102218383836102c8565b5b505050565b60007c01000000000000000000000000000000000000000000000000000000006000350490505b90565b600061025c82610289565b905073ffffffffffffffffffffffffffffffffffffffff8116811415156102835760006000fd5b5b919050565b600060208202600401602081013610156102a35760006000fd5b80359150505b919050565b8060005260206000f35b50565b6102c560016102ae565b5b565b7fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef6102f584848484610330565b505b505050565b7f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b92561032984848484610330565b505b505050565b8360005282828260206000a35b50505050565b6000600090505b90565b6000600190505b90565b6000816000526002602052604060002090505b919050565b6000816000526003602052604060002090508260005280602052604060002090505b92915050565b60006103a1610343565b5490505b90565b60006103b261034d565b5490505b90565b6103ca816103c56103a8565b6104a1565b6103d261034d565b555b50565b60006103e282610357565b5490505b919050565b6103f481610357565b6103ff8382546104a1565b8155505b5050565b61041081610357565b805461042461041f8286610483565b6104e0565b838103825550505b5050565b600061043c838361036f565b5490505b92915050565b82610451838361036f565b555b505050565b610462828261036f565b80546104766104718287610483565b6104e0565b848103825550505b505050565b60008282111590505b92915050565b60008282101590505b92915050565b6000828201905082811082821017156104ba5760006000fd5b5b92915050565b6000336104cc610397565b1490505b90565b6104dc816104e0565b5b50565b8015156104ed5760006000fd5b5b50565b";
            address yul;
            assembly {
                yul := create(0, add(code, 32), mload(code))
            }
            zxx = ZXX(yul);
        }
        
        u1 = new User();
        u2 = new User();
        u3 = new User();
        u4 = new User();
    }

    function test_total_supply() public {
        zxx.mint(address(this), 100_000_000e18);
        assertEq(zxx.totalSupply(), 100_000_000e18);
        assertEq(zxx.balanceOf(address(this)), zxx.totalSupply());
    }

    function test_transfer() public {
        zxx.mint(address(this), 100_000_000e18);
        uint256 amount = 1 ether;

        zxx.transfer(address(0x1), amount);
        
        assertEq(zxx.balanceOf(address(this)), zxx.totalSupply() - amount);
        assertEq(zxx.balanceOf(address(0x1)), amount);
    }

    function test_transfer_From() public {
        zxx.mint(address(this), 100_000_000e18);
        zxx.transfer(address(u1), 1 ether);

        assertEq(zxx.balanceOf(address(u1)), 1 ether);

        u1.doApprove(zxx, address(u2), 0.5 ether);

        assertEq(zxx.allowance(address(u1), address(u2)), 0.5 ether);

        u2.doTransferFrom(zxx, address(u1), address(u2), 0.5 ether);

        assertEq(zxx.balanceOf(address(u1)), 0.5 ether);
        assertEq(zxx.balanceOf(address(u2)), 0.5 ether);

        assertEq(zxx.allowance(address(u1), address(u2)), 0 ether);
    }

    function testFail_transfer_From() public {
        zxx.mint(address(this), 100_000_000e18);
        zxx.transfer(address(u1), 1 ether);

        assertEq(zxx.balanceOf(address(u1)), 1 ether);

        u1.doApprove(zxx, address(u2), 0.5 ether);

        assertEq(zxx.allowance(address(u1), address(u2)), 0.5 ether);

        u2.doTransferFrom(zxx, address(u1), address(u2), 0.6 ether);
    }

    function test_mint() public {
        uint256 totalSupply = zxx.totalSupply();

        zxx.mint(address(0x2), 1 ether);
        assertEq(zxx.balanceOf(address(0x2)), 1 ether);
        assertEq(zxx.totalSupply(), totalSupply + 1 ether);
    }

    function testFail_unauthorized_mint() public {
        u1.doMint(zxx, address(u1), 1 ether);
    }

    function test_transferFrom_gas_usage() public {
        zxx.mint(address(this), 100_000_000e18);
        zxx.transfer(address(u1), 1 ether);

        assertEq(zxx.balanceOf(address(u1)), 1 ether);

        u1.doApprove(zxx, address(u2), 0.5 ether);

        assertEq(zxx.allowance(address(u1), address(u2)), 0.5 ether);

        uint256 gas = gasleft();
        u2.doTransferFrom(zxx, address(u1), address(u2), 0.5 ether);
        emit log_named_uint("ZXX trasferFrom", gas - gasleft());

        assertEq(zxx.balanceOf(address(u1)), 0.5 ether);
        assertEq(zxx.balanceOf(address(u2)), 0.5 ether);

        assertEq(zxx.allowance(address(u1), address(u2)), 0 ether);
    }

    function prove_transfer(uint supply, address usr, uint amt) public {
        if (usr == address(0)) return; // no transfer to address 0
        if (amt > supply) return; // no underflow

        zxx.mint(address(this), supply);

        uint prebal = zxx.balanceOf(usr);
        zxx.transfer(usr, amt);
        uint postbal = zxx.balanceOf(usr);

        uint expected = usr == address(this)
                        ? 0    // self transfer is a noop
                        : amt; // otherwise `amt` has been transfered to `usr`
        assertEq(expected, postbal - prebal);
    }

    function prove_balance(address usr, uint amt) public {
        assertEq(0, zxx.balanceOf(usr));
        zxx.mint(usr, amt);
        assertEq(amt, zxx.balanceOf(usr));
    }

    function prove_supply(uint supply) public {
        zxx.mint(address(0x1), supply);
        uint actual = zxx.totalSupply();
        assertEq(supply, actual);
    }
}
