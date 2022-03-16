import { mapGetters } from 'vuex'

export default {
	data() {
		return {
			USDC: null,
			VREF: null,
		}
	},
	computed: {
		...mapGetters([
			'getABI'
		]),
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
	    formatMoney(number, decPlaces, decSep, thouSep) {
		    decPlaces = isNaN(decPlaces = Math.abs(decPlaces)) ? 2 : decPlaces,
		    decSep = typeof decSep === "undefined" ? "." : decSep;
		    thouSep = typeof thouSep === "undefined" ? "," : thouSep;
		    var sign = number < 0 ? "-" : "";
		    var i = String(parseInt(number = Math.abs(Number(number) || 0).toFixed(20)));
		    var j = (j = i.length) > 3 ? j % 3 : 0;

		    return sign +
		        (j ? i.substr(0, j) + thouSep : "") +
		        i.substr(j).replace(/(\decSep{3})(?=\decSep)/g, "$1" + thouSep) +
		        (decPlaces ? decSep + Math.abs(number - i).toFixed(20).slice(2) : "").slice(0,decPlaces);
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
		this.VREF = window.VREF;
	}
}