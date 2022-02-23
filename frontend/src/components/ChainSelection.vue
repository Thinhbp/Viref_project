<template>
  <div class="chain-selection">
    <p>
      <span v-if="networkNameHandler"
        >The current network is:
        <span
          ><strong>{{ networkNameHandler }}</strong></span
        ></span
      >
    </p>
    <!-- <select class="select-box" @change="optionHandler">
      <option value="ethereum">Ethereum Main Network (Mainnet)</option>
      <option value="ropsten">Ropsten Test Network</option>
      <option value="rinkeby">Rinkeby Test Network</option>
      <option value="goerli">Goerli Test Network</option>
      <option value="kovan">Kovan Test Network</option>
    </select> -->
    <button class="btn-submit" @click="switchToRopstenHandler">
      Switch to Ropsten Test Network
    </button>
  </div>
</template>

<script>
const { networkName } = require("../constants/constantNetwork")

const helper = require("../helper").default;

export default {
  data() {
    return {
      networkName: networkName,
      chainId: null,
      isNetworkNameShown: true,
    };
  },
  props: {
    networkId: {
      type: Number,
    },
  },
  computed:{
    networkNameHandler() {
      return Object.keys(networkName).find((key) => networkName[key] === this.networkId);
    }
  },
  methods: {
    // optionHandler(event) {
    //   this.option = event.target.value;
    // },
    // Function to get hex value of corresponding network
    // getHexValue() {
    //   Object.keys(chainId).find((key) => {
    //       if(key == this.option) {
    //         this.chainId = chainId[key]
    //       }
    //   });
    // },
    async switchToRopstenHandler() {
      try {
        await ethereum.request({
          method: "wallet_switchEthereumChain",
          params: [{ chainId: "0x3" }],
        });
        this.onChainChanged()
      } catch (error) {
        console.log(error);
      }
    },
  },
  mixins: [helper]
};
</script>

<style scoped>
.chain-selection {
  text-align: center;
}
.select-box {
  width: 250px;
}
.btn-submit {
  margin: 0 2px;
}
</style>