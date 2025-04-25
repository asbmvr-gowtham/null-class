// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProjectFunding {
    struct Project {
        uint fundingGoal;
        uint fundingReceived;
    }

    mapping(uint => Project) public projects;

    function addProject(uint projectId, uint fundingGoal) public {
        projects[projectId] = Project(fundingGoal, 0);
    }


    function fundProject(uint projectId, uint amount) public {
        projects[projectId].fundingReceived += amount;
    }

    function getRemainingFunding(uint projectId) public view returns (uint) {
        Project memory project = projects[projectId];
        if (project.fundingReceived >= project.fundingGoal) {
            return 0;
        } else {
            return project.fundingGoal - project.fundingReceived;
        }
    }
}
