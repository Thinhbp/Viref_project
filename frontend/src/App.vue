<template>
  <div id="app" class="bootstrap-wrapper">
    <button v-if="!isConnected" @click="connectWallet" class="btn-primary">Connect Wallet</button>
    <div v-if="isConnected && isRightNetwork" class="row">
      <div class="col-sm-12 col-md-4">
        <div class="tabs">
          <div class="tab-item" :class="{active: tab=='contract'}" @click="tab='contract'">Contracts</div>
          <div class="tab-item" :class="{active: tab=='history'}" @click="tab='history'">History</div>
          <button @click="disconnectWallet" class="btn-primary">Disconnect Wallet</button>
          
        </div>
        <div :style="{display: tab=='contract'?'block':'none'}">
          <usdc :accounts="accounts" :extra="[]" />
          <vref :accounts="accounts" :extra="[]" />
        </div>
        <div :style="{display: tab=='history'?'block':'none'}">
          <history />
        </div>
      </div>
      <div class="col-sm-12 col-md-8">
        <chart />
      </div>
    </div>
    <div v-if="isConnected && !isRightNetwork">
      <chain-selection :network-id="networkId" />
    </div>
    <!-- <div id="nav">
      <router-link to="/">Home</router-link> |
      <router-link to="/about">About</router-link>
    </div>
    <router-view/> -->
  </div>
</template>
<script>

import Web3 from "web3";
import Web3Modal from "web3modal";
import WalletConnectProvider from "@walletconnect/web3-provider";

import usdc from "./views/usdc";
import vref from "./views/vref";
import chart from "./views/chart";
import history from "./views/history";
import chainSelection from "./components/ChainSelection";
import { chains } from "./constants/constantNetwork";

import helper from "./helper";
import { mapMutations } from 'vuex'

import './views/grid.css';

export default {
  components: { usdc, vref, chart, history, chainSelection },
  data() {
    return {
      accounts: null,
      loading: true,
      tab: 'contract',
      web3Modal: null,
      networkId: null
    }
  },
  computed: {
    isConnected() {
      const cachedProviderName = JSON.parse(localStorage.getItem("WEB3_CONNECT_CACHED_PROVIDER"));
      return this.accounts && this.accounts.length && cachedProviderName;
    },
    isRightNetwork() {
      return this.usdc && this.usdc.address;
    }
  },
  methods: {
    ...mapMutations(['setChainId']),
    async connectWallet() {
        const providerOptions = {
          walletconnect: {
            package: WalletConnectProvider, // required
            options: {
              infuraId: "1a466cc6a1314f818035d806ffbf7f71" // required
            }
          }
        };
        this.web3Modal = new Web3Modal({
          // network: "mainnet", // optional
          cacheProvider: true, // optional
          providerOptions // required
        });
        let provider;
        try {
          provider = await this.web3Modal.connect();
        } catch(e) {
          console.log("Could not get a wallet connection", e);
          return;
        }
        window.web3 = new Web3(provider);
        this.networkId = await this.getCurrentNetwork();
        this.setChainId(this.networkId);
        return this.getAccounts().then(async accounts => {
          await this.connectContract();
          this.accounts = accounts;
          ethereum.on("chainChanged", () => {
            window.location.reload();
          });
          return true;
        })
    },
    async disconnectWallet() {
      await this.web3Modal.clearCachedProvider();
      window.location.reload();
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
  },
  mixins: [helper]
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
