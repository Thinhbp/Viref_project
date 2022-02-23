export default {
	methods: {
		formatVAN(value) {
	      return web3.utils.fromWei(value.toString());
	    },
	    formatMoney(price) {
	    	let dollarUSLocale = Intl.NumberFormat('en-US');
	    	return dollarUSLocale.format(price)
	    },
	    formatUSDC(value) {
	      return value/10**6;
	    },
		async onChainChanged() {			
			await ethereum.on("chainChanged", () => {
				window.location.reload();
			});
		}
	}
}