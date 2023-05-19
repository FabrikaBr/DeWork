pragma solidity ^0.8.0;

contract DeWork4UsContract {
    struct Job {
        string title;
        string description;
        uint256 payment;
        address employer;
        bool completed;
        uint256 teamScopeRelationshipId;
    }

    Job[] public jobs;

    function createJob(string memory _title, string memory _description, uint256 _payment, uint256 _teamScopeRelationshipId) public {
        Job memory newJob = Job(_title, _description, _payment, msg.sender, false, _teamScopeRelationshipId);
        jobs.push(newJob);
    }

    function completeJob(uint256 _jobId) public {
        require(_jobId < jobs.length, "Invalid job ID");
        Job storage job = jobs[_jobId];
        require(job.employer == msg.sender, "You are not the employer of this job");
        job.completed = true;
    }

    function getJob(uint256 _jobId) public view returns (string memory, string memory, uint256, address, bool, uint256) {
        require(_jobId < jobs.length, "Invalid job ID");
        Job storage job = jobs[_jobId];
        return (job.title, job.description, job.payment, job.employer, job.completed, job.teamScopeRelationshipId);
    }
}

contract TeamScopeContract {
    struct Relationship {
        uint256 relationshipId;
        address teamScopeMember;
        address deWork4UsMember;
    }

    Relationship[] public relationships;

    function createRelationship(address _teamScopeMember, address _deWork4UsMember) public {
        Relationship memory newRelationship = Relationship(relationships.length, _teamScopeMember, _deWork4UsMember);
        relationships.push(newRelationship);
    }

    function getRelationship(uint256 _relationshipId) public view returns (address, address) {
        require(_relationshipId < relationships.length, "Invalid relationship ID");
        Relationship storage relationship = relationships[_relationshipId];
        return (relationship.teamScopeMember, relationship.deWork4UsMember);
    }
}
