import { mapGetters } from 'vuex'

export default {
	data() {
		return {
			USDC: null,
			VUSD: null,
			VREF: null,
		}
	},
	computed: {
		...mapGetters([
			'getABI'
		]),
		vusd() {
			return this.getABI('vusd')
		},
		usdc() {
			return this.getABI('usdc')
		},
		vref() {
			return this.getABI('vref')
		}
	},
	methods: {
		formatVREF(value) {
	      return window.web3.utils.fromWei(value.toString());
	    },
	    formatMoney(price) {
	    	let dollarUSLocale = Intl.NumberFormat('en-US');
	    	return dollarUSLocale.format(price)
	    },
	    formatUSDC(value) {
	      return value/10**6;
	    },
		contract(name) {
			return new window.web3.eth.Contract(this[name].abi, this[name].address);
		},
		connectContract() {
			if ( !window.web3.eth || !this.usdc ) return false;
	        if ( !window.USDC ) {
				window.USDC = this.contract('usdc');
				window.VUSD = this.contract('vusd');
				window.VREF = this.contract('vref');
	        }
		},
	    async getCurrentNetwork() {
	      return window.web3.eth.net.getId();
	    },
		async switchNetwork() {
			return window.ethereum.request({
				method: "wallet_switchEthereumChain",
				params: [{ chainId: chainId.bsc }],
	        });
		}
	},
	mounted() {
		this.USDC = window.USDC;
		this.VUSD = window.VUSD;
		this.VREF = window.VREF;
	}
}