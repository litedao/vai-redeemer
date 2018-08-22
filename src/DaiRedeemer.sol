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
    DSToken public scd;
    DSToken public mcd;

    constructor(DSToken scd_, DSToken mcd_) public {
        scd = scd_;
        mcd = mcd_;
    }

    function redeem(uint256 wad) external {
        scd.pull(msg.sender, wad);
        mcd.push(msg.sender, wad);
    }

    function undo(uint256 wad) external {
        mcd.pull(msg.sender, wad);
        scd.push(msg.sender, wad);
    }

    function reclaim(DSToken token, uint256 wad) external auth {
        token.push(msg.sender, wad);
    }
}

contract DaiRedeemerProxy {
    function redeem(DaiRedeemer r, uint256 wad) public {
        r.scd().pull(msg.sender, wad);
        if (r.scd().allowance(this, r) < wad) {
            r.scd().approve(r);
        }
        r.redeem(wad);
        r.mcd().transfer(msg.sender, wad);
    }
}
