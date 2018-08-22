/// DaiRedeemer.t.sol - tests for DaiRedeemer

// Copyright (C) 2018  DappHub, LLC

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.4.24;

import "ds-test/test.sol";

import "./DaiRedeemer.sol";

contract TokenUser {
    DSToken  token;
    DaiRedeemer r;

    constructor(DSToken token_, DaiRedeemer r_) public {
        token = token_;
        r = r_;
    }

    function doApprove(address guy) public returns (bool) {
        return token.approve(guy);
    }
    function doPush(address who, uint amount) public {
        token.push(who, amount);
    }
    function doPull(address who, uint amount) public {
        token.pull(who, amount);
    }
    function doRedeem(uint256 wad) public {
        r.redeem(wad);
    }
    function doUndo(uint256 wad) public {
        r.undo(wad);
    }
    function doReclaim(uint256 wad) public {
        r.reclaim(token, wad);
    }
}

contract DaiRedeemerTest is DSTest {
    DaiRedeemer r;
    DSToken from;
    DSToken to;
    TokenUser user;

    function setUp() public {
        from = new DSToken("SCDAI");
        to = new DSToken("DAI");
        r = new DaiRedeemer(from, to);
        user = new TokenUser(from, r);
        from.mint(user, 100);
        to.mint(100);
    }

    function test_reclaim() public {
        assertEq(to.balanceOf(r), 0);
        assertEq(to.balanceOf(this), 100);

        to.push(r, 50);

        assertEq(to.balanceOf(r), 50);
        assertEq(to.balanceOf(this), 50);

        r.reclaim(to, 10);

        assertEq(to.balanceOf(r), 40);
        assertEq(to.balanceOf(this), 60);

        r.reclaim(to, 40);

        assertEq(to.balanceOf(r), 0);
        assertEq(to.balanceOf(this), 100);
    }

    function testFail_reclaim() public {
        assertEq(from.balanceOf(r), 0);
        assertEq(from.balanceOf(user), 100);
        
        user.doPush(r, 10);

        assertEq(from.balanceOf(r), 10);
        assertEq(from.balanceOf(user), 90);

        user.doReclaim(10);
    }

    function test_redeem_wad() public {
        to.push(r, 100);
        
        assertEq(from.balanceOf(user), 100);
        assertEq(to.balanceOf(user), 0);

        assertEq(from.balanceOf(r), 0);
        assertEq(to.balanceOf(r), 100);

        user.doApprove(r);
        user.doRedeem(50);

        assertEq(from.balanceOf(user), 50);
        assertEq(to.balanceOf(user), 50);

        assertEq(from.balanceOf(r), 50);
        assertEq(to.balanceOf(r), 50);

        r.reclaim(from, 50);
        r.reclaim(to, 50);

        assertEq(from.balanceOf(r), 0);
        assertEq(to.balanceOf(r), 0);

        assertEq(from.balanceOf(this), 50);
        assertEq(to.balanceOf(this), 50);
    }
}
