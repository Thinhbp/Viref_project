<template>
	<div>
		<h2>VAN <span class="loading" v-if="loading">Loading...</span><div class="subtitle">{{ address }}</div></h2>
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
					<td>{{ formatMoney(formatVAN(acc.balance)) }}</td>
					<td><button :disabled="loading" @click="buyToken(acc.address)">Buy</button> <button :disabled="loading" @click="sellToken(acc.address)">Sell</button></td>
				</tr>
			</tbody>
		</table>
	</div>
</template>
<script type="text/javascript">
const vusd = require("../contract/vusd.json");
const usdc = require("../contract/usdc.json");
const van = require("../contract/van.json");
export default {
	props: ['accounts'],
	data() {
		return {
			VUSD: null,
			USDC: null,
			VAN: null,
			balances: [],
			loading: false,
			address: van.address
		}
	},
	methods: {
		async buyToken(from) {
			let amount = window.prompt("How much VUSD do you want to pay to buy VAN ?","10");
			if ( !amount ) return;
			this.loading = true;
			amount = parseFloat(amount) * 10**6;
			let approved = await this.VUSD.methods.allowance(from, van.address).call({ from });
			if ( !approved || parseFloat(approved)<amount ) {
				let approve = await this.VUSD.methods.approve(van.address, amount).send({ from });
				if ( !approve || !approve.status ) {
					this.loading = false;
					this.error = "Contract cannot access your money";
					return false;
				}
			}
	        this.VAN.methods.buyToken(amount).send({ from }).then(result => {
	        	let status = result.status;
	        	if ( status ) window.location.reload();
	        }).finally(e => {
	        	this.loading = false;
	        });
	    },
		async sellToken(from) {
			let amount = window.prompt("How much VAN do you want to sell ?","10");
			if ( !amount ) return;
			this.loading = true;
			amount = BigInt(parseFloat(amount) * 10**18).toString();
			let approved = await this.VAN.methods.allowance(from, van.address).call({ from });
			console.log({approved})
			if ( !approved || parseFloat(approved)<amount ) {
				let approve = await this.VAN.methods.approve(van.address, amount).send({ from });
				if ( !approve || !approve.status ) {
					this.loading = false;
					this.error = "Contract cannot access your money";
					return false;
				}
			}

	        this.VAN.methods.sellToken(amount).send({ from }).then(result => {
	        	let status = result.status;
	        	if ( status ) window.location.reload();
	        }).finally(e => {
	        	this.loading = false;
	        });
	    },
	    async getBalances() {
	      for ( let acc of this.balances ) {
	        acc.balance = await this.VAN.methods.balanceOf(acc.address).call();
	      }
	    },
	    formatVAN(value) {
	      return value/10**18;
	    },
	    getLogs() {
	    	web3.eth.getPastLogs({fromBlock:'0x0',address:van.address})
			.then(res => {
			  res.forEach(rec => {
			    // console.log(rec.blockNumber, rec.transactionHash, rec.topics);
			    web3.eth.getTransaction(rec.transactionHash).then(res => {
			    	console.log(res)
			    })
			  });
			}).catch(err => console.log("getPastLogs failed", err));
	    },
	    formatMoney(price) {
	    	let dollarUSLocale = Intl.NumberFormat('en-US');
	    	return dollarUSLocale.format(price)
	    }
	},
	mounted() {
		this.VUSD = new web3.eth.Contract(vusd.abi, vusd.address);
		// this.USDC = new web3.eth.Contract(usdc.abi, usdc.address);
		this.VAN = new web3.eth.Contract(van.abi, van.address);
		this.balances = this.accounts.map(acc => ({
			address: acc,
			balance: 0
		}));
		this.getBalances()
		// this.getLogs();
	}
}
</script>
<style scoped>

</style>