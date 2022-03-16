<template>
	<div>
		<h2>USDC <span class="loading" v-if="loading">Loading...</span><div class="subtitle">{{ usdc.address }}</div></h2>
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
					<td><button :disabled="loading" @click="mintToken(acc.address)" v-if="acc.mine">mintToken</button></td>
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
	methods: {
		async mintToken(from) {
			let amount = window.prompt("How much USDC do you want ?","1000");
			if ( !amount ) return;
			this.loading = true;
	        this.USDC.methods.mintToken(parseFloat(amount) * 10**6).send({ from }).then(result => {
	        	let status = result.status;
	        	if ( status ) this.getBalances();
	        }).finally(e => {
	        	this.loading = false;
	        });
	    },
	    async getBalances() {
	      for ( let acc of this.balances ) {
	        acc.balance = await this.USDC.methods.balanceOf(acc.address).call();
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
<style>
h2 {
	text-align: left;
}
.subtitle {
	color: gray;
	font-weight: normal;
	font-size: 14px;
}
.loading {
	color:  gray;
}
</style>