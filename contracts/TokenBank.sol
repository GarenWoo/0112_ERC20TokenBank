// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Bank.sol";

interface IERC20TokenGTT {
    function transferFrom(address, address, uint256) external returns (bool);

    function balanceOf(address) external view returns (uint256);

    function transfer(address, uint256) external returns (bool);
}

contract TokenBank is Bank {
    mapping(address => uint) internal tokenBalance;
    address[3] internal tokenRank;
    address public tokenAddr;
    IERC20TokenGTT public IGTT;
    error TokenTransferFail(uint transferredAmount, uint tokenBalance);

    constructor(address _tokenAddr) {
        tokenAddr = _tokenAddr;
        owner = msg.sender;
        IGTT = IERC20TokenGTT(tokenAddr);
    }

    function depositToken(uint _tokenAmount) public {
        bool transferSuccess = IGTT.transferFrom(
            msg.sender,
            address(this),
            _tokenAmount
        );
        if (!transferSuccess)
            revert TokenTransferFail(_tokenAmount, IGTT.balanceOf(msg.sender));
        tokenBalance[msg.sender] += _tokenAmount;
        _handleRankWhenDepositToken();
    }

    function withdrawToken() public onlyOwner {
        IGTT.transfer(owner, IGTT.balanceOf(address(this)));
    }

    function getTokenBalance(address _account) public view returns (uint) {
        return tokenBalance[_account];
    }

    function getTokenTopThreeAccount()
        public
        view
        returns (address, address, address)
    {
        return (tokenRank[0], tokenRank[1], tokenRank[2]);
    }

    function _handleRankWhenDepositToken() internal {
        uint membershipIndex = _checkTokenRankMembership();
        uint convertedIndex;
        uint indexRecord = 777;
        if (membershipIndex != 999) {
            // Case 1: msg.sender is already inside the top3 rank.
            convertedIndex = membershipIndex + 4;
            for (uint i = convertedIndex - 3; i > 1; i--) {
                if (membershipIndex != 0) {
                    if (
                        tokenBalance[msg.sender] >=
                        tokenBalance[tokenRank[i - 2]]
                    ) {
                        indexRecord = i - 2;
                        for (uint j = 2; j > i - 2; j--) {
                            tokenRank[j] = tokenRank[j - 1];
                        }
                        // Boundry condition
                        if (indexRecord == 0) {
                            tokenRank[indexRecord] = msg.sender;
                        }
                    } else {
                        if (indexRecord != 777) {
                            tokenRank[indexRecord] = msg.sender;
                        }
                    }
                }
            }
        } else {
            // Case 2: msg.sender is not inside the top3 rank.
            for (uint i = 3; i > 0; i--) {
                if (
                    tokenBalance[msg.sender] >= tokenBalance[tokenRank[i - 1]]
                ) {
                    indexRecord = i - 1;
                    // move backward the element(s) which is(/are) right at the index and also behind the index
                    for (uint j = 2; j > i - 1; j--) {
                        tokenRank[j] = tokenRank[j - 1];
                    }
                    // Boundry condition
                    if (indexRecord == 0) {
                        tokenRank[indexRecord] = msg.sender;
                    }
                } else {
                    if (indexRecord != 777) {
                        tokenRank[indexRecord] = msg.sender;
                    }
                }
            }
        }
    }

    function _checkTokenRankMembership() internal view returns (uint) {
        uint index = 999;
        for (uint i = 0; i < 3; i++) {
            if (tokenRank[i] == msg.sender) {
                index = i;
                break;
            }
        }
        return index;
    }
}
