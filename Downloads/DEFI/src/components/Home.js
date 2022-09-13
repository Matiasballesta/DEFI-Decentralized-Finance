import React, { Component } from 'react';

import JamToken from '../abis/JamToken.json';//Token para Staking
import StellarToken from '../abis/StellarToken.json';//Token para emitir recompensa de staking
import TokenFarm from '../abis/TokenFarm.json';//Contrato que gestiona ambos tokens
import Web3 from 'web3'; //Obtener la info de la blockchain
import logo from '../logo.png';
import Navigation from './Navbar';
import MyCarousel from './Carousel';
import Main from './Main'

class App extends Component {

  async componentDidMount() {
    // 1. Carga de Web3
    await this.loadWeb3()
    // 2. Carga de datos de la Blockchain
    await this.loadBlockchainData()
  }

  // 1. Carga de Web3 para la obtencion de cuentas
  async loadWeb3() {
    if (window.ethereum) {
      console.log('what', window.ethereum)
      window.web3 = new Web3(window.ethereum)
      const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
      console.log('Accounts: ', accounts)
    }
    else if (window.web3) {
      window.web3 = new Web3(window.web3.currentProvider)
    }
    else {
      window.alert('¡Deberías considerar usar Metamask!')
    }
  }

  // 2. Carga de datos de la Blockchain
  async loadBlockchainData() {
    const web3 = window.web3
    const accounts = await web3.eth.getAccounts()
    console.log(accounts)
    this.setState({ account: accounts[0] })
    // Ganache -> 5777, Rinkeby -> 4, BSC -> 97
    const networkId = await web3.eth.net.getId() 
    console.log('networkid:', networkId)

    //Carga del JamToken (Tokens para hacer staking)
    const jamTokenData = JamToken.networks[networkId];
    if(jamTokenData){
      const jamToken = new web3.eth.Contract(JamToken.abi, jamTokenData.address)
      this.setState({jamToken: jamToken})
      let jamTokenBalance = await jamToken.methods.balanceOf(this.state.account).call()
      this.setState({jamTokenBalance: jamTokenBalance.toString()})
      
      //Cuando yo obtenga info de la blockchain hacemos un CALL
      //Cuando envie info a la blockchain hacemos un send
    } else{
      window.alert("El JamToken no se ha desplegado en")
    }

   // Carga de Stellar Token
    const stellarTokenData = StellarToken.networks[networkId];
    if(stellarTokenData){
      const stellarToken = new web3.eth.Contract(StellarToken.abi, stellarTokenData.address)
      this.setState({stellarToken: stellarToken})
      //console.log('stellaChota:', stellarToken)
      let stellarTokenBalance = await stellarToken.methods.balanceOf(this.state.account).call()
      this.setState({stellarTokenBalance: stellarTokenBalance.toString()})
      //console.log(stellarTokenBalance)
    } else{
      window.alert("El JamToken no se ha desplegado en la red")
    }

    const tokenFarmData = TokenFarm.networks[networkId];
    if(tokenFarmData) {
      const tokenFarm = new web3.eth.Contract(TokenFarm.abi, tokenFarmData.address);
      this.setState({tokenFarm: tokenFarm})
      console.log(tokenFarm)
      let stakingBalance = await tokenFarm.methods.stakingBalance(this.state.account).call()
      this.setState({stakingBalance: stakingBalance.toString()});
    }else{
      window.alert("TokenFarm no se ha desplegado en la red")
    }

    this.setState({loading: false})

  }

/* The above code is a function that allows the user to stake tokens. */
  stakeTokens = (amount) => {
    this.setState({loading: true})
    this.state.jamToken.methods.approve(this.state.tokenFarm._address, amount).send({
      from: this.state.account
    }).on('transactionHash', (hash) => {
      this.state.tokenFarm.methods.stakeTokens(amount).send({from: this.state.account})
      .on('transactionHash', (hash) => {
      this.setState({loading: false})
      })
    })

  }

    unstakeTokens = (amount) => {
      this.setState({loading: true})
      this.state.tokenFarm.methods.unStakeTokens().send({from: this.state.account})
      .on('transactionHash', (hash) => {
        this.setState({loading: false})
      })
  }
  

  constructor(props) {
    super(props)
    this.state = {
      account: '0x0',
      loading: true,
      jamToken: {},
      jamTokenBalance: '0',
      stellarToken: {},
      stellarTokenBalance: '0',
      tokenFarm: {},
      stakingBalance: '0'
    }
  }

  render() {

    let content
    if(this.state.loading){
      content = <p id="loader" className="text-center">Loading..</p>
    }else{
      content = <Main
          jamTokenBalance={this.state.jamTokenBalance}
          stellarTokenBalance={this.state.stellarTokenBalance}
          stakingBalance={this.state.stakingBalance}
          stakeTokens={this.stakeTokens}
          unstakeTokens={this.unstakeTokens}
      />
    }
    return (
      <div>
        <Navigation account={this.state.account} />
        <MyCarousel />
        <div className="container-fluid mt-5">
          <div className="row">
            <main role="main" className="col-lg-12 d-flex text-center">
              <div className="content mr-auto ml-auto">

                {content}


              </div>
            </main>
          </div>
        </div>
      </div>
    );
  }
}

export default App;
