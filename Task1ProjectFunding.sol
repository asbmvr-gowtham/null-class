// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProjectFunding {
    struct Project {
        uint fundingGoal;
        uint fundingReceived;
        uint deadline;
        address creator;
        bool isSuccessful;
        bool evaluated;
    }

    mapping(uint => Project) public projects;
    uint public totalProjectsCreated;
    uint public totalSuccessfulProjects;
    uint public totalFailedProjects;
    uint public commissionCollected;
    address public admin;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    function addProject(uint projectId, uint fundingGoal, uint deadline) public {
        require(projects[projectId].fundingGoal == 0, "Project already exists");
        projects[projectId] = Project(fundingGoal, 0, deadline, msg.sender, false, false);
        totalProjectsCreated++;
    }

    function fundProject(uint projectId) public payable {
        Project storage project = projects[projectId];
        require(block.timestamp <= project.deadline, "Project funding deadline passed");

        uint commission = (msg.value * 5) / 100;
        uint amountAfterCommission = msg.value - commission;

        commissionCollected += commission;
        project.fundingReceived += amountAfterCommission;

        // Check if funding goal is met (only once)
        if (!project.evaluated && project.fundingReceived >= project.fundingGoal) {
            project.isSuccessful = true;
            project.evaluated = true;
            totalSuccessfulProjects++;
        }
    }

    function getRemainingFunding(uint projectId) public view returns (uint) {
        Project memory project = projects[projectId];
        if (project.fundingReceived >= project.fundingGoal) {
            return 0;
        } else {
            return project.fundingGoal - project.fundingReceived;
        }
    }

    function extendProjectDeadline(uint projectId, uint newDeadline) public {
        Project storage project = projects[projectId];
        require(msg.sender == project.creator, "Only project creator can extend deadline");
        require(newDeadline > project.deadline, "New deadline must be later than current deadline");
        project.deadline = newDeadline;
    }

    function evaluateProject(uint projectId) public {
        Project storage project = projects[projectId];
        require(block.timestamp > project.deadline, "Project is still active");
        require(!project.evaluated, "Project already evaluated");

        project.evaluated = true;
        if (project.fundingReceived >= project.fundingGoal) {
            project.isSuccessful = true;
            totalSuccessfulProjects++;
        } else {
            project.isSuccessful = false;
            totalFailedProjects++;
        }
    }

    function getTotalSuccessfulProjects() public view returns (uint) {
        return totalSuccessfulProjects;
    }

    function getTotalFailedProjects() public view returns (uint) {
        return totalFailedProjects;
    }

    function withdrawCommission() public onlyAdmin {
        uint amount = commissionCollected;
        commissionCollected = 0;
        payable(admin).transfer(amount);
    }

    // Allow contract to receive ETH
    receive() external payable {}
}
