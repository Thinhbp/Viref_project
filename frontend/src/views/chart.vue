<template>
  <div><canvas ref="myChart" style="width: 100%;"></canvas>
    <div class="currentInfo">
      <p>Token in Pool : {{ formatMoney(tokenInPool) }} VAN</p>
      <p>Money in Pool : {{ formatMoney(moneyInPool) }} VUSD</p>
      <p>Current Price : {{ formatMoney(moneyInPool/tokenInPool) }} VUSD/VAN</p>
      <p>Current step : {{ currentStep }}</p>
      <p>In active : {{ active }}</p>
    </div>
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
const { EventBus } = require("../helper/eventbus");
const helper = require("../helper").default;

export default {
  data() {
    return {
      chart: null,
      historyData: [],
      forecastData: [],
      selected: -1,
      VAN: null,
      tokenInPool: 0,
      moneyInPool: 0,
      currentStep: 0,
      active: true
    }
  },
  methods: {
    chartDatasets() {
      let type = 'price-token';
      let bubbles = this.historyData.map((p,idx) => ({
        type: 'bubble',
        label: 'Transaction #'+(idx+1),
        data: [{
          x: type=='price-token' ? p.tokenInPool : idx,
          y: p.moneyInPool/p.tokenInPool,
          r: 6
        }],
        backgroundColor: idx==this.selected ? 'red' : 'green'
      }));
      return [...bubbles, {
        type: 'scatter',
        label: "forecast",
        options: { plugins: { legend: { display: false }, } },
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
        this.chart.data.datasets = this.chartDatasets();
        this.chart.update()
        return;
      }
      const ctx = this.$refs['myChart'].getContext('2d');
      this.chart = new Chart(ctx, {
        data: {
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
      this.currentStep = await this.VAN.methods.currentStep().call();
      this.active = await this.VAN.methods.status().call();
      
      this.moneyInPool = Web3.utils.fromWei(_moneyInPool, 'ether');
      this.tokenInPool = Web3.utils.fromWei(_tokenInPool, 'ether');
      
      this.loadForecast(this.tokenInPool, this.moneyInPool).then(res => {
        this.drawChart();
      })
    },
  },
  mounted() {
    this.VAN = new web3.eth.Contract(van.abi, van.address);
    Chart.defaults.plugins.legend.display = false;
    this.loadVAN()
    EventBus.$on("historyTrans", (trans) => {
      fetch("https://vinet.gostudio.co/script", {
        method: "POST",
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          script: trans.map(tx => ({
            name: tx.event,
            address: tx.data.address,
            amount: parseInt(this.formatVAN(tx.data.amount))
          }))
        })
      }).then(res => res.json()).then(res => {
        this.historyData = res;
        this.drawChart();
      })
    })
    EventBus.$on("selectHistory", i => {
      this.selected = i;
      this.drawChart();
    })
  },
  mixins: [helper]
}
</script>
<style scoped>
.currentInfo {
  text-align: left;
  padding: 20px;
  background-color: rgba(190, 190, 190, 0.3);
  display: inline-block;
  border-radius: 6px;
  margin-top: 20px;
}
.currentInfo p {
  margin: 0 4px;
}
</style>