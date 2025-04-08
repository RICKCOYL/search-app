document.addEventListener('turbo:load', function() {
  const topSearchesCanvas = document.getElementById('topSearchesChart');
  const userSearchesCanvas = document.getElementById('userSearchesChart');
  
  if (!topSearchesCanvas || !userSearchesCanvas) return;
  
  function createChart(canvas, labels, data, title) {
    return new Chart(canvas, {
      type: 'bar',
      data: {
        labels: labels,
        datasets: [{
          label: title,
          data: data,
          backgroundColor: 'rgba(235, 54, 54, 0.6)',
          borderColor: 'rgb(235, 54, 54)',
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        scales: {
          y: {
            beginAtZero: true,
            title: {
              display: true,
              text: 'Count'
            }
          },
          x: {
            title: {
              display: true,
              text: 'Search Terms'
            }
          }
        }
      }
    });
  }
  
  function extractChartData(selector) {
    const table = document.querySelector(selector);
    if (!table) return { labels: [], data: [] };
    
    const rows = table.querySelectorAll('tbody tr');
    const labels = [];
    const data = [];
    
    rows.forEach(row => {
      const cells = row.querySelectorAll('td');
      if (cells.length >= 2) {
        labels.push(cells[0].textContent);
        data.push(parseInt(cells[1].textContent));
      }
    });
    
    return { labels, data };
  }
  
  const topSearchesData = extractChartData('.table:first-of-type');
  const userSearchesData = extractChartData('.table:last-of-type');
  
  if (topSearchesData.labels.length > 0) {
    createChart(topSearchesCanvas, topSearchesData.labels, topSearchesData.data, 'Top Searches');
  } else {
    topSearchesCanvas.getContext('2d').font = '14px Arial';
    topSearchesCanvas.getContext('2d').fillText('No data available', 10, 50);
  }
  
  
  if (userSearchesData.labels.length > 0) {
    createChart(userSearchesCanvas, userSearchesData.labels, userSearchesData.data, 'Your Searches');
  } else {
    userSearchesCanvas.getContext('2d').font = '14px Arial';
    userSearchesCanvas.getContext('2d').fillText('No data available', 10, 50);
  }
});
