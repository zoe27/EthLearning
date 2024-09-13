// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Quicksort{

    function sort(int256[] memory sort_data) external pure returns(int[] memory){

        uint length = sort_data.length;
        int256[] memory data = sort_data;

        for(uint i = 0; i < length; i++){
            int256 temp = data[i];
            for(uint j = i + 1; j < length; j++){
                if(temp > data[j]){
                    temp = data[j];
                    data[j] = data[i];
                    data[i] = temp;
                }
            }
        }

        return data;

    }


}