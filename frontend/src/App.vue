<template>
  <div id="app">
    <button @click="connectWallet">Connect Wallet</button>
    <div v-if="status && accounts.length" class="desk">
      <div class="leftCol">
        <usdc :accounts="usdcAccounts" />
        <vusd :accounts="vusdAccounts" />
        <van :accounts="vanAccounts" />
      </div>
      <div class="rightCol">
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
const usdc = require("./views/usdc").default;
const vusd = require("./views/vusd").default;
const van = require("./views/van").default;
const chart = require("./views/chart").default;

const vusdMetadata = require("./contract/vusd.json");
const usdcMetadata = require("./contract/usdc.json");
const vanMetadata = require("./contract/van.json");

export default {
  components: { usdc, vusd, van, chart },
  data() {
    return {
      accounts: [],
      loading: true,
      status: false
    }
  },
  computed: {
    usdcAccounts() {
      return [...this.accounts, vusdMetadata.address];
    },
    vusdAccounts() {
      return [...this.accounts, vanMetadata.address];
    },
    vanAccounts() {
      return this.accounts;
    }
  },
  methods: {
    async connectWallet() {
      if (window.ethereum) {
        await window.ethereum.request({method: 'eth_requestAccounts'});
        window.web3 = new Web3(window.ethereum);
        this.getAccounts().then(accounts => {
          this.accounts = accounts;
        })
        return true;
      }
      return false;
    },
    async getAccounts() {
      return window.ethereum.request({ method: 'eth_accounts' })
    }
  },
  mounted() {
    web3.eth.net.isListening().then(status => {
      this.status = status;
      if ( status ) {
        this.getAccounts().then(accounts => {
          this.accounts = accounts;
        })
      }
    }).finally(e => {
      this.loading = false;
    });
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
.desk {
  display: flex;
  flex-direction: row;
}
.leftCol {
}
.rightCol {
  flex: 1;
}
</style>
