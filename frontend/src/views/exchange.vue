<template>
	<div>
		<h2>Exchange</h2>
		<table border="0" cellpadding="10" >
			<tbody>
				<tr>
					<td style="text-align: left; font-size: 15px; width: 10%"><span class="cut-text">From
						<strong style="float: right">{{ coins[0].toUpperCase() }}</strong></span></td>
					<td style="text-align: left;"><input type="number" :disabled="loading" class="txt" min="0" v-model="values[0]" onFocus="this.select()" /></td>
					<td style="text-align: left;"><button @click="setMax()">Max</button></td>
				</tr>
			</tbody>
			<tbody>
				<tr>
					<td style="text-align: left; font-size: 15px; width: 10%"><span class="cut-text">To
						<strong style="float: right">{{ coins[1].toUpperCase() }}</strong></span></td>
					<td style="text-align: left;"><input type="number" class="txt" min="0" v-model="values[1]" onFocus="this.select()" /></td>
					<td style="text-align: left;"><button @click="switchCoin()">Switch</button></td>
				</tr> 
			</tbody>
			<tbody>
				<tr>
					<td style="text-align: center;"></td>
					<td style="text-align: left;"><button @click="swap()">Swap</button></td>
					<td style="text-align: center;"></td>
				</tr>
			</tbody>
		</table>
	</div>
</template>
<script type="text/javascript">
import helper from "../helper";
import pool from "../helper/pool";

export default {
	props: ['address'],
	data() {
		return {
			coins: ['vref', 'usdc'],
			values: [0, 0],
			loading: false,
			timer: null
		}
	},
	watch: {
		'values.0': {
			async handler(value) {
				// calculate swap token
				// price slippage
				this.calculate()
			}
		}
	},
	methods: {
		async setMax() {
			this.loading = true;
			let value = await this[this.coins[0].toUpperCase()].methods.balanceOf(this.address).call();
			value /= 10**(this[this.coins[0].toUpperCase()].decimals);
			this.loading = false;
			this.$set(this.values, 0, value);
		},
		switchCoin() {
			this.coins.reverse()
			this.values = [0, 0]
		},
		swap() {
			let value1 = (BigInt(this.values[1])*BigInt(10**18)).toString();
			this.$emit(this.coins[0]=='vref'?"sell":"buy", [this.values[0], value1])
		},
		calculate() {
			if ( this.timer ) {
				clearTimeout(this.timer);
			}
			this.timer = setTimeout(this.doCalculate.bind(this), 1000);
		},
		async doCalculate() {
			if ( this.loading ) return false;
			if ( this.values[0]==0 ) return this.$set(this.values, 1, 0);
			this.loading = true;
			let _moneyInPool = BigInt(await this.VREF.methods._moneyInPool().call());
			let _tokenInPool = BigInt(await this.VREF.methods._tokenInPool().call());
			let delta;
			let method = 'buyToken';
			if ( this.coins[0]=='vref' ) { // vref to usd
  				delta = pool.sell(_tokenInPool, _moneyInPool, this.values[0]);
  				method = 'sellToken';
			} else {
  				let currentStep = parseInt(await this.VREF.methods.currentStep().call());
  				let state = parseInt(await this.VREF.methods.state().call());
  				let subIDOSold = BigInt(await this.VREF.methods.subIDOSold().call());
				delta = pool.buy(_tokenInPool, _moneyInPool, currentStep, state, subIDOSold, this.values[0]);

				// try {
				// 	const resGasMethod = await this.VREF.methods[method](
				// 			"100200000", 
				// 			"0").estimateGas({ from: this.address });
				// 	const latestBlock = await web3.eth.getBlock('latest');
				// 	const blockGas = latestBlock.gasLimit;
				// 	const finalGas = (blockGas * resGasMethod);
				// 	const finalGasInEther = web3.utils.fromWei(finalGas.toString(), 'ether');
				// 	console.log({resGasMethod, blockGas, finalGas, finalGasInEther})
				// } catch(e) {
				// 	console.log(e)
				// }
			}

			this.loading = false;
			return this.$set(this.values, 1, delta);
		}
	},
	mounted() {

	},
	mixins: [helper]
}
</script>
<style scoped>
.txt {
	height: 26px;
	padding-left:  6px;
	padding-right:  6px;
	width: 100%;
}
</style>