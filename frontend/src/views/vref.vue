<template>
	<div>
		<h2>VREF <span class="loading" v-if="loading">Loading...</span><div class="subtitle">{{ address }}</div></h2>
		<table border="1" cellpadding="10" >
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
					<td style="text-align: right;">{{ formatMoney(formatVREF(acc.balance)) }}</td>
					<td><button v-if="acc.mine" :disabled="loading" @click="buyToken(acc.address)">Buy</button> <button v-if="acc.mine" :disabled="loading" @click="sellToken(acc.address)">Sell</button></td>
				</tr>
			</tbody>
		</table>
	</div>
</template>
<script type="text/javascript">
const vusd = require("../contract/vusd.json");
const usdc = require("../contract/usdc.json");
const vref = require("../contract/vref.json");
const helper = require("../helper").default;
export default {
	props: ['accounts', 'extra'],
	data() {
		return {
			VUSD: null,
			USDC: null,
			VREF: null,
			balances: [],
			loading: false,
			address: vref.address
		}
	},
	methods: {
		async buyToken(from) {
			let amount = window.prompt("How much VUSD do you want to pay to buy VREF ?","10");
			if ( !amount ) return;
			this.loading = true;
			amount = parseFloat(amount) * 10**6;
			let approved = await this.VUSD.methods.allowance(from, vref.address).call({ from });
			if ( !approved || parseFloat(approved)<amount ) {
				let approve = await this.VUSD.methods.approve(vref.address, amount).send({ from });
				if ( !approve || !approve.status ) {
					this.loading = false;
					this.error = "Contract cannot access your money";
					return false;
				}
			}
	        this.VREF.methods.buyToken(amount).send({ from }).then(result => {
	        	let status = result.status;
	        	if ( status ) window.location.reload();
	        }).finally(e => {
	        	this.loading = false;
	        });
	    },
		async sellToken(from) {
			let amount = window.prompt("How much VREF do you want to sell ?","10");
			if ( !amount ) return;
			this.loading = true;
			amount = BigInt(parseFloat(amount) * 10**18).toString();
			let approved = await this.VREF.methods.allowance(from, vref.address).call({ from });
			if ( !approved || parseFloat(approved)<amount ) {
				let approve = await this.VREF.methods.approve(vref.address, amount).send({ from });
				if ( !approve || !approve.status ) {
					this.loading = false;
					this.error = "Contract cannot access your money";
					return false;
				}
			}

	        this.VREF.methods.sellToken(amount).send({ from }).then(result => {
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
		this.VUSD = new web3.eth.Contract(vusd.abi, vusd.address);
		// this.USDC = new web3.eth.Contract(usdc.abi, usdc.address);
		this.VREF = new web3.eth.Contract(vref.abi, vref.address);
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