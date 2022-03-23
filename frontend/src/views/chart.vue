<template>
  <div style="width: 96%;"><canvas ref="myChart" style="width: 96%;"></canvas>
    <div class="currentInfo">
      <p>Token in Pool : {{ formatMoney(tokenInPool) }} VREF</p>
      <p>Money in Pool : {{ formatMoney(moneyInPool) }} USDC</p>
      <p>Current Price : {{ tokenInPool==0?0:(moneyInPool/tokenInPool).toString().slice(0, 5) }} USDC/VREF</p>
      <p>Total supply : {{ formatMoney(totalSupply) }} VREF</p>
      <p>Money can withdraw : {{ formatMoney(moneyCanWithdraw) }} USDC</p>
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
import helper from "../helper";
import Web3 from "web3";
import { mapGetters } from 'vuex';

export default {
  data() {
    return {
      chart: null,
      historyData: [],
      forecastData: [],
      tokenInPool: 0,
      moneyInPool: 0,
      currentStep: 0,
      totalSupply: 0,
      active: true
    }
  },
  computed: {
    ...mapGetters(['history', 'selectedTx']),
    moneyCanWithdraw() {
      return this.totalSupply==0?0:(this.moneyInPool*this.tokenInPool/this.totalSupply)
    }
  },
  watch: {
    history: {
      deep: true,
      handler(trans) {
        if ( trans.length==0 ) return;
        fetch("https://vinet.gostudio.co/script", {
          method: "POST",
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            script: trans.map(tx => ({
              name: tx.event,
              address: tx.data.address,
              amount: parseInt(this.formatCurrency(tx.data.amount, VREF))
            }))
          })
        }).then(res => res.json()).then(res => {
          this.historyData = res;
          let maxPrice = 0;
          let maxMoney = 0;
          res.forEach(p => {
            let price = p.tokenInPool==0 ? 0 : p.moneyInPool/p.tokenInPool;
            maxPrice = Math.max(price, maxPrice)
            maxMoney = Math.max(p.moneyInPool, maxMoney)
          })
          return this.loadForecast(maxPrice, maxMoney).then(res => {
            this.drawChart();
          })
        })
      }
    },
    selectedTx() {
      this.drawChart();
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
        backgroundColor: idx==this.selectedTx ? 'red' : 'rgba(0,255,0,0.5)'
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
    loadForecast(maxPrice, maxMoney) {
      return fetch(`https://vinet.gostudio.co/forecast?maxPrice=${maxPrice}&maxMoney=${maxMoney}`).then(res => res.json()).then(res => {
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
    async loadVREF() {
      let _moneyInPool = await this.VREF.methods._moneyInPool().call();
      let _tokenInPool = await this.VREF.methods._tokenInPool().call();
      this.currentStep = await this.VREF.methods.currentStep().call();
      this.active = await this.VREF.methods.status().call();
      this.totalSupply = Web3.utils.fromWei(await this.VREF.methods.totalSupply().call());
      
      this.moneyInPool = Web3.utils.fromWei(_moneyInPool, 'ether');
      this.tokenInPool = Web3.utils.fromWei(_tokenInPool, 'ether');
    },
  },
  mounted() {
    Chart.defaults.plugins.legend.display = false;
    this.loadVREF();
    this.drawChart();
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