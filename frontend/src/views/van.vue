<template>
	<div>
		<h2>VAN <span class="loading" v-if="loading">Loading...</span><div class="subtitle">{{ address }}</div></h2>
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
					<td style="text-align: left; font-size: 15px">{{ acc.address }}</td>
					<td style="text-align: right;">{{ formatMoney(formatVAN(acc.balance)) }}</td>
					<td><button v-if="acc.mine" :disabled="loading" @click="buyToken(acc.address)">Buy</button> <button v-if="acc.mine" :disabled="loading" @click="sellToken(acc.address)">Sell</button></td>
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
	props: ['accounts', 'extra'],
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
			  	const test = web3.eth.abi.decodeParameter('bytes32', rec.topics[0]);
			  	const from = rec.topics[1] ? web3.eth.abi.decodeParameter('address', rec.topics[1]) : '';
				const to = rec.topics[2] ? web3.eth.abi.decodeParameter('address', rec.topics[2]) : '';
				const value = web3.eth.abi.decodeParameter('uint256', rec.data);
				const amount = web3.utils.fromWei(value);
			  	console.log({ test, from, to, value, amount, hash: rec.transactionHash });
			    // console.log(rec.blockNumber, rec.transactionHash, rec.topics);

			    let buyTokenPrefix = web3.eth.abi.encodeFunctionSignature('buyToken(uint256)');
			    let sellTokenPrefix = web3.eth.abi.encodeFunctionSignature('sellToken(uint256)');

			    web3.eth.getTransaction(rec.transactionHash).then(tx => {
		    	    let tx_data = tx.input;
			    	if ( tx_data.indexOf(buyTokenPrefix)==0 ) {
			    		let amount = web3.eth.abi.decodeParameter('uint256', tx_data.replace(buyTokenPrefix, ''))
			    		console.log(amount);
			    	}
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
		this.balances = [...this.accounts, ...this.extra].map(acc => ({
			address: acc,
			balance: 0,
			mine: this.accounts.indexOf(acc)>=0
		}));
		this.getBalances()
		// this.getLogs();
	}
}
</script>
<style scoped>

</style>