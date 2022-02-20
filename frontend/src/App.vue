<template>
  <div id="app" class="bootstrap-wrapper">
    <button @click="connectWallet" v-if="accounts.length==0" class="btn-primary">Connect Wallet</button>
    <div v-if="accounts.length" class="row">
      <div class="col-sm-12 col-md-4">
        <div class="tabs">
          <div class="tab-item" :class="{active: tab=='contract'}" @click="tab='contract'">Contracts</div>
          <div class="tab-item" :class="{active: tab=='history'}" @click="tab='history'">History</div>
        </div>
        <div :style="{display: tab=='contract'?'block':'none'}">
          <usdc :accounts="accounts" :extra="[vusdMetadata.address]" />
          <vusd :accounts="accounts" :extra="[vanMetadata.address]" />
          <van :accounts="accounts" :extra="[vanMetadata.address]" />
        </div>
        <div :style="{display: tab=='history'?'block':'none'}">
          <history />
        </div>
      </div>
      <div class="col-sm-12 col-md-8">
        <chart />
      </div>
    </div>
    <!-- <div id="nav">
      <router-link to="/">Home</router-link> |
      <router-link to="/about">About</router-link>
    </div>
    <router-view/> -->
  </div>
</template>
<script>
const Web3 = require("web3");
const Web3Modal = require("web3modal").default;
const WalletConnectProvider = require("@walletconnect/web3-provider").default;

const usdc = require("./views/usdc").default;
const vusd = require("./views/vusd").default;
const van = require("./views/van").default;
const chart = require("./views/chart").default;
const history = require("./views/history").default;

const vusdMetadata = require("./contract/vusd.json");
const usdcMetadata = require("./contract/usdc.json");
const vanMetadata = require("./contract/van.json");

import './views/grid.css';

export default {
  components: { usdc, vusd, van, chart, history },
  data() {
    return {
      accounts: [],
      loading: true,
      vusdMetadata,
      vanMetadata,
      tab: 'contract'
    }
  },
  methods: {
    async connectWallet() {
      // if (window.ethereum) {
        // await window.ethereum.request({method: 'eth_requestAccounts'});
        // window.web3 = new Web3(window.ethereum);
        const providerOptions = {
          walletconnect: {
            package: WalletConnectProvider, // required
            options: {
              infuraId: "eff8bba2cb8a3a28cf5acd4cd2e3e59c" // required
            }
          }
        };
        const web3Modal = new Web3Modal({
          // network: "mainnet", // optional
          cacheProvider: true, // optional
          providerOptions // required
        });
        let provider;
        try {
          provider = await web3Modal.connect();
        } catch(e) {
          console.log("Could not get a wallet connection", e);
          return;
        }
        window.web3 = new Web3(provider);
        this.getAccounts().then(accounts => {
          this.accounts = accounts;
        })
        return true;
      // }
      // return false;
    },
    async getAccounts() {
      if ( window.ethereum )
        return window.ethereum.request({ method: 'eth_accounts' })
      return [];
    },
    detectEthereum() {
      const { ethereum } = window;
      if (ethereum && ethereum.isMetaMask) {
        console.log('Ethereum successfully detected!');
        // Access the decentralized web!
      } else {
        console.log('Please install MetaMask!');
      }
    }
  },
  mounted() {
    if ( window.ethereum ) {
      this.getAccounts().then(accounts => {
        if ( accounts.length )
          return this.connectWallet();
      }).catch(e => console.log(e)).finally(e => {
        this.loading = false;
      })
    } else {
      window.addEventListener('ethereum#initialized', this.detectEthereum, {
        once: true,
      });

      // If the event is not dispatched by the end of the timeout,
      // the user probably doesn't have MetaMask installed.
      setTimeout(this.detectEthereum, 3000); // 3 seconds
    }
  }
}
</script>
<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}

#nav {
  padding: 30px;
}

#nav a {
  font-weight: bold;
  color: #2c3e50;
}

#nav a.router-link-exact-active {
  color: #42b983;
}
.cut-text { 
  width : 200px;
  overflow:hidden;
  display:inline-block;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.tabs {
  line-height: 40px;
  width: 100%;
  display: inline-block;
}
.tab-item {
  float: left;
  padding: 0 10px;
  border-bottom: 2px solid white;
  cursor: pointer;
}
.tab-item.active {
  border-bottom: 2px solid gray;
}
.btn-primary {
  padding: 10px 20px;
}
</style>
