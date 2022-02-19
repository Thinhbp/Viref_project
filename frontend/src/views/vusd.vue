<template>
	<div>
		<h2>VUSD <span class="loading" v-if="loading">Loading...</span><div class="subtitle">{{ address }}</div></h2>
		<table border="1" cellpadding="10">
			<thead>
				<tr>
					<td>Address</td>
					<td>Balance</td>
					<td>Action</td>
				</tr>
			</thead>
			<tbody>
				<tr v-for="acc in balances">
					<td>{{ acc.address }}</td>
					<td>{{ formatMoney(formatUSDC(acc.balance)) }}</td>
					<td><button :disabled="loading" @click="buyToken(acc.address)">Buy</button> <button :disabled="loading" @click="sellToken(acc.address)">Sell</button></td>
				</tr>
			</tbody>
		</table>
	</div>
</template>
<script type="text/javascript">
const vusd = require("../contract/vusd.json");
const usdc = require("../contract/usdc.json");
export default {
	props: ['accounts'],
	data() {
		return {
			VUSD: null,
			balances: [],
			loading: false,
			address: vusd.address
		}
	},
	methods: {
		async buyToken(from) {
			let amount = window.prompt("How much VUSD do you want to buy ?","10");
			if ( !amount ) return;
			this.loading = true;
			amount = this.convertTokenValue(amount);
			let approved = await this.USDC.methods.allowance(from, vusd.address).call({ from });
			if ( !approved || parseFloat(approved)<amount ) {
				let approve = await this.USDC.methods.approve(vusd.address, amount).send({ from });
				if ( !approve || !approve.status ) {
					this.loading = false;
					this.error = "Contract cannot access your money";
					return false;
				}
			}
	        this.VUSD.methods.buyToken(amount).send({ from }).then(result => {
	        	let status = result.status;
	        	if ( status ) window.location.reload();
	        }).finally(e => {
	        	this.loading = false;
	        });
	    },
		async sellToken(from) {
			let amount = window.prompt("How much VUSD do you want to sell ?","10");
			if ( !amount ) return;
			this.loading = true;
	        this.VUSD.methods.sellToken(this.convertTokenValue(amount)).send({ from }).then(result => {
	        	let status = result.status;
	        	if ( status ) window.location.reload();
	        }).finally(e => {
	        	this.loading = false;
	        });
	    },
	    async getBalances() {
	      for ( let acc of this.balances ) {
	        acc.balance = await this.VUSD.methods.balanceOf(acc.address).call();
	      }
	    },
	    convertTokenValue(amount) {
	    	return parseFloat(amount) * 10**6;
	    },
	    formatUSDC(value) {
	      return value/10**6;
	    },
	    formatMoney(price) {
	    	let dollarUSLocale = Intl.NumberFormat('en-US');
	    	return dollarUSLocale.format(price)
	    }
	},
	mounted() {
		this.VUSD = new web3.eth.Contract(vusd.abi, vusd.address);
		this.USDC = new web3.eth.Contract(usdc.abi, usdc.address);
		this.balances = this.accounts.map(acc => ({
			address: acc,
			balance: 0
		}));
		this.getBalances()
	}
}
</script>
<style scoped>

</style>