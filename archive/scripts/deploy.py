import json
import os

from solcx import compile_standard, install_solc
from web3 import Web3
from dotenv import load_dotenv

load_dotenv()

team_contract = "TeamBounties.sol"
payment_splitter_contract = "Payment.sol"

with open(f"./contracts/{team_contract}") as f:
    contract = f.read()

install_solc("0.8.0")
team_contract_sol = compile_standard(
    {
        "language":"Solidity",
        "sources":{"TeamBounties.sol": {"content": contract}},
        "settings": {
            "outputSelection": {"*": {"*": ["abi", "metadata", "evm.bytecode", "evm.sourceMap"]}}
        }
    },
    solc_version="0.8.0"
)

def main():
    with open(f"./contracts/{team_contract}.json", "w") as f:
        json.dump(team_contract_sol, f)

    # Get bytecode
    team_bounties_bytes = team_contract_sol["contracts"]["TeamBounties.sol"]["TeamBounties"]["evm"]["bytecode"]["object"]
    # Get ABI
    team_bounties_abi = team_contract_sol["contracts"]["TeamBounties.sol"]["TeamBounties"]["abi"]

    # Create a local blockchain using GanacheCli
    # w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:8545"))
    w3 = Web3(Web3.HTTPProvider("https://rinkeby.infura.io/v3/b9558799c57a4be2a97d00fc63f6e794"))
    chain_id = 4
    my_address = "0x13B945CC6aFe41Fb3215e82ff4825819C9cA271D"
    # my_address = "0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1"
    private_key = os.getenv("PRIVATE_KEY")

    # Create the contract in python
    TeamBounties = w3.eth.contract(abi=team_bounties_abi, bytecode=team_bounties_bytes)
    # Get the latest transaction
    nonce = w3.eth.getTransactionCount(my_address)

    MAX_GAS_ETHER = 0.0005
    gas_price = float(w3.fromWei(w3.eth.gas_price, 'ether'))
    allowed_gas = int(MAX_GAS_ETHER/gas_price)

    # 1. Build a transaction
    transaction = TeamBounties.constructor().buildTransaction({
        "gasPrice": w3.eth.gas_price,
        "chainId": chain_id,
        "from": my_address,
        "nonce": nonce
    })

    # 2. Sign the transaction
    signed_txn = w3.eth.account.sign_transaction(transaction, private_key=private_key)
    # 3. Send the transaction
    tx_hash = w3.eth.send_raw_transaction(signed_txn.rawTransaction)
    # 4. Wait for transaction confirmation
    tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)


    # Interact with contract
    team_bounties = w3.eth.contract(address=tx_receipt.contractAddress, abi=team_bounties_abi)
    participants = ['0xC01bf15E7E7b0d71F00eD22D4Bbb381bCbAA4342', '0x8688E0262B57C6D8EfC4850b899D767b1BF1353b', '0x6AC5F9620af1948CFBF2A3FaD1d48740c7ABD370']
    stakes = [30,30,40]
    payment_split_address = '0xB4c7CbE043dC3B7CB4ebDC9e64506690e226b273'

    create_team_transaction = team_bounties.functions.createTeam("team1", participants, stakes, payment_split_address).buildTransaction(
        {
            "gasPrice": w3.eth.gas_price,
            "chainId": chain_id,
            "from": my_address,
            "nonce": nonce + 1
        }
    )
    signed_create_team_txn = w3.eth.account.sign_transaction(
        create_team_transaction, private_key=private_key
    )
    create_team_tx_hash = w3.eth.send_raw_transaction(signed_create_team_txn.rawTransaction)
    create_team_tx_receipt = w3.eth.wait_for_transaction_receipt(create_team_tx_hash)
    data = team_bounties.functions.getTeam(0).call()
    print(data)

if __name__ == "__main__":
    main()