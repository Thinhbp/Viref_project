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
	    formatCurrency(value, contract) {
	    	return value/10**contract.decimals;
	    },
	    formatMoney(number, decPlaces, decSep, thouSep) {
		    decPlaces = isNaN(decPlaces = Math.abs(decPlaces)) ? 2 : decPlaces,
		    decSep = typeof decSep === "undefined" ? "." : decSep;
		    thouSep = typeof thouSep === "undefined" ? "," : thouSep;
		    var sign = number < 0 ? "-" : "";
		    let parts = number.toString().split(".");
		    let decimals = parts[1] ? parts[1].slice(0, decPlaces) : "";
		    let str = "";
		    let count = 0;
		    for ( let i=parts[0].length-1; i>=0; i-- ) {
		    	str = parts[0][i]+str
		    	if ( count==2 && i!=0 ) {
		    		str = thouSep+str;
		    		count = 0;
		    	} else count++;
		    }

		    return sign + str + (decimals.length ? (decSep + decimals):"");
		},
		async contract(name) {
			let contract = new window.web3.eth.Contract(this[name].abi, this[name].address);
			contract.decimals = await contract.methods.decimals().call();
			return contract
		},
		async connectContract() {
			if ( !window.web3.eth || !this.usdc ) return false;
	        if ( !window.USDC ) {
				window.USDC = await this.contract('usdc');
				window.VREF = await this.contract('vref');
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