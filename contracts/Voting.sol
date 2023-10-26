// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import de la bibliothèque "Ownable" d'OpenZeppelin
import "@openzeppelin/contracts/access/Ownable.sol";

 // Contrat Voting
contract Voting is Ownable(msg.sender) {
    // Structures de données
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }

    struct Proposal {
        string description;
        uint voteCount;
    }

    // Structure de données pour les commentaires
    struct Comment {
        address commenter;
        uint proposalId;
        string text;
    }

    // Énumération pour gérer les états du vote
    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistration,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    // Variables de contrat
    WorkflowStatus public workflowStatus;
    uint public winningProposalId;

    // Mappage pour stocker les électeurs
    mapping(address => Voter) public voters;

    // Tableau dynamique de propositions
    Proposal[] public proposals;

    // Tableau dynamique de commentaires
    Comment[] public comments;

    // Événements
    event VoterRegistered(address indexed voterAddress);
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted(address indexed voter, uint proposalId);
    event VotingEnded(uint winningProposalId);

    // Constructeur
    constructor() {
        workflowStatus = WorkflowStatus.RegisteringVoters;
    }

    // Fonction pour inscrire un électeur
    function registerVoter(address voterAddress) public onlyOwner {
        require(workflowStatus == WorkflowStatus.RegisteringVoters, "Le vote est en cours ou termine.");
        require(!voters[voterAddress].isRegistered, "L'electeur est deja inscrit.");

        voters[voterAddress].isRegistered = true;
        emit VoterRegistered(voterAddress);
    }

    // Fonction pour commencer la session d'enregistrement des propositions
    function startProposalsRegistration() public onlyOwner {
        require(workflowStatus == WorkflowStatus.RegisteringVoters, "Le vote est en cours ou termine.");

        workflowStatus = WorkflowStatus.ProposalsRegistration;
        emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters, WorkflowStatus.ProposalsRegistration);
    }

    // Fonction pour enregistrer une proposition
    function registerProposal(string memory _description) public {
        require(workflowStatus == WorkflowStatus.ProposalsRegistration, "L'enregistrement de la proposition n'est pas actif.");
        proposals.push(Proposal(_description, 0));
        uint proposalId = proposals.length - 1;
        emit ProposalRegistered(proposalId);
    }

    // Fonction pour terminer l'enregistrement des propositions
    function closeProposalsRegistration() public onlyOwner {
        require(workflowStatus == WorkflowStatus.ProposalsRegistration, "L'enregistrement de la proposition n'est pas actif.");

        workflowStatus = WorkflowStatus.VotingSessionStarted;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistration, WorkflowStatus.VotingSessionStarted);
    }

    // Fonction pour commencer la session de vote
    function startVotingSession() public onlyOwner {
        require(workflowStatus == WorkflowStatus.VotingSessionStarted, "L'enregistrement des propositions n'est pas termine.");

        workflowStatus = WorkflowStatus.VotesTallied;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted, WorkflowStatus.VotesTallied);
    }

    // Fonction pour voter pour une proposition
    function vote(uint _proposalId) public {
        require(workflowStatus == WorkflowStatus.VotesTallied, "La session de vote n'est pas active.");
        require(voters[msg.sender].isRegistered, "Vous n'etes pas inscrit pour voter.");
        require(!voters[msg.sender].hasVoted, "Vous avez deja vote.");
        require(_proposalId < proposals.length, "La proposition n'existe pas.");

        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedProposalId = _proposalId;
        proposals[_proposalId].voteCount++;
        emit Voted(msg.sender, _proposalId);
    }

    // Fonction pour terminer la session de vote et déterminer le gagnant
    function endVotingSession() public onlyOwner {
        require(workflowStatus == WorkflowStatus.VotesTallied, "La session de vote n'est pas active.");

        uint maxVoteCount = 0;
        for (uint i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > maxVoteCount) {
                maxVoteCount = proposals[i].voteCount;
                winningProposalId = i;
            }
        }

        workflowStatus = WorkflowStatus.VotingSessionEnded;
        emit VotingEnded(winningProposalId);
    }

    // Fonction pour obtenir le gagnant
    function getWinner() public view returns (uint) {
        require(workflowStatus == WorkflowStatus.VotingSessionEnded, "Le depouillement des votes n'est pas termine.");
        return winningProposalId;
    }


    //Nouvelles fonctionnalités : 

    // Fonction pour supprimer la proposition et en proposer une autre
    function resetVote() public onlyOwner {
        workflowStatus = WorkflowStatus.RegisteringVoters;
        delete proposals;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded, WorkflowStatus.RegisteringVoters);
    }

    // Fonction pour ajouter un commentaire à une proposition
    function addComment(uint _proposalId, string memory _text) public {
        require(voters[msg.sender].isRegistered, "Vous n'etes pas un electeur inscrit.");
        require(_proposalId < proposals.length, "Proposition invalide.");
        require(workflowStatus == WorkflowStatus.VotingSessionStarted, "La session de vote n'est pas active.");

        Comment memory newComment;
        newComment.commenter = msg.sender;
        newComment.proposalId = _proposalId;
        newComment.text = _text;

        comments.push(newComment);
    }
}

