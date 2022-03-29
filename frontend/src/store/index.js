import Vue from 'vue';
import Vuex from 'vuex';
import usdc from "../contract/usdc.json";
import vref from "../contract/vref.json";
import chains from '../constants/constantNetwork';
const contracts = { usdc, vref };

Vue.use(Vuex)

function initState() {
  let chainNames = Object.keys(chains);
  let supportedNetworks = {};
  for ( let chain of chainNames ) {
    if ( contracts.vref.address[chain] )
      supportedNetworks[chain] = {
        symbol: chain,
        ...chains[chain]
      };
  }
  return {
    chainId: 0,
    history: [],
    selectedTx: -1,
    supportedNetworks
  }
}

export default new Vuex.Store({
  state: initState(),
  mutations: {
    setChainId(state, id) {
      state.chainId = id;
    },
    setHistory(state, history) {
      state.history = history;
    },
    setSelectedTx(state, tx) {
      state.selectedTx = tx;
    }
  },
  actions: {
  },
  getters: {
    getABI: state => id => {
      let chain = Object.values(state.supportedNetworks).find(c => c.id==state.chainId);
      if ( !chain ) return null;
      return {
        address: contracts[id].address[chain.symbol],
        abi: contracts[id].abi
      }
    },
    history: state => state.history,
    selectedTx: state => state.selectedTx,
    supportedNetworks: state => state.supportedNetworks,
    chainId: state => state.chainId,
    chainName: state => Object.keys(chains).find(name => chains[name].id==state.chainId)
  }
})
