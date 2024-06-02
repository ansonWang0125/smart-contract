// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "./Token.sol";

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
        uint256 clusterIndex;
        string dataImage;
        string trainImage;
        uint256 status;
    }

    struct Log {
        address sender;
        address client;
    }

    event RegisterCluster(address provider, uint256 gpuId, uint256 clusterSize);
    event StartRun(address provider, uint256 taskIndex, string dataImage, string trainImage);
    event TaskAccessed(address client, address caller, bool isEqual);
    event LogThis(string msg);

    Token public token;

    constructor(address tokenAddress) {
        token = Token(tokenAddress);
    }

    uint256 private randomNumber;
    Cluster[] public clusters;
    Task[] public tasks;

    function _getRandomNumber() internal returns (uint256) {
        randomNumber = uint (keccak256(abi.encodePacked (msg.sender, block.timestamp, randomNumber)));
        return randomNumber;
    }

    function registerCluster(uint256 gpuId, uint256 clusterSize) public returns (uint256) {
        address provider = msg.sender;
        clusters.push(Cluster(provider, gpuId, clusterSize, true));
        return clusters.length;
    }

    function _registerTaskWithSpecificCluster(string memory dataImage, string memory trainImage, uint256 clusterIndex) internal{
        require(clusters[clusterIndex].available, "This GPU Cluster has been chosen");
        clusters[clusterIndex].available = false;

        address provider = clusters[clusterIndex].provider;
        address client = msg.sender;
        tasks.push(Task(provider, client, clusterIndex, dataImage, trainImage, 0));

        emit StartRun(provider, tasks.length-1, dataImage, trainImage);
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
        _registerTaskWithSpecificCluster(dataImage, trainImage, suitable_clusters[index]);       // return task index
        token.approve(address(this), 1000);
    }

    function unregister(uint256 clusterIndex) public {
        require(clusters[clusterIndex].provider == msg.sender, "you are not the provider for this cluster");
        clusters[clusterIndex].available = false;
    }

    function updateStatus(uint256 taskIndex, uint256 newStatus) public { // add time paremeter (s)
        /*
           0: scheduling: waiting for the provider checking and update the status to 'downloading'
           1: downloading
           2: training
           3: error
           4: finished
        */
        Task memory task = tasks[taskIndex];
        require(task.provider == msg.sender, "you are not the provider for this task");
        require(newStatus > task.status && newStatus<=4, "Not correct status code");
        task.status = newStatus;

        if (newStatus == 3 || newStatus == 4){
            clusters[task.clusterIndex].available = true;
        }
        if (newStatus == 4){
            token.transferFrom(task.client, task.provider, 1000);
        }
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

    function getAllTasks() public view returns (Task[] memory) {
        return tasks;
    }

    function getTasks(address sender) public view returns (Task[] memory) {
        uint256 userTasksCount = 0;
        uint256 errorCount = 0;
        Log[] memory log = new Log[](tasks.length);
        // Count the number of tasks belonging to the caller
        for (uint256 i = 0; i < tasks.length; i++) {
            if (tasks[i].client == sender) {
                userTasksCount++;
            } else {
                errorCount++;
            }
            log[i].client = tasks[i].client;
            log[i].sender = sender;
        }

        // Allocate memory for userTasks array
        Task[] memory userTasks = new Task[](userTasksCount);
        
        // Copy matching tasks into userTasks array
        uint256 index = 0;
        for (uint256 i = 0; i < tasks.length; i++) {
            if (tasks[i].client == sender) {
                userTasks[index] = tasks[i];
                index++;
            }
        }
        return userTasks;
    }
}
