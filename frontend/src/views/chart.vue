<template>
	<div><canvas ref="myChart" style="width: 100%;"></canvas>
	</div>
</template>
<script type="text/javascript">
import {
  Chart,
  ArcElement,
  LineElement,
  BarElement,
  PointElement,
  BarController,
  BubbleController,
  DoughnutController,
  LineController,
  PieController,
  PolarAreaController,
  RadarController,
  ScatterController,
  CategoryScale,
  LinearScale,
  LogarithmicScale,
  RadialLinearScale,
  TimeScale,
  TimeSeriesScale,
  Decimation,
  Filler,
  Legend,
  Title,
  Tooltip
} from 'chart.js';

Chart.register(
  ArcElement,
  LineElement,
  BarElement,
  PointElement,
  BarController,
  BubbleController,
  DoughnutController,
  LineController,
  PieController,
  PolarAreaController,
  RadarController,
  ScatterController,
  CategoryScale,
  LinearScale,
  LogarithmicScale,
  RadialLinearScale,
  TimeScale,
  TimeSeriesScale,
  Decimation,
  Filler,
  Legend,
  Title,
  Tooltip
);
const van = require("../contract/van.json");
const Web3 = require("web3");

export default {
	data() {
		return {
			chart: null,
			historyData: [],
			forecastData: [],
			selected: 0,
			VAN: null
		}
	},
	methods: {
		chartDatasets() {
			const backgroundColor = new Array(this.historyData.length).fill('green');
			if ( backgroundColor[this.selected] )
				backgroundColor[this.selected] = 'red'
			let type = 'price-token';
			return [{
				type: 'bubble',
			    label: 'Token / Price',
			    data: this.historyData.map((p,idx) => ({
			    	x: type=='price-token' ? p.tokenInPool : idx,
			    	y: p.moneyInPool/p.tokenInPool,
			    	r: 6
			    })),
			    backgroundColor
			}, {
				type: 'scatter',
				label: "forecast",
			    data: this.forecastData.map((p,idx) => ({
			     	x: type=='price-token' ? p.tokenInPool : idx,
			     	y: p.moneyInPool/p.tokenInPool
			    }))
			}]
		},
		loadForecast(maxToken, maxMoney) {
			return fetch(`https://vinet.gostudio.co/forecast?maxToken=${maxToken}&maxMoney=${maxMoney}`).then(res => res.json()).then(res => {
				this.forecastData = res;
				return true;
			}).catch(e => {
				return []
			})
		},
		drawChart() {
			if ( this.chart ) {
				this.chart.data.datasets = chartDatasets();
				this.chart.update()
				return;
			}
			const ctx = this.$refs['myChart'].getContext('2d');
			this.chart = new Chart(ctx, {
			    data: {
			        // labels: ['Red', 'Blue', 'Yellow', 'Green', 'Purple', 'Orange'],
			        datasets: this.chartDatasets()
			    },
			    options: {
			        scales: {
			            y: {
			                beginAtZero: true
			            }
			        },
			        animation: {
				        duration: 0
				    }
			    }
			});
		},
		async loadVAN() {
			let _moneyInPool = await this.VAN.methods._moneyInPool().call();
			let _tokenInPool = await this.VAN.methods._tokenInPool().call();
			
			_moneyInPool = Web3.utils.fromWei(_moneyInPool, 'ether');
			_tokenInPool = Web3.utils.fromWei(_tokenInPool, 'ether');
			this.historyData = [{
				tokenInPool: _tokenInPool,
				moneyInPool: _moneyInPool
			}]
			
			this.loadForecast(_tokenInPool, _moneyInPool).then(res => {
				this.drawChart();
			})
		}
	},
	mounted() {
		this.VAN = new web3.eth.Contract(van.abi, van.address);
		
		this.loadVAN()
	}
}
</script>
<style scoped>

</style>