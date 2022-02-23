<template>
  <div class="chain-selection">
    <p>
      <span
        >The current network is:
        <span
          ><strong>{{ networkNameHandler(networkId) }}</strong></span
        ></span
      >
    </p>
    <select class="select-box" @change="optionHandler">
      <option value="ethereum">Ethereum Main Network (Mainnet)</option>
      <option value="ropsten">Ropsten Test Network</option>
      <option value="rinkeby">Rinkeby Test Network</option>
      <option value="goerli">Goerli Test Network</option>
      <option value="kovan">Kovan Test Network</option>
    </select>
    <button class="btn-submit" @click="changeNetworkHandler">
      Change Network
    </button>
  </div>
</template>

<script>
const {chainId, networkName} = require("../constants/constantNetwork")

const helper = require("../helper").default;

export default {
  data() {
    return {
      option: "ethereum",
      networkName: networkName,
      chainId: null
    };
  },
  props: {
    networkId: {
      type: Number,
      require: true,
    },
  },
  methods: {
    optionHandler(event) {
      this.option = event.target.value;
    },
    getHexValue() {
      Object.keys(chainId).find((key) => {
          if(key == this.option) {
            this.chainId = chainId[key]
          }
      });
    },
    async changeNetworkHandler() {
      await this.getHexValue()
      try {
        await ethereum.request({
          method: "wallet_switchEthereumChain",
          params: [{ chainId: this.chainId }],
        });
        this.onChainChanged()
      } catch (error) {
        console.log(error);
      }
    },
    networkNameHandler(id) {
      return Object.keys(networkName).find((key) => networkName[key] === id);
    },
  },
  mixins: [helper]
};
</script>

<style scoped>
.chain-selection {
  width: 90%;
}
.select-box {
  width: 250px;
}
.btn-submit {
  margin: 0 2px;
}
</style>