// ./frontend/src/App.js
import React, { Component } from "react"
import Voting from "./artifacts/contracts/Voting.sol/Voting.json"
import getWeb3 from "./getWeb3.js"
import "./App.css"

class App extends Component {
  state = {
    web3: null,
    accounts: [],
    contract: null,
    userAddress: null,
    isOwner: false,
  }

  // componentDidMount : méthode qui permet de lancer une fonction au moment ou app.js est instancié, si la page se lance bien elle envoie componentDidMount

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3()

      // Use web3 to get the user's accounts.
      /* on récupère le tableau des comptes sur le metamask du user */
      let accounts = await web3.eth.getAccounts()
      console.log(accounts)

  
      /* Création de l'objet de contrat avec l'abi et l'addresse du contrat  */
      const instance = new web3.eth.Contract(
        Voting.abi,
        "0xeFb802c9FAa5EAf28D794A8E5Fa94826Db4167Da"
      )

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState({ web3, accounts, contract: instance })
      console.log(this.state)
      // let account = this.state.accounts[0]

      this.setState({
        userAddress: accounts[0].slice(0, 6) + "..." + accounts[0].slice(38, 42),
      })

			// Check if the user is the owner
      const owner = await instance.methods.owner().call()
      if (accounts[0] === owner) {
        this.setState({
          isOwner: true,
        })
      }

    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`
      )
      console.error(error)
    }
  }
  render() {
    return (
      <div className="App">
        <div className="flex flex-col justify-between min-h-screen">
          <div className="flex-1">
            <header>
              <nav className="bg-yellow-10 border-yellow-30  z-50 fixed w-full">
                <div className="sm:px-6 sm:py-3 md:px-8 md:py-6 flex flex-row items-center justify-between border border-b">
                  <div className="flex flex-row items-center">
                    <a className="logo md:w-170 w-80" href="/">
                      Vote DApp
                    </a>
                  </div>
                  <div className="flex">
                    <button className="p-1 block md:hidden">
                      <svg
                        stroke="currentColor"
                        fill="currentColor"
                        strokeWidth="0"
                        viewBox="0 0 24 24"
                        className="h-8 w-auto"
                        height="1em"
                        width="1em"
                        xmlns="http://www.w3.org/2000/svg"
                      >
                        <path d="M3 18h18v-2H3v2zm0-5h18v-2H3v2zm0-7v2h18V6H3z"></path>
                      </svg>
                    </button>
                  </div>
                  <ul className="hidden list-none md:flex flex-row gap-4 items-baseline ml-10">
                    <li>
                      <button
                        id="web3-status-connected"
                        className="web3-button"
                      >
                        <p className="Web3StatusText">
                          {this.state.userAddress}
                        </p>
                        <div
                          size="16"
                          className="Web3Status__IconWrapper-sc-wwio5h-0 hqHdeW"
                        >
                          <div className="Identicon__StyledIdenticon-sc-1ssoit4-0 kTWLky">
                            <span>
                              <div className="avatar">
                                <svg x="0" y="0" width="16" height="16">
                                  <rect
                                    x="0"
                                    y="0"
                                    width="16"
                                    height="16"
                                    transform="translate(-1.1699893080448718 -1.5622487594391614) rotate(255.7 8 8)"
                                    fill="#2379E1"
                                  ></rect>
                                  <rect
                                    x="0"
                                    y="0"
                                    width="16"
                                    height="16"
                                    transform="translate(4.4919645360147475 7.910549295855059) rotate(162.8 8 8)"
                                    fill="#03595E"
                                  ></rect>
                                  <rect
                                    x="0"
                                    y="0"
                                    width="16"
                                    height="16"
                                    transform="translate(11.87141302372359 2.1728091065947037) rotate(44.1 8 8)"
                                    fill="#FB1877"
                                  ></rect>
                                </svg>
                              </div>
                            </span>
                          </div>
                        </div>
                      </button>
                    </li>
                  </ul>
                </div>
              </nav>
            </header>
          </div>
        </div>
      </div>
    )
  }
}
export default App