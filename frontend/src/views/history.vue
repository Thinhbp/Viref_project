<template>
	<div>
		<h2>History</h2>
		<div class="history">
			<table border="1" cellpadding="10">
				<thead>
					<tr>
						<td style="text-align: left;">Event</td>
						<td style="text-align: left;">Address</td>
						<td style="text-align: right;">Amount</td>
					</tr>
				</thead>
				<tbody>
					<tr v-for="(tx,idx) in transactions" 
						:key="tx.transactionHash" :style="{ cursor: 'pointer', color: selectedTx==idx?'red':'black' }" @click="select(idx)">
						<td style="text-align: left; font-size: 15px">{{ tx.event }}</td>
						<td style="text-align: left;"><span class="cut-text">{{ tx.data.address }}</span></td>
						<td style="text-align: right;">{{ formatMoney(formatCurrency(tx.data.amount, VREF)) }} {{ tx.event=='buy'?'USD':'VREF' }}</td>
					</tr>
				</tbody>
			</table>
		</div>
	</div>
</template>
<script type="text/javascript">
import helper from "../helper";
import { mapMutations, mapGetters } from 'vuex';

export default {
	data() {
		return {
			transactions: []
		}
	},
	computed: {
		...mapGetters([ 'selectedTx' ])
	},
	methods: {
		...mapMutations([ 'setHistory', 'setSelectedTx' ]),
		select(i) {
			this.setSelectedTx(i);
		},
	    async getLogsEvent(event) {
	    	let currentBlock = await web3.eth.getBlockNumber()
	    	return this.VREF.getPastEvents(event, {
			    fromBlock: 0, // currentBlock-5000,
			    toBlock: 'latest'
			})
		    .then(results => {
		    	return results.map(r => ({
		    		blockNumber: r.blockNumber,
		    		event: r.event,
		    		transactionHash: r.transactionHash,
		    		transactionIndex: r.transactionIndex,
		    		data: {
		    			address: r.returnValues._address,
		    			amount: r.returnValues._amount
		    		}
		    	}))
		    })
		    .catch(err => {
		    	console.log(err);
		    	return [];
		    });
	    },
	    getLogs() {
	    	return Promise.all([this.getLogsEvent('buy'), this.getLogsEvent('sell')]).then(values => {
	    		let txs = [...values[0], ...values[1]];
	    		txs.sort(function(x, y) {
	    			if ( x.blockNumber<y.blockNumber || ( x.blockNumber==y.blockNumber && x.transactionIndex<y.transactionIndex ) ) return -1;
				  	return 1;
				});
				this.transactions = txs;
				this.setHistory(txs);
				return true;
	    	})


	  //   	web3.eth.getPastLogs({fromBlock:'0x0',address:van.address})
			// .then(res => {
			//   res.forEach(rec => {
			//   	const test = web3.eth.abi.decodeParameter('bytes32', rec.topics[0]);
			//   	const from = rec.topics[1] ? web3.eth.abi.decodeParameter('address', rec.topics[1]) : '';
			// 	const to = rec.topics[2] ? web3.eth.abi.decodeParameter('address', rec.topics[2]) : '';
			// 	const value = web3.eth.abi.decodeParameter('uint256', rec.data);
			// 	const amount = web3.utils.fromWei(value);
			//   	console.log({ test, from, to, value, amount, hash: rec.transactionHash });
			//     // console.log(rec.blockNumber, rec.transactionHash, rec.topics);

			//     let buyTokenPrefix = web3.eth.abi.encodeFunctionSignature('buyToken(uint256)');
			//     let sellTokenPrefix = web3.eth.abi.encodeFunctionSignature('sellToken(uint256)');

			//     web3.eth.getTransaction(rec.transactionHash).then(tx => {
		 //    	    let tx_data = tx.input;
			//     	if ( tx_data.indexOf(buyTokenPrefix)==0 ) {
			//     		let amount = web3.eth.abi.decodeParameter('uint256', tx_data.replace(buyTokenPrefix, ''))
			//     		console.log(amount);
			//     	}
			//     })
			//   });
			// }).catch(err => console.log("getPastLogs failed", err));
	    }
	},
	mounted() {
		this.getLogs();
	},
	mixins: [helper]
}
</script>
<style scoped>
.history {
	max-height: 70vh;
	overflow-y: auto;
}
</style>