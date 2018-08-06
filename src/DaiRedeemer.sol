/// DaiRedeemer.sol - redeemer

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

import "ds-token/token.sol";

contract DaiRedeemer is DSAuth {
    DSToken public from;
    DSToken public to;

    constructor(DSToken from_, DSToken to_) public {
        from = from_;
        to = to_;
    }

    function redeem() external {
        redeem(from.balanceOf(msg.sender));
    }

    function redeem(uint256 wad) public {
        from.pull(msg.sender, wad);
        to.push(msg.sender, wad);
    }

    function reclaim(DSToken token, uint256 wad) external auth {
        token.push(msg.sender, wad);
    }
}

contract DaiRedeemerProxy {
    function redeem(DaiRedeemer daiRedeemer) external {
        redeem(daiRedeemer, daiRedeemer.from().balanceOf(msg.sender));
    }

    function redeem(DaiRedeemer daiRedeemer, uint256 wad) public {
        daiRedeemer.from().pull(msg.sender, wad);
        if (daiRedeemer.from().allowance(this, daiRedeemer) < wad) {
            daiRedeemer.from().approve(daiRedeemer, uint(-1));
        }
        daiRedeemer.redeem(wad);
        daiRedeemer.to().transfer(msg.sender, wad);
    }
}
