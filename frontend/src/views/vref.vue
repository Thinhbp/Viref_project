<template>
	<div>
		<h2>VREF <span class="loading" v-if="loading">Loading...</span><div class="subtitle">{{ vref.address }}</div></h2>
		<table border="1" cellpadding="10" >
			<thead>
				<tr>
					<td style="text-align: left;">Address</td>
					<td style="text-align: right;">Balance</td>
					<!-- <td>Action</td> -->
				</tr>
			</thead>
			<tbody>
				<tr v-for="acc in balances">
					<td style="text-align: left; font-size: 15px"><span class="cut-text">{{ acc.address }}</span></td>
					<td style="text-align: right;">{{ formatMoney(formatCurrency(acc.balance, VREF)) }}</td>
					<!-- <td>
						<button v-if="acc.mine" :disabled="loading" @click="buyToken(acc.address)">Buy</button> <button v-if="acc.mine" :disabled="loading" @click="sellToken(acc.address)">Sell</button></td> -->
				</tr>
			</tbody>
		</table>
		<exchange v-if="balances.length" :address="balances[0].address" 
			@sell="(values) => sellToken(balances[0].address, values)" @buy="(values) => buyToken(balances[0].address, values)" />
	</div>
</template>
<script type="text/javascript">
import helper from "../helper";
import Exchange from "./exchange";

export default {
	props: ['accounts', 'extra'],
	components: { Exchange },
	data() {
		return {
			balances: [],
			loading: false
		}
	},
	methods: {
		async buyToken(from, values) {
			let amount = window.prompt("How much USDC do you want to pay to buy VREF ?", values[0]?values[0]:10);
			if ( !amount ) return;
			this.loading = true;
			amount = parseFloat(amount) * 10**6;
			let approved = await this.USDC.methods.allowance(from, this.vref.address).call({ from });
			if ( !approved || parseFloat(approved)<amount ) {
				let approve = await this.USDC.methods.approve(this.vref.address, amount).send({ from });
				if ( !approve || !approve.status ) {
					this.loading = false;
					this.error = "Contract cannot access your money";
					return false;
				}
			}
	        this.VREF.methods.buyToken(amount, values[1]?values[1]:0).send({ from }).then(result => {
	        	let status = result.status;
	        	if ( status ) window.location.reload();
	        }).finally(e => {
	        	this.loading = false;
	        });
	    },
		async sellToken(from, values) {
			if ( !values ) values = [];
			console.log({values})
			let amount = window.prompt("How much VREF do you want to sell ?", values[0]?values[0]:10);
			if ( !amount ) return;
			this.loading = true;
			amount = BigInt(parseFloat(amount) * 10**18).toString();
			let approved = await this.VREF.methods.allowance(from, this.vref.address).call({ from });
			if ( !approved || parseFloat(approved)<amount ) {
				let approve = await this.VREF.methods.approve(this.vref.address, amount).send({ from });
				if ( !approve || !approve.status ) {
					this.loading = false;
					this.error = "Contract cannot access your money";
					return false;
				}
			}

	        this.VREF.methods.sellToken(amount, values[1]?values[1]:0).send({ from }).then(result => {
	        	let status = result.status;
	        	if ( status ) window.location.reload();
	        }).finally(e => {
	        	this.loading = false;
	        });
	    },
	    async getBalances() {
	      for ( let acc of this.balances ) {
	        acc.balance = await this.VREF.methods.balanceOf(acc.address).call();
	      }
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