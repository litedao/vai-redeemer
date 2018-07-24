pragma solidity ^0.4.24;

import "ds-test/test.sol";

import "./DaiRedeemer.sol";

contract DaiRedeemerTest is DSTest {
    DaiRedeemer redeemer;

    function setUp() public {
        redeemer = new DaiRedeemer();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
