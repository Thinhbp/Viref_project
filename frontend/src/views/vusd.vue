<template>
	<div>
		<h2>VUSD <span class="loading" v-if="loading">Loading...</span><div class="subtitle">{{ address }}</div></h2>
		<table border="1" cellpadding="10">
			<thead>
				<tr>
					<td style="text-align: left;">Address</td>
					<td style="text-align: right;">Balance</td>
					<td>Action</td>
				</tr>
			</thead>
			<tbody>
				<tr v-for="acc in balances">
					<td style="text-align: left; font-size: 15px"><span class="cut-text">{{ acc.address }}</span></td>
					<td style="text-align: right;">{{ formatMoney(formatUSDC(acc.balance)) }}</td>
					<td><button v-if="acc.mine" :disabled="loading" @click="buyToken(acc.address)">Buy</button> <button v-if="acc.mine" :disabled="loading" @click="sellToken(acc.address)">Sell</button></td>
				</tr>
			</tbody>
		</table>
	</div>
</template>
<script type="text/javascript">
import helper from "../helper";
export default {
	props: ['accounts', 'extra'],
	data() {
		return {
			balances: [],
			loading: false
		}
	},
	computed: {
		address() {
			return this.vusd.address
		}
	},
	methods: {
		async buyToken(from) {
			let amount = window.prompt("How much VUSD do you want to buy ?","10");
			if ( !amount ) return;
			this.loading = true;
			amount = this.convertTokenValue(amount);
			let approved = await this.USDC.methods.allowance(from, this.address).call({ from });
			if ( !approved || parseFloat(approved)<amount ) {
				let approve = await this.USDC.methods.approve(this.address, amount).send({ from });
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
	    }
	},
	mounted() {
		this.balances = [...this.accounts, ...this.extra].map(acc => ({
			address: acc,
			balance: 0,
			mine: this.accounts.indexOf(acc)>=0
		}));
		this.getBalances()
	},
	mixins: [helper]
}
</script>
<style scoped>

</style>