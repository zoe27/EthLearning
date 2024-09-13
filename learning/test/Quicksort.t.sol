// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Quicksort} from "../src/Quicksort.sol";


contract QuicksortTest is Test{

    Quicksort public quicksort;

    function setUp() public{
        quicksort = new Quicksort();
    }

    function test_Sort() public view{
        int[] memory data = new int[](5);

        data[0] = 9;
        data[1] = 4;
        data[2] = 1;
        data[3] = 19;
        data[4] = 29;

        int[] memory res = quicksort.sort(data);
        assert(res[0] == 1);
        assert(res[1] == 4);
        assert(res[2] == 9);
        assert(res[3] == 19);
        assert(res[4] == 29);

    }


}