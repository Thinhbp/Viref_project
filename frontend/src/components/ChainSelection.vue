<template>
  <div class="chain-selection">
    <p>Your current blockchain network is not supported. Please switch to one of these networks.</p>
    <p v-for="net,name in supportedNetworks">
      <button class="btn-submit" @click="switchNetworkHandler(net.id)">
        Switch to {{ name }}
      </button>
    </p>
  </div>
</template>

<script>
import { chains } from "../constants/constantNetwork";
import helper from "../helper";
import { mapGetters } from 'vuex';

export default {
  data() {
    return {
      chainId: null,
    };
  },
  props: {
    networkId: {
      type: Number,
    },
  },
  computed:{
    ...mapGetters(['supportedNetworks']),
  },
  methods: {
    async switchNetworkHandler(chainId) {
      try {
        await ethereum.request({
          method: "wallet_switchEthereumChain",
          params: [{ chainId: "0x"+chainId.toString(16) }],
        });
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