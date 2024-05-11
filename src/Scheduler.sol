// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Scheduler {
    struct Cluster {
        address provider;
        uint256 gpuId;
        uint256 clusterSize;
        bool available;
    }

    struct Task {
        address provider;
        address client;
        string dataImage;
        string trainImage;
        uint256 status;
    }

    event StartRun(address provider, string dataImage, string trainImage);

    uint256 private randomNumber;
    Cluster[] public clusters;
    Task[] public tasks;

    function _getRandomNumber() internal returns (uint256) {
        randomNumber = uint (keccak256(abi.encodePacked (msg.sender, block.timestamp, randomNumber)));
        return randomNumber;
    }

    function registerCluster(uint256 gpuId, uint256 clusterSize) public {
        address provider = msg.sender;
        clusters.push(Cluster(provider, gpuId, clusterSize, true));
    }

    function _registerTaskWithSpecificCluster(string memory dataImage, string memory trainImage, uint256 clusterIndex) internal {
        require(clusters[clusterIndex].available, "This GPU Cluster has been chosen");
        clusters[clusterIndex].available = false;

        address provider = clusters[clusterIndex].provider;
        address client = msg.sender;
        tasks.push(Task(provider, client, dataImage, trainImage, 1));

        emit StartRun(provider, dataImage, trainImage);
    }

    function registerTaskWithConditions(string memory dataImage, string memory trainImage, uint256 gpuId, uint256 clusterSize) public {
        uint256[] memory suitable_clusters = new uint256[](clusters.length);
        uint256 index = 0;
        for (uint256 i=0; i<clusters.length; i++) {
            if (clusters[i].gpuId == gpuId && clusters[i].clusterSize == clusterSize && clusters[i].available) {
                suitable_clusters[index] = i;
                index += 1;
            }
        }
        require(index>0, "No suitable cluster.");

        // random
        index = _getRandomNumber() % index;
        _registerTaskWithSpecificCluster(dataImage, trainImage, suitable_clusters[index]);
    }

    function getNumberOfClusters() public view returns (uint256) {
        return clusters.length;
    }

    function getClusterInfo(uint256 clusterIndex) public view returns(Cluster memory) {
        return clusters[clusterIndex];
    }
    
    function getClusters() public view returns (Cluster[] memory) {
        return clusters;
    }
}
