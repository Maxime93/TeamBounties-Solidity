from copyreg import constructor
import time

from brownie import accounts, config, TeamBounties, Payment

PARTICIPANTS = [accounts[1], accounts[2], accounts[3]]
STAKES = [30,30,40]

def deploy():
    print("Deploying Payment contract")
    payment = Payment.deploy(PARTICIPANTS, STAKES, {"from": accounts[0]})

    print("Deploying TeamBounties contract")
    team_bounties = TeamBounties.deploy({"from": accounts[0]})

    print("Creating a team")
    team_bounties.createTeam("team1", PARTICIPANTS, STAKES, payment.address, {"from": accounts[0]})
    print(team_bounties.getTeam(0))

    print("Balances:")
    for account in accounts:
        print(account.balance())

    print("Paying the team")
    team_bounties.payTeam(0, {"from": accounts[5], "value":100000000000000000000})
    print(team_bounties.getTeam(0))

    print("Voting to withdraw")
    team_bounties.voteWithdraw(0, {"from": accounts[1]})
    print(team_bounties.getTeam(0))

    print("Voting to withdraw")
    team_bounties.voteWithdraw(0, {"from": accounts[3]})
    print(team_bounties.getTeam(0))

    print("Balances before getting paid:")
    for account in accounts:
        print(account.balance())

    print("Withdraw funds to PaymentSplitter")
    team_bounties.withdraw(0, {"from": accounts[2]})
    print(team_bounties.getTeam(0))

    print("Now missing ether is in the Payments contract..")
    print("total shares: ", payment.totalShares())
    print("total released: ", payment.totalShares())

    payment.release(accounts[1])
    payment.release(accounts[2])
    payment.release(accounts[3])

    time.sleep(3)

    print("Balances after getting paid:")
    for account in accounts:
        print(account.balance())

    print("We can see the reward has been paid out correctly.")
    print(team_bounties.getTeam(0))

    print("Proposing a collegue to the team")
    team_bounties.proposeParticipant(accounts[4], 10, 0, {"from":accounts[2]})
    print(team_bounties.getTeam(0))

    print("Voting for new participant")
    team_bounties.voteNewParticipant(accounts[4], 0, {"from":accounts[1]})
    team_bounties.voteNewParticipant(accounts[4], 0, {"from":accounts[3]})

    print(team_bounties.getTeam(0))
    return team_bounties

def main():
    deploy()
