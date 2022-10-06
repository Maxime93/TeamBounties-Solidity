from brownie import network, accounts, TeamBounties, Payment
import pytest

from scripts.deploy import deploy

PARTICIPANTS = [accounts[1], accounts[2], accounts[3]]
STAKES = [30,30,40]

@pytest.fixture
def payment(Payment, accounts):
    # deploy the contract with the initial value as a constructor argument
    yield Payment.deploy(PARTICIPANTS, STAKES, {'from': accounts[0]})

@pytest.fixture
def team_bounties(TeamBounties, accounts):
    # deploy the contract with the initial value as a constructor argument
    yield TeamBounties.deploy({'from': accounts[0]})

def test_create_team():
    name = "team1"
    team_bounties.createTeam(name, PARTICIPANTS, STAKES, payment.address, {"from": accounts[0]})
    team = team_bounties.getTeam(0)
    assert team[0] == name
